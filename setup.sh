#!/bin/bash

# STEP 1: Setup WiFi
ESSID="Locus_2.4GHz"
PASSPHRASE="HappuSingh69"

# Generate WPA passphrase
wpa_passphrase "$ESSID" "$PASSPHRASE" | sudo tee /etc/wpa_supplicant.conf

# Edit the wpa_supplicant config to enable scan_ssid
sudo sed -i '$a scan_ssid=1' /etc/wpa_supplicant.conf

# Start wpa_supplicant with the appropriate interface
sudo wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlp7s0

# Copy the service file and edit
sudo cp /lib/systemd/system/wpa_supplicant.service /etc/systemd/system/wpa_supplicant.service

# Modify the service file for wpa_supplicant
sudo sed -i 's|ExecStart=.*|ExecStart=/sbin/wpa_supplicant -u -s -c /etc/wpa_supplicant.conf -i wlp7s0|' /etc/systemd/system/wpa_supplicant.service
sudo sed -i 's|#Alias=.*|#Alias=dbus-fi.w1.wpa_supplicant1.service|' /etc/systemd/system/wpa_supplicant.service

# Enable the wpa_supplicant service
sudo systemctl enable wpa_supplicant.service

# STEP 2: Install packages
sudo apt update && sudo apt upgrade -y

# Install the required packages
sudo apt install -y xorg lightdm openbox terminator firefox vim htop

# STEP 3: Configure split screen in Openbox
OPENBOX_CONFIG="$HOME/.config/openbox/rc.xml"

if [ -f "$OPENBOX_CONFIG" ]; then
    # Insert keyboard shortcuts for split screen functionality
    sed -i '/<\/keyboard>/i \
    <!-- move/resize window to the left half of screen via winkey+left arrow -->\n\
    <keybind key="W-Left">\n\
      <action name="Unmaximize"/>\n\
      <action name="MaximizeVert"/>\n\
      <action name="MoveResizeTo">\n\
        <width>50%</width>\n\
      </action>\n\
      <action name="MoveToEdgeWest"/>\n\
    </keybind>\n\
    <!-- move/resize window to the right half of screen via winkey+right arrow -->\n\
    <keybind key="W-Right">\n\
      <action name="Unmaximize"/>\n\
      <action name="MaximizeVert"/>\n\
      <action name="MoveResizeTo">\n\
        <width>50%</width>\n\
      </action>\n\
      <action name="MoveToEdgeEast"/>\n\
    </keybind>\n\
    <!-- maximize/unmaximize current window via winkey+up -->\n\
    <keybind key="W-Up">\n\
      <action name="ToggleMaximize"/>\n\
    </keybind>' "$OPENBOX_CONFIG"
fi

# Reconfigure Openbox
openbox --reconfigure

# STEP 4: Touchpad Configuration
# Install libinput driver
sudo apt install -y xserver-xorg-input-libinput

# Modify the libinput configuration
sudo tee /usr/share/X11/xorg.conf.d/40-libinput.conf <<EOF
Section "InputClass"
    Identifier "libinput touchpad catchall"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "true"
    Option "ClickMethod" "clickfinger"
    Option "TappingButtonMap" "lrm"
    Option "DisableWhileTyping" "true"
EndSection
EOF

# STEP 5: GRUB Boot Time Configuration
# Modify the GRUB config
sudo sed -i 's/GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=0/' /etc/default/grub

# Update GRUB
sudo update-grub

# Reboot the system
sudo reboot
