local utils = {}

function city_encode(str)
  if str then
    str = string.gsub(str, "([^%w%-%.%_%~ ])", function(c)
      return string.format("%%%02X", string.byte(c))
    end)
    str = string.gsub(str, " ", "%%20")
  end
  return str
end

function utils.get_weather_json()
	return conky_parse(
		"${exec curl -s '" .. settings.weather.api_url ..
			"?q=" .. city_encode(settings.weather.city) .. "," .. settings.weather.language_code .. 
			"&lang=" .. settings.weather.lang .. 
			"&units=" .. settings.weather.units .. 
			"&appid=" .. settings.weather.api_key .. 
		"'}"
	)
end

function utils.is_set_api_key(cr)
	if settings.weather.api_key == nil then
		local error_text_1 = "ERROR :("
		text(cr, 0, 40, settings.appearance.font.transparency.light, error_text_1, settings.appearance.font.face, 40, CAIRO_FONT_WEIGHT_BOLD, settings.appearance.font.color.light)
		
		local error_text_2 = "The 'OPENWEATHER_API_KEY' environment variable must be exported!"
		text(cr, 0, 70, settings.appearance.font.transparency.light, error_text_2, settings.appearance.font.face, 20, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
		
		local error_text_3 = "   1. Sign up on http://openweathermap.org to get an API key."
		text(cr, 0, 90, settings.appearance.font.transparency.light, error_text_3, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
		
		local error_text_4 = "   2. After the registration Check your e-mail, the API key should be sent!"
		text(cr, 0, 110, settings.appearance.font.transparency.light, error_text_4, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
		
		local error_text_5 = "   3. Open a terminal and export the API key:"
		text(cr, 0, 130, settings.appearance.font.transparency.light, error_text_5, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
		
		local error_text_6 = "       export OPENWEATHER_API_KEY=<YOUR-API-KEY>"
		text(cr, 0, 150, settings.appearance.font.transparency.light, error_text_6, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)

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

function utils.check_api_response_status(cr, obj)
	if obj.cod == 200 then
		return true
	end

	local error_text_1 = "ERROR :("
	text(cr, 0, 40, settings.appearance.font.transparency.light, error_text_1, settings.appearance.font.face, 40, CAIRO_FONT_WEIGHT_BOLD, settings.appearance.font.color.light)
	
	local error_text_2 = "- OpenWeatherMap API response: " .. obj.message
	text(cr, 0, 70, settings.appearance.font.transparency.light, error_text_2, settings.appearance.font.face, 20, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
	
	print(
		   "\n" .. error_text_1 
		.. "\n" .. error_text_2
	)
	
	return false
end

return utils
