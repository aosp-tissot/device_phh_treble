$(call inherit-product, device/phh/treble/base-pre.mk)
include build/make/target/product/treble_common.mk
$(call inherit-product, vendor/vndk/vndk.mk)
$(call inherit-product, device/phh/treble/base.mk)


PRODUCT_NAME := aosp_arm64_bgN
PRODUCT_DEVICE := aosp_arm64_ab
PRODUCT_BRAND := Android
PRODUCT_MODEL := Phh-Treble Sooti AOSP

PRODUCT_PACKAGES += 
