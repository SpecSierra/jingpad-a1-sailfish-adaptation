#!/bin/bash
set -eu
set -o pipefail

export HOME=/parentroot/parentroot/srv/sailfishos/workspace/sfos/home
export PATH=/parentroot/parentroot/srv/sailfishos/workspace/sfos/home/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

cd /parentroot/parentroot/srv/sailfishos/workspace/sfos/android/halium-10

exec /parentroot/parentroot/srv/sailfishos/workspace/sfos/home/bin/repo sync \
  -c \
  --no-clone-bundle \
  --no-tags \
  -j4 \
  vendor/sprd/interfaces/broadcastradio \
  vendor/sprd/interfaces/power \
  vendor/sprd/interfaces/enhance \
  vendor/sprd/partner/goodix \
  vendor/sprd/partner/silead \
  vendor/sprd/modules/hwcomposer \
  vendor/sprd/modules/libmemion \
  vendor/sprd/modules/libcamera \
  vendor/sprd/modules/lights \
  vendor/sprd/modules/enhance \
  vendor/sprd/modules/power \
  vendor/sprd/modules/sensors \
  vendor/sprd/modules/vdsp \
  vendor/sprd/modules/vibrator \
  vendor/sprd/proprietories-source/charge \
  vendor/sprd/proprietories-source/packimage_scripts \
  vendor/sprd/platform/frameworks/base
