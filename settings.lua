local settings = {}

settings.appearance = {
    theme = "light",
    icon = {
        set = "dovora",
        transparency = 1.0,
    },
    text = {
        transparency = {
            max = 1.0,
            min = 0.5,
        },
        font = {
            face = "Noto Sans",
            color = "#ffffff",
        },
    },
    background = {
        transparency = 0.0,
        color = "#000000",
    },
}

settings.system = {
    locale = "en_US.UTF-8",
}

settings.weather = {
    city = "Budapest",
    language_code = "hu",
    lang = "hu",
    units = "metric",
    api_key = os.getenv("OPENWEATHER_API_KEY"),
    api_url = "https://api.openweathermap.org/data/2.5/weather",
}

return settings