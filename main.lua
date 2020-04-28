require 'cairo'

draw = require "draw"
settings = require "settings"
utils = require "utils"

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

		if utils.check_api_response_status(cr, weather_json) then
			draw.elements(cr, weather_json)
			cairo_surface_destroy(cs)
			cairo_destroy(cr)
		end
	end
end
