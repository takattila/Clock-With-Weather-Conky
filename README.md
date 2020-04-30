# Conky Widget with Clock and Weather

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

## Table of Contents

* [Installation](#installation)
   * [1. Install conky and other dependencies](#1-install-conky-and-other-dependencies)
      * [On Debian based systems](#on-debian-based-systems)
      * [On CentOS](#on-centos)
      * [On ArchLinux](#on-archlinux)
      * [On SuseLinux](#on-suselinux)
      * [On Mac](#on-mac)
   * [2. Clone repository](#2-clone-repository)
   * [3. Install font](#3-install-font)
* [First setup](#first-setup)
   * [1. Get the OpenWeatherMap API key](#1-get-the-openweathermap-api-key)
   * [2. Change your location](#2-change-your-location)
* [Start / stop the widget](#start--stop-the-widget)
   * [1. Start the widget](#1-start-the-widget)
   * [2. Stop the widget](#2-stop-the-widget)
* [Configuration](#configuration)
   * [Window settings](#window-settings)
   * [Theme settings](#theme-settings)
      * [Appearance](#appearance)
      * [Weather](#weather)
* [Example Themes](#example-themes)
* [Convert weather icons to dark](#convert-weather-icons-to-dark)
   * [Install imagemagic](#install-imagemagic)
   * [Run the command](#run-the-command)


## Installation

### 1. Install conky and other dependencies

#### On Debian based systems

```bash
sudo apt update
sudo apt install conky-all curl git
conky --version
```

[Back to top](#conky-widget-with-clock-and-weather)

#### On CentOS

```bash
sudo yum install -y epel-release
sudo yum install -y conky curl git
```

[Back to top](#conky-widget-with-clock-and-weather)

#### On ArchLinux

```bash
sudo pacman -Sy --noconfirm conky curl git
```

[Back to top](#conky-widget-with-clock-and-weather)

#### On SuseLinux

```bash
sudo zypper -n in conky curl git
```

[Back to top](#conky-widget-with-clock-and-weather)

#### On Mac

You can find the installation steps on [this page](https://github.com/Conky-for-macOS/conky-for-macOS/wiki/How-to-install).

[Back to top](#conky-widget-with-clock-and-weather)

### 2. Clone repository

```bash
git clone https://github.com/takattila/Clock-With-Weather-Conky.git ~/.conky/Clock-With-Weather-Conky
```

[Back to top](#conky-widget-with-clock-and-weather)

### 3. Install font

If you don't have `Noto Sans Regular` font *(usually on Ubuntu)* 
you can install it as the followings:
  ```bash
  mkdir -p ~/.local/share/fonts
  cp ~/.conky/Clock-With-Weather-Conky/fonts/NotoSans-Regular.ttf ~/.local/share/fonts
  ls ~/.local/share/fonts
  ```

[Back to top](#conky-widget-with-clock-and-weather)

## First setup

### 1. Get the OpenWeatherMap API key

- Go to the [openweathermap.org/users/sign_up](https://home.openweathermap.org/users/sign_up) page and create your account.
- After the registration, you should receive your API key **via e-mail**.

[Back to top](#conky-widget-with-clock-and-weather)

### 2. Change your location

- First, you should **change your language and location** in the default weather settings file: [themes/weather/default/weather.lua](./themes/weather/default/weather.lua).

  ```
  city = "Budapest",    # Which city's data do you want to be displayed?
  language_code = "hu", # Check it here: https://openweathermap.org/current#multi
  lang = "hu",          # Details will be displayed in this language.
  units = "metric",     # Units: metric, imperial.
  ```

- You can also choose a **pre-defined** location, which can be found [here](./themes/weather).

- **More info** can be found under: [Theme settings / Weather](#weather) section.

[Back to top](#conky-widget-with-clock-and-weather)

## Start / stop the widget

### 1. Start the widget

```bash
bash ~/.conky/Clock-With-Weather-Conky/start.sh <YOUR-API-KEY>
```

[Back to top](#conky-widget-with-clock-and-weather)

### 2. Stop the widget

```bash
bash ~/.conky/Clock-With-Weather-Conky/stop.sh
```

[Back to top](#conky-widget-with-clock-and-weather)

## Configuration

### Window settings

By editing the [app.cfg](app.cfg), you can modify the widget's window settings:

- Size: `minimum_width, minimum_height`
- Background: `background`
- Border: `border_width, border_inner_margin, border_outer_margin, draw_borders, draw_graph_borders`
- Alignment: `alignment`

### Theme settings

- You can easily modify the theme of the widget, by editing the [theme.lua](theme.lua).

#### Appearance

- Edit the `appearance.name` section in the [theme.lua](theme.lua):

  ```lua
  appearance = { 
    name = "light", -- Change it for example: 'dark-green' or 'light-orange'
  },
  ```

- The available themes are listed [here](./themes/appearance).

#### Weather

- Some weather locations are already defined [here](./themes/weather), if you want to use one of them, then simply edit the `weather.name` section in the [theme.lua](theme.lua):

  ```lua
  weather = {
    name = "default", -- You can change it for example: 'new-york', 'london' or 'tokyo'
  },
  ```

- You can **define your own location** as well, by editing the default weather settings file: [themes/weather/default/weather.lua](./themes/weather/default/weather.lua).

[Back to top](#conky-widget-with-clock-and-weather)

#### System

- Set the `hour_format_12` variable to `true` in the [theme.lua](theme.lua) if you want to use **12-hour formatted** clock (AM / PM):

  ```lua
  system = {
      hour_format_12 = true, -- If you set to false, a 24-hour formatted clock will be displayed
  },
  ```

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

## Convert weather icons to dark

If you want to add your custom weather icons, you can put them under `images/theme/light/weather/` directory.
After that, you can convert these icons to dark by `imagemagic` tool.

### Install imagemagic

You can download binaries from [here](https://www.imagemagick.org/script/download.php#unix).

[Back to top](#conky-widget-with-clock-and-weather)

### Run the command

```bash
cd ~/.conky/Clock-With-Weather-Conky

image_dir="monochrome"
light_dir="images/theme/light/weather/${image_dir}"
dark_dir="images/theme/dark/weather/${image_dir}"

mkdir -p $dark_dir

for f in $(ls $light_dir) ; do
    convert "${light_dir}/${f}" \
        -colorspace HSI \
        -channel B \
        -level 100,0% +channel \
        -colorspace sRGB \
    "${dark_dir}/${f}"
done
```

[Back to top](#conky-widget-with-clock-and-weather)
