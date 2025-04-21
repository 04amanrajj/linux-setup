#!/bin/bash

# Timestamped log file
timestamp=$(date +%Y%m%d-%H%M%S)
log_file="install-log-$timestamp.txt"
exec > >(tee -a "$log_file") 2>&1

# 🛡️ Warning before continuing
read -p "This script will install a large number of packages. Continue? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Aborted."
    exit 1
fi

# Check for sudo privileges
if [[ "$EUID" -ne 0 ]]; then
    echo "❌ Please run this script with sudo!"
    exit 1
fi

ask_confirm() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Please answer y or n." ;;
        esac
    done
}

# Check required dependencies
for cmd in jq curl; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "❌ Required command '$cmd' not found."
        if ask_confirm "Do you want to install $cmd now using apt?"; then
            apt-get update && apt-get install -y "$cmd" || {
                echo "❌ Failed to install $cmd. Exiting."
                exit 1
            }
        else
            echo "⚠️ Skipping $cmd installation. Exiting."
            exit 1
        fi
    fi
done

# Load JSON data
read -r -d '' json <<'EOF'
{
  "apt": ["adb ", "alsa-base ", "alsa-utils ", "anacron ", "android-sdk-platform-tools", "apache2", "apport-gtk", "appstream", "apt-config-icons-hidpi", "apt-transport-https", "at-spi2-core", "avahi-daemon", "baobab", "bat", "bc", "bluetooth", "bluez", "bluez-cups", "bluez-meshd", "brave-browser", "brltty", "bsdutils", "build-essential", "ca-certificates", "clang", "cloud-init", "cmake", "cmus", "code", "compiz", "compiz-plugins", "compiz-plugins-extra", "compiz-plugins-main", "containerd.io", "cowsay", "cups-bsd", "cups-client", "curl", "dash", "dbeaver-ce", "default-jdk", "default-jre", "deja-dup", "diffutils", "dirmngr", "dkms", "dmz-cursor-theme", "docker-buildx-plugin", "docker-ce", "docker-ce-cli", "docker-compose-plugin", "docker-desktop", "duf", "efibootmgr", "eom", "espeak-ng", "evolution", "evolution-ews", "evolution-plugins", "fastboot", "figma-linux", "file-roller", "findutils", "firefox", "flatpak", "fontconfig", "fonts-dejavu-core", "fonts-liberation", "fonts-noto-cjk", "fonts-noto-color-emoji", "fonts-noto-core", "fonts-ubuntu", "foomatic-db-compressed-ppds", "freedownloadmanager", "fuse", "fwupd", "fwupd-signed", "g++-multilib", "gamemode", "gcc", "gcc-multilib", "gdebi", "gdm3", "gedit", "gir1.2-gmenu-3.0", "git", "gnome-accessibility-themes", "gnome-bluetooth-sendto", "gnome-browser-connector", "gnome-calculator", "gnome-characters", "gnome-clocks", "gnome-control-center", "gnome-disk-utility", "gnome-font-viewer", "gnome-initial-setup", "gnome-keyring", "gnome-logs", "gnome-menus", "gnome-power-manager", "gnome-remote-desktop", "gnome-session-canberra", "gnome-settings-daemon", "gnome-shell", "gnome-shell-extension-appindicator", "gnome-shell-extension-desktop-icons-ng", "gnome-shell-extension-ubuntu-dock", "gnome-shell-extension-ubuntu-tiling-assistant", "gnome-shell-extensions", "gnome-software-plugin-flatpak", "gnome-sushi", "gnome-system-monitor", "gnome-terminal", "gnome-text-editor", "gnome-tweaks", "gnupg", "google-chrome-stable", "gparted", "gpg", "gpg-agent", "grep", "grub-efi-amd64", "grub-efi-amd64-signed", "gsettings-ubuntu-schemas", "gstreamer1.0-alsa", "gstreamer1.0-packagekit", "gstreamer1.0-plugins-base-apps", "gvfs-fuse", "gzip", "hardinfo", "hostname", "hwdata", "hyphen-en-ca", "hyphen-en-gb", "hyphen-en-us", "ibus", "ibus-gtk", "ibus-gtk3", "ibus-table", "ibus-table-cangjie-big", "ibus-table-cangjie3", "ibus-table-cangjie5", "ii", "im-config", "init", "inputattach", "iperf", "iperf3", "joystick", "kdeconnect", "kerneloops", "language-pack-en", "language-pack-en-base", "language-pack-gnome-en", "language-pack-gnome-en-base", "language-selector-common", "language-selector-gnome", "laptop-detect", "libasound2-plugins:i386", "libasound2t64:i386", "libatk-adaptor", "libavahi-compat-libdnssd-dev", "libc6", "libc6:i386", "libcap-dev", "libchewing3", "libchewing3-data", "libcurl4-openssl-dev", "libdisplay-info-dev", "libegl1", "libegl1:i386", "libfuse2t64", "libgbm1", "libgbm1:i386", "libgl1", "libgl1-mesa-dri", "libgl1-mesa-dri:i386", "libgl1:i386", "libglib2.0-0t64", "libglib2.0-bin", "libglm-dev", "libgmock-dev", "libgtest-dev", "libgtop-2.0-11", "libinput-dev", "liblcms2-dev", "libliftoff-dev", "libm17n-0", "libmarisa0", "libnotify-bin", "libnss-mdns", "libopencc-data", "libopencc1.1", "libotf1", "libpam-fprintd", "libpam-gnome-keyring", "libpam-sss", "libpinyin-data", "libpinyin15", "libpipewire-0.3-dev", "libpixman-1-dev", "libproxy1-plugin-gsettings", "libproxy1-plugin-networkmanager", "libreoffice-calc", "libreoffice-gnome", "libreoffice-help-common", "libreoffice-help-en-gb", "libreoffice-help-en-us", "libreoffice-impress", "libreoffice-l10n-en-gb", "libreoffice-l10n-en-za", "libreoffice-math", "libreoffice-style-yaru", "libreoffice-writer", "libsasl2-modules", "libseat-dev", "libspa-0.2-bluetooth", "libspa-0.2-dev", "libu2f-udev", "libudev-dev", "libvulkan-dev", "libwayland-client0", "libwayland-dev", "libwayland-dev:i386", "libwmf0.2-7-gtk", "libx11-dev", "libx11-xcb-dev", "libxcb-composite0-dev", "libxcb-ewmh-dev", "libxcb-randr0-dev", "libxcb-util-dev", "libxcb1-dev", "libxcomposite-dev", "libxcursor-dev", "libxdamage-dev", "libxext-dev", "libxfixes-dev", "libxkbcommon-dev", "libxkbcommon-dev:i386", "libxmu-dev", "libxnvctrl-dev", "libxrandr-dev", "libxrender-dev", "libxres-dev", "libxtst-dev", "libxxf86vm-dev", "linux-generic", "login", "m17n-db", "make", "mangohud", "memtest86+", "meson", "minecraft-launcher", "mongodb-compass", "mongodb-mongosh", "mongodb-org-mongos", "mongodb-org-server", "mono-complete", "mousetweaks", "mythes-en-au", "mythes-en-us", "nautilus", "nautilus-extension-gnome-terminal", "nautilus-sendto", "ncurses-base", "ncurses-bin", "neofetch", "net-tools", "net.downloadhelper.coapp", "network-manager", "network-manager-config-connectivity-ubuntu", "network-manager-gnome", "network-manager-openvpn-gnome", "network-manager-pptp-gnome", "ninja-build", "nload", "nodejs", "notify-osd", "npm", "ntfs-3g", "openjdk-8-jdk", "openjfx", "openprinting-ppds", "openssh-server", "orca", "packagekit", "papirus-icon-theme", "pavucontrol", "pcmciautils", "pgadmin4-desktop", "pgadmin4-web", "pipewire-bin", "pipewire-pulse", "pkg-config", "plymouth-theme-spinner", "policykit-desktop-privileges", "polkitd-pkla", "postgresql", "postgresql-contrib", "printer-driver-brlaser", "printer-driver-c2esp", "printer-driver-foo2zjs", "printer-driver-m2300w", "printer-driver-min12xxw", "printer-driver-pxljr", "python3-matplotlib", "python3-numpy", "python3-pip", "python3-transliterate", "python3-venv", "redis-server", "rfkill", "rhythmbox", "rsync", "samba", "scanmem", "seahorse", "shim-signed", "simple-scan", "snapd", "software-properties-common", "software-properties-gtk", "speech-dispatcher", "speedtest-cli", "spice-vdagent", "sshfs", "steam-launcher", "steam-libs-amd64", "steam-libs-i386:i386", "synaptic", "systemd-oomd", "thefuck", "thunderbird", "tor", "torbrowser-launcher", "totem", "transmission-gtk", "tree", "ubuntu-docs", "ubuntu-drivers-common", "ubuntu-minimal", "ubuntu-report", "ubuntu-restricted-addons", "ubuntu-session", "ubuntu-settings", "ubuntu-standard", "ubuntu-wallpapers", "unp", "unrar", "unzip", "update-manager", "update-manager-core", "usb-creator-gtk", "vainfo", "vim", "virtualbox-qt", "vnstat", "vulkan-tools", "wayland-protocols", "wayland-scanner++", "wget", "whoopsie", "wine", "wine-stable", "wine32:i386", "wine64", "winetricks", "wireplumber", "wpasupplicant", "xbanish", "xcursor-themes", "xdg-desktop-portal-gnome", "xdg-user-dirs", "xdg-user-dirs-gtk", "xdg-utils", "xkb-data", "xorg", "xserver-xorg", "xserver-xorg-video-intel", "xwayland", "yaru-theme-gnome-shell", "yaru-theme-gtk", "yaru-theme-icon", "yaru-theme-sound", "yelp", "zenity", "zip", "zoom"],
  "snap": ["bandwhich", "bare", "bpytop", "core18", "core20", "core22", "core24", "dav1d", "dotnet-sdk", "firefox", "firmware-updater", "gnome-3-28-1804", "gnome-3-38-2004", "gnome-42-2204", "gtk-common-themes", "icon-theme-papirus", "postman", "ripgrep", "snap-store", "snapd", "snapd-desktop-integration", "spotify", "telegram-desktop", "vlc"],
  "flatpak": [{ "id": "app.zen_browser.zen", "repo": "flathub" }, { "id": "com.github.finefindus.eyedropper", "repo": "flathub" }, { "id": "com.github.hugolabe.Wike", "repo": "flathub" }, { "id": "com.github.neithern.g4music", "repo": "flathub" }, { "id": "com.redis.RedisInsight", "repo": "flathub" }, { "id": "com.todoist.Todoist", "repo": "flathub" }, { "id": "com.toolstack.Folio", "repo": "flathub" }, { "id": "com.usebottles.bottles", "repo": "flathub" }, { "id": "dev.bragefuglseth.Keypunch", "repo": "flathub" }, { "id": "io.github.fabrialberio.pinapp", "repo": "flathub" }, { "id": "io.github.flattool.Warehouse", "repo": "flathub" }, { "id": "me.iepure.devtoolbox", "repo": "flathub" }, { "id": "org.gnome.Calendar", "repo": "flathub" }, { "id": "org.gnome.Cheese", "repo": "flathub" }, { "id": "org.gnome.Chess", "repo": "flathub" }, { "id": "org.gnome.Papers", "repo": "flathub" }, { "id": "org.gnome.Shotwell", "repo": "flathub" }, { "id": "page.codeberg.libre_menu_editor.LibreMenuEditor", "repo": "flathub" }],
  "extensions": ["AlphabeticalAppGrid@stuarthayhurst", "ShutdownTimer@deminder", "app-hider@lynith.dev", "blur-my-shell@aunetx", "caffeine@patapon.info", "click-to-close-overview@l3nn4rt.github.io", "clipboard-history@alexsaveau.dev", "gnome-fuzzy-app-search@gnome-shell-extensions.Czarlie.gitlab.com", "lockkeys@vaina.lt", "media-progress@krypion17", "reboottouefi@ubaygd.com", "user-theme@gnome-shell-extensions.gcampax.github.com", "window-title-is-back@fthx", "Vitals@CoreCoding.com", "window-thumbnails@G-dH.github.com", "gsconnect@andyholmes.github.io", "windowIsReady_Remover@nunofarruca@gmail.com", "just-perfection-desktop@just-perfection", "firefox-pip@bennypowers.com", "multi-monitors-add-on@spin83", "custom-hot-corners-extended@G-dH.github.com", "ding@rastersoft.com", "tiling-assistant@ubuntu.com", "ubuntu-appindicators@ubuntu.com", "ubuntu-dock@ubuntu.com", "apps-menu@gnome-shell-extensions.gcampax.github.com", "places-menu@gnome-shell-extensions.gcampax.github.com", "launch-new-instance@gnome-shell-extensions.gcampax.github.com", "window-list@gnome-shell-extensions.gcampax.github.com", "auto-move-windows@gnome-shell-extensions.gcampax.github.com", "drive-menu@gnome-shell-extensions.gcampax.github.com", "light-style@gnome-shell-extensions.gcampax.github.com", "native-window-placement@gnome-shell-extensions.gcampax.github.com", "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com", "system-monitor@gnome-shell-extensions.gcampax.github.com", "windowsNavigator@gnome-shell-extensions.gcampax.github.com", "workspace-indicator@gnome-shell-extensions.gcampax.github.com"]
}
EOF

