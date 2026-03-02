local draw = {}

local abs_pos_x = 70
local abs_pos_y = 25

function hex2rgb(hex)
	local hex = hex:gsub("#","")
	return (tonumber("0x"..hex:sub(1,2))/255), 
		(tonumber("0x"..hex:sub(3,4))/255), 
		tonumber(("0x"..hex:sub(5,6))/255)
end

function unit_temperature(unit)
	if unit == "metric" then
		return "˚C"
	end
	return "˚F"
end

function date_time(obj, format)
	local now = os.time() + obj.timezone
	return os.date('!' .. format, now)
end

function background(cr)
	local corner_r = 20
	local w = conky_window.width
	local h = conky_window.height
	local r, g, b = hex2rgb(settings.appearance.background.color)
	
	cairo_move_to(cr,corner_r,0)
	cairo_line_to(cr,w-corner_r,0)
	cairo_curve_to(cr,w,0,w,0,w,corner_r)
	cairo_line_to(cr,w,h-corner_r)
	cairo_curve_to(cr,w,h,w,h,w-corner_r,h)
	cairo_line_to(cr,corner_r,h)
	cairo_curve_to(cr,0,h,0,h,0,h-corner_r)
	cairo_line_to(cr,0,corner_r)
	cairo_curve_to(cr,0,0,0,0,corner_r,0)
	cairo_close_path(cr)
	
	cairo_set_source_rgba(cr, r, g, b, settings.appearance.background.transparency)
	cairo_fill(cr)
end

function image(cr, pos_x, pos_y, transparency, image_name)
	local image_path = "./images/" .. (image_name or "01d") .. ".png"

	cairo_set_operator(cr, CAIRO_OPERATOR_OVER)
	local image = cairo_image_surface_create_from_png(image_path)
	local w_img = cairo_image_surface_get_width(image)
	local h_img = cairo_image_surface_get_height(image)

	cairo_save(cr)
	cairo_set_source_surface(cr, image, abs_pos_x + pos_x-w_img / 2, abs_pos_y + pos_y-h_img / 2)
	cairo_paint_with_alpha(cr, transparency)
	cairo_surface_destroy(image)
	cairo_restore(cr)
end

function text(cr, pos_x, pos_y, transparency, text, font_face, font_size, font_weight, font_color)
	local r_text, g_text, b_text = hex2rgb(font_color)
	cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE)
	cairo_set_source_rgba(cr, r_text, g_text, b_text, transparency)
	local ct = cairo_text_extents_t:create()
	cairo_select_font_face(cr, font_face, CAIRO_FONT_SLANT_NORMAL, font_weight)
	cairo_set_font_size(cr, font_size)
	cairo_text_extents(cr,text,ct)
	cairo_move_to(cr, abs_pos_x + pos_x, abs_pos_y + pos_y)
	cairo_show_text(cr,text)
	cairo_close_path(cr)
end

function get_hour(obj)
	local hour_format = '%H'

	if settings.system.hour_format_12 then
		hour_format = '%I'
	end

	return date_time(obj, hour_format)
end

function time_prefix(cr, obj)
	if settings.system.hour_format_12 then
		local r, g, b = hex2rgb(settings.appearance.background.color)

		cairo_set_line_width(cr, 1)
		cairo_rectangle(cr, abs_pos_x + 16, abs_pos_y + 128, 54, 32)
		cairo_set_source_rgba(cr, r, g, b, settings.appearance.background.transparency)
		cairo_fill_preserve(cr)
		cairo_set_source_rgba(cr, r, g, b, settings.appearance.background.transparency)
		cairo_stroke(cr)

		local time_prefix = date_time(obj, '%p')
		text(cr, 20, 155, settings.appearance.font.transparency.dark, time_prefix, settings.appearance.font.face, 28, CAIRO_FONT_WEIGHT_BOLD, settings.appearance.font.color.dark)
	end
end

function hour(cr, obj)
	text(cr, 10, 155, settings.appearance.font.transparency.light, get_hour(obj), settings.appearance.font.face, 145, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.light)
	time_prefix(cr, obj)
end

function element_clock(cr, obj)
	-- Date / year
	local year = date_time(obj, '%Y.')
	text(cr, 20, 30, settings.appearance.font.transparency.light, year, settings.appearance.font.face, 20, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.light)

	------------------------------------------------------------------------------------------

	-- Date / month text + day number
	local date = date_time(obj, '| %B %d. | %A')
	text(cr, 70, 30, settings.appearance.font.transparency.dark, date, settings.appearance.font.face, 20, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)

	------------------------------------------------------------------------------------------

	-- Hour
	hour(cr, obj)
	------------------------------------------------------------------------------------------

	-- Minutes
	local minutes = date_time(obj, ':%M')
	text(cr, 170, 155, settings.appearance.font.transparency.dark, minutes, settings.appearance.font.face, 145, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)

	------------------------------------------------------------------------------------------

	-- Seconds
	local seconds = ": " .. date_time(obj, '%S')
	text(cr, 370, 155, settings.appearance.font.transparency.light, seconds, settings.appearance.font.face, 20, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.light)
