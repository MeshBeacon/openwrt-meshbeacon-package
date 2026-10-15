#
# Copyright (C) 2026
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-clusterduckd
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-clusterduckd
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for the ClusterDuck Protocol gateway (clusterduckd)
  DEPENDS:=+luci-base +luci-compat +clusterduckd
endef

define Package/luci-app-clusterduckd/description
  Provides a LuCI web interface page to configure the SX130x concentrator
  interface (com_type, com_path) and the MQTT uplink settings (enabled,
  server, port, client_id, username, password, keepalive, use_tls,
  ca_cert_file) of the clusterduckd ClusterDuck Protocol gateway daemon.
  MQTT topic configuration is intentionally not exposed here.
endef

define Build/Compile
endef

define Package/luci-app-clusterduckd/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/clusterduckd.lua \
		$(1)/usr/lib/lua/luci/controller/clusterduckd.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/clusterduckd.lua \
		$(1)/usr/lib/lua/luci/model/cbi/clusterduckd.lua

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/luci-app-clusterduckd.json \
		$(1)/usr/share/rpcd/acl.d/luci-app-clusterduckd.json
endef

$(eval $(call BuildPackage,luci-app-clusterduckd))
