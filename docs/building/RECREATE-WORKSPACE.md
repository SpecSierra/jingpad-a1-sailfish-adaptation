# Recreating the local build tree

This repository is not a full source checkout, but it contains enough
information to rebuild the working environment that produced the published
artifacts.

The original build used this filesystem layout:

- Platform SDK root: `/srv/sailfishos`
- Platform SDK chroot: `/srv/sailfishos/sdks/sfossdk`
- Ubuntu HA chroot: `/srv/sailfishos/sdks/ubuntu`
- shared workspace: `/srv/sailfishos/workspace/sfos`
- Android tree: `/srv/sailfishos/workspace/sfos/android/halium-10`
- workspace home for `repo`: `/srv/sailfishos/workspace/sfos/home`

## Host expectations

- x86_64 Linux host
- Ubuntu 20.04 or 22.04 preferred
- 300+ GiB free SSD space recommended
- 32 GiB RAM recommended

The original host had 30 GiB RAM and used a persistent 64 GiB swapfile to stay
comfortable during sync/build work.

## 1. Install the Sailfish Platform SDK

Install `bzip2` first if your host is missing it, then unpack the current
Platform SDK chroot under `/srv/sailfishos`:

```bash
sudo apt-get update
sudo apt-get install -y bzip2 curl

export PLATFORM_SDK_ROOT=/srv/sailfishos
sudo mkdir -p "$PLATFORM_SDK_ROOT/sdks/sfossdk"
curl -k -fL -o /tmp/Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 \
  https://releases.sailfishos.org/sdk/installers/latest/Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2
sudo tar --numeric-owner -p -xjf /tmp/Jolla-latest-SailfishOS_Platform_SDK_Chroot-i486.tar.bz2 \
  -C "$PLATFORM_SDK_ROOT/sdks/sfossdk"
```

Prepare the shared directories:

```bash
sudo mkdir -p /srv/sailfishos/{targets,toolings}
sudo install -d -o nobody -g nogroup \
  /srv/sailfishos/workspace \
  /srv/sailfishos/workspace/sfos \
  /srv/sailfishos/workspace/sfos/{downloads,android,tmp,home}
```

## 2. Install SDK tooling and the generic `aarch64` target

Run `sdk-assistant` as a non-root SDK user. The original build used
`SailfishOS-4.6.0` tooling and `SailfishOS-4.6.0-aarch64` as the base target.

```bash
/srv/sailfishos/sdks/sfossdk/sdk-chroot -u nobody -m root /bin/bash -lc '
  yes y | sdk-assistant create SailfishOS-4.6.0 \
    https://releases.sailfishos.org/sdk/targets/Sailfish_OS-latest-Sailfish_SDK_Tooling-i486.tar.7z &&
  yes y | sdk-assistant create SailfishOS-4.6.0-aarch64 \
    https://releases.sailfishos.org/sdk/targets/Sailfish_OS-latest-Sailfish_SDK_Target-aarch64.tar.7z
'
```

Install the extra HADK-side tools inside the Platform SDK:

```bash
/srv/sailfishos/sdks/sfossdk/sdk-chroot -u nobody -m root /bin/bash -lc '
  sudo zypper ref &&
  sudo zypper -n in android-tools-hadk kmod createrepo_c
'
```

## 3. Install the Ubuntu HA chroot used for Android/Halium work

The Android side was built in the Focal HA chroot provided by Jolla:

```bash
/srv/sailfishos/sdks/sfossdk/sdk-chroot -u nobody -m root /bin/bash -lc '
  TARBALL=ubuntu-focal-20210531-android-rootfs.tar.bz2
  cd /parentroot/srv/sailfishos/workspace/sfos/downloads
  curl -fLO https://releases.sailfishos.org/ubu/$TARBALL
  sudo mkdir -p /srv/sailfishos/sdks/ubuntu
  sudo tar --numeric-owner -xjf $TARBALL -C /srv/sailfishos/sdks/ubuntu
'
```

Install the Ubuntu-side prerequisites and the standalone `repo` launcher into
the workspace home:

