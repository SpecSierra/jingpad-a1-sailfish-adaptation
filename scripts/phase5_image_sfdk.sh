#!/bin/bash
set -euo pipefail

export ANDROID_ROOT=/parentroot/srv/sailfishos/workspace/sfos/android/halium-10
export VENDOR=sprd
export DEVICE=jingpad_a1
export HABUILD_DEVICE=ud710_3h10u
export PORT_ARCH=aarch64
export RELEASE=4.6.0.13
export EXTRA_NAME=

TARGET_NAME="${VENDOR}-${DEVICE}-${PORT_ARCH}"
BASE_TARGET=SailfishOS-4.6.0-aarch64
LOCAL_REPO="${ANDROID_ROOT}/droid-local-repo/${DEVICE}"
LOG_FILE=/tmp/jingpad-phase5.log

if [ ! -d "/srv/mer/targets/${TARGET_NAME}" ]; then
  sdk-assistant --non-interactive target clone "${BASE_TARGET}" "${TARGET_NAME}"
fi

cd "${ANDROID_ROOT}"

if ! mb2 -t "${TARGET_NAME}" build-init >/tmp/jingpad-mb2-init.log 2>&1; then
  cat /tmp/jingpad-mb2-init.log
  exit 1
fi

set +o pipefail
if ! yes a | rpm/dhd/helpers/build_packages.sh --mw --gg >"${LOG_FILE}" 2>&1; then
  set -o pipefail
  tail -n 200 "${LOG_FILE}"
  exit 1
fi
set -o pipefail

if ! rpm/dhd/helpers/build_packages.sh --version >>"${LOG_FILE}" 2>&1; then
  tail -n 200 "${LOG_FILE}"
  exit 1
fi

if ! rpm/dhd/helpers/build_packages.sh --mic >>"${LOG_FILE}" 2>&1; then
  tail -n 200 "${LOG_FILE}"
  exit 1
fi

tail -n 120 "${LOG_FILE}"
