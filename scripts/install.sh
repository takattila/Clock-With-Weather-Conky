#!/bin/bash

REPO="Clock-With-Weather-Conky"
BASE_DIR="/home/$(whoami)/.conky"

OPENWEATHER_API_KEY="${OPENWEATHER_API_KEY}"

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

DEFAULT_WEATHER_LUA='
local settings = {}

settings.weather = {
    city = "REPLACE_CITY",
    language_code = "REPLACE_LANGUAGE_CODE",
    lang = "REPLACE_LANG",
    units = "REPLACE_UNITS",
    api_key = os.getenv("OPENWEATHER_API_KEY"),
    api_url = "https://api.openweathermap.org/data/2.5/weather",
}

return settings
'

DESKTOP_LAUNCHER='
[Desktop Entry]
Comment=Clock with Weather Conky widget
Terminal=false
Name=Clock with Weather widget
Exec=bash REPLACE_APP_DIR/scripts/start.sh REPLACE_API_KEY
Type=Application
GenericName[en_GB.UTF-8]=Clock with Weather Conky widget
Icon=REPLACE_APP_DIR/images/theme/light/weather/dovora/01d.png
'

LANG_AND_COUNTRY_CODES="af al ar az bg ca cz da de el en eu fa fi fr gl he hi hr hu id it ja kr la lt mk no nl pl pt pt_br ro ru sv sk sl sp sr th tr ua vi zh_cn zh_tw zu"

C_D=$(echo -en "\e[0m")    # COLOR: DEFAULT
C_Y=$(echo -en "\e[1;93m") # COLOR: YELLOW
C_R=$(echo -en "\e[1;31m") # COLOR: RED
C_U=$(echo -en "\e[1;4m")  # UNDERLINED

echo -ne '\e]11;#000000\e\\' # set default foreground to black
echo -ne '\e]10;#ffffff\e\\' # set default background to #abcdef

function helperReplace() {
    local string=$1
    local from=$2
    local to=$3

    echo "${string//$from/$to}"
}

function helperExistsProgram() {
    local program=$1
    sudo which ${program} &> /dev/null
    echo $?
}

function helperCheckDir() {
    local dir=$1

    if [[ -d "${dir}" ]]; then
        echo 0
    else
        echo 1
    fi
}

function helperCheckout() {
    echo

    cd "${BASE_DIR}"/"${REPO}" || exit
    git checkout v1.0.0 &> /dev/null
}

function helperCloneAndCheckout() {
    echo
    echo -n "- Downloading ${C_Y}${REPO}${C_D} ... "

    {
      git clone https://github.com/takattila/"${REPO}".git \
          "${BASE_DIR}"/"${REPO}"
    } &> /dev/null

    echo "done."

    helperCheckout

    echo -e "- The ${C_Y}'${BASE_DIR}/${REPO}'${C_D} application installed."
}

