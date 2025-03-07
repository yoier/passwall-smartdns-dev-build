local m, s = ...

local api = require "luci.passwall.api"

if not api.is_finded("trojan-plus") then
	return
end

local option_prefix = "trojan_plus_"

local function option_name(name)
	return option_prefix .. name
end

local function rm_prefix_cfgvalue(self, section)
	if self.option:find(option_prefix) == 1 then
		return m:get(section, self.option:sub(1 + #option_prefix))
	end
end
local function rm_prefix_write(self, section, value)
	if self.option:find(option_prefix) == 1 then
		m:set(section, self.option:sub(1 + #option_prefix), value)
	end
end

-- [[ Trojan Plus ]]

s.fields["type"]:value("Trojan-Plus", translate("Trojan-Plus"))

o = s:option(Value, "trojan_plus_address", translate("Address (Support Domain Name)"))

o = s:option(Value, "trojan_plus_port", translate("Port"))
o.datatype = "port"

o = s:option(Value, "trojan_plus_password", translate("Password"))
o.password = true

o = s:option(ListValue, "trojan_plus_tcp_fast_open", "TCP " .. translate("Fast Open"), translate("Need node support required"))
o:value("false")
o:value("true")

o = s:option(Flag, "trojan_plus_tls", translate("TLS"))
o.default = 0
o.validate = function(self, value, t)
	if value then
		local type = s.fields["type"]:formvalue(t) or ""
		if value == "0" and type == "Trojan-Plus" then
			return nil, translate("Original Trojan only supported 'tls', please choose 'tls'.")
		end
		return value
	end
end

o = s:option(Flag, "trojan_plus_tls_allowInsecure", translate("allowInsecure"), translate("Whether unsafe connections are allowed. When checked, Certificate validation will be skipped."))
o.default = "0"
o:depends({ trojan_plus_tls = true })

o = s:option(Value, "trojan_plus_tls_serverName", translate("Domain"))
o:depends({ trojan_plus_tls = true })

o = s:option(Flag, "trojan_plus_tls_sessionTicket", translate("Session Ticket"))
o.default = "0"
o:depends({ trojan_plus_tls = true })

for key, value in pairs(s.fields) do
	if key:find(option_prefix) == 1 then
		if not s.fields[key].not_rewrite then
			s.fields[key].cfgvalue = rm_prefix_cfgvalue
			s.fields[key].write = rm_prefix_write
		end

		local deps = s.fields[key].deps
		if #deps > 0 then
			for index, value in ipairs(deps) do
				deps[index]["type"] = "Trojan-Plus"
			end
		else
			s.fields[key]:depends({ type = "Trojan-Plus" })
		end
	end
end
