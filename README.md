# JingPad A1 SailfishOS adaptation

This repository is a **clean adaptation overlay** for the JingPad A1 SailfishOS
bring-up work completed in this session.

It is intentionally **not** a full Android/Sailfish source checkout. Instead, it
contains:

- JingPad-specific source changes as an overlay under `overlay/`
- build/helper scripts under `scripts/`
- build and flashing documentation under `docs/`
- a manifest for the generated image artifacts under `artifacts/current-build/`

## What is not stored here

Large generated binaries are **not committed** here, because they are not a good
fit for a normal GitHub repository.

The current build artifacts are available locally at:

`/srv/sailfishos/workspace/sfos/android/halium-10/SailfishOScommunity-release-4.6.0.13-jingpad_a1/`

That directory currently contains:

- `hybris-boot.img`
- `sfe-jingpad_a1-4.6.0.13.tar.bz2`
- `jingpad_a1-sailfishos-4.6.0.13-manual-flash.zip`

Checksums and exact paths are recorded in:

`artifacts/current-build/manifest.txt`

## Repository layout

- `overlay/` — source overlay to apply on top of the working Sailfish/Android tree
- `scripts/` — build helpers used during phases 3 to 5
- `docs/` — AGENT/work journal plus Linux/macOS flashing instructions
- `artifacts/current-build/` — manifest only, no large binaries

## Current status

- Android/Halium-side build completed
- `droid-hal-jingpad_a1` completed
- `droid-configs` completed
- `droid-hal-version-jingpad_a1` completed
- first SailfishOS 4.6 image artifacts completed

Current manual-install path:

1. stage the rootfs into Android userdata at `/data/.stowaways/sailfishos`
2. flash `hybris-boot.img` to `boot`
3. reboot into Sailfish

Current limitation:

- updater/recovery zip generation is still incomplete because Android-side
  `hybris-updater-script` is not generated for this device tree

## Suggested GitHub publishing model

Use this repository as the **source/adaptation repo**, and publish the large
image artifacts separately as:

- GitHub Releases assets, or
- another file host

Do **not** commit the `*.tar.bz2`, `*.img`, or `*.zip` image artifacts directly
into the Git repository.

## How to publish this repo to GitHub

From inside this repository:

```bash
git remote add origin git@github.com:YOUR_ACCOUNT/jingpad-a1-sailfish-adaptation.git
git push -u origin main
```

Or with HTTPS:

```bash
git remote add origin https://github.com/YOUR_ACCOUNT/jingpad-a1-sailfish-adaptation.git
git push -u origin main
```

If you want to authenticate with GitHub device code using the GitHub CLI:

```bash
gh auth login
gh repo create jingpad-a1-sailfish-adaptation --private --source=. --push
```

## Notes

This repo was prepared from a live workspace, so paths under `overlay/` are
stored relative to the Sailfish workspace root:

`/srv/sailfishos/workspace/sfos/`
