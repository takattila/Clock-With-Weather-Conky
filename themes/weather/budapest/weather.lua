local settings = {}

settings.weather = {
    city = "Budapest",
    language_code = "hu",
    lang = "hu",
    units = "metric",
    api_key = os.getenv("OPENWEATHER_API_KEY"),
    api_url = "https://api.openweathermap.org/data/2.5/weather",
}

return settings
