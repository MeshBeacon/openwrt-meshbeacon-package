local m, s, s2

m = Map("clusterduckd", translate("MeshBeacon"),
	translate("Configure the SX130x concentrator interface, region frequency "
		.. "preset and the MQTT uplink used by the ClusterDuck Protocol "
		.. "gateway daemon (clusterduckd). MQTT topic configuration is not "
		.. "exposed here and must be edited directly in "
		.. "/etc/clusterduckd/global_conf.json."))

local s0 = m:section(TypedSection, "clusterduckd", translate("General"))
s0.anonymous = true

local enabled = s0:option(Flag, "enabled", translate("Enable"),
	translate("Start the clusterduckd gateway daemon. Disabled by default -- "
		.. "enable once the concentrator interface and MQTT settings below "
		.. "are configured."))
enabled.default = enabled.disabled
enabled.rmempty = false

s = m:section(TypedSection, "clusterduckd", translate("Concentrator"))
s.anonymous = true

local com_type = s:option(ListValue, "com_type", translate("Interface type"))
com_type:value("USB", "USB")
com_type:value("SPI", "SPI")
com_type.default = "USB"

local com_path = s:option(Value, "com_path", translate("Interface path"),
	translate("Path to the concentrator device node, e.g. /dev/ttyACM0 "
		.. "for USB or /dev/spidev0.0 for SPI"))
com_path.default = "/dev/ttyACM0"
com_path.rmempty = false

local region = s:option(ListValue, "region", translate("Region preset"),
	translate("Frequency plan applied to the concentrator's LBT scan "
		.. "channels and radio_0/radio_1 center/TX frequencies. These are "
		.. "representative per-region presets mirroring the duck "
		.. "firmware's RadioRegionConfig and are not regulator-verified -- "
		.. "confirm the selected plan is legal for your deployment "
		.. "location before transmitting."))
region.widget = "radio"
region:value("MY", translate("Malaysia (AS923)"))
region:value("SG", translate("Singapore (AS923)"))
region:value("PH", translate("Philippines (AS923)"))
region:value("ID", translate("Indonesia (AS923)"))
region:value("US", translate("United States (US915)"))
region:value("UK", translate("United Kingdom (EU868)"))
region:value("PS", translate("Palestine (EU868, no dedicated allocation)"))
region.default = "MY"
region.rmempty = false

s2 = m:section(TypedSection, "clusterduckd", translate("MQTT"))
s2.anonymous = true

local mqtt_enabled = s2:option(Flag, "mqtt_enabled", translate("Enable MQTT"))
mqtt_enabled.default = mqtt_enabled.enabled
mqtt_enabled.rmempty = false

local mqtt_server = s2:option(Value, "mqtt_server", translate("Broker address"),
	translate("MQTT broker hostname or IP address"))
mqtt_server:depends("mqtt_enabled", "1")

local mqtt_port = s2:option(Value, "mqtt_port", translate("Broker port"))
mqtt_port.datatype = "port"
mqtt_port.default = "1883"
mqtt_port:depends("mqtt_enabled", "1")

local mqtt_client_id = s2:option(Value, "mqtt_client_id", translate("Client ID"),
	translate("Unique MQTT client identifier"))
mqtt_client_id:depends("mqtt_enabled", "1")

local mqtt_username = s2:option(Value, "mqtt_username", translate("Username"))
mqtt_username.optional = true
mqtt_username:depends("mqtt_enabled", "1")

local mqtt_password = s2:option(Value, "mqtt_password", translate("Password"))
mqtt_password.password = true
mqtt_password.optional = true
mqtt_password:depends("mqtt_enabled", "1")

local mqtt_keepalive = s2:option(Value, "mqtt_keepalive", translate("Keepalive (s)"))
mqtt_keepalive.datatype = "uinteger"
mqtt_keepalive.default = "60"
mqtt_keepalive:depends("mqtt_enabled", "1")

local mqtt_use_tls = s2:option(Flag, "mqtt_use_tls", translate("Use TLS"))
mqtt_use_tls:depends("mqtt_enabled", "1")

local mqtt_ca_cert_file = s2:option(Value, "mqtt_ca_cert_file",
	translate("CA certificate file"),
	translate("Path to CA certificate file for TLS verification"))
mqtt_ca_cert_file.optional = true
mqtt_ca_cert_file:depends({mqtt_enabled = "1", mqtt_use_tls = "1"})

function m.on_after_commit(self)
	luci.sys.call("/etc/init.d/clusterduckd reload >/dev/null 2>&1")
end

return m
