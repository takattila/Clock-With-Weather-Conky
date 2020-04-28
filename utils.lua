local utils = {}

function utils.get_weather_json()
	return conky_parse(
		"${exec curl -s '" .. settings.weather.api_url ..
			"?q=" .. settings.weather.city .. "," .. settings.weather.language_code .. 
			"&lang=" .. settings.weather.lang .. 
			"&units=" .. settings.weather.units .. 
			"&appid=" .. settings.weather.api_key .. 
		"'}"
	)
end

function utils.is_set_api_key(cr)
	if settings.weather.api_key == nil then
		local error_text_1 = "ERROR :("
		text(cr, 0, 40, settings.appearance.transparency_full, error_text_1, settings.appearance.default_font_face, 40, CAIRO_FONT_WEIGHT_BOLD)
		
		local error_text_2 = "The 'OPENWEATHER_API_KEY' environment variable must be exported!"
		text(cr, 0, 70, settings.appearance.transparency_full, error_text_2, settings.appearance.default_font_face, 20, CAIRO_FONT_WEIGHT_normal)
		
		local error_text_3 = "   1. Sign up on http://openweathermap.org to get an API key."
		text(cr, 0, 90, settings.appearance.transparency_full, error_text_3, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)
		
		local error_text_4 = "   2. After the registration Check your e-mail, the API key should be sent!"
		text(cr, 0, 110, settings.appearance.transparency_full, error_text_4, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)
		
		local error_text_5 = "   3. Open a terminal and export the API key:"
		text(cr, 0, 130, settings.appearance.transparency_full, error_text_5, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)
		
		local error_text_6 = "       export OPENWEATHER_API_KEY=<YOUR-API-KEY>"
		text(cr, 0, 150, settings.appearance.transparency_full, error_text_6, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)

		print(
			   "\n" .. error_text_1 
			.. "\n" .. error_text_2 
			.. "\n" .. error_text_3 
			.. "\n" .. error_text_4 
			.. "\n" .. error_text_5 
			.. "\n" .. error_text_6
		)

		return false
	end

	return true
end

function utils.check_api_response_status(cr, weather_json)
	if weather_json ~= "" then
		local obj = json.decode(weather_json)
		
		if obj.cod == 200 then
			return true
		end

		local error_text_1 = "ERROR :("
		text(cr, 0, 40, settings.appearance.transparency_full, error_text_1, settings.appearance.default_font_face, 40, CAIRO_FONT_WEIGHT_BOLD)
		
		local error_text_2 = "- API: " .. obj.message
		text(cr, 0, 70, settings.appearance.transparency_full, error_text_2, settings.appearance.default_font_face, 20, CAIRO_FONT_WEIGHT_normal)
		
		print(
			   "\n" .. error_text_1 
			.. "\n" .. error_text_2
		)
		return false
	end
end

return utils