#!/bin/bash

# Arguments
while [[ ! $# -eq 0 ]]; do
    case "$1" in
    	# Optional parameters
        --from-install | -f)
            shift
            FROM_INSTALL=$1
            ;;
        --api-key | -a)
            shift
            ARG_API_KEY=$1
            ;;
        --city | -c)
            shift
            ARG_CITY=$1
            ;;
        --language-code | -lc)
            shift
            ARG_LANGUAGE_CODE=$1
            ;;
        --lang | -la)
            shift
            ARG_LANG=$1
            ;;
        --units-number | -u)
            shift
            ARG_UNITS_NUMBER=$1
            ;;
        --theme-number | -t)
            shift
            ARG_THEME_NUMBER=$1
            ;;
        --hour-format-12-number | -hf)
            shift
            ARG_HOUR_FORMAT_12_NUMBER=$1
            ;;
        --window-alignment-number | -wa)
            shift
            ARG_WINDOW_ALIGMENT_NUMBER=$1
            ;;
        --window-position-x-number | -wx)
            shift
            ARG_WINDOW_POSITION_X=$1
            ;;
        --window-position-y-number | -wy)
            shift
            ARG_WINDOW_POSITION_Y=$1
            ;;
	esac
	shift
done

DEFAULT_OPENWEATHER_API_KEY="$(    [[ -n "${ARG_API_KEY}" ]]                 && echo "${ARG_API_KEY}"                || echo "${OPENWEATHER_API_KEY}" )"
DEFAULT_CITY="$(                   [[ -n "${ARG_CITY}" ]]                    && echo "${ARG_CITY}"                   || echo "budapest" )"
DEFAULT_LANGUAGE_CODE="$(          [[ -n "${ARG_LANGUAGE_CODE}" ]]           && echo "${ARG_LANGUAGE_CODE}"          || echo "hu" )"
DEFAULT_LANG="$(                   [[ -n "${ARG_LANG}" ]]                    && echo "${ARG_LANG}"                   || echo "hu" )"
DEFAULT_UNITS_NUMBER="$(           [[ -n "${ARG_UNITS_NUMBER}" ]]            && echo "${ARG_UNITS_NUMBER}"           || echo "1" )"
DEFAULT_THEME_NUMBER="$(           [[ -n "${ARG_THEME_NUMBER}" ]]            && echo "${ARG_THEME_NUMBER}"           || echo "11" )"
DEFAULT_HOUR_FORMAT_12_NUMBER="$(  [[ -n "${ARG_HOUR_FORMAT_12_NUMBER}" ]]   && echo "${ARG_HOUR_FORMAT_12_NUMBER}"  || echo "24" )"
DEFAULT_WINDOW_ALIGMENT_NUMBER="$( [[ -n "${ARG_WINDOW_ALIGMENT_NUMBER}" ]]  && echo "${ARG_WINDOW_ALIGMENT_NUMBER}" || echo "9" )"
DEFAULT_WINDOW_POSITION_X="$(      [[ -n "${ARG_WINDOW_POSITION_X}" ]]       && echo "${ARG_WINDOW_POSITION_X}"      || echo "0" )"
DEFAULT_WINDOW_POSITION_Y="$(      [[ -n "${ARG_WINDOW_POSITION_Y}" ]]       && echo "${ARG_WINDOW_POSITION_Y}"      || echo "0" )"

REPO="Clock-With-Weather-Conky"
BASE_DIR="/home/$(whoami)/.conky"

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

DEFAULT_CONKY_CONFIG='
	conky.config = {
	update_interval = 1,

	background = false,
	alignment = "REPLACE_CONFIG_ALIGNMENT",

	border_width = 10,
	border_inner_margin = 0,
	border_outer_margin = 0,

	draw_borders = false,
	draw_graph_borders = false,

	minimum_width = 745,
	minimum_height = 250,

	gap_x = REPLACE_CONFIG_POSITION_X,
	gap_y = REPLACE_CONFIG_POSITION_Y,

	override_utf8_locale = true,

	double_buffer = true,
	no_buffers = true,

	text_buffer_size = 2048,
	imlib_cache_size = 0,

	own_window = true,
	own_window_type = "normal",
	own_window_transparent = true,
	own_window_argb_visual = true,
	own_window_hints = "undecorated,below,sticky,skip_taskbar,skip_pager",

	draw_shades = true,
	draw_outline = false,

	use_xft = true,
	xftalpha = 0.5,

	uppercase = false,

	lua_load = "main.lua",
	lua_draw_hook_pre = "main",
};

conky.text = [[ ]];
'

