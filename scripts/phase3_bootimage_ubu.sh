#!/bin/bash
set -e
set -o pipefail

export HOME=/parentroot/parentroot/srv/sailfishos/workspace/sfos/home
export PATH=/parentroot/parentroot/srv/sailfishos/workspace/sfos/home/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
BOOTIMAGE_JOBS="${BOOTIMAGE_JOBS:-16}"
WORKTREE=/parentroot/parentroot/srv/sailfishos/workspace/sfos/android/halium-10
LOGDIR=/parentroot/parentroot/srv/sailfishos/workspace/sfos/logs

mkdir -p "$LOGDIR"

cd "$WORKTREE"
export PWD="$(pwd -P)"
export ANDROID_BUILD_TOP="$PWD"

config_path=vendor/sprd/proprietories-source/packimage_scripts/signimage/sprd/config
if [ ! -e "$config_path" ]; then
  ln -s ../../../../../../bsp/build/packimage_scripts/config "$config_path"
fi

if ! source build/envsetup.sh >"$LOGDIR/jingpad-envsetup.log" 2>&1; then
  cat "$LOGDIR/jingpad-envsetup.log"
  exit 1
fi

if ! lunch ud710_3h10u_native-userdebug >"$LOGDIR/jingpad-lunch.log" 2>&1; then
  cat "$LOGDIR/jingpad-lunch.log"
  exit 1
fi

if ! m bootimage -j"${BOOTIMAGE_JOBS}" >"$LOGDIR/jingpad-bootimage.log" 2>&1; then
  tail -n 200 "$LOGDIR/jingpad-bootimage.log"
  exit 1
fi

tail -n 80 "$LOGDIR/jingpad-bootimage.log"
