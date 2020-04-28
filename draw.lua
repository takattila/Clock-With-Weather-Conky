local draw = {}

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

function get_time_zone(weather_json)
		local obj = json.decode(weather_json)
		return obj.timezone / 60 / 60
end

function image(cr, pos_x, pos_y, transparency, image_name)
	local image_path = "./images/" .. (image_name or "01d") .. ".png"
	
	cairo_set_operator(cr, CAIRO_OPERATOR_OVER)
	local image = cairo_image_surface_create_from_png (image_path)
	local w_img = cairo_image_surface_get_width (image)
	local h_img = cairo_image_surface_get_height (image)

	cairo_save(cr)
	cairo_set_source_surface (cr, image, pos_x-w_img/2, pos_y-h_img/2)
	cairo_paint_with_alpha (cr, transparency)
	cairo_surface_destroy (image)
	cairo_restore(cr)
end

function text(cr, pos_x, pos_y, transparency, text, font_face, font_size, font_weight)
	local r_text, g_text, b_text = hex2rgb(settings.appearance.html_text_color)
	cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE)
	cairo_set_source_rgba(cr, r_text, g_text, b_text, transparency)
	local ct = cairo_text_extents_t:create()
	cairo_select_font_face(cr, font_face, CAIRO_FONT_SLANT_NORMAL, font_weight)
	cairo_set_font_size(cr, font_size)
	cairo_text_extents(cr,text,ct)
	cairo_move_to(cr,pos_x,pos_y)
	cairo_show_text(cr,text)
	cairo_close_path(cr)
end

