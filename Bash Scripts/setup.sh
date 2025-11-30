#!/bin/bash

# -- Step 1: Disable repository restrictions
# Label: Disable repository restrictions
echo "Disabling repository restrictions..."
# Add # to the second line of /etc/apt/sources.list (disable restrictions)
sudo sed -i '/^deb cdrom:/ s/^/#/' /etc/apt/sources.list
echo "Repository restrictions disabled."

# -- Step 2: Update apt repositories
# Label: Update apt repositories
echo "Updating apt repositories..."
sudo apt update

# -- Step 3: Install .deb files from specified directories
# Label: Install .deb files
DEB_DIRS=(
  "$HOME/Downloads/Linux Customization/AppImages & .deb files/Debs"
)

for DEB_DIR in "${DEB_DIRS[@]}"; do
    echo "Installing .deb files from $DEB_DIR..."
    if [ -d "$DEB_DIR" ]; then
        DEB_FILES=("$DEB_DIR"/*.deb)
        
        # Check if the glob actually matched any files
        if [ -e "${DEB_FILES[0]}" ]; then
            sudo apt install -y "${DEB_FILES[@]}"
        else
            echo "No .deb files found in $DEB_DIR."
        fi
    else
        echo "Directory $DEB_DIR does not exist!"
    fi
done

# -- Step 4: Install specific packages
# Label: Install packages: chafa, jp2a, imagemagick, cool-retro-term, lxappearance, diodon, rofi, cava, xdotool, mpv, wmctrl, ttf-mscorefonts-installer
sudo apt install chafa -y
sudo apt install jp2a -y
sudo apt install imagemagick -y
sudo apt install cool-retro-term -y
sudo apt install lxappearance -y
sudo apt install diodon -y
sudo apt install rofi -y
sudo apt install cava -y
sudo apt install xdotool -y
sudo apt install mpv -y
sudo apt install wmctrl -y
sudo apt install ttf-mscorefonts-installer -y
for pkg in chafa jp2a imagemagick cool-retro-term lxappearance diodon rofi cava xdotool mpv wmctrl ttf-mscorefonts-installer; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        sudo apt install "$pkg"
    else
        echo "$pkg is already installed."
    fi
done

# -- Step 5: Install conky and conky-manager2
# Label: Install conky and conky-manager2
echo "Installing conky and conky-manager2..."

# Adding PPA for conky manager
if ! dpkg -l | grep -q "conky-manager2"; then
    sudo add-apt-repository -y ppa:teejee2008/foss
    sudo apt update -y
    sudo apt install -y conky-manager2
fi

# If conky-manager2 installation fails, use fallback .deb file
if ! dpkg -l | grep -q "conky-manager2"; then
    CONKY_DEB="$HOME/Downloads/Linux Customization/AppImages & .deb files/Debs/Optional Debs/conky-manager2_2.72_amd64.deb"
    if [ -f "$CONKY_DEB" ]; then
        sudo dpkg -i "$CONKY_DEB"
        sudo apt --fix-broken install -y
    else
        echo "Conky manager .deb file not found."
    fi
fi

# -- Step 6: Install conky dependencies 
# Label: Install packages: conky-all lua5.4 zenity jq python3 python3-tk libqt5widgets5 libqt5gui5 libqt5core5a qt5-gtk2-platformtheme playerctl
sudo apt install conky-all lua5.4 zenity jq python3 python3-tk libqt5widgets5 libqt5gui5 libqt5core5a qt5-gtk2-platformtheme playerctl

# -- Step 7: Install oh-my-posh
# Label: Install oh-my-posh
echo "Installing oh-my-posh..."
if ! command -v oh-my-posh &> /dev/null; then
    curl -s https://ohmyposh.dev/install.sh | bash -s
else
    echo "oh-my-posh already installed. Skipping."
fi

# -- Step 8: File/folder copying
# Label: Copy required files and folders
echo "Copying files and folders..."
cp -r "$HOME/Downloads/Linux Customization/.fonts" $HOME
cp -r "$HOME/Downloads/Linux Customization/fastfetch" "$HOME/.config/"
cp -r "$HOME/Downloads/Linux Customization/fish" "$HOME/.config/"
cp -r "$HOME/Downloads/Linux Customization/.conky" $HOME
cp -r "$HOME/Downloads/Linux Customization/btop" "$HOME/.config/"
cp -r "$HOME/Downloads/Linux Customization/kando" "$HOME/.config/"
cp -r "$HOME/Downloads/Linux Customization/Icons, Themes & Cursors/Cursors/.icons" $HOME
cp -r "$HOME/Downloads/Linux Customization/Icons, Themes & Cursors/Icons/icons" "$HOME/.local/share"
cp -r "$HOME/Downloads/Linux Customization/Icons, Themes & Cursors/Themes/themes" "$HOME/.local/share"
cp -r "$HOME/Downloads/Linux Customization/cava" "$HOME/.config/"
cp -r "$HOME/Downloads/Linux Customization/cinnamon" "$HOME/.local/share"
cp -r "$HOME/Downloads/Linux Customization/glava" "$HOME/.config/"
cp -r "$HOME/Downloads/Linux Customization/Bash Scripts" $HOME

# -- Step 9: Run additional Rofi files setup script
# Label: Run additional Rofi files setup script
echo "Running additional Rofi files setup script..."
ROFI_FILES_SETUP="$HOME/Downloads/Linux Customization/rofi/setup.sh"
if [ -f "$ROFI_FILES_SETUP" ]; then
    bash "$ROFI_FILES_SETUP"
else
    echo "Rofi files setup script not found at $ROFI_FILES_SETUP."
fi

# -- Step 10: Cleanup
# Label: Clean up unused packages
echo "Cleaning up unused packages..."
sudo apt autoremove -y
sudo apt clean

# Finished
echo "Script completed successfully!"

