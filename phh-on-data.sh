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
