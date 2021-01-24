-- Copyright (C) 2016-2017 Jian Chang <aa65535@live.com>
-- Copyright (C) 2020-2021 honwen <https://github.com/honwen>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local shadowsocks = "shadowsocks"
local sid = arg[1]
local encrypt_methods = {
	"aes-256-gcm",
	"aes-128-gcm",
	"chacha20-ietf-poly1305",
	"rc4-md5",
	"aes-128-cfb",
	"aes-192-cfb",
	"aes-256-cfb",
	"aes-128-ctr",
	"aes-192-ctr",
	"aes-256-ctr",
	"camellia-128-cfb",
	"camellia-192-cfb",
	"camellia-256-cfb",
	"chacha20-ietf",
	"plain",
}

m = Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"), translate("Edit Server")})
m.redirect = luci.dispatcher.build_url("admin/services/shadowsocks/servers")
m.sid = sid
m.template = "shadowsocks/servers-details"

if m.uci:get(shadowsocks, sid) ~= "servers" then
	luci.http.redirect(m.redirect)
	return
end

-- [[ Edit Server ]]--
s = m:section(NamedSection, sid, "servers")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias(optional)"))
o.rmempty = true

o = s:option(Value, "server", translate("Server Address"))
o.datatype = "host"
o.rmempty = false

o = s:option(Value, "server_port", translate("Server Port"))
o.datatype = "port"
o.rmempty = false

o = s:option(Value, "timeout", translate("TCP Connection Timeout"))
o.datatype = "uinteger"
o.default = 60
o.rmempty = false

o = s:option(Value, "password", translate("Password"))
o.password = true

o = s:option(ListValue, "encrypt_method", translate("Encrypt Method"))
for _, v in ipairs(encrypt_methods) do o:value(v, v:upper()) end
o.rmempty = false

o = s:option(Value, "plugin", translate("Plugin Name"))
o.placeholder = "eg: v2ray-plugin"

o = s:option(Value, "plugin_opts", translate("Plugin Arguments"))
o.placeholder = "eg: tls;host=www.bing.com;path=/websocket"

return m