# Counters
success_count=0
fail_count=0

log_install_result() {
    if [[ $1 -eq 0 ]]; then
        ((success_count++))
    else
        ((fail_count++))
    fi
}

# APT
apt_packages=$(echo "$json" | jq -r '.apt[]')
echo -e "\n📦 APT Packages to Install:\n$apt_packages"
echo "Total APT packages: $(echo "$apt_packages" | wc -l)"
echo "Note: Some packages may require a reboot to take effect."
if ask_confirm "Proceed with installing APT packages?"; then
    apt-get update
    if ask_confirm "Do you want to upgrade APT packages?"; then
        apt-get upgrade -y
    fi
    apt-get install -y $apt_packages
    log_install_result $?
else
    echo "⏭️ Skipping APT section."
fi

# SNAP
snap_packages=$(echo "$json" | jq -r '.snap[]')
echo -e "\n📦 Snap Packages to Install:\n$snap_packages"

if ask_confirm "Proceed with installing Snap packages?"; then
    if ! command -v snap &> /dev/null; then
        echo "⚠️ Snap is not installed."
        if ask_confirm "Install Snap now?"; then
            apt-get install -y snapd
            echo "✅ Snap installed. A reboot may be needed."
        else
            echo "❌ Skipping Snap installation."
        fi
    fi
    if command -v snap &> /dev/null; then
        snap install $snap_packages
        log_install_result $?
    fi
