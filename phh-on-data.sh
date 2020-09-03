#!/system/bin/sh

vndk="$(getprop persist.sys.vndk)"
[ -z "$vndk" ] && vndk="$(getprop ro.vndk.version |grep -oE '^[0-9]+')"

if getprop persist.sys.phh.no_vendor_overlay |grep -q true;then
	for part in odm vendor;do
		mount /mnt/phh/empty_dir/ /$part/overlay
	done
fi

if getprop persist.sys.phh.caf.media_profile |grep -q true;then
    setprop media.settings.xml "/vendor/etc/media_profiles_vendor.xml"
fi

<<<<<<< HEAD
if getprop ro.vendor.build.fingerprint |grep -iq  -e redmi/curtana \
    -e redmi/joyeuse -e redmi/excalibur;then
    setprop persist.sys.phh.disable_a2dp_offload true
    setprop persist.bluetooth.bluetooth_audio_hal.disabled true
    setprop persist.sys.phh.caf.audio_policy 1
    mount -o bind /system/etc/mixer_paths_wcd937x.xml /vendor/etc/mixer_paths_wcd937x.xml
    mount -o bind /system/etc/media_profiles_vendor.xml /vendor/etc/media_profiles_vendor.xml
    setprop ctl.restart vendor.audio-hal-2-0
    setprop persist.sys.phh.linear_brightness true
    pkill -f com.android.bluetooth
fi

crashingProcess=$(getprop ro.init.updatable_crashing_process_name |grep media)
if [ "$vndk" = 27 ] && ( getprop init.svc.mediacodec |grep -q restarting || [ -n "$crashingProcess" ] );then
=======

if [ "$vndk" = 27 ];then
>>>>>>> 6e496dafb01975cf12b09628945c2fa879aae5e3
    mount /system/lib64/vndk-27/libminijail.so /vendor/lib64/libminijail_vendor.so
    mount /system/lib/vndk-27/libminijail.so /vendor/lib/libminijail_vendor.so
fi

if [ "$vndk" = 28 ];then
    mount /system/lib64/vndk-27/libminijail.so /vendor/lib64/libminijail_vendor.so
    mount /system/lib/vndk-27/libminijail.so /vendor/lib/libminijail_vendor.so
    mount /system/lib64/vndk-27/libminijail.so /system/lib64/vndk-28/libminijail.so
    mount /system/lib/vndk-27/libminijail.so /system/lib/vndk-28/libminijail.so
    mount /system/lib64/vndk-27/libminijail.so /vendor/lib64/libminijail.so
    mount /system/lib/vndk-27/libminijail.so /vendor/lib/libminijail.so
fi

# Enable IMS on qcom devices
if getprop ro.boot.hardware|grep -q -e qcom;then
    if getprop ro.product.cpu.abi | grep -q -e 'arm64-v8a'; then
        resetprop persist.dbg.allow_ims_off 1
        resetprop persist.dbg.volte_avail_ovr 1
        resetprop persist.dbg.vt_avail_ovr 1
        resetprop persist.dbg.wfc_avail_ovr 1
        resetprop persist.sys.phh.ims.caf true
     fi
     if getprop ro.product.cpu.abi | grep -q -e 'armeabi-v7a'; then
        resetprop persist.dbg.allow_ims_off 1
        resetprop persist.dbg.volte_avail_ovr 1
        resetprop persist.dbg.vt_avail_ovr 1
        resetprop persist.dbg.wfc_avail_ovr 1
        resetprop persist.sys.phh.ims.caf true
     fi
fi
