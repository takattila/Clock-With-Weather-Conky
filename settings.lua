local settings = {}

settings.appearance = {
    theme = "light",
    icon = {
        set = "dovora",
        transparency = {
            light = 1.0,
            dark = 0.5,
        },
    },
    font = {
        face = "Noto Sans",
        color = {
            light = "#ffffff",
            dark = "#9e9e9e",
        },
        transparency = {
            light = 1.0,
            dark = 1.0,
        },
    },
    background = {
        transparency = 0.0,
        color = "#000000",
    },
}

settings.system = {
    locale = "en_US.UTF-8",
    hour_format_12 = false,
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