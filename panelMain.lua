require 'cairo'

local draw = require "panelDraw"

function conky_panelMain()
	if conky_window == nil then return end

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
