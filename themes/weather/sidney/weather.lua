local settings = {}

settings.weather = {
    city = "Sidney",
    language_code = "au",
    lang = "au",
    units = "imperial",
    api_key = os.getenv("OPENWEATHER_API_KEY"),
    api_url = "https://api.openweathermap.org/data/2.5/weather",
}

return settings