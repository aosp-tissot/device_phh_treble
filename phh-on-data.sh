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


minijailSrc=/system/system_ext/apex/com.android.vndk.v28/lib/libminijail.so
minijailSrc64=/system/system_ext/apex/com.android.vndk.v28/lib64/libminijail.so
if [ "$vndk" = 27 ];then
    mount $minijailSrc64 /vendor/lib64/libminijail_vendor.so
    mount $minijailSrc /vendor/lib/libminijail_vendor.so
fi

if [ "$vndk" = 28 ];then
    mount $minijailSrc64 /vendor/lib64/libminijail_vendor.so
    mount $minijailSrc /vendor/lib/libminijail_vendor.so
    mount $minijailSrc64 /system/lib64/vndk-28/libminijail.so
    mount $minijailSrc /system/lib/vndk-28/libminijail.so
    mount $minijailSrc64 /vendor/lib64/libminijail.so
    mount $minijailSrc /vendor/lib/libminijail.so
fi

# Enable IMS on qcom devices
if getprop ro.boot.hardware|grep -q -e qcom;then
    if getprop ro.product.cpu.abi | grep -q -e 'arm64-v8a'; then
        resetprop_phh persist.dbg.allow_ims_off 1
        resetprop_phh persist.dbg.volte_avail_ovr 1
        resetprop_phh persist.dbg.vt_avail_ovr 1
        resetprop_phh persist.dbg.wfc_avail_ovr 1
        resetprop_phh persist.sys.phh.ims.caf true
     fi
     if getprop ro.product.cpu.abi | grep -q -e 'armeabi-v7a'; then
        resetprop_phh persist.dbg.allow_ims_off 1
        resetprop_phh persist.dbg.volte_avail_ovr 1
        resetprop_phh persist.dbg.vt_avail_ovr 1
        resetprop_phh persist.dbg.wfc_avail_ovr 1
        resetprop_phh persist.sys.phh.ims.caf true
     fi
fi