```bash
/srv/sailfishos/sdks/sfossdk/sdk-chroot -u nobody -m root /bin/bash -lc '
  install -d -o nobody -g nogroup /parentroot/srv/sailfishos/workspace/sfos/home
  ubu-chroot -u nobody -m root -r /srv/sailfishos/sdks/ubuntu \
    env HOME=/parentroot/srv/sailfishos/workspace/sfos/home \
        PATH=/parentroot/srv/sailfishos/workspace/sfos/home/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /bin/bash -c "
      sudo apt-get update -qq &&
      sudo apt-get install -y git cpio curl python3 &&
      mkdir -p \"\$HOME/bin\" &&
      curl -fLo \"\$HOME/bin/repo\" https://storage.googleapis.com/git-repo-downloads/repo &&
      chmod +x \"\$HOME/bin/repo\"
    "
'
```

## 4. Initialize the Halium 10 source tree

Enter the Ubuntu HA chroot as the non-root builder, keeping the workspace home
and `repo` launcher on `PATH`:

```bash
/srv/sailfishos/sdks/sfossdk/sdk-chroot -u nobody -m root /bin/bash
```

From inside that shell:

```bash
install -d -o nobody -g nogroup /parentroot/srv/sailfishos/workspace/sfos/home
ubu-chroot -u nobody -m root -r /srv/sailfishos/sdks/ubuntu \
  env HOME=/parentroot/srv/sailfishos/workspace/sfos/home \
      PATH=/parentroot/srv/sailfishos/workspace/sfos/home/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
  /bin/bash
```

Inside the Ubuntu HA shell:

```bash
git config --global user.name "JingPad SFOS Builder"
git config --global user.email "jingpad-sfos-builder@local.invalid"

mkdir -p /parentroot/parentroot/srv/sailfishos/workspace/sfos/android/halium-10
cd /parentroot/parentroot/srv/sailfishos/workspace/sfos/android/halium-10

repo init -u https://github.com/Halium/android.git -b halium-10.0 --repo-rev=v2.54
mkdir -p .repo/local_manifests
cp /parentroot/parentroot/PATH/TO/jingpad-a1-sailfish-adaptation/docs/building/jingpad-a1.xml \
  .repo/local_manifests/jingpad-a1.xml
repo sync -c --no-clone-bundle --no-tags -j4
```

Notes:

- `repo init` originally failed until the repo tool was pinned to `v2.54`.
- The first `repo init` also prompted for color support; the original session
  answered `n`.
- The resulting source tree occupied about 89 GiB.
- The exact local manifest used for this build is stored in
  `docs/building/jingpad-a1.xml`.

## 5. Apply the adaptation overlay

This repository stores modified files relative to the workspace root
`/srv/sailfishos/workspace/sfos/`. Apply them into the live tree before
building:

```bash
rsync -a PATH/TO/jingpad-a1-sailfish-adaptation/overlay/ /srv/sailfishos/workspace/sfos/
```

If you want the published build helper scripts available from the shared
workspace too, copy them there as well:

```bash
rsync -a PATH/TO/jingpad-a1-sailfish-adaptation/scripts/ /srv/sailfishos/workspace/sfos/scripts/
```

## 6. Run the saved phase helpers

The repository contains the helper scripts that were used for the successful
Phase 3-5 builds:

- `scripts/phase3_lunch_ubu.sh`
- `scripts/phase3_bootimage_ubu.sh`
- `scripts/phase3_hybris_hal_ubu.sh`
- `scripts/phase3_droid_hal_sfdk.sh`
- `scripts/phase4_droid_configs_sfdk.sh`
- `scripts/phase5_image_sfdk.sh`

Android/Halium scripts run inside `ubu-chroot`. Sailfish packaging/image scripts
run inside `sdk-chroot`.

Two path quirks from the original environment matter:

1. In `sdk-chroot`, the host root is visible at `/parentroot`.
2. In `ubu-chroot` entered from `sdk-chroot`, the same host root appears at
   `/parentroot/parentroot`.

That is why the Android-side helper scripts use paths such as:

```text
/parentroot/parentroot/srv/sailfishos/workspace/sfos/android/halium-10
```

while the SDK-side helper scripts use:

```text
/parentroot/srv/sailfishos/workspace/sfos/android/halium-10
```

## 7. Extra references

- Full command log: `docs/build_journal.md`
- Original task instructions: `docs/AGENT.MD`
- Exact local manifest used for sync: `docs/building/jingpad-a1.xml`
- Published artifact list and checksums: `artifacts/current-build/manifest.txt`

## 8. Important reality check

This is enough to recreate the build tree and rebuild the published artifacts,
but it does **not** guarantee a working installer path on hardware. See
`README.md` and `docs/flashing/FLASHING-Linux-macOS.md` for the current known
installer blocker.
