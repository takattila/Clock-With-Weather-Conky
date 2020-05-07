# Conky Widget with Clock and Weather

![debian](https://img.shields.io/badge/debian%20%5B%2064bit%20%5D-test%20[%20ok%20]-d70751?style=for-the-badge&logo=debian)
![ubuntu](https://img.shields.io/badge/ubuntu%20%5B%2064bit%20%5D-test%20[%20ok%20]-e95420?style=for-the-badge&logo=ubuntu)
![mint](https://img.shields.io/badge/mint%20%5B%2064bit%20%5D-test%20[%20ok%20]-97d953?style=for-the-badge&logo=linux%20mint)
![arch](https://img.shields.io/badge/arch%20%5B%2064bit%20%5D-test%20[%20ok%20]-1793d1?style=for-the-badge&logo=arch%20linux)
![manjaro](https://img.shields.io/badge/manjaro%20%5B%2064bit%20%5D-test%20[%20ok%20]-35bf5c?style=for-the-badge&logo=manjaro)
![suse gnome](https://img.shields.io/badge/suse%20gnome%20%5B%2064bit%20%5D-test%20[%20ok%20]-35bf5c?style=for-the-badge&logo=opensuse)
![suse kde](https://img.shields.io/badge/suse%20kde%20%5B%2064bit%20%5D-test%20[%20ok%20]-35bf5c?style=for-the-badge&logo=opensuse)
![zorin](https://img.shields.io/badge/zorin%20%5B%2064bit%20%5D-test%20[%20ok%20]-239fc2?style=for-the-badge&logo=zorin)
![fedora](https://img.shields.io/badge/fedora%20%5B%2064bit%20%5D-test%20[%20ok%20]-3b90ff?style=for-the-badge&logo=fedora)


- This widget uses [openweathermap.org](https://openweathermap.org) API, to get weather information.
- Easy to customize, supports appearance on **light** and **dark** backgrounds. *(See: [Example Themes](#example-themes))*.
- Supports `12` and `24-hour` clock format.

<table>
    <tr>
        <th>
            On a dark background
        </th>
        <th>
            On a light background
        </th>
    </tr>
    <tr>
        <td>
            <img src="./images/screenshots/Clock-With-Weather-Conky-Themes-Budapest.png">
        </td>
        <td>
            <img src="./images/screenshots/Clock-With-Weather-Conky-Themes-New-York.png">
        </td>
    </tr>
</table>


## Get the OpenWeatherMap API key

- Go to the [openweathermap.org/users/sign_up](https://home.openweathermap.org/users/sign_up) page and create your account.
- After the registration, you should receive your API key **via e-mail**.
- For easier installation, export this API key before running the script below:

  ```bash
  export OPENWEATHER_API_KEY=<YOUR-API-KEY>
  ```

[Back to top](#conky-widget-with-clock-and-weather)

## Installation

You can install it via the command-line with either `wget` or `curl`:

... via wget:

```bash
bash -c "$(wget --no-cache --no-cookies -O- https://raw.githubusercontent.com/takattila/Clock-With-Weather-Conky/v1.0.0/scripts/install.sh)"
```

... via curl:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/takattila/Clock-With-Weather-Conky/v1.0.0/scripts/install.sh)"
```

[Back to top](#conky-widget-with-clock-and-weather)

## Start / stop the widget

### 1. Start the widget

```bash
bash ~/.conky/Clock-With-Weather-Conky/scripts/start.sh <YOUR-API-KEY>
```

[Back to top](#conky-widget-with-clock-and-weather)

### 2. Stop the widget

```bash
bash ~/.conky/Clock-With-Weather-Conky/scripts/stop.sh
```

[Back to top](#conky-widget-with-clock-and-weather)

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

[Back to top](#conky-widget-with-clock-and-weather)

## Wiki

For detailed documentation, please visit the [wiki](https://github.com/takattila/Clock-With-Weather-Conky/wiki) page.

[Back to top](#conky-widget-with-clock-and-weather)

## Example Themes

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-Berlin-Bg.png)

[Back to top](#conky-widget-with-clock-and-weather)

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-Berlin.png)

[Back to top](#conky-widget-with-clock-and-weather)

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-Budapest.png)

[Back to top](#conky-widget-with-clock-and-weather)

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-Delhi-Bg.png)

[Back to top](#conky-widget-with-clock-and-weather)

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-Delhi.png)

[Back to top](#conky-widget-with-clock-and-weather)

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-London.png)

[Back to top](#conky-widget-with-clock-and-weather)

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-Moscow.png)

[Back to top](#conky-widget-with-clock-and-weather)

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-New-York.png)

[Back to top](#conky-widget-with-clock-and-weather)

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-Paris.png)

[Back to top](#conky-widget-with-clock-and-weather)

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-Sidney.png)

[Back to top](#conky-widget-with-clock-and-weather)

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-Tokyo.png)

[Back to top](#conky-widget-with-clock-and-weather)

![themes](./images/screenshots/Clock-With-Weather-Conky-Themes-Wien.png)

[Back to top](#conky-widget-with-clock-and-weather)