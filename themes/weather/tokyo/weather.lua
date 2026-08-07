local settings = {}

settings.weather = {
    city = "Tokyo",
    language_code = "jp",
    lang = "jp",
    units = "metric",
    api_key = utils.resolve_api_key(),
    api_url = "https://api.openweathermap.org/data/2.5/weather",
}

return settings