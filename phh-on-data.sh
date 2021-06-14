#!/system/bin/sh

vndk="$(getprop persist.sys.vndk)"
[ -z "$vndk" ] && vndk="$(getprop ro.vndk.version |grep -oE '^[0-9]+')"

if getprop persist.sys.phh.no_vendor_overlay |grep -q true;then
	for part in odm vendor;do
		mount /mnt/phh/empty_dir/ /$part/overlay
	done
fi

mount -o remount,rw /
mount -o remount,rw /system
mount -o remount,rw /system_root
if getprop persist.sys.phh.root |grep -q true && [ ! -f /system/xbin/su ];then
   cp -rf /system/phh/root/system/* /system/
   chmod 0755 /system/bin/phh-su
   chmod -R 0755 /system/xbin
   chmod 0644 /system/etc/init/su.rc
   chcon u:object_r:phhsu_exec:s0 /system/bin/phh-su
   mv /system/phh/root/phh.apk.tmp /system/priv-app/phh-su.apk
   chmod 0755 /system/priv-app/phh-su.apk
fi

if getprop persist.sys.phh.root |grep -q false && [ -f /system/xbin/su ];then
    rm -rf /system/bin/phh-su
    rm -rf /system/xbin
    rm /system/etc/su.rc
    rm -rf /data/su
    mv /system/priv-app/phh-su.apk /system/phh/root/phh.apk.tmp
fi
mount -o remount,ro /
mount -o remount,ro /system
mount -o remount,ro /system_root

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
    setprop persist.sys.phh.backlight.scale 1
    pkill -f com.android.bluetooth
fi

if getprop persist.sys.fflag.override.settings_fuse|grep -q -e false;then
   setprop persist.sys.fflag.override.settings_fuse true
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
