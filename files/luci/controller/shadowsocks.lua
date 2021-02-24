-- Copyright (C) 2014-2017 Jian Chang <aa65535@live.com>
-- Copyright (C) 2020-2021 honwen <https://github.com/honwen>
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.shadowsocks", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/shadowsocks") then
		return
	end

	entry({"admin", "services", "shadowsocks"},
		alias("admin", "services", "shadowsocks", "general"),
		_("ShadowSocks"), 10).dependent = true

	entry({"admin", "services", "shadowsocks", "general"},
		cbi("shadowsocks/general"),
		_("General Settings"), 10).leaf = true

	entry({"admin", "services", "shadowsocks", "status"},
		call("action_status")).leaf = true

	entry({"admin", "services", "shadowsocks", "servers"},
		arcombine(cbi("shadowsocks/servers"), cbi("shadowsocks/servers-details")),
		_("Servers Manage"), 20).leaf = true

	if luci.sys.call("command -v sslocal >/dev/null") ~= 0 then
		return
	end

	entry({"admin", "services", "shadowsocks", "access-control"},
		cbi("shadowsocks/access-control"),
		_("Access Control"), 30).leaf = true

	entry({"admin", "services", "shadowsocks", "log"},
		call("action_log"),
		_("System Log"), 90).leaf = true

	if luci.sys.call("command -v /etc/init.d/dnsmasq-extra >/dev/null") ~= 0 then
		return
	end

	entry({"admin", "services", "shadowsocks", "gfwlist"},
		call("action_gfw"),
		_("GFW-List"), 60).leaf = true

	entry({"admin", "services", "shadowsocks", "custom"},
		cbi("shadowsocks/gfwlist-custom"),
		_("Custom-List"), 50).leaf = true

end

local function is_running(name)
	return luci.sys.call("pgrep -f '%s' >/dev/null" %{name}) == 0
end

function action_status()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		ss_redir = is_running("protocol=redir"),
		ss_http = is_running("protocol=http"),
		ss_socks = is_running("protocol=socks"),
		ss_tunnel = is_running("protocol=tunnel")
	})
end

function action_log()
	local conffile = "/var/log/shadowsocks_watchdog.log"
	local watchdog = nixio.fs.readfile(conffile) or ""
	luci.template.render("shadowsocks/plain", {content=watchdog})
end

function action_gfw()
	local conffile = "/etc/dnsmasq-extra.d/gfwlist"
	local gfwlist = nixio.fs.readfile(conffile) or luci.sys.exec("cat %s.gz | gunzip -c" %{conffile}) or ""
	luci.template.render("shadowsocks/plain", {content=gfwlist})
end