DESKTOP_LAUNCHER='
[Desktop Entry]
Comment=Start - Clock with Weather Conky widget
Terminal=false
Name=[ Start ] Clock with Weather widget
Exec=bash -c "REPLACE_APP_DIR/scripts/start.sh REPLACE_API_KEY"
Type=Application
GenericName[en_GB.UTF-8]=Clock with Weather Conky widget
Icon=REPLACE_APP_DIR/images/theme/light/weather/dovora/01d.png
'

DESKTOP_LAUNCHER_SETUP='
[Desktop Entry]
Comment=Setup - Clock with Weather Conky widget
Terminal=true
Name=[ Setup ] Clock with Weather widget
Exec=bash -c "REPLACE_APP_DIR/scripts/setup.sh -a REPLACE_API_KEY -c REPLACE_CITY -lc REPLACE_LANGUAGE_CODE -la REPLACE_LANG -u REPLACE_UNITS_NUMBER -t REPLACE_THEME_NUMBER -hf REPLACE_HOUR_FORMAT_12_NUMBER -wa REPLACE_CONFIG_ALIGNMENT -wx REPLACE_CONFIG_POSITION_X -wy REPLACE_CONFIG_POSITION_Y"
Type=Application
GenericName[en_GB.UTF-8]=Clock with Weather Conky widget setup
Icon=REPLACE_APP_DIR/images/setup.png
'

LANGUAGE_CODES="af al ar az bg ca cz da de el en eu fa fi fr gl he hi hr hu id it ja kr la lt mk no nl pl pt pt_br ro ru sv sk sl sp sr th tr ua vi zh_cn zh_tw zu"
COUNTRY_CODES="ad ae af ag ai al am ao aq ar as at au aw ax az ba bb bd be bf bg bh bi bj bl bm bn bo bq br bs bt bv bw by bz ca cc cd cf cg ch ci ck cl cm cn co cr cu cv cw cx cy cz de dj dk dm do dz ec ee eg eh er es et fi fj fk fm fo fr ga gb gd ge gf gg gh gi gl gm gn gp gq gr gs gt gu gw gy hk hm hn hr ht hu id ie il im in io iq ir is it je jm jo jp ke kg kh ki km kn kp kr kw ky kz la lb lc li lk lr ls lt lu lv ly ma mc md me mf mg mh mk ml mm mn mo mp mq mr ms mt mu mv mw mx my mz na nc ne nf ng ni nl no np nr nu nz om pa pe pf pg ph pk pl pm pn pr ps pt pw py qa re ro rs ru rw sa sb sc sd se sg sh si sj sk sl sm sn so sr ss st sv sx sy sz tc td tf tg th tj tk tl tm tn to tr tt tv tw tz ua ug um us uy uz va vc ve vg vi vn vu wf ws ye yt za zm zw"

ALIGNMENTS_ARRAY=(
    "top_left"
    "top_right"
    "top_middle"
    "bottom_left"
    "bottom_right"
    "bottom_middle"
    "middle_left"
    "middle_right"
    "middle_middle"
)

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
        if [[ "${defaultAnswer}" = "EMPTY_ANSWER_NOT_ALLOWED" ]]; then
            helperPrompt "${printHelperText}" "${defaultAnswer}" "${validAnswersArray[@]}"
            return
        fi
        echo "${defaultAnswer}"
        return
    fi

    if [[ "${validAnswersArray}" = "VALIDATE_NUMBER" ]]; then
        if ! [[ ${answer} =~ ^[-0-9]+$ ]]; then
            helperPrompt "${printHelperText}" "${defaultAnswer}" "${validAnswersArray[@]}"
            return
        fi
        echo "${answer}"
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

