#
# Copyright (C) 2026
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clusterduckd
PKG_VERSION:=1.2.4
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
  PKG_HASH:=45e3e34eb25e0090e8cd7430cc6fec2a7d18123e49c052059b8a11db8f71e21f
else
  PKG_SOURCE:=clusterduckd-v$(PKG_VERSION)-linux-mipsel-24kec
  PKG_HASH:=5282b618c480c6f6ad8f1d486573fffbb982c24f344efbcf6c47c77cf0f4348f
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

# reset_lgw.sh is the SX1302/SX1250 concentrator GPIO reset script. It is
# not shipped by this package -- some devices already have it installed
# (e.g. by a vendor image or another package). If present on the device,
# copy it next to the clusterduckd binary so it can be invoked relative to
# $PROG; otherwise just warn, since clusterduckd may still work with
# concentrators that don't need a reset script (e.g. USB).
define Package/clusterduckd/postinst
#!/bin/sh
ROOT="$${IPKG_INSTROOT}"
TARGET_DIR="$${ROOT}/usr/sbin"
TARGET="$$TARGET_DIR/reset_lgw.sh"

[ -f "$$TARGET" ] && exit 0

SRC=$$(find "$${ROOT}/usr" "$${ROOT}/root" "$${ROOT}/etc" "$${ROOT}/opt" "$${ROOT}/www" "$${ROOT}/tmp" -xdev -maxdepth 6 -name 'reset_lgw.sh' 2>/dev/null | grep -v -x "$$TARGET" | head -n1)

if [ -n "$$SRC" ]; then
	cp -p "$$SRC" "$$TARGET" 2>/dev/null || cp "$$SRC" "$$TARGET"
	chmod +x "$$TARGET"
	echo "clusterduckd: copied reset_lgw.sh from $$SRC to $$TARGET"
else
	echo "clusterduckd: WARNING: reset_lgw.sh not found on this device; copy the LoRa concentrator reset script to $$TARGET_DIR manually if your hardware requires it." >&2
fi

exit 0
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
