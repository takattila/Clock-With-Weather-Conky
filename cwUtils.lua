local utils = {}

-- The OpenWeatherMap API key is NOT stored in a theme file (so it never ends
-- up in the repository). It is resolved in this order:
--   1. the OPENWEATHER_API_KEY environment variable,
--   2. a local, git-ignored file .api_key in the widget folder (first line),
--   3. nil (the widget shows an API key error message).
function utils.resolve_api_key()
	local key = os.getenv("OPENWEATHER_API_KEY")
	if key and key ~= "" then
		return key
	end

	local f = io.open(".api_key", "r")
	if f then
		key = f:read("*l")
		f:close()
		if key and key ~= "" then
			return key
		end
	end

	return nil
end

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
		"${execi 600 curl -s '" .. settings.weather.api_url ..
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
		
		local error_text_2 = "The OpenWeatherMap API key is missing!"
		text(cr, 0, 70, settings.appearance.font.transparency.light, error_text_2, settings.appearance.font.face, 20, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
		
		local error_text_3 = "   1. Sign up on http://openweathermap.org to get an API key."
		text(cr, 0, 90, settings.appearance.font.transparency.light, error_text_3, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
		
		local error_text_4 = "   2. Set it via the environment variable:"
		text(cr, 0, 110, settings.appearance.font.transparency.light, error_text_4, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
		
		local error_text_5 = "       export OPENWEATHER_API_KEY=<YOUR-API-KEY>"
		text(cr, 0, 130, settings.appearance.font.transparency.light, error_text_5, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
		
		local error_text_6 = "   3. Or create the git-ignored file .api_key in the widget folder:"
		text(cr, 0, 150, settings.appearance.font.transparency.light, error_text_6, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)
		
		local error_text_7 = "       printf '<YOUR-API-KEY>\\n' > .api_key && chmod 600 .api_key"
		text(cr, 0, 170, settings.appearance.font.transparency.light, error_text_7, settings.appearance.font.face, 15, CAIRO_FONT_WEIGHT_NORMAL, settings.appearance.font.color.dark)

		print(
			   "\n" .. error_text_1 
			.. "\n" .. error_text_2 
			.. "\n" .. error_text_3 
			.. "\n" .. error_text_4 
			.. "\n" .. error_text_5 
			.. "\n" .. error_text_6
			.. "\n" .. error_text_7
		)

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
