#
# Copyright (C) 2026
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clusterduckd
PKG_VERSION:=1.2.3
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/MeshBeacon/meshbeacon-uplink/releases/download/v$(PKG_VERSION)

# Upstream ships separate prebuilt static binaries per CPU architecture.
# $(ARCH) is set by rules.mk from CONFIG_ARCH (e.g. "mipsel" for ramips/
# mt76x8, "mips" for ath79/generic -- e.g. AR9331 boards, "aarch64" for
# arm64 targets).
ifeq ($(ARCH),aarch64)
  PKG_SOURCE:=clusterduckd-v$(PKG_VERSION)-linux-arm64
  PKG_HASH:=f5d68cd4ee24fffee2db46066feb8f90e40116447e8d69ba9cc91a1cf291f936
else ifeq ($(ARCH),mips)
  PKG_SOURCE:=clusterduckd-v$(PKG_VERSION)-linux-mips-24kc
  PKG_HASH:=95ba9cdbf4fed221f4f23d30b9f94755da9feee3b0b456a2655ab5d67fca6d34
else
  PKG_SOURCE:=clusterduckd-v$(PKG_VERSION)-linux-mipsel-24kec
  PKG_HASH:=a0977237bfa902e28c0fb175054aa39631075380ab29ad9f548c09e7e439f6b4
endif

PKG_MAINTAINER:=
PKG_LICENSE:=BSD-3-Clause

include $(INCLUDE_DIR)/package.mk

define Package/clusterduckd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ClusterDuck Protocol PapaDuck gateway daemon
  URL:=https://github.com/MeshBeacon/meshbeacon-uplink
  DEPENDS:=+jshn
endef

define Package/clusterduckd/description
  clusterduckd is the ClusterDuck Protocol "SuperDuck"/PapaDuck LoRa
  concentrator gateway daemon. It receives packets from a ClusterDuck mesh
  network via a SX1302/SX1250 concentrator (USB or SPI) and forwards them to
  an MQTT broker.
  This package ships the prebuilt statically-linked binary from the
  upstream v$(PKG_VERSION) release matching the target architecture
  (mipsel-24kec for MT76x8, mips-24kc for AR9331/ath79, arm64 for aarch64
  targets), together with a UCI configuration and init script which
  generate /etc/clusterduckd/global_conf.json.
endef

# Prebuilt binary release: nothing to compile, just download and install it.
define Download/clusterduckd
  URL:=$(PKG_SOURCE_URL)
  URL_FILE:=$(PKG_SOURCE)
  FILE:=$(PKG_SOURCE)
  HASH:=$(PKG_HASH)
endef

define Build/Prepare
endef

define Build/Compile
endef

define Package/clusterduckd/conffiles
/etc/config/clusterduckd
/etc/clusterduckd/global_conf.json
endef

define Package/clusterduckd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(DL_DIR)/$(PKG_SOURCE) $(1)/usr/sbin/clusterduckd

	$(INSTALL_DIR) $(1)/etc/clusterduckd
	$(INSTALL_DATA) ./files/global_conf.json $(1)/etc/clusterduckd/global_conf.json

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/clusterduckd.config $(1)/etc/config/clusterduckd

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/clusterduckd.init $(1)/etc/init.d/clusterduckd
endef

$(eval $(call Download,clusterduckd))
$(eval $(call BuildPackage,clusterduckd))