function draw.elements(cr, weather_json)
	if weather_json ~= "" then
		local obj = json.decode(weather_json)
		local unit_temperature = unit_temperature(settings.weather.units)
		local theme_dir = "theme/" .. settings.appearance.theme
		local elements_dir = theme_dir .. "/elements/"
		local weather_dir = theme_dir .. "/weather/"
		local TZ = get_time_zone(weather_json)

		------------------------------------------------------------------------------------------
		-- CLOCK section
		------------------------------------------------------------------------------------------

		-- Date / year
		local year = conky_parse("${exec date -d '" .. TZ .. " hours' -u '+%Y.'}")
		text(cr, 20, 30, settings.appearance.transparency_full, year, settings.appearance.default_font_face, 20, CAIRO_FONT_WEIGHT_NORMAL)

		------------------------------------------------------------------------------------------

		-- Date / month text + day number
		local date = conky_parse("${exec date -d '" .. TZ .. " hours' -u '+| %B %d. | %A'}")
		--date = "| Wednesday | December 31."
		text(cr, 70, 30, settings.appearance.transparency_half, date, settings.appearance.default_font_face, 20, CAIRO_FONT_WEIGHT_NORMAL)

		------------------------------------------------------------------------------------------

		-- Hour
		local hour = conky_parse("${exec date -d '" .. TZ .. " hours' -u '+%H'}")
		text(cr, 10, 155, settings.appearance.transparency_full, hour, settings.appearance.default_font_face, 145, CAIRO_FONT_WEIGHT_NORMAL)

		------------------------------------------------------------------------------------------

		-- Minutes
		local minutes = conky_parse("${exec date -d '" .. TZ .. " hours' -u '+:%M'}")
		text(cr, 170, 155, settings.appearance.transparency_half, minutes, settings.appearance.default_font_face, 145, CAIRO_FONT_WEIGHT_NORMAL)

		------------------------------------------------------------------------------------------

		-- Seconds
		local seconds = ": " .. conky_parse("${exec date -d '" .. TZ .. " hours' -u '+%S'}")
		text(cr, 370, 155, settings.appearance.transparency_full, seconds, settings.appearance.default_font_face, 20, CAIRO_FONT_WEIGHT_NORMAL)

		------------------------------------------------------------------------------------------

		-- HDD
		local hdd = "HDD"
		text(cr, 20, 180, settings.appearance.transparency_full, hdd, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

		hdd = conky_parse("${fs_free} / ${fs_size}")
		text(cr, 60, 180, settings.appearance.transparency_half, hdd, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

		------------------------------------------------------------------------------------------

		-- RAM
		local ram = "RAM"
		text(cr, 200, 180, settings.appearance.transparency_full, ram, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

		ram = conky_parse("${mem} / ${memmax}")
		text(cr, 250, 180, settings.appearance.transparency_half, ram, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

		------------------------------------------------------------------------------------------

		-- CPU
		local cpu = "CPU"
		text(cr, 20, 200, settings.appearance.transparency_full, cpu, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

		cpu = conky_parse("${cpu cpu0}%")
		text(cr, 60, 200, settings.appearance.transparency_half, cpu, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

		------------------------------------------------------------------------------------------

		-- SWAP
		local swap = "SWAP"
		text(cr, 200, 200, settings.appearance.transparency_full, swap, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

		swap = conky_parse("${swapperc}% (size: ${swapmax})")
		text(cr, 250, 200, settings.appearance.transparency_half, swap, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

		------------------------------------------------------------------------------------------

		-- Vertical line-colorspace HSI -channel B -level 100,0%  +channel -colorspace sRGB 
		image(cr, 415, 130, settings.appearance.transparency_full, elements_dir .. "line")

		------------------------------------------------------------------------------------------
		-- WEATHER section
		------------------------------------------------------------------------------------------

		-- Weather icon
		local weather_icon = weather_dir .. settings.appearance.iconset .. "/" .. obj.weather[1].icon
		image(cr, 470, 45, settings.appearance.transparency_weather_icon, weather_icon)

		------------------------------------------------------------------------------------------

		-- City
		image(cr, 440, 100, settings.appearance.transparency_half, elements_dir .. "map-marker")
		text(cr, 455, 110, settings.appearance.transparency_half, settings.weather.city, "Noto Sans", 30, CAIRO_FONT_WEIGHT_THIN)

		------------------------------------------------------------------------------------------

		-- Temperature -> Current
		image(cr, 440, 140, settings.appearance.transparency_half, elements_dir .. "temperature")

		local temperature = obj.main.temp
		temperature = string.format("%.0f", (temperature or 0)) .. unit_temperature

		text(cr, 460, 155, settings.appearance.transparency_full, temperature, settings.appearance.default_font_face, 40, CAIRO_FONT_WEIGHT_BOLD) 

		------------------------------------------------------------------------------------------

		-- Temperature -> Details
		image(cr, 435, 175, settings.appearance.transparency_half, elements_dir .. "arrow-right")

		local details = obj.weather[1].description
		text(cr, 445, 180, settings.appearance.transparency_half, details, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)

		------------------------------------------------------------------------------------------

		-- Temperature -> MIN
		image(cr, 435, 195, settings.appearance.transparency_half, elements_dir .. "arrow-down")

		local temp_min = obj.main.temp_min
		temp_min = string.format("%.0f", (temp_min or 0)) .. unit_temperature

		text(cr, 445, 200, settings.appearance.transparency_full, temp_min, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)

		------------------------------------------------------------------------------------------

		-- Temperature -> MAX
		image(cr, 495, 195, settings.appearance.transparency_half, elements_dir .. "arrow-up")

		local temp_max = obj.main.temp_max
		temp_max = string.format("%.0f", (temp_max or 0)) .. unit_temperature

		text(cr, 505, 200, settings.appearance.transparency_full, temp_max, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)

		------------------------------------------------------------------------------------------

		-- Temperature -> Feels like
		image(cr, 555, 195, settings.appearance.transparency_half, elements_dir .. "white-man")

		local feels_like = obj.main.feels_like
		feels_like = string.format("%.0f", (feels_like or 0)) .. unit_temperature

		text(cr, 565, 200, settings.appearance.transparency_full, feels_like, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)
	end
end

return draw