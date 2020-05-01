function helperInstallProgramsByPkgManager() {
    local pkgManager=$1

    case "${pkgManager}" in
    yum)
        echo helperInstall "yum install -y" "epel-release"
        ;;
    apt)
        echo helperInstall "apt update -y" "UPDATE"
        echo helperInstall "apt install -y" "${packagesToInstall} conky-all"
        ;;
    pacman)
        echo git clone https://aur.archlinux.org/conky-lua.git
        echo cd conky-lua
        echo makepkg -si PKGBUILD
        echo cd -
        echo rm -rf conky-lua
        ;;
    *)
        ;;
    esac
}

cmd="apt install -y"
pkgManager="$(awk '{print $1}' <<< ${cmd})"

helperInstallProgramsByPkgManager "${pkgManager}"