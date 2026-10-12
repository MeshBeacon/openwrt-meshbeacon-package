module("luci.controller.clusterduckd", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/clusterduckd") then
		return
	end

	entry({"admin", "services", "clusterduckd"},
		cbi("clusterduckd"), _("ClusterDuck Gateway"), 60).dependent = true
end
