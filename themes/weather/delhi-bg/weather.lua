local settings = {}

settings.weather = {
    city = "Delhi",
    language_code = "in",
    lang = "in",
    units = "metric",
    api_key = os.getenv("OPENWEATHER_API_KEY"),
    api_url = "https://api.openweathermap.org/data/2.5/weather",
}

return settings