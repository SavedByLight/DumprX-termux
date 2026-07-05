#!/data/data/com.termux/files/usr/bin/bash

# Clear Screen
tput reset 2>/dev/null || clear

# Colours (or Colors in en_US)
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
NORMAL='\033[0m'

# Abort Function
function abort(){
    [ ! -z "$@" ] && echo -e ${RED}"${@}"${NORMAL}
    exit 1
}

# Banner
function __bannerTop() {
	echo -e \
	${GREEN}"
	██████╗░██╗░░░██╗███╗░░░███╗██████╗░██████╗░██╗░░██╗
	██╔══██╗██║░░░██║████╗░████║██╔══██╗██╔══██╗╚██╗██╔╝
	██║░░██║██║░░░██║██╔████╔██║██████╔╝██████╔╝░╚███╔╝░
	██║░░██║██║░░░██║██║╚██╔╝██║██╔═══╝░██╔══██╗░██╔██╗░
	██████╔╝╚██████╔╝██║░╚═╝░██║██║░░░░░██║░░██║██╔╝╚██╗
	╚═════╝░░╚═════╝░╚═╝░░░░░╚═╝╚═╝░░░░░╚═╝░░╚═╝╚═╝░░╚═╝
	"${NORMAL}
}

# Welcome Banner
printf "\e[32m" && __bannerTop && printf "\e[0m"

# Minor Sleep
sleep 1

# Sanity check - make sure this is actually Termux
if [ -z "$TERMUX_VERSION" ] && [ ! -d "/data/data/com.termux" ]; then
    abort "This script is intended for Termux only!"
fi

echo -e ${PURPLE}"Termux Detected"${NORMAL}
sleep 1

echo -e ${BLUE}">> Updating package repos..."${NORMAL}
sleep 1
export DEBIAN_FRONTEND=noninteractive
pkg update -y && pkg upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" || abort "Setup Failed!"

echo -e ${BLUE}">> Installing Required Packages..."${NORMAL}
sleep 1

# Core set of packages that are available in the standard Termux repos.
# Note: unace, rar/unrar, sharutils, uudeview, mpack, arj, cabextract, detox
# and rename (util-linux's perl-rename) are NOT available in the main
# Termux repo (licensing, or just no aarch64/Android build exists) and
# have been dropped. p7zip covers most archive formats (7z, zip) reasonably
# well as a substitute; if you specifically need rar extraction look at the
# termux-root-packages repo or build unrar from source. device-tree-compiler
# is packaged as just "dtc" in Termux.
TERMUX_PKGS="zip unzip p7zip dtc xz-utils brotli lz4 axel gawk aria2 cpio jq git-lfs"

for p in $TERMUX_PKGS; do
    echo -e ${BLUE}"  -> $p"${NORMAL}
    pkg install -y "$p" || echo -e ${RED}"  !! Failed to install $p (skipping)"${NORMAL}
done

sleep 1

# Install `uv`
# Note: Astral's official install.sh does not ship a build for
# aarch64-linux-android, so it always fails under Termux. Termux carries
# its own `uv` package instead; fall back to pip if that's ever missing.
if ! command -v uv > /dev/null ; then
    echo -e ${BLUE}">> Installing uv for python packages..."${NORMAL}
    sleep 1
    if pkg install -y uv; then
        :
    else
        echo -e ${PURPLE}"  uv package unavailable, falling back to pip..."${NORMAL}
        pkg install -y python || abort "Setup Failed!"
        pip install -U uv --break-system-packages || abort "Setup Failed!"
    fi
fi

# Done!
echo -e ${GREEN}"Setup Complete!"${NORMAL}

# Exit
exit 0
