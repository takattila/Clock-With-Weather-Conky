require 'cairo'

local draw = require "panelDraw"
local theme = require "cwTheme"

-- Load settings from the active theme (same as cwMain.lua)
settings = {
	appearance = require('themes.appearance.' .. theme.appearance.name .. '.appearance').appearance,
	system = theme.system,
}

-- Flag to ensure startup info is printed only once
local startup_info_printed = false

function conky_panelMain()
	if conky_window == nil then return end

	-- Wait until a VALID NIC is detected or use fallback, then print once
	if not startup_info_printed then
		local iface = conky_parse("${gw_iface}")
		
		-- If conky is unsure, try the fallback method immediately for the log
		if iface == "" or iface == nil or iface == "(null)" or iface == "multiple" then
			iface = conky_parse("${exec ip route get 8.8.8.8 | grep -Po '(?<=dev )\\S+' | head -1}")
		end

		-- Print only if we have a real interface name now
		if iface ~= nil and iface ~= "" and iface ~= "(null)" and iface ~= "multiple" then
			print("-> detected NIC -------- : " .. tostring(iface))
			startup_info_printed = true
		end
	end

	local cs = cairo_xlib_surface_create(
		conky_window.display,
		conky_window.drawable,
		conky_window.visual, 
		conky_window.width,
		conky_window.height
	)

	local cr = cairo_create(cs)

	draw.elements(cr)

	cairo_surface_destroy(cs)
	cairo_destroy(cr)
end