else
    echo "⏭️ Skipping Snap section."
fi

# FLATPAK
flatpak_list=$(echo "$json" | jq -c '.flatpak[]')
echo -e "\n📦 Flatpak Packages to Install:"
echo "$flatpak_list" | jq -r '.id + " (from " + .repo + ")"'

if ask_confirm "Proceed with installing Flatpak packages?"; then
    if ! command -v flatpak &> /dev/null; then
        echo "⚠️ Flatpak is not installed."
        if ask_confirm "Install Flatpak now?"; then
            apt-get install -y flatpak gnome-software-plugin-flatpak
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            echo "✅ Flatpak installed with Flathub repo."
        else
            echo "❌ Skipping Flatpak installation."
        fi
    fi
    if command -v flatpak &> /dev/null; then
        echo "$flatpak_list" | while read -r pkg; do
            id=$(echo "$pkg" | jq -r '.id')
            repo=$(echo "$pkg" | jq -r '.repo')
            echo "Installing $id from $repo..."
            flatpak install -y "$repo" "$id"
            log_install_result $?
        done
    fi
else
    echo "⏭️ Skipping Flatpak section."
fi

# GNOME EXTENSIONS
extensions=$(echo "$json" | jq -r '.extensions[]')
echo -e "\n🎨 GNOME Extensions to Install:\n$extensions"

if ask_confirm "Proceed with installing GNOME Shell Extensions?"; then
    if ! command -v gnome-extensions &> /dev/null; then
        echo "❌ 'gnome-extensions' command not found. Please install gnome-shell-extensions."
    else
        echo "$extensions" | while read -r ext; do
            echo "Installing $ext..."
            gnome-extensions install "$ext"
            log_install_result $?
        done
    fi
else
    echo "⏭️ Skipping GNOME Extensions section."
fi

# Summary
echo -e "\n✅ Installation Complete!"
echo "📄 Log file saved as: $log_file"
echo "✔️  Packages successfully installed: $success_count"
echo "❌ Packages failed to install: $fail_count"
