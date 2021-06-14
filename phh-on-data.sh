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

if getprop ro.vendor.build.fingerprint |grep -iq  -e redmi/curtana \
    -e redmi/joyeuse -e redmi/excalibur;then
    setprop persist.sys.phh.disable_a2dp_offload true
    setprop persist.bluetooth.bluetooth_audio_hal.disabled true
    setprop persist.sys.phh.caf.audio_policy 1
    mount -o bind /system/etc/mixer_paths_wcd937x.xml /vendor/etc/mixer_paths_wcd937x.xml
    mount -o bind /system/etc/media_profiles_vendor.xml /vendor/etc/media_profiles_vendor.xml
    setprop ctl.restart vendor.audio-hal-2-0
    setprop persist.sys.phh.linear_brightness false
    pkill -f com.android.bluetooth
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
