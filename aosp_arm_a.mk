TARGET_GAPPS_ARCH := arm
$(call inherit-product, device/phh/treble/base-pre.mk)
include build/make/target/product/legacy_gsi_common.mk
$(call inherit-product, vendor/vndk/vndk-binder32.mk)
$(call inherit-product, device/phh/treble/base.mk)
$(call inherit-product, device/phh/treble/base-sas.mk)

$(call inherit-product, device/phh/treble/aosp.mk)

PRODUCT_NAME := aosp_arm_a
PRODUCT_DEVICE := phhgsi_arm_a
PRODUCT_BRAND := Android
PRODUCT_MODEL := Phh-Treble (ARM - A)

GAPPS_VARIANT := pico

# AOSP Packages
PRODUCT_PACKAGES += \
    Launcher3 \
    messaging \
    Terminal