function helperInArray() {
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

function helperPrompt() {
    local printHelperText=$1
    local defaultAnswer=$2
    shift

    local validAnswersArray=("${@:2}")

    read -p "${printHelperText}" answer

    if [[ -z "${answer}" ]]; then
        echo "${defaultAnswer}"
        return
    fi


    if [[ "${validAnswersArray}" != "NO_VALIDATE" ]]; then

        if [[ "$(helperInArray "${answer}" "${validAnswersArray[@]}")" = "false" ]]; then
            helperPrompt "${printHelperText}" "${defaultAnswer}" "${validAnswersArray[@]}"
            return
        fi

    fi

    echo "${answer}"
}

function helperInstall() {
    local cmd=$1
    shift

    local packages=$@

    if [[ "${packages}" = "UPDATE" ]]; then
        echo -n "  == Running ${C_Y}${cmd}${C_D} ... "
        eval "sudo ${cmd}" &> /dev/null
        echo "done."
        return
    fi

    for package in $(echo ${packages}) ; do
        echo -n "  == Installing ${C_Y}${package}${C_D} ... "
        eval "sudo ${cmd} ${package}" &> /dev/null
        echo "done."
    done
}

function helperInstallConkyByPackman() {
    helperInstall "pacman -Sy --noconfirm" "tolua++"
    
    echo "  == Installing ${C_Y}conky-lua${C_D} ... "
    echo
    rm -rf conky-lua

    git clone https://aur.archlinux.org/conky-lua.git
    cd conky-lua
    makepkg -si PKGBUILD
    cd -

    rm -rf conky-lua
    echo
    echo "  == The ${C_Y}conky-lua${C_D} installation finioshed."
}

function installPrintLogo() {
    printf "${C_Y}"
cat <<-'EOF'
  ____ _            _               _ _   _     
 / ___| | ___   ___| | __ __      _(_) |_| |__  
| |   | |/ _ \ / __| |/ / \ \ /\ / / | __| '_ \ 
| |___| | (_) | (__|   <   \ V  V /| | |_| | | |
 \____|_|\___/ \___|_|\_\   \_/\_/ |_|\__|_| |_|
   __        __         _   _               
   \ \      / /__  __ _| |_| |__   ___ _ __ 
    \ \ /\ / / _ \/ _` | __| '_ \ / _ \ '__|
     \ V  V /  __/ (_| | |_| | | |  __/ |   
      \_/\_/ \___|\__,_|\__|_| |_|\___|_|   

             ... Conky Widget ....
EOF
    printf "${C_D}\n"

}

function installCheckOS() {
    local os="$(uname -s)"
    if [[ "${os}" != "Linux" ]]; then
        echo "${C_R}[ ERROR ]${C_D} The ${C_Y}${os}${C_D} OS is not supported by this script."
        echo
        echo "          If you run this script ${C_Y}on Mac OS${C_D}, please visit this site, for conky installation:"
        echo "          ${C_U}https://github.com/Conky-for-macOS/conky-for-macOS/wiki/How-to-install${C_D}"
        echo
        exit 1
    fi
}

function installSetRootPassword() {
    sudo -p "$(
        echo "- A password is required for installation."
        echo "  Please enter the ${C_Y}root password${C_D}: "
    )" echo -n ""
}

function installEnUsLocale() {
        local en="en_US"
        local utf8="UTF-8"
        local usLocale="${en}.${utf8}"
        local reCfg="dpkg-reconfigure"

        if [[ "$(locale -a | grep -q "${en}.utf8" ; echo $?)" = "1" ]]; then
            if [[ "$(helperExistsProgram "${reCfg}")" = "0" ]]; then
                echo
                echo -en "- Generating ${C_Y}${usLocale}${C_D} locale, this might take a while ... "

                {
                    sudo cp /etc/locale.gen .
                    sudo chown $(whoami) locale.gen
                    echo "${usLocale} ${utf8}" >> locale.gen
                    sudo chown root locale.gen
                    sudo mv -f locale.gen /etc
                    sudo ${reCfg} locales --frontend noninteractive
                } &> /dev/null

                echo "done."
            fi
        fi
}

function installDependencies() {
    local packages="curl gawk git"
    local packagesToInstall=""

    for package in $(echo ${packages}) ; do
        if [[ "$(helperExistsProgram "${package}")" = "1" ]]; then
            packagesToInstall="${packagesToInstall}${package} "
        fi
    done

    if [[ ! -z "${packagesToInstall}" ]]; then
        if [[ "$(helperExistsProgram yum)" = "0" ]]; then
            helperInstall "yum install -y" "epel-release"
            helperInstall "yum install -y" "${packagesToInstall}"
        elif [[ "$(helperExistsProgram apt)" = "0" ]]; then
            helperInstall "apt update -y" "UPDATE"
            helperInstall "apt install -y" "${packagesToInstall}"
        elif [[ "$(helperExistsProgram pacman)" = "0" ]]; then
            helperInstall "pacman -Sy --noconfirm" "${packagesToInstall}"
            helperInstallConkyByPackman
        elif [[ "$(helperExistsProgram zypper)" = "0" ]]; then
            helperInstall "zypper -n in" "${packagesToInstall}"
        elif [[ "$(helperExistsProgram dnf)" = "0" ]]; then
            helperInstall "dnf install -y" "${packagesToInstall}"
        else
            echo
            echo "${C_R}[ ERROR ]${C_D} Can't install dependencies: ${C_Y}install system not known${C_D}"
            echo
            exit 1;
        fi
    fi
}

function installConky() {
    if [[ "$(helperExistsProgram yum)" = "0" ]]; then
        helperInstall "yum install -y" "conky"
    elif [[ "$(helperExistsProgram apt)" = "0" ]]; then
        helperInstall "apt install -y" "conky-all"
    elif [[ "$(helperExistsProgram pacman)" = "0" ]]; then
        helperInstallConkyByPackman
    elif [[ "$(helperExistsProgram zypper)" = "0" ]]; then
        helperInstall "zypper -n in" "conky"
    elif [[ "$(helperExistsProgram dnf)" = "0" ]]; then
        helperInstall "dnf install -y" "conky"
    else
        echo
        echo "${C_R}[ ERROR ]${C_D} Can't install dependencies: ${C_Y}install system not known${C_D}"
        echo
        exit 1;
    fi
}

function installWidgetFromGitHub() {
    local repo_dir="${BASE_DIR}/${REPO}"
    local delete_repo_dir

    if [[ "$(helperCheckDir "${repo_dir}")" = "0" ]]; then
        echo
        echo "- The ${C_Y}'${repo_dir}'${C_D} already exists."
        delete_repo_dir="$(
            helperPrompt "  Do you want to delete it? ${C_Y}[y or n]${C_D}: " "n" "y n"
        )"

        if [[ "${delete_repo_dir}" = "y" ]]; then
            rm -rf "${repo_dir}"
            helperCloneAndCheckout

            return
        fi
        
        helperCheckout
        
        return
    fi

    helperCloneAndCheckout
}

function installFont() {
    local font="NotoSans-Regular.ttf"

    mkdir -p /home/"$(whoami)"/.local/share/fonts
    cp "${BASE_DIR}"/"${REPO}"/fonts/"${font}" /home/"$(whoami)"/.local/share/fonts
    
    echo -e "- The ${C_Y}'${font}'${C_D} font installed."
}

function setupApiKey() {
    local apiKey
    if [[ -z ${OPENWEATHER_API_KEY} ]]; then
        echo
        apiKey="$(
            helperPrompt "- Please enter your ${C_Y}OpenWeatherMap API key${C_D}: " "API_KEY_NOT_GIVEN" "NO_VALIDATE"
        )"
        export OPENWEATHER_API_KEY="${apiKey}"
    fi
}

function setupListThemes() {
    local printWithoutNames=$1
    local i=0 

    for t in $(ls -A themes/appearance) ; do 
        i=$(( i + 1 ))
        if [[ "${printWithoutNames}" ]]; then
            echo "${i} "
        else
            echo "  ${C_Y}${i}.${C_D} ${t}"
        fi
    done
}

function setupListUnits() {
    echo -e "  ${C_Y}1.${C_D} metric (for displaying ${C_Y}Celsius${C_D})"
    echo -e "  ${C_Y}2.${C_D} imperial (for displaying ${C_Y}Fahrenheit${C_D})"
}

function setupGetUnitByNumber() {
    local number=$1
    
    if [[ "$number" = "1" ]]; then
        echo "metric"
        return
    fi

    echo "imperial"
}

function setupGetThemeNameByNumber() {
    local number=$1
    local i=0 

    for t in $(ls -A ${BASE_DIR}/"${REPO}"/themes/appearance) ; do 
        i=$(( i + 1 ))
        if [[ "$i" = "$number" ]]; then
            echo $t
            break
        fi
    done
}

function setupHourFormatByNumber() {
    local number=$1
    
    if [[ "$number" = "12" ]]; then
        echo "true"
        return
    fi

    echo "false"
}

function setupSetWeatherApiVariables() {
    local city
    local languageCode
    local lang
    local unitsNumber
    local units
    local themeNumber
    local theme
    local hourFormat_12_number
    local hourFormat_12
    local themeLua
    local weatherLua

    local themeFile="${BASE_DIR}/${REPO}/theme.lua"
    local weatherFile="${BASE_DIR}/${REPO}/themes/weather/default/weather.lua"

    echo
    city="$(
        helperPrompt "- Please enter your ${C_Y}city${C_D} name ${C_Y}[e.g.: budapest, wien or london]${C_D}: " "budapest" "NO_VALIDATE"
    )"
    city="$(gawk '{print tolower($0);}' <<< "${city}")"
    city="$(gawk '{print toupper($0);}' <<< "${city:0:1}")${city:1}"

    echo
    echo "- Please enter your ${C_Y}country code${C_D}."
    echo "  This one is to specify in which country the given ${C_Y}city is located${C_D}."
    echo "  Check your country code here: ${C_U}https://openweathermap.org/current#multi${C_D}"
    echo
    languageCode="$(
        helperPrompt "  ${C_Y}[eg.: hu, gb, us]${C_D}: " "hu" "${LANG_AND_COUNTRY_CODES}"
    )"

    echo
    echo "- Please enter your ${C_Y}language code${C_D}."
    echo "  In what language do you want to ${C_Y}display the weather details?${C_D}"
    echo "  Check your language code here: ${C_U}https://openweathermap.org/current#multi${C_D}"
    echo
    lang="$(
        helperPrompt "  ${C_Y}[eg.: hu, gb, us]${C_D}: " "hu" "${LANG_AND_COUNTRY_CODES}"
    )"

    echo
    echo "- Please enter which temperature unit do you want to use: "
    setupListUnits
    echo
    unitsNumber="$(
        helperPrompt "  ${C_Y}[1 or 2]${C_D} ?: " "1" "1 2"
    )"
    units=$(setupGetUnitByNumber "${unitsNumber}")

    echo
    setupListThemes
    echo
    themeNumber="$(
        helperPrompt "- Enter choosen ${C_Y}theme${C_D} number ${C_Y}[eg.: 11]${C_D}: " "11" "$(setupListThemes 1)"
    )"
    theme=$(setupGetThemeNameByNumber "${themeNumber}")

    echo
    hourFormat_12_number="$(
        helperPrompt "- What type of ${C_Y}hour format${C_D} do you want to use ${C_Y}[12 or 24]${C_D} ?: " "24" "12 24"
    )"
    hourFormat_12=$(setupHourFormatByNumber "${hourFormat_12_number}")

    themeLua=$(helperReplace "${DEFAULT_THEME_LUA}" "REPLACE_APPEARANCE" "${theme}")
    themeLua=$(helperReplace "${themeLua}" "REPLACE_WEATHER" "default")
    themeLua=$(helperReplace "${themeLua}" "REPLACE_HOUR_FORMAT_12" "${hourFormat_12}")

    weatherLua=$(helperReplace "${DEFAULT_WEATHER_LUA}" "REPLACE_CITY" "${city}")
    weatherLua=$(helperReplace "${weatherLua}" "REPLACE_LANGUAGE_CODE" "${languageCode}")
    weatherLua=$(helperReplace "${weatherLua}" "REPLACE_LANG" "${lang}")
    weatherLua=$(helperReplace "${weatherLua}" "REPLACE_UNITS" "${units}")

    echo "${themeLua}" > "${themeFile}"
    echo "${weatherLua}" > "${weatherFile}"
}

function startApplication() {
    bash "${BASE_DIR}"/"${REPO}"/scripts/start.sh "${OPENWEATHER_API_KEY}" &> /dev/null

    echo
    echo "- Starting: ${C_Y}bash ${BASE_DIR}/${REPO}/scripts/start.sh ${OPENWEATHER_API_KEY}${C_D}"

    echo
    echo "- Conky widget started. - ${C_Y}Bye! :-)${C_D}"
}

function createDesktopIcon() {
    local launcherPath
    local launcher

    launcherPath="$(xdg-user-dir DESKTOP)/Clock with Weather Conky widget.desktop"

    launcher=$(helperReplace "${DESKTOP_LAUNCHER}" "REPLACE_APP_DIR" "${BASE_DIR}/${REPO}")
    launcher=$(helperReplace "${launcher}" "REPLACE_API_KEY" "${OPENWEATHER_API_KEY}")

    echo "${launcher}" > "${launcherPath}"
    chmod 755 "${launcherPath}"

    echo
    echo "- Desktop icon created: ${C_Y}${launcherPath}${C_D}"
}

function main() {
    clear

    installPrintLogo
    installCheckOS
    installSetRootPassword
    installDependencies
    installConky
    installEnUsLocale
    installWidgetFromGitHub
    installFont

    setupApiKey
    setupSetWeatherApiVariables

    createDesktopIcon
    startApplication
}

main
