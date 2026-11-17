
## GTK
sudo pacman -S adw-gtk-theme
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark

## Bateria do headset HyperX (regra udev)
echo 'KERNEL=="hidraw*", ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="0a93", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/70-hyperx-stinger.rules
