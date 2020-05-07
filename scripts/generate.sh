#!/bin/bash

# Arguments
while [[ ! $# -eq 0 ]]; do
    case "$1" in
    	# Optional parameters
        --screenshots | -s)
            shift
            SCREENSHOTS=$1
            ;;
        --markdown | -m)
            shift
            MARKDOWN=$1
            ;;
	esac
	shift
done

DEFAULT_THEME_LUA='
  local settings = {}
  
  settings = {
      appearance = { 
          name = "REPLACE_APPEARANCE",
      },
      weather = {
          name = "REPLACE_WEATHER",
      },
      system = {
          hour_format_12 = REPLACE_HOUR_FORMAT_12,
          locale = "en_US.UTF-8",
      },
  }
  
  return settings
'

DEFAULT_MARKDOWN='
<details>
<summary>
Weather of <code>REPLACE_WEATHER</code> city with <code>REPLACE_APPEARANCE</code> text
</summary>

![REPLACE_WEATHER-REPLACE_APPEARANCE](../images/screenshots/REPLACE_WEATHER-REPLACE_APPEARANCE.png)

- #### Content of the `themes/weather/REPLACE_WEATHER/weather.lua` file: [click here](../themes/weather/REPLACE_WEATHER/weather.lua).

- #### Content of the `themes/appearance/REPLACE_APPEARANCE/appearance.lua` file: [click here](../themes/appearance/REPLACE_APPEARANCE/appearance.lua).

- #### Content of the [theme.lua](../theme.lua) file:

  ```lua
  REPLACE_THEME_LUA_CONTENT
  ```

[Back to top](#example-themes)

</details>

'

function inArray() {
    local what=$1
    shift

    local validAnswersArray=($@)
    local match=false

    for str in "${validAnswersArray[@]}" ; do
        if [[ "${str}" = "${what}" ]]; then
            match=true
            break
        fi
    done

    echo ${match}
}

function createArray() {
    local fromDir=$1
    local exclude=$2
    local negate=$3
    local array=()
    local arrayNegate=()
    local i=0

    for e in $(ls -A "${fromDir}") ; do
        if [[ "$e" != *"${exclude}"* ]]; then
            array[$i]=$e
            i=$(( i + 1 ))
        else
            arrayNegate[$i]=$e
            i=$(( i + 1 ))
        fi
    done

    [[ -z $negate ]] && echo "${array[@]}"
    [[ -n $negate ]] && echo "${arrayNegate[@]}"
}

function replace() {
    local string=$1
    local from=$2
    local to=$3

    echo "${string//$from/$to}"
}

function generateScreenshots() {
    if [[ -n "${SCREENSHOTS}" ]]; then
        local i
        local appearanceArray=($(createArray "themes/appearance" "-bg" "$1"))
        local weatherArray=($(createArray "themes/weather" "default"))
        local themeLua
        local themeFile="theme.lua"
        local color

        local hour_format_12_array=(
            "delhi"
            "delhi-bg"
            "london"
            "london-bg"
            "new-york"
            "new-york-bg"
            "sidney"
            "sidney-bg"
        )

        i=0
        for appearance in "${appearanceArray[@]}" ; do

            hourFormat_12=false
            weather=${weatherArray[$i]}

            if [[ "$(inArray "${weather}" "${hour_format_12_array[@]}")" = "true" ]]; then
                hourFormat_12="true"
            fi

            themeLua=$(replace "${DEFAULT_THEME_LUA}" "REPLACE_APPEARANCE" "${appearance}")
            themeLua=$(replace "${themeLua}" "REPLACE_WEATHER" "${weather}")
            themeLua=$(replace "${themeLua}" "REPLACE_HOUR_FORMAT_12" "${hourFormat_12}")

            pngFile="images/screenshots/${weather}-${appearance}.png"

            echo -n "- Generating: ${pngFile} ... "

            {
                killall conky

                [[ ${appearance} == *"light"* ]] && color="#2e3436" || color="#babdb6"
                gsettings set org.gnome.desktop.background primary-color "$(echo "${color}")" 

                echo "${themeLua}" > "${themeFile}"
                conky -c app.cfg &

                sleep 3
                shutter -s 1690,305,780,290 -o images/screenshots/"${weather}-${appearance}".png -e

                sleep1
            } &> /dev/null

            echo "done."

            i=$(( i + 1 ))
        done

        killall conky
        git checkout "${themeFile}"
    fi
}

function generateMarkdown() {
    if [[ -n "${MARKDOWN}" ]]; then
        local i
        local appearanceArray=($(createArray "themes/appearance" "-bg" "$1"))
        local weatherArray=($(createArray "themes/weather" "default"))
        local themeLua
        local markdownContent
        local path="themes"
        local markdownFile="themes.md"

        mkdir -p "${path}"
        if [[ -z ${1} ]]; then
            echo "# Example themes"                          >  "${path}"/"${markdownFile}"
            echo "The available themes are listed bellow."   >> "${path}"/"${markdownFile}"
            echo "<br>**Click an item** to see the details!" >> "${path}"/"${markdownFile}"
        fi

        i=0
        for appearance in "${appearanceArray[@]}" ; do

            hourFormat_12=true
            weather=${weatherArray[$i]}

            echo -n "- Generating: ${weather} with ${appearance} theme ... "

            themeLua=$(replace "${DEFAULT_THEME_LUA}" "REPLACE_APPEARANCE" "${appearance}")
            themeLua=$(replace "${themeLua}" "REPLACE_WEATHER" "${weather}")
            themeLua=$(replace "${themeLua}" "REPLACE_HOUR_FORMAT_12" "${hourFormat_12}")

            markdownContent=$(replace "${DEFAULT_MARKDOWN}" "REPLACE_APPEARANCE" "${appearance}")
            markdownContent=$(replace "${markdownContent}" "REPLACE_WEATHER" "${weather}")
            markdownContent=$(replace "${markdownContent}" "REPLACE_THEME_LUA_CONTENT" "${themeLua}")
            
            echo "${markdownContent}" >> "${path}"/"${markdownFile}"

            echo "done."

            i=$(( i + 1 ))
        done
    fi
}

function main() {
    generateScreenshots
    generateScreenshots with-background

    generateMarkdown
    generateMarkdown with-background
}

main
