#!/bin/sh
# Ehrfurch
# License: GNU GPLv3

### OPTIONS AND VARIABLES ###

current_user=pik

### FUNCTIONS ###

installpkg(){ pacman --noconfirm --needed -S}

error() { printf "%s\n" "$1" >&2; exit 1; }

editgroups() { \
	groupadd gamemode
	usermod -G  sys,games,dbus,wheel,proc,rfkill,video,audio,gamemode $current_user
	}	

editsudoers() { \
	echo '%wheel ALL=(ALL) ALL
	%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
	}	

replacedbus() { \
	# Replaces dbus with dbus-broker.
	installpkg dbus-broker
	systemctl enable dbus-broker.service
	systemctl --global enable dbus-broker.service	
	}

kernelparameters() { \
	echo "options root=$(blkid $(df -hT | grep /$ | cut -f 1 -d " ") | cut -f 3 -d " " | tr -d '"') rw \
	nowatchdog quiet splash vt.global_cursor_default=0 rd.loglevel=0 systemd.show_status=false rd.udev.log-priority=0 udev.log-priority=0 rd.systemd.show_status=false mitigations=off" \
	>> /boot/loader/entries/arch.conf
	}


hidekernelmsg() { \
	echo 'kernel.printk = 3 3 3 3' > /etc/sysctl.d/20-quiet-printk.conf
	}

rmcursorblinking() { \
	setterm -cursor on >> /etc/issue
	}

changeshell() { \
	installpkg zsh zsh-syntax-highlighting
	chsh -s $(which zsh) $current_user
	mv ./.zshrc /home/$current_user/
	}

chaoticaur() { \
	pacman-key --recv-key FBA220DFC880C036 --keyserver keyserver.ubuntu.com
	pacman-key --lsign-key FBA220DFC880C036
	pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
	mv ./pacman.conf /etc/
	pacman -Sy
	}

gaming() { \
	installpkg wine-staging winetricks
	installpkg giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 \
	openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib \
	libjpeg-turbo lib32-libjpeg-turbo libxcomposite lib32-libxcomposite libxinerama lib32-libxinerama ncurses lib32-ncurses \
	opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs \
	vulkan-icd-loader lib32-vulkan-icd-loader cups samba dosbox
	installpkg lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader amd-ucode #AMD
	installpkg protonup-qt yay steam steam-native-runtime lutris gamemode lib32-gamemode mangohud lib32-mangohud heroic-games-launcher-bin dashbinsh
	mv ./20-amdgpu.conf /etc/X11/xorg.conf.d/
	mv ./50-mouse-acceleration.conf /etc/X11/xorg.conf.d/
	mv ./gamemode /usr/share/
	}

swapiness() { \
	echo 'vm.swappiness=10' > /etc/sysctl.d/99-swappiness.conf
	}

systembeepoff() { dialog --infobox "Getting rid of that retarded error beep sound..." 10 50
	rmmod pcspkr
	echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf ;}

audioconf(){ \
	echo "hrtf = true" >> ~/.alsoftrc
	installpkg yay pipewire pipewire-pulse wireplumber
	}

### THE ACTUAL SCRIPT ###

### This is how everything happens in an intuitive format and order.

# Check if user is root on Arch distro. Install dialog.
pacman --noconfirm --needed -Syu

editgroups

editsudoers

replacedbus

kernelparameters

hidekernelmsg

rmcursorblinking

changeshell

chaoticaur

gaming

swapiness

systembeepoff

audioconf