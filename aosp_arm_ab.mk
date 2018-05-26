TARGET_GAPPS_ARCH := arm
$(call inherit-product, device/phh/treble/base-pre.mk)
include build/make/target/product/treble_common.mk
$(call inherit-product, vendor/vndk/vndk32.mk)
$(call inherit-product, device/phh/treble/base.mk)

$(call inherit-product, device/phh/treble/aosp.mk)

PRODUCT_NAME := aosp_arm_ab
PRODUCT_DEVICE := phhgsi_arm_ab
PRODUCT_BRAND := Android
PRODUCT_MODEL := PixelExperience for Phh-Treble

