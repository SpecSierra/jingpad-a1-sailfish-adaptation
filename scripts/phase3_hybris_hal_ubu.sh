#!/bin/bash
set -e
set -o pipefail

export HOME=/parentroot/parentroot/srv/sailfishos/workspace/sfos/home
export PATH=/parentroot/parentroot/srv/sailfishos/workspace/sfos/home/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HYBRIS_HAL_JOBS="${HYBRIS_HAL_JOBS:-16}"
WORKTREE=/parentroot/parentroot/srv/sailfishos/workspace/sfos/android/halium-10
LOGDIR=/parentroot/parentroot/srv/sailfishos/workspace/sfos/logs

mkdir -p "$LOGDIR"

cd "$WORKTREE"
export PWD="$(pwd -P)"
export ANDROID_BUILD_TOP="$PWD"

if [ -e out/.path ] && [ ! -w out/.path ]; then
  echo "out/.path is not writable by $(id -un); fix ownership before rerunning phase3_hybris_hal_ubu.sh" >&2
  exit 1
fi

unwritable_soong_dir="$(find out/soong/.intermediates -type d ! -writable -print -quit 2>/dev/null || true)"
if [ -n "$unwritable_soong_dir" ]; then
  echo "$unwritable_soong_dir is not writable by $(id -un); fix out/soong ownership before rerunning phase3_hybris_hal_ubu.sh" >&2
  exit 1
fi

config_path=vendor/sprd/proprietories-source/packimage_scripts/signimage/sprd/config
if [ ! -e "$config_path" ]; then
  ln -s ../../../../../../bsp/build/packimage_scripts/config "$config_path"
fi

for link in \
  external/droidmedia:../vendor/halium/droidmedia \
  external/audioflingerglue:../vendor/halium/audioflingerglue
do
  target="${link%%:*}"
  source_path="${link#*:}"
  if [ ! -e "$target" ]; then
    ln -s "$source_path" "$target"
  fi
done

compat_uapi_path=bsp/out/ud710_3h10u/headers/kernel/usr
generated_uapi_path=out/soong/.intermediates/vendor/lineage/build/soong/generated_kernel_includes/gen/usr
if [ ! -e "$compat_uapi_path" ]; then
  mkdir -p "$(dirname "$compat_uapi_path")"
  ln -s ../../../../../"$generated_uapi_path" "$compat_uapi_path"
fi

mkdir -p vendor/sprd/external/kernel-headers
if [ ! -e vendor/sprd/external/kernel-headers/sprd_ion.h ]; then
  echo "missing vendor/sprd/external/kernel-headers/sprd_ion.h compatibility header" >&2
  exit 1
fi

if ! source build/envsetup.sh >"$LOGDIR/jingpad-envsetup.log" 2>&1; then
  cat "$LOGDIR/jingpad-envsetup.log"
  exit 1
fi

if ! lunch ud710_3h10u_native-userdebug >"$LOGDIR/jingpad-lunch.log" 2>&1; then
  cat "$LOGDIR/jingpad-lunch.log"
  exit 1
fi

PORT_ARCH="${PORT_ARCH:-aarch64}"
TARGET_ARCH="$(get_build_var TARGET_ARCH)"
DROIDMEDIA_TARGETS=($(external/droidmedia/detect_build_targets.sh "${PORT_ARCH}" "${TARGET_ARCH}"))
AUDIOFLINGERGLUE_TARGETS=($(external/audioflingerglue/detect_build_targets.sh "${PORT_ARCH}" "${TARGET_ARCH}"))
BUILD_TARGETS=(hybris-hal "${DROIDMEDIA_TARGETS[@]}" "${AUDIOFLINGERGLUE_TARGETS[@]}")

if ! m "${BUILD_TARGETS[@]}" -j"${HYBRIS_HAL_JOBS}" >"$LOGDIR/jingpad-hybris-hal.log" 2>&1; then
  tail -n 200 "$LOGDIR/jingpad-hybris-hal.log"
  exit 1
fi

tail -n 120 "$LOGDIR/jingpad-hybris-hal.log"
