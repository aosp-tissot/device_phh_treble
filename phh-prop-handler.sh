#!/system/bin/sh
set -o pipefail

display_usage() {
    echo -e "\nUsage:\n ./phh-prop-handler.sh [prop]\n"
}

if [ "$#" -ne 1 ]; then
    display_usage
    exit 1
fi

prop_value=$(getprop "$1")

xiaomi_toggle_dt2w_proc_node() {
    DT2W_PROC_NODES=("/proc/touchpanel/wakeup_gesture"
        "/proc/tp_wakeup_gesture"
        "/proc/tp_gesture")
    for node in "${DT2W_PROC_NODES[@]}"; do
        [ ! -f "${node}" ] && continue
        echo "Trying to set dt2w mode with /proc node: ${node}"
        echo "$1" >"${node}"
        [[ "$(cat "${node}")" -eq "$1" ]] # Check result
        return
    done
    return 1
}

xiaomi_toggle_dt2w_event_node() {
    for ev in $(
        cd /sys/class/input || return
        echo event*
    ); do
        isTouchscreen=false
        if getevent -p /dev/input/$ev |grep -e 0035 -e 0036|wc -l |grep -q 2;then
            isTouchscreen=true
        fi
        [ ! -f "/sys/class/input/${ev}/device/device/gesture_mask" ] &&
            [ ! -f "/sys/class/input/${ev}/device/wake_gesture" ] &&
            ! $isTouchscreen && continue
        echo "Trying to set dt2w mode with event node: /dev/input/${ev}"
        if [ "$1" -eq 1 ]; then
            # Enable
            sendevent /dev/input/"${ev}" 0 1 5
            return
        else
            # Disable
            sendevent /dev/input/"${ev}" 0 1 4
            return
        fi
    done
    return 1
}


restartAudio() {
    setprop ctl.restart audioserver
    audioHal="$(getprop |sed -nE 's/.*init\.svc\.(.*audio-hal[^]]*).*/\1/p')"
    setprop ctl.restart "$audioHal"
    setprop ctl.restart vendor.audio-hal-2-0
    setprop ctl.restart audio-hal-2-0
}

if [ "$1" == "persist.sys.phh.xiaomi.dt2w" ]; then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    if ! xiaomi_toggle_dt2w_proc_node "$prop_value"; then
        # Fallback to event node method
        xiaomi_toggle_dt2w_event_node "$prop_value"
    fi
    exit $?
fi

if [ "$1" == "persist.sys.phh.oppo.dt2w" ]; then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    echo "$prop_value" >/proc/touchpanel/double_tap_enable
    exit
fi

if [ "$1" == "persist.sys.phh.oppo.gaming_mode" ]; then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    echo "$prop_value" >/proc/touchpanel/game_switch_enable
    exit
fi

if [ "$1" == "persist.sys.phh.root" ]; then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi
    mount -o remount,rw /
    mount -o remount,rw /system
    if [[ "$prop_value" == "0" ]]; then
       rm -rf /system/bin/phh-su
       rm -rf /system/xbin
       rm /system/etc/su.rc
       rm -rf /data/su
    fi
    if [[ "$prop_value" == "1" ]]; then
       cp -rf /system/phh/root/system/* /system/
       chmod 0755 /system/bin/phh-su
       chmod -R 0755 /system/xbin
       chmod 0644 /system/etc/init/su.rc
       chcon u:object_r:phhsu_exec:s0 /system/bin/phh-su
       mv /system/phh/root/phh.apk.tmp /system/phh/root/phh.apk
       pm install /system/phh/root/phh.apk
    fi
    mount -o remount,ro /
    mount -o remount,ro /system
fi


if [ "$1" == "persist.sys.phh.oppo.usbotg" ]; then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    echo "$prop_value" >/sys/class/power_supply/usb/otg_switch
    exit
fi

if [ "$1" == "persist.sys.phh.disable_audio_effects" ];then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    if [[ "$prop_value" == 1 ]];then
        resetprop_phh ro.audio.ignore_effects true
    else
        resetprop_phh --delete ro.audio.ignore_effects
    fi
    restartAudio
    exit
fi

if [ "$1" == "persist.sys.phh.caf.audio_policy" ];then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    sku="$(getprop ro.boot.product.vendor.sku)"
    if [[ "$prop_value" == 1 ]];then
        umount /vendor/etc/audio
        umount /vendor/etc/audio

        if [ -f /vendor/etc/audio_policy_configuration_sec.xml ];then
            mount /vendor/etc/audio_policy_configuration_sec.xml /vendor/etc/audio_policy_configuration.xml
        elif [ -f /vendor/etc/audio/sku_${sku}_qssi/audio_policy_configuration.xml ] && [ -f /vendor/etc/audio/sku_$sku/audio_policy_configuration.xml ];then
            umount /vendor/etc/audio
            mount /vendor/etc/audio/sku_${sku}_qssi/audio_policy_configuration.xml /vendor/etc/audio/sku_$sku/audio_policy_configuration.xml
        elif [ -f /vendor/etc/audio/audio_policy_configuration.xml ];then
            mount /vendor/etc/audio/audio_policy_configuration.xml /vendor/etc/audio_policy_configuration.xml
        elif [ -f /vendor/etc/audio_policy_configuration_base.xml ];then
            mount /vendor/etc/audio_policy_configuration_base.xml /vendor/etc/audio_policy_configuration.xml
        fi

        if [ -f /vendor/lib/hw/audio.bluetooth_qti.default.so ];then
            cp /vendor/etc/a2dp_audio_policy_configuration.xml /mnt/phh
            sed -i 's/bluetooth_qti/a2dp/' /mnt/phh/a2dp_audio_policy_configuration.xml
            mount /mnt/phh/a2dp_audio_policy_configuration.xml /vendor/etc/a2dp_audio_policy_configuration.xml
            chcon -h u:object_r:vendor_configs_file:s0 /vendor/etc/a2dp_audio_policy_configuration.xml
            chmod 644 /vendor/etc/a2dp_audio_policy_configuration.xml
        fi
    else
        umount /vendor/etc/audio_policy_configuration.xml
        umount /vendor/etc/audio/sku_$sku/audio_policy_configuration.xml
        umount /vendor/etc/a2dp_audio_policy_configuration.xml
        rm /mnt/phh/a2dp_audio_policy_configuration.xml
        if [ $(find /vendor/etc/audio -type f |wc -l) -le 3 ];then
            mount /mnt/phh/empty_dir /vendor/etc/audio
        fi
    fi
    restartAudio
    exit
fi

if [ "$1" == "persist.sys.phh.vsmart.dt2w" ];then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    if [[ "$prop_value" == 1 ]];then
        echo 0 > /sys/class/vsm/tp/gesture_control
    else
        echo > /sys/class/vsm/tp/gesture_control
    fi
    exit
fi

if [ "$1" == "persist.sys.phh.backlight.scale" ];then
    if [[ "$prop_value" != "0" && "$prop_value" != "1" ]]; then
        exit 1
    fi

    if [[ "$prop_value" == 1 ]];then
        if [ -f /sys/class/leds/lcd-backlight/max_brightness ];then
            setprop persist.sys.qcom-brightness "$(cat /sys/class/leds/lcd-backlight/max_brightness)"
        elif [ -f /sys/class/backlight/panel0-backlight/max_brightness ];then
            setprop persist.sys.qcom-brightness "$(cat /sys/class/backlight/panel0-backlight/max_brightness)"
        fi
    else
        setprop persist.sys.qcom-brightness -1
    fi
    exit
fi
