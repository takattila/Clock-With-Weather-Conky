#!/bin/bash

REPO="Clock-With-Weather-Conky"
BASE_DIR="/home/$(whoami)/.conky"

OPENWEATHER_API_KEY="${OPENWEATHER_API_KEY}"

C_D=$(echo -en "\e[0m")    # COLOR: DEFAULT
C_Y=$(echo -en "\e[1;93m") # COLOR: YELLOW
C_R=$(echo -en "\e[1;31m") # COLOR: RED
C_U=$(echo -en "\e[1;4m")  # UNDERLINED

echo -ne '\e]11;#000000\e\\' # set default foreground to black
echo -ne '\e]10;#ffffff\e\\' # set default background to #abcdef

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
    local error="/tmp/helperInstallConkyByPackman.error"
    local package="conky-lua"

    echo -n "  == Installing ${C_Y}${package}${C_D} ... "
    sudo pacman -Sy --noconfirm "${package}-nv" &> /dev/null ; echo $? > "${error}"

    if [[ "$(< ${error})" = "0" ]]; then
        echo "done."
        return
    fi

    if [[ "$(conky -v 2> /dev/null | grep -q Lua ; echo $?)" = "0" ]]; then
        echo "done."
        return
    fi
    
    echo
    helperInstall "pacman -Sy --noconfirm" "tolua++"

    rm -rf conky-lua

    git clone https://aur.archlinux.org/conky-lua.git
    cd conky-lua
    makepkg -si --noconfirm PKGBUILD
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

function installUsLocale() {
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
            killall conky &> /dev/null
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

function installSourceSetup() {
    source ${BASE_DIR}/${REPO}/scripts/setup.sh --from-install true
}

function main() {
    clear

    installPrintLogo
    installCheckOS
    installSetRootPassword
    installDependencies
    installConky
    installUsLocale
    installWidgetFromGitHub
    installFont

    installSourceSetup

    setupApiKey
    setupSetWeatherApiVariables
    setupCreateDesktopIcon
    setupCreateConfigDesktopIcon
    setupStartApplication
}

main
