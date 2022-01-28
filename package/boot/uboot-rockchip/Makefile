#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_VERSION:=nanopi4-v2017.09
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@github.com:friendlyarm/uboot-rockchip.git
PKG_SOURCE_DATE:=2022-01-10
PKG_SOURCE_VERSION:=60a32b83607cd757c7a0f5869527c9a631b2d5e8
PKG_MIRROR_HASH:=80c7a5599407d7a0a5231ca3878bea3576da95100abcb93e62e40aa721175372
PKG_MAINTAINER:=Tobias Maedel <openwrt@tbspace.de>

BL31_ELF_SOURCE_URL:=https://github.com/friendlyarm/rkbin/raw/friendlyelec/bin/rk33/
BL31_ELF_SOURCE_FILE:=rk3399_bl31_v1.35.elf
BL31_ELF_HASH:=04489e39580d93665a50660ce4ec83eecd51aa6f54cbe20f0402678b69144c06
IDB_LOADER_SOURCE_URL:=https://github.com/friendlyarm/sd-fuse_rk3399/raw/kernel-5.10.y/prebuilt/
IDB_LOADER_HASH:=b86b283ed12c58f2d63198e96a76d42da29b845c36996d99ecd4299d1394d49c

include $(INCLUDE_DIR)/u-boot.mk
include $(INCLUDE_DIR)/package.mk

define U-Boot/Default
  BUILD_TARGET:=rockchip
  UENV:=default
  HIDDEN:=1
endef


# RK3328 boards

define U-Boot/nanopi-r2s-rk3328
  BUILD_SUBTARGET:=armv8
  NAME:=NanoPi R2S
  BUILD_DEVICES:= \
    friendlyarm_nanopi-r2s
  DEPENDS:=+PACKAGE_u-boot-nanopi-r2s-rk3328:arm-trusted-firmware-rockchip
  PKG_BUILD_DEPENDS:=arm-trusted-firmware-rockchip
  ATF:=rk3328_bl31.elf
  OF_PLATDATA:=$(1)
endef


# RK3399 boards

define U-Boot/nanopi-r4s-rk3399
  BUILD_SUBTARGET:=armv8
  NAME:=NanoPi R4S
  BUILD_DEVICES:= \
    friendlyarm_nanopi-r4s
  DEPENDS:=+PACKAGE_u-boot-nanopi-r4s-rk3399:arm-trusted-firmware-rockchip
  PKG_BUILD_DEPENDS:=arm-trusted-firmware-rockchip
  ATF:=rk3399_bl31.elf
  UBOOT_CONFIG:=rk3399
endef

define U-Boot/rock-pi-4-rk3399
  BUILD_SUBTARGET:=armv8
  NAME:=Rock Pi 4
  BUILD_DEVICES:= \
    radxa_rock-pi-4a
  DEPENDS:=+PACKAGE_u-boot-rock-pi-4-rk3399:arm-trusted-firmware-rockchip
  PKG_BUILD_DEPENDS:=arm-trusted-firmware-rockchip
  ATF:=rk3399_bl31.elf
endef

define U-Boot/rockpro64-rk3399
  BUILD_SUBTARGET:=armv8
  NAME:=RockPro64
  BUILD_DEVICES:= \
    pine64_rockpro64
  DEPENDS:=+PACKAGE_u-boot-rockpro64-rk3399:arm-trusted-firmware-rockchip
  PKG_BUILD_DEPENDS:=arm-trusted-firmware-rockchip
  ATF:=rk3399_bl31.elf
endef

UBOOT_TARGETS := \
  nanopi-r4s-rk3399 \
  rock-pi-4-rk3399 \
  rockpro64-rk3399 \
  nanopi-r2s-rk3328

UBOOT_CONFIGURE_VARS += USE_PRIVATE_LIBGCC=yes

UBOOT_MAKE_FLAGS += \
  BL31=$(STAGING_DIR_IMAGE)/$(ATF)

define Build/Configure
	$(call Build/Configure/U-Boot)

ifneq ($(OF_PLATDATA),)
	mkdir -p $(PKG_BUILD_DIR)/tpl/dts
	mkdir -p $(PKG_BUILD_DIR)/include/generated

	$(CP) $(PKG_BUILD_DIR)/of-platdata/$(OF_PLATDATA)/dt-plat.c $(PKG_BUILD_DIR)/tpl/dts/dt-plat.c
	$(CP) $(PKG_BUILD_DIR)/of-platdata/$(OF_PLATDATA)/dt-structs-gen.h $(PKG_BUILD_DIR)/include/generated/dt-structs-gen.h
	$(CP) $(PKG_BUILD_DIR)/of-platdata/$(OF_PLATDATA)/dt-decl.h $(PKG_BUILD_DIR)/include/generated/dt-decl.h
endif

	$(SED) 's#CONFIG_MKIMAGE_DTC_PATH=.*#CONFIG_MKIMAGE_DTC_PATH="$(PKG_BUILD_DIR)/scripts/dtc/dtc"#g' $(PKG_BUILD_DIR)/.config
	echo 'CONFIG_IDENT_STRING=" OpenWrt"' >> $(PKG_BUILD_DIR)/.config
endef

define Build/Compile/U-Boot
	$(SCRIPT_DIR)/download.pl $(PKG_BUILD_DIR) bl31.elf $(BL31_ELF_HASH) $(BL31_ELF_SOURCE_FILE) $(BL31_ELF_SOURCE_URL)
	+$(MAKE) _all u-boot.itb -C $(PKG_BUILD_DIR) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		$(if $(DTC),DTC="$(DTC)") \
		$(UBOOT_MAKE_FLAGS)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR_IMAGE)
	$(SCRIPT_DIR)/download.pl $(PKG_BUILD_DIR) idbloader.img $(IDB_LOADER_HASH) idbloader.img $(IDB_LOADER_SOURCE_URL)
	$(CP) $(PKG_BUILD_DIR)/idbloader.img $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-idbloader.img
	$(CP) $(PKG_BUILD_DIR)/u-boot.itb $(STAGING_DIR_IMAGE)/$(BUILD_VARIANT)-u-boot.itb
endef

define Package/u-boot/install/default
endef

$(eval $(call BuildPackage/U-Boot))