function setupPrintLogo() {
    clear

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

function setupChDir() {
    cd ${BASE_DIR}/${REPO}
}

function setupApiKey() {
    local apiKey
    if [[ -z ${DEFAULT_OPENWEATHER_API_KEY} ]]; then
        echo
        echo "- Please enter your ${C_Y}OpenWeatherMap API key${C_D}."
        echo "  If you don't have it yet, ${C_Y}you can get it from here${C_D}:"
        echo
        echo "  ${C_U}https://home.openweathermap.org/users/sign_up${C_D}"
        echo

        apiKey="$(
            helperPrompt "  your ${C_Y}API key${C_D}: " "EMPTY_ANSWER_NOT_ALLOWED" "NO_VALIDATE"
        )"
        export DEFAULT_OPENWEATHER_API_KEY="${apiKey}"
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

function setupListConfigAlignments() {
    local printWithoutNames=$1
    local i=0

    for a in "${ALIGNMENTS_ARRAY[@]}" ; do
        i=$(( i + 1 ))
        if [[ "${printWithoutNames}" ]]; then
            echo "${i} "
        else
            echo -e "  ${C_Y}${i}.${C_D} ${a}"
        fi
    done
}

function setupGetConfigAlignmentByNumber() {
    local number=$1
    local i=0 

    for a in "${ALIGNMENTS_ARRAY[@]}" ; do
        i=$(( i + 1 ))
        if [[ "$i" = "$number" ]]; then
            echo $a
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
        helperPrompt "- Please enter your ${C_Y}city${C_D} name ${C_Y}[e.g.: budapest, wien or london]${C_D}: " "${DEFAULT_CITY}" "NO_VALIDATE"
    )"
    city="$(gawk '{print tolower($0);}' <<< "${city}")"
    city="$(gawk '{print toupper($0);}' <<< "${city:0:1}")${city:1}"
    DEFAULT_CITY="${city}"

    echo
    echo "- Please enter your ${C_Y}country code${C_D}."
    echo "  This one is to specify in which country the given ${C_Y}city is located${C_D}."
    echo "  Check your country code here: ${C_U}https://www.iban.com/country-codes${C_D}"
    echo
    languageCode="$(
        helperPrompt "  ${C_Y}[e.g.: hu, gb, us]${C_D}: " "${DEFAULT_LANGUAGE_CODE}" "${COUNTRY_CODES}"
    )"
    DEFAULT_LANGUAGE_CODE="${languageCode}"

    echo
    echo "- Please enter your ${C_Y}language code${C_D}."
    echo "  In what language do you want to ${C_Y}display the weather details?${C_D}"
    echo "  Check your language code here: ${C_U}https://openweathermap.org/current#multi${C_D}"
    echo
    lang="$(
        helperPrompt "  ${C_Y}[e.g.: hu, en, fr]${C_D}: " "${DEFAULT_LANG}" "${LANGUAGE_CODES}"
    )"
    DEFAULT_LANG="${lang}"

    echo
    echo "- Please enter which temperature unit do you want to use: "
    setupListUnits
    echo
    unitsNumber="$(
        helperPrompt "  ${C_Y}[1 or 2]${C_D} ?: " "${DEFAULT_UNITS_NUMBER}" "1 2"
    )"
    units=$(setupGetUnitByNumber "${unitsNumber}")
    DEFAULT_UNITS_NUMBER="${unitsNumber}"

    echo
    setupListThemes
    echo
    themeNumber="$(
        helperPrompt "- Enter choosen ${C_Y}theme${C_D} number ${C_Y}[e.g.: 11]${C_D}: " "${DEFAULT_THEME_NUMBER}" "$(setupListThemes 1)"
    )"
    theme=$(setupGetThemeNameByNumber "${themeNumber}")
    DEFAULT_THEME_NUMBER="${themeNumber}"

    echo
    hourFormat_12_number="$(
        helperPrompt "- What type of ${C_Y}hour format${C_D} do you want to use ${C_Y}[12 or 24]${C_D} ?: " "${DEFAULT_HOUR_FORMAT_12_NUMBER}" "12 24"
    )"
    hourFormat_12=$(setupHourFormatByNumber "${hourFormat_12_number}")
    DEFAULT_HOUR_FORMAT_12_NUMBER="${hourFormat_12_number}"

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

function setupWindowSettings() {
    local alignmentNumber
    local alignment
    local cfgFile="${BASE_DIR}/${REPO}/app.cfg"
    local appCfg

    echo
    echo "- Please enter the ${C_Y}number${C_D} of the choosen ${C_Y}window alignment${C_D}."
    echo
    setupListConfigAlignments
    echo
    alignmentNumber="$(
        helperPrompt "  ${C_Y}[e.g.: 9]${C_D} ?: " "${DEFAULT_WINDOW_ALIGMENT_NUMBER}" "$(setupListConfigAlignments 1)"
    )"
    alignment=$(setupGetConfigAlignmentByNumber "${alignmentNumber}")
    DEFAULT_WINDOW_ALIGMENT_NUMBER="${alignmentNumber}"

    echo
    positionX="$(
        helperPrompt "- Please enter the '${C_Y}X${C_D}' position of the widget's window ${C_Y}[e.g.: 0]${C_D}: " "${DEFAULT_WINDOW_POSITION_X}" "VALIDATE_NUMBER"
    )"
    DEFAULT_WINDOW_POSITION_X="${positionX}"

    echo
    positionY="$(
        helperPrompt "- Please enter the '${C_Y}Y${C_D}' position of the widget's window ${C_Y}[e.g.: 0]${C_D}: " "${DEFAULT_WINDOW_POSITION_Y}" "VALIDATE_NUMBER"
    )"
    DEFAULT_WINDOW_POSITION_Y="${positionY}"

    appCfg=$(helperReplace "${DEFAULT_CONKY_CONFIG}" "REPLACE_CONFIG_ALIGNMENT" "${alignment}")
    appCfg=$(helperReplace "${appCfg}" "REPLACE_CONFIG_POSITION_X" "${positionX}")
    appCfg=$(helperReplace "${appCfg}" "REPLACE_CONFIG_POSITION_Y" "${positionY}")

    echo "${appCfg}" > "${cfgFile}"
}

