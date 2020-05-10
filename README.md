# Conky widget with clock and current weather report

[![Version](https://img.shields.io/badge/dynamic/json.svg?label=version&url=https://api.github.com/repos/takattila/Clock-With-Weather-Conky/releases/latest&query=tag_name)](https://github.com/takattila/Clock-With-Weather-Conky/releases)
[![Wiki](https://img.shields.io/badge/wiki-docs-orange)](https://github.com/takattila/Clock-With-Weather-Conky/wiki)


- This widget uses [openweathermap.org](https://openweathermap.org) API, to get weather information.
- Easy to customize, supports appearance on **light** and **dark** backgrounds. *(See: [Example Themes](./themes/themes.md))*.
- Supports `12` and `24-hour` clock format.

<table>
    <tr>
        <th>
            Dark text with light background
        </th>
        <th>
            Light text with dark background
        </th>
    </tr>
    <tr>
        <td>
            <img src="./images/screenshots/budapest-dark-blue.png">
        </td>
        <td>
            <img src="./images/screenshots/new-york-light-bg.png">
        </td>
    </tr>
</table>

- A list of successful tests can be found [here](TESTS.md).


## Get the OpenWeatherMap API key

- Go to the [openweathermap.org/users/sign_up](https://home.openweathermap.org/users/sign_up) page and create your account.
- After the registration, you should receive your API key **via e-mail**.
- For easier installation, export this API key before running the script below:

  ```bash
  export OPENWEATHER_API_KEY=<YOUR-API-KEY>
  ```

[Back to top](#conky-widget-with-clock-and-current-weather-report)

## Installation

You can install it via the command-line with either `wget` or `curl`:

... via wget:

```bash
bash -c "$(wget--no-check-certificate --no-cache --no-cookies -O- https://raw.githubusercontent.com/takattila/Clock-With-Weather-Conky/v1.0.0/scripts/install.sh)"
```

... via curl:

```bash
bash -c "$(curl -fsSLk https://raw.githubusercontent.com/takattila/Clock-With-Weather-Conky/v1.0.0/scripts/install.sh)"
```

[Back to top](#conky-widget-with-clock-and-current-weather-report)

## Start / stop the widget

### 1. Start the widget

```bash
bash ~/.conky/Clock-With-Weather-Conky/scripts/start.sh <YOUR-API-KEY>
```

[Back to top](#conky-widget-with-clock-and-current-weather-report)

### 2. Stop the widget

```bash
bash ~/.conky/Clock-With-Weather-Conky/scripts/stop.sh
```

[Back to top](#conky-widget-with-clock-and-current-weather-report)

## Change settings after installation

```bash
bash ~/.conky/Clock-With-Weather-Conky/scripts/setup.sh
```

Use the above command to **change** the following **settings**:

- city
- country code
- language code
- temperature unit:
  1. metric (for displaying Celsius)
  2. imperial (for displaying Fahrenheit)
- theme number
- hour format (12 or 24)
- window alignment and position

[Back to top](#conky-widget-with-clock-and-current-weather-report)

## Wiki

For detailed documentation, please visit the [wiki](https://github.com/takattila/Clock-With-Weather-Conky/wiki) page.

[Back to top](#conky-widget-with-clock-and-current-weather-report)

## Example Themes

Click [here to see](./themes/themes.md) the available example themes!

[Back to top](#conky-widget-with-clock-and-current-weather-report)