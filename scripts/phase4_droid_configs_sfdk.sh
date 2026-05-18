#!/bin/bash
set -euo pipefail

export HOME="${HOME:-/parentroot/srv/sailfishos/workspace/sfos/home}"
export ANDROID_ROOT=/parentroot/srv/sailfishos/workspace/sfos/android/halium-10
export VENDOR=sprd
export DEVICE=jingpad_a1
export HABUILD_DEVICE=ud710_3h10u
export PORT_ARCH=aarch64

TARGET_NAME="${VENDOR}-${DEVICE}-${PORT_ARCH}"
BASE_TARGET=SailfishOS-4.6.0-aarch64

if [ ! -d "/srv/mer/targets/${TARGET_NAME}" ]; then
  sdk-assistant --non-interactive target clone "${BASE_TARGET}" "${TARGET_NAME}"
fi

cd "${ANDROID_ROOT}"

if ! mb2 -t "${TARGET_NAME}" build-init >/tmp/jingpad-mb2-init.log 2>&1; then
  cat /tmp/jingpad-mb2-init.log
  exit 1
fi

if ! rpm/dhd/helpers/build_packages.sh --configs >/tmp/jingpad-droid-configs.log 2>&1; then
  tail -n 200 /tmp/jingpad-droid-configs.log
  exit 1
fi

tail -n 120 /tmp/jingpad-droid-configs.log
