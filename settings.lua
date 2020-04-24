local settings = {}

settings.appearance = {
    transparency_full = 1.0,
    transparency_half = 0.5,
    transparency_weather_icon = 1.0,
    default_font_face = "Noto Sans",
    html_text_color = "#ffffff",
}

settings.system = {
    locale = "en_US.UTF-8",
}

settings.weather = {
    city = "Budapest",
    language_code = "hu",
    lang = "en",
    units = "metric",
    api_key = os.getenv("OPENWEATHER_API_KEY"),
    api_url = "https://api.openweathermap.org/data/2.5/weather",
}

return settings