end

function element_system(cr)
	-- HDD
	local hdd = "HDD"
	text(cr, 20, 180, settings.appearance.font.transparency.light, hdd, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.light)

	hdd = conky_parse("${fs_free} / ${fs_size}")
	text(cr, 60, 180, settings.appearance.font.transparency.dark, hdd, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)

	------------------------------------------------------------------------------------------

	-- RAM
	local ram = "RAM"
	text(cr, 200, 180, settings.appearance.font.transparency.light, ram, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.light)

	ram = conky_parse("${mem} / ${memmax}")
	text(cr, 250, 180, settings.appearance.font.transparency.dark, ram, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)

	------------------------------------------------------------------------------------------

	-- CPU
	local cpu = "CPU"
	text(cr, 20, 200, settings.appearance.font.transparency.light, cpu, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.light)

	cpu = conky_parse("${cpu cpu0}%")
	text(cr, 60, 200, settings.appearance.font.transparency.dark, cpu, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)

	------------------------------------------------------------------------------------------

	-- SWAP
	local swap = "SWAP"
	text(cr, 200, 200, settings.appearance.font.transparency.light, swap, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.light)

	swap = conky_parse("${swapperc}% (size: ${swapmax})")
	text(cr, 250, 200, settings.appearance.font.transparency.dark, swap, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
end

function element_weather(cr, obj)
	local unit_temperature = unit_temperature(settings.weather.units)
	local theme_dir = "theme/" .. settings.appearance.theme
	local elements_dir = theme_dir .. "/elements/"
	local weather_dir = theme_dir .. "/weather/"

	-- Vertical line
	image(cr, 415, 110, settings.appearance.font.transparency.light, elements_dir .. "line")

	------------------------------------------------------------------------------------------

	-- Weather icon
	local weather_icon = weather_dir .. settings.appearance.icon.set .. "/" .. obj.weather[1].icon
	image(cr, 470, 45, settings.appearance.icon.transparency.light, weather_icon)

	------------------------------------------------------------------------------------------

	-- City
	image(cr, 440, 100, settings.appearance.icon.transparency.dark, elements_dir .. "map-marker")
	text(cr, 455, 110, settings.appearance.font.transparency.dark, settings.weather.city, settings.appearance.font.face, 30, CAIRO_FONT_WEIGHT_THIN, settings.appearance.font.color.dark)

	------------------------------------------------------------------------------------------

	-- Temperature -> Current
	image(cr, 440, 140, settings.appearance.icon.transparency.dark, elements_dir .. "temperature")

	local temperature = obj.main.temp
	temperature = string.format("%.0f", (temperature or 0)) .. unit_temperature

	text(cr, 460, 155, settings.appearance.font.transparency.light, temperature, settings.appearance.font.face, 40, CAIRO_FONT_WEIGHT_BOLD, settings.appearance.font.color.light)

	------------------------------------------------------------------------------------------

	-- Temperature -> Details
	image(cr, 435, 175, settings.appearance.icon.transparency.light, elements_dir .. "arrow-right")

	local details = obj.weather[1].description
	text(cr, 445, 180, settings.appearance.font.transparency.dark, details, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)

	------------------------------------------------------------------------------------------

	-- Temperature -> MIN
	image(cr, 435, 195, settings.appearance.icon.transparency.light, elements_dir .. "arrow-down")

	local temp_min = obj.main.temp_min
	temp_min = string.format("%.0f", (temp_min or 0)) .. unit_temperature

	text(cr, 445, 200, settings.appearance.font.transparency.dark, temp_min, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)

	------------------------------------------------------------------------------------------

	-- Temperature -> MAX
	image(cr, 495, 195, settings.appearance.icon.transparency.light, elements_dir .. "arrow-up")

	local temp_max = obj.main.temp_max
	temp_max = string.format("%.0f", (temp_max or 0)) .. unit_temperature

	text(cr, 505, 200, settings.appearance.font.transparency.dark, temp_max, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)

	------------------------------------------------------------------------------------------

	-- Temperature -> Feels like
	image(cr, 555, 195, settings.appearance.icon.transparency.light, elements_dir .. "white-man")

	local feels_like = obj.main.feels_like
	feels_like = string.format("%.0f", (feels_like or 0)) .. unit_temperature

	text(cr, 565, 200, settings.appearance.font.transparency.dark, feels_like, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
end

function draw.elements(cr, obj)
	background(cr)
	element_clock(cr, obj)
	element_system(cr)
	element_weather(cr, obj)
end

return draw