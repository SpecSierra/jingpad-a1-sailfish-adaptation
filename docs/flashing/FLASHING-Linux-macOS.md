# JingPad A1 SailfishOS 4.6 manual flash bundle

This bundle installs the current JingPad A1 SailfishOS rootfs onto the
existing Android `userdata` partition at:

`/data/.stowaways/sailfishos`

and then replaces the Android boot image with `hybris-boot.img`.

## Status notice

This bundle documents the current bring-up artifact set, but the installation
path below is still **experimental**.

On real JingPad A1 hardware, `fastboot boot hybris-recovery.img` was accepted
by the bootloader but did **not** expose the expected USB debug interface, and
flashing `hybris-boot.img` before staging the rootfs resulted in a JingPad-logo
boot hang. Keep stock recovery access and a known-good Android/JingOS boot
image available before experimenting further.

## What is in this bundle

- `hybris-boot.img`
- `hybris-recovery.img`
- `sfe-jingpad_a1-4.6.0.13.tar.bz2`
- `on-device-install.sh`
- `Jolla-4.6.0.13-jingpad_a1-aarch64.ks`
- `Jolla-4.6.0.13-jingpad_a1-aarch64.packages`
- `Jolla-4.6.0.13-jingpad_a1-aarch64.urls`
- `os-release`

## Important

1. Your bootloader must already be **unlocked**.
2. This is a **manual install path**, not a stock-recovery update zip.
3. Flashing `hybris-boot.img` replaces Android's current boot image. Keep a copy
   of your stock Android boot image or full firmware so you can return to Android.
4. The first boot can take several minutes.

## Host tools

### Linux

- `fastboot` and `adb` from Android platform-tools
- `python3`
- a telnet client (`telnet` package is fine)

### macOS

- Android platform-tools
- `python3`
- a telnet client

If you use Homebrew:

```bash
brew install android-platform-tools python inetutils
```

Then use `gtelnet` instead of `telnet`.

## Install steps

### 1. Extract this zip on your host

Run the remaining commands from the extracted bundle directory.

### 2. Start a simple HTTP server in the bundle directory

Linux or macOS:

```bash
python3 -m http.server 8000
```

Leave that terminal open.

### 3. Reboot the tablet to fastboot / bootloader mode

Typical command if Android is running:

```bash
adb reboot bootloader
```

### 4. Boot the Sailfish recovery image for installation

Use the recovery image as the installer/debug environment. It is built with
always-debug enabled, unlike the normal `hybris-boot.img`.

First try temporary boot:

```bash
fastboot boot hybris-recovery.img
```

If temporary boot does not work on your fastboot/bootloader combination, use:

```bash
fastboot flash recovery hybris-recovery.img
```

Then boot to recovery mode using your normal JingPad recovery-key path or any
working `fastboot reboot recovery` equivalent your host fastboot provides.

If the tablet never exposes the `192.168.2.x` installer network after booting
or flashing `hybris-recovery.img`, stop there and do **not** flash
`hybris-boot.img`.

### 5. Wait for the USB network interface to appear

The debug boot exports a USB RNDIS network:

- **tablet IP:** `192.168.2.15`
- **host IP:** a DHCP-assigned `192.168.2.x` address

#### Linux: find your host-side USB IP

```bash
ip -4 addr | grep 192.168.2.
```

#### macOS: find your host-side USB IP

```bash
ifconfig | grep -B2 'inet 192.168.2.'
```

Use the host IP you find below as `HOST_IP`.

### 6. Open the debug shell on the tablet

Linux:

```bash
telnet 192.168.2.15
```

macOS with Homebrew inetutils:

```bash
gtelnet 192.168.2.15 23
```

### 7. Stage and extract the Sailfish rootfs onto Android userdata

Inside the tablet debug shell, run:

```sh
sh -c "wget -O /tmp/on-device-install.sh http://HOST_IP:8000/on-device-install.sh || busybox wget -O /tmp/on-device-install.sh http://HOST_IP:8000/on-device-install.sh"
sh /tmp/on-device-install.sh http://HOST_IP:8000/sfe-jingpad_a1-4.6.0.13.tar.bz2
sync
```

Replace `HOST_IP` with the host USB-network address from step 5.

This populates:

`/data/.stowaways/sailfishos`

### 8. Reboot back to fastboot

From the debug shell:

```sh
reboot bootloader
```

If that does not work, force the tablet back to bootloader manually.

### 9. Flash the Sailfish boot image

```bash
fastboot flash boot hybris-boot.img
fastboot reboot
```

## First boot

- Expect the first boot to be slow.
- The current image is the reduced-scope bring-up build.
- Modem/SIM and GPS were intentionally not treated as blockers for this image.

## Returning to Android

Flash your saved stock Android `boot.img` back to the `boot` partition:

```bash
fastboot flash boot STOCK-BOOT.img
fastboot reboot
```

If you did not save the stock boot image, restore it from the original Android
firmware package for the JingPad A1.

An additional experimental asset, `android-boot-rescue.img`, is published with
the beta release. Prefer testing it with `fastboot boot android-boot-rescue.img`
before flashing it permanently.
