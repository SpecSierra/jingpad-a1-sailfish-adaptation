#!/bin/bash
set -e
set -o pipefail

export HOME=/parentroot/parentroot/srv/sailfishos/workspace/sfos/home
export PATH=/parentroot/parentroot/srv/sailfishos/workspace/sfos/home/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

cd /parentroot/parentroot/srv/sailfishos/workspace/sfos/android/halium-10

config_path=vendor/sprd/proprietories-source/packimage_scripts/signimage/sprd/config
if [ ! -e "$config_path" ]; then
  ln -s ../../../../../../bsp/build/packimage_scripts/config "$config_path"
fi

if ! source build/envsetup.sh >/tmp/jingpad-envsetup.log 2>&1; then
  cat /tmp/jingpad-envsetup.log
  exit 1
fi

if ! lunch ud710_3h10u_native-userdebug >/tmp/jingpad-lunch.log 2>&1; then
  cat /tmp/jingpad-lunch.log
  exit 1
fi

tail -n 80 /tmp/jingpad-lunch.log
