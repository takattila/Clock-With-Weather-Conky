local draw = {}

local abs_pos_x = 70
local abs_pos_y = 45

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
	local corner_r = 50
	local w = conky_window.width
	local h = conky_window.height
	
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
	
	cairo_set_source_rgba(cr, r_text, g_text, b_text, settings.appearance.background.transparency)
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

function text(cr, pos_x, pos_y, transparency, text, font_face, font_size, font_weight)
	local r_text, g_text, b_text = hex2rgb(settings.appearance.text.font.color)
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
		cairo_set_line_width (cr, 1)
		cairo_rectangle (cr, abs_pos_x + 16, abs_pos_y + 128, 54, 32)
		cairo_set_source_rgba (cr, 255, 255, 255, 0.0)
		cairo_fill_preserve (cr)
		cairo_set_source_rgba (cr, 255, 255, 255, 0.0)
		cairo_stroke (cr)

		local time_prefix = date_time(obj, '%p')
		text(cr, 20, 155, settings.appearance.text.transparency.min, time_prefix, settings.appearance.text.font.face, 28, CAIRO_FONT_WEIGHT_BOLD)
	end
end

function hour(cr, obj)
	text(cr, 10, 155, settings.appearance.text.transparency.max, get_hour(obj), settings.appearance.text.font.face, 145, CAIRO_FONT_WEIGHT_NORMAL)
	time_prefix(cr, obj)
end

function element_clock(cr, obj)
	-- Date / year
	local year = date_time(obj, '%Y.')
	text(cr, 20, 30, settings.appearance.text.transparency.max, year, settings.appearance.text.font.face, 20, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Date / month text + day number
	local date = date_time(obj, '| %B %d. | %A')
	text(cr, 70, 30, settings.appearance.text.transparency.min, date, settings.appearance.text.font.face, 20, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Hour
	hour(cr, obj)
	------------------------------------------------------------------------------------------

	-- Minutes
	local minutes = date_time(obj, ':%M')
	text(cr, 170, 155, settings.appearance.text.transparency.min, minutes, settings.appearance.text.font.face, 145, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Seconds
	local seconds = ": " .. date_time(obj, '%S')
	text(cr, 370, 155, settings.appearance.text.transparency.max, seconds, settings.appearance.text.font.face, 20, CAIRO_FONT_WEIGHT_NORMAL)
end

function element_system(cr)
	-- HDD
	local hdd = "HDD"
	text(cr, 20, 180, settings.appearance.text.transparency.max, hdd, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	hdd = conky_parse("${fs_free} / ${fs_size}")
	text(cr, 60, 180, settings.appearance.text.transparency.min, hdd, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	------------------------------------------------------------------------------------------

	-- RAM
	local ram = "RAM"
	text(cr, 200, 180, settings.appearance.text.transparency.max, ram, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	ram = conky_parse("${mem} / ${memmax}")
	text(cr, 250, 180, settings.appearance.text.transparency.min, ram, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	------------------------------------------------------------------------------------------

	-- CPU
	local cpu = "CPU"
	text(cr, 20, 200, settings.appearance.text.transparency.max, cpu, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	cpu = conky_parse("${cpu cpu0}%")
	text(cr, 60, 200, settings.appearance.text.transparency.min, cpu, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	------------------------------------------------------------------------------------------

	-- SWAP
	local swap = "SWAP"
	text(cr, 200, 200, settings.appearance.text.transparency.max, swap, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	swap = conky_parse("${swapperc}% (size: ${swapmax})")
	text(cr, 250, 200, settings.appearance.text.transparency.min, swap, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL) 
end

function element_weather(cr, obj)
	local unit_temperature = unit_temperature(settings.weather.units)
	local theme_dir = "theme/" .. settings.appearance.theme
	local elements_dir = theme_dir .. "/elements/"
	local weather_dir = theme_dir .. "/weather/"

	-- Vertical line
	image(cr, 415, 110, settings.appearance.text.transparency.max, elements_dir .. "line")

	------------------------------------------------------------------------------------------

	-- Weather icon
	local weather_icon = weather_dir .. settings.appearance.icon.set .. "/" .. obj.weather[1].icon
	image(cr, 470, 45, settings.appearance.icon.transparency, weather_icon)

	------------------------------------------------------------------------------------------

	-- City
	image(cr, 440, 100, settings.appearance.text.transparency.min, elements_dir .. "map-marker")
	text(cr, 455, 110, settings.appearance.text.transparency.min, settings.weather.city, settings.appearance.text.font.face, 30, CAIRO_FONT_WEIGHT_THIN)

	------------------------------------------------------------------------------------------

	-- Temperature -> Current
	image(cr, 440, 140, settings.appearance.text.transparency.min, elements_dir .. "temperature")

	local temperature = obj.main.temp
	temperature = string.format("%.0f", (temperature or 0)) .. unit_temperature

	text(cr, 460, 155, settings.appearance.text.transparency.max, temperature, settings.appearance.text.font.face, 40, CAIRO_FONT_WEIGHT_BOLD) 

	------------------------------------------------------------------------------------------

	-- Temperature -> Details
	image(cr, 435, 175, settings.appearance.text.transparency.min, elements_dir .. "arrow-right")

	local details = obj.weather[1].description
	text(cr, 445, 180, settings.appearance.text.transparency.min, details, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Temperature -> MIN
	image(cr, 435, 195, settings.appearance.text.transparency.min, elements_dir .. "arrow-down")

	local temp_min = obj.main.temp_min
	temp_min = string.format("%.0f", (temp_min or 0)) .. unit_temperature

	text(cr, 445, 200, settings.appearance.text.transparency.max, temp_min, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Temperature -> MAX
	image(cr, 495, 195, settings.appearance.text.transparency.min, elements_dir .. "arrow-up")

	local temp_max = obj.main.temp_max
	temp_max = string.format("%.0f", (temp_max or 0)) .. unit_temperature

	text(cr, 505, 200, settings.appearance.text.transparency.max, temp_max, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Temperature -> Feels like
	image(cr, 555, 195, settings.appearance.text.transparency.min, elements_dir .. "white-man")

	local feels_like = obj.main.feels_like
	feels_like = string.format("%.0f", (feels_like or 0)) .. unit_temperature

	text(cr, 565, 200, settings.appearance.text.transparency.max, feels_like, settings.appearance.text.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL)
end

function draw.elements(cr, obj)
	background(cr)
	element_clock(cr, obj)
	element_system(cr)
	element_weather(cr, obj)
end

return draw