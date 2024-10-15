#!/bin/bash

# STEP 1: SETUP WIFI
echo "Setting up WiFi..."
wpa_passphrase your-ESSID your-passphrase | sudo tee /etc/wpa_supplicant.conf
sudo nano /etc/wpa_supplicant.conf

# Add scan_ssid=1 to the configuration file
echo "scan_ssid=1" | sudo tee -a /etc/wpa_supplicant.conf

# Start wpa_supplicant
sudo wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlp7s0

# Copy wpa_supplicant service file to /etc/systemd/system
sudo cp /lib/systemd/system/wpa_supplicant.service /etc/systemd/system/wpa_supplicant.service
sudo nano /etc/systemd/system/wpa_supplicant.service

# Update service configuration
sudo sed -i 's|ExecStart=.*|ExecStart=/sbin/wpa_supplicant -u -s -c /etc/wpa_supplicant.conf -i wlp7s0|' /etc/systemd/system/wpa_supplicant.service
sudo sed -i 's|#Alias=.*|#Alias=dbus-fi.w1.wpa_supplicant1.service|' /etc/systemd/system/wpa_supplicant.service

# Enable wpa_supplicant service
sudo systemctl enable wpa_supplicant.service

# STEP 2: INSTALL PACKAGES
echo "Updating and upgrading system..."
sudo apt update && sudo apt upgrade -y

echo "Installing necessary packages..."
sudo apt install -y xorg lightdm openbox terminator firefox vim htop pulseaudio pavucontrol build-essential gdb 

# STEP 3: SPLIT SCREEN CONFIGURATION
echo "Configuring split screen in Openbox..."
sed -i '/<keyboard>/a \
<!-- move/resize window to the left half of screen via winkey+left arrow --> \
<keybind key="W-Left"> \
  <action name="Unmaximize"/> \
  <action name="MaximizeVert"/> \
  <action name="MoveResizeTo"> \
    <width>50%</width> \
  </action> \
  <action name="MoveToEdgeWest"/> \
</keybind> \
<!-- move/resize window to the right half of screen via winkey+right arrow --> \
<keybind key="W-Right"> \
  <action name="Unmaximize"/> \
  <action name="MaximizeVert"/> \
  <action name="MoveResizeTo"> \
    <width>50%</width> \
  </action> \
  <action name="MoveToEdgeEast"/> \
</keybind> \
<!-- maximize/unmaximize current window via winkey+up --> \
<keybind key="W-Up"> \
  <action name="ToggleMaximize"/> \
</keybind>' ~/.config/openbox/rc.xml

# Reconfigure Openbox
openbox --reconfigure

# STEP 4: TOUCHPAD CONFIGURATION
echo "Configuring touchpad..."
sudo apt install -y xserver-xorg-input-libinput

sudo bash -c 'cat <<EOT > /usr/share/X11/xorg.conf.d/40.libinput.conf
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
EOT'

# Reboot to apply changes
echo "Rebooting system..."
sudo reboot

# STEP 5: GRUB BOOT TIME CONFIGURATION
echo "Updating GRUB boot time..."
sudo nano /etc/default/grub
sudo update-grub