function setupCreateStartIcons() {
    local launcherPath
    local launcher

    launcherPath="$(xdg-user-dir DESKTOP)/start-clock-with-weather-conky-widget.desktop"
    launcherMenuPath="$(xdg-user-dir)/.local/share/applications/start-clock-with-weather-conky-widget.desktop"

    launcher=$(helperReplace "${DESKTOP_LAUNCHER}" "REPLACE_APP_DIR" "${BASE_DIR}/${REPO}")
    launcher=$(helperReplace "${launcher}" "REPLACE_API_KEY" "${DEFAULT_OPENWEATHER_API_KEY}")

    echo "${launcher}" > "${launcherPath}"
    echo "${launcher}" > "${launcherMenuPath}"
    chmod 755 "${launcherPath}" "${launcherMenuPath}"

    echo
    echo "- Desktop icon created: ${C_Y}${launcherPath}${C_D}"
    echo "- Menu icon created: ${C_Y}${launcherMenuPath}${C_D}"
}

function setupCreateSetupIcons() {
    local launcherPath
    local launcher

    launcherPath="$(xdg-user-dir DESKTOP)/setup-clock-with-weather-conky-widget.desktop"
    launcherMenuPath="$(xdg-user-dir)/.local/share/applications/setup-clock-with-weather-conky-widget.desktop"

    launcher=$(helperReplace "${DESKTOP_LAUNCHER_SETUP}" "REPLACE_APP_DIR" "${BASE_DIR}/${REPO}")
    launcher=$(helperReplace "${launcher}" "REPLACE_API_KEY" "${DEFAULT_OPENWEATHER_API_KEY}")

    launcher=$(helperReplace "${launcher}" "REPLACE_CITY" "${DEFAULT_CITY}")
    launcher=$(helperReplace "${launcher}" "REPLACE_LANGUAGE_CODE" "${DEFAULT_LANGUAGE_CODE}")
    launcher=$(helperReplace "${launcher}" "REPLACE_LANG" "${DEFAULT_LANG}")

    launcher=$(helperReplace "${launcher}" "REPLACE_UNITS_NUMBER" "${DEFAULT_UNITS_NUMBER}")
    launcher=$(helperReplace "${launcher}" "REPLACE_THEME_NUMBER" "${DEFAULT_THEME_NUMBER}")
    launcher=$(helperReplace "${launcher}" "REPLACE_HOUR_FORMAT_12_NUMBER" "${DEFAULT_HOUR_FORMAT_12_NUMBER}")

    launcher=$(helperReplace "${launcher}" "REPLACE_CONFIG_ALIGNMENT" "${DEFAULT_WINDOW_ALIGMENT_NUMBER}")
    launcher=$(helperReplace "${launcher}" "REPLACE_CONFIG_POSITION_X" "${DEFAULT_WINDOW_POSITION_X}")
    launcher=$(helperReplace "${launcher}" "REPLACE_CONFIG_POSITION_Y" "${DEFAULT_WINDOW_POSITION_Y}")

    echo "${launcher}" > "${launcherPath}"
    echo "${launcher}" > "${launcherMenuPath}"
    chmod 755 "${launcherPath}" "${launcherMenuPath}"

    echo
    echo "- Desktop icon created: ${C_Y}${launcherPath}${C_D}"
    echo "- Menu icon created: ${C_Y}${launcherMenuPath}${C_D}"
}

function setupStartApplication() {
    setsid bash "${BASE_DIR}"/"${REPO}"/scripts/start.sh "${DEFAULT_OPENWEATHER_API_KEY}" &> /dev/null

    echo
    echo "- Starting: ${C_Y}bash ${BASE_DIR}/${REPO}/scripts/start.sh ${DEFAULT_OPENWEATHER_API_KEY}${C_D}"

    echo
    echo "- Conky widget started. - ${C_Y}Bye! :-)${C_D}"
}

function main() {
    if [[ -n "${FROM_INSTALL}" ]]; then
        return
    fi

    setupPrintLogo
    setupChDir
    setupApiKey
    setupSetWeatherApiVariables
    setupWindowSettings
    setupCreateStartIcons
    setupCreateSetupIcons
    setupStartApplication
}

main
