local settings = {}

settings.weather = {
    city = "London",
    language_code = "gb",
    lang = "gb",
    units = "imperial",
    api_key = utils.resolve_api_key(),
    api_url = "https://api.openweathermap.org/data/2.5/weather",
}

return settings