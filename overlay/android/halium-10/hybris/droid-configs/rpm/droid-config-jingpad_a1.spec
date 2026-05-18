%define device jingpad_a1
%define vendor sprd

%define vendor_pretty JingPad
%define device_pretty JingPad A1

%define community_adaptation 1
%define android_version_major 10
%define remove_modem 1
%define pulseaudio_min_version 14.2+git9

%define pixel_ratio 1.5

%include droid-configs-device/droid-configs.inc
%include patterns/patterns-sailfish-device-adaptation-jingpad_a1.inc
%include patterns/patterns-sailfish-device-configuration-jingpad_a1.inc
