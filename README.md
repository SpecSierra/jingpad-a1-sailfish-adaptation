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
- `hybris-recovery.img`
- `android-boot-rescue.img`
- `sfe-jingpad_a1-4.6.0.13.tar.bz2`
- `jingpad_a1-sailfishos-4.6.0.13-manual-flash.zip`

Checksums and exact paths are recorded in:

`artifacts/current-build/manifest.txt`

## Repository layout

- `overlay/` — source overlay to apply on top of the working Sailfish/Android tree
- `scripts/` — build helpers used during phases 3 to 5
- `docs/` — AGENT/work journal plus Linux/macOS flashing instructions
- `artifacts/current-build/` — manifest only, no large binaries

## Recreating the local build tree

If the original VM is gone, the rebuild notes are now preserved in:

- `docs/building/RECREATE-WORKSPACE.md`
- `docs/building/jingpad-a1.xml`

Those files document the original `/srv/sailfishos` workspace layout, Platform
SDK and Ubuntu HA chroot setup, the exact saved local manifest used for `repo
sync`, and where the Phase 3-5 helper scripts fit into the workflow.

## Current status

- Android/Halium-side build completed
- `droid-hal-jingpad_a1` completed
- `droid-configs` completed
- `droid-hal-version-jingpad_a1` completed
- first SailfishOS 4.6 image artifacts completed

## Real-device status

The source and artifact set is real, but the manual installer path is **not yet
verified on hardware**.

Observed on a real JingPad A1 during testing:

- `fastboot boot hybris-recovery.img` was accepted by the bootloader, but did
  not expose the expected USB RNDIS/telnet installer interface
- flashing `hybris-boot.img` before staging the rootfs led to a JingPad-logo
  boot hang
- `android-boot-rescue.img` was prepared as a recovery aid, but it is not
  confirmed as a stock-equivalent rollback image

Current manual-install path:

1. stage the rootfs into Android userdata at `/data/.stowaways/sailfishos`
2. flash `hybris-boot.img` to `boot`
3. reboot into Sailfish

Current limitation:

- updater/recovery zip generation is still incomplete because Android-side
  `hybris-updater-script` is not generated for this device tree
- the manual install procedure should be treated as experimental until a
  working installer/debug boot path is confirmed on real hardware

## Notes

This repo was prepared from a live workspace, so paths under `overlay/` are
stored relative to the Sailfish workspace root:

`/srv/sailfishos/workspace/sfos/`
