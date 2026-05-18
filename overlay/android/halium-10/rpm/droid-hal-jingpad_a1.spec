%define device ud710_3h10u
%define rpm_device jingpad_a1
%define vendor sprd

%define vendor_pretty JingPad
%define device_pretty JingPad A1

%define lunch_device ud710_3h10u_native-userdebug
%define droid_target_aarch64 1
%define makefstab_skip_entries /product /system /vendor /mnt/vendor /mnt/vendor/socko /mnt/vendor/odmko

%define android_config \
#define MALI_QUIRKS 1\
%{nil}

%include rpm/dhd/droid-hal-device.inc
