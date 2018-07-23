$(call inherit-product, device/phh/treble/base-pre.mk)
include build/make/target/product/treble_common.mk
$(call inherit-product, vendor/vndk/vndk32.mk)
$(call inherit-product, device/phh/treble/base.mk)
$(call inherit-product, vendor/foss/foss.mk)


PRODUCT_NAME := treble_arm_afN
PRODUCT_DEVICE := phhgsi_arm_a
PRODUCT_BRAND := Android
PRODUCT_MODEL := Phh-Treble with FOSS apps

PRODUCT_PACKAGES += 