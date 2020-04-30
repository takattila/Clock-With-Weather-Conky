require 'cairo'

draw = require "draw"
json = require "json"
theme = require "theme"
utils = require "utils"

settings = {
	appearance = require('themes.appearance.' .. theme.appearance.name .. '.appearance').appearance,
	weather = require('themes.weather.' .. theme.weather.name .. '.weather').weather,
	system = theme.system,
}

print("-> appearance --------- : " .. './themes/' .. theme.appearance.name .. '/appearance.lua')
print("-> weather ------------ : " .. './themes/' .. theme.weather.name .. '/weather.lua')
print("-> use 12 hour format - : " .. tostring(settings.system.hour_format_12))

assert(os.setlocale(settings.system.locale))

function conky_main()
	if conky_window == nil then return end

	local cs = cairo_xlib_surface_create(
		conky_window.display,
		conky_window.drawable,
		conky_window.visual, 
		conky_window.width,
		conky_window.height
	)

	local cr = cairo_create(cs)

	if utils.is_set_api_key(cr) then
		local weather_json = utils.get_weather_json()

		if weather_json ~= "" then
			local obj = json.decode(weather_json)

			if utils.check_api_response_status(cr, obj) then
				draw.elements(cr, obj)
				cairo_surface_destroy(cs)
				cairo_destroy(cr)
			end
		end
	end
end
