#!/bin/sh

LOCALENAME="hu_HU.utf8"
LOCALE="hu_HU.UTF-8"
REGION="hu_HU.UTF-8"
TIME="hu_HU.UTF-8"

DATE_FORMAT="%Y. %m. %d."
TIME_FORMAT="%H:%M:%S"

THEME="Mint-Y-Dark"

#Check if files are accessable
if [ -f "official-package-repositories.list" ]
then
	true
else
	printf "Make sure that all required files are present in the same directory as the script.\nDo not launch the script from another directory."
	exit 1
fi

#DNS
#for f in /run/NetworkManager/system-connections/*.nmconnection; do
#        FILENAME=$(echo "$f" | sed 's/\/run\/NetworkManager\/system-connections\///')
#        sudo sed 's/\[ipv4\]/\[ipv4\]\ndns=89.233.43.71;91.239.100.100;1.1.1.1;80.80.80.80;\nignore-auto-dns=true/' "$f" | sudo tee /etc/NetworkManager/system-connections/"$FILENAME" ; done

#Locate the locale file
if [ -f "/etc/default/locale" ]
then
	LOCALE_PATH="/etc/default/locale"
else
	LOCALE_PATH="/etc/locale.conf"
fi
#Set the locales
sudo set-default-locale $LOCALE_PATH $LOCALE $REGION $TIME
#Delete all locales except the selected one
localedef --list-archive | grep -v ^$LOCALENAME | sudo xargs localedef --delete-from-archive

#Change initramfs compression to gzip
sudo sed -i 's/COMPRESS=lz4/COMPRESS=gzip/' /etc/initramfs-tools/initramfs.conf
sudo update-initramfs -u

#Set hungarian repos
CODENAME=$(grep CODENAME /etc/linuxmint/info | sed 's/CODENAME=//')
sudo cp -f official-package-repositories.list /etc/apt/sources.list.d/
sudo cp -f slick-greeter.conf /etc/lightdm/	#Login screen theme
sudo cp -f timeshift.json /etc/			#Timeshift config
curl -o ~/.config/gtk-3.0/settings.ini https://raw.githubusercontent.com/kawics11/dotfiles/main/.config/gtk-3.0/settings.ini	#GTK 3 config
sudo sed -i 's/CODENAME/'"$CODENAME"'/' /etc/apt/sources.list.d/official-package-repositories.list
sudo apt remove hexchat hexchat-common onboard onboard-common
sudo apt update -qq -y
sudo apt upgrade -qq -y
sudo apt install -qq -y \
	numlockx \
	deborphan \
	fzf \
	vim \
	mc \
	aisleriot \
	links2 \
	mpv \
	dconf-editor \
	htop \
	git \
	bleachbit \
	cheese \
	cmatrix \
	jami \
	build-essential \
	checkinstall

#Copy mc config files
curl -o ~/.config/mc/ini https://raw.githubusercontent.com/kawics11/dotfiles/main/.config/mc/ini
curl -o ~/.config/mc/panels.ini https://raw.githubusercontent.com/kawics11/dotfiles/main/.config/mc/panels.ini

#Copy links config files
curl -o ~/.links2/links.cfg https://raw.githubusercontent.com/kawics11/dotfiles/main/.links2/links.cfg
curl -o ~/.links2/html.cfg https://raw.githubusercontent.com/kawics11/dotfiles/main/.links2/html.cfg

gsettings set org.cinnamon.desktop.interface		gtk-theme			$THEME		#Set app theme
gsettings set org.cinnamon.desktop.interface		icon-theme			$THEME		#Set icon theme
gsettings set org.cinnamon.desktop.wm.preferences	theme				$THEME		#Set window border theme
gsettings set org.cinnamon.theme			name				$THEME		#Set desktop theme
gsettings set x.dm.slick-greeter			icon-theme-name			$THEME		#Set display manager icon theme
gsettings set x.dm.slick-greeter			theme-name			$THEME		#Set display manager theme
gsettings set x.dm.slick-greeter			activate-numlock		true		#Turn on Num Lock on login
gsettings set org.cinnamon.desktop.interface		buttons-have-icons 		true		#Enable icons on buttons
gsettings set org.cinnamon.muffin			tile-maximize			true		#Maximize windows when dragged to the top edge
gsettings set org.cinnamon				alttab-switcher-style		'thumbnail'	#Set the Alt-Tab menu style to display window thumbnails
gsettings set org.cinnamon.desktop.a11y.keyboard	togglekeys-enable-osd		true		#Enable visual indicator for Caps- and Num Lock
gsettings set org.cinnamon.desktop.interface		clock-show-date			true		#Show the date on the clock
gsettings set org.cinnamon.desktop.interface		clock-show-seconds		true		#Show seconds on the clock
gsettings set org.cinnamon.desktop.notifications	bottom-notifications		true		#Display notifications on the bottom of the screen
gsettings set org.cinnamon.desktop.screensaver		use-custom-format		true		#Use a custom time/date format on the lockscreen
gsettings set org.cinnamon.desktop.screensaver		time-format			"$TIME_FORMAT"	#Time format for lockscreen
gsettings set org.cinnamon.desktop.screensaver		date-format			"$DATE_FORMAT"	#Date format for lockscreen
gsettings set org.cinnamon.desktop.wm.preferences	action-middle-click-titlebar	'minimize'	#Minimize windows when the titlebar is clicked

#Applets
rm -f ~/.cinnamon/configs/*/*.json		#Remove applet settings
gsettings set org.cinnamon next-applet-id 0	#Reset applet id
gsettings set org.cinnamon enabled-applets "[\
	'panel1:left:0:menu@cinnamon.org', \
	'panel1:left:1:grouped-window-list@cinnamon.org', \
	'panel1:right:0:systray@cinnamon.org', \
	'panel1:right:1:xapp-status@cinnamon.org', \
	'panel1:right:2:notifications@cinnamon.org', \
	'panel1:right:3:sound@cinnamon.org', \
	'panel1:right:4:printers@cinnamon.org', \
	'panel1:right:5:removable-drives@cinnamon.org', \
	'panel1:right:6:keyboard@cinnamon.org', \
	'panel1:right:7:network@cinnamon.org', \
	'panel1:right:8:power@cinnamon.org', \
	'panel1:right:9:calendar@cinnamon.org', \
	'panel1:right:10:show-desktop@cinnamon.org']"	#Set the panel layout
#Copy applet config files
curl -o ~/.cinnamon/configs/menu@cinnamon.org/0.json https://raw.githubusercontent.com/kawics11/dotfiles/main/.cinnamon/configs/menu%40cinnamon.org/0.json
curl -o ~/.cinnamon/configs/grouped-window-list@cinnamon.org/1.json https://raw.githubusercontent.com/kawics11/dotfiles/main/.cinnamon/configs/grouped-window-list%40cinnamon.org/1.json
curl -o ~/.cinnamon/configs/notifications@cinnamon.org/notifications@cinnamon.org.json https://raw.githubusercontent.com/kawics11/dotfiles/main/.cinnamon/configs/notifications%40cinnamon.org/notifications%40cinnamon.org.json
curl -o ~/.cinnamon/configs/printers@cinnamon.org/5.json https://raw.githubusercontent.com/kawics11/dotfiles/main/.cinnamon/configs/printers%40cinnamon.org/5.json
curl -o ~/.cinnamon/configs/sound@cinnamon.org/sound@cinnamon.org.json https://raw.githubusercontent.com/kawics11/dotfiles/main/.cinnamon/configs/sound%40cinnamon.org/sound%40cinnamon.org.json
curl -o ~/.cinnamon/configs/power@cinnamon.org/power@cinnamon.org.json https://raw.githubusercontent.com/kawics11/dotfiles/main/.cinnamon/configs/power%40cinnamon.org/power%40cinnamon.org.json
curl -o ~/.cinnamon/configs/calendar@cinnamon.org/11.json https://raw.githubusercontent.com/kawics11/dotfiles/main/.cinnamon/configs/calendar%40cinnamon.org/11.json
curl -o ~/.cinnamon/configs/show-desktop@cinnamon.org/12.json https://raw.githubusercontent.com/kawics11/dotfiles/main/.cinnamon/configs/show-desktop%40cinnamon.org/12.json

sudo sed -i 's/ENABLED=no/ENABLED=yes/'	/etc/ufw/ufw.conf #Enable firewall

gsettings set com.linuxmint.updates			show-welcome-page		false	#Disable update manager welcome screen
gsettings set com.linuxmint.updates			hide-kernel-update-warning	true	#Disable warning screen in the kernel menu
gsettings set com.linuxmint.updates			show-size-column		true	#Enable the size column in the update manager

gsettings set org.x.pix.slideshow			automatic			false	#Disable automatic slideshow
gsettings set org.x.pix.pixbuf-savers.jpeg		quality				100	#Set jpeg quality to 100

gsettings set io.github.celluloid-player.Celluloid	always-autohide-cursor		true	#Hide the cursor in windowed mode
gsettings set io.github.celluloid-player.Celluloid	last-folder-enable		true	#Remember the last accessed folder

gsettings set org.gnome.rhythmbox.pluginsr active-plugins "[\
	'android', \
	'power-manager', \
	'mtpdevice', \
	'dbus-media-server', \
	'fmradio', \
	'generic-player', \
	'mmkeys', \
	'iradio', \
	'audiocd', \
	'ipod', \
	'mpris', \
	'rb', \
	'lyrics', \
	'artsearch']" #Set the enabled plugins
gsettings set org.gnome.rhythmbox.plugins.lyrics sites "[\
	'winampcn.com', \
	'terra.com.br', \
	'darklyrics.com', \
	'j-lyric.net', \
	'jetlyrics.com']" #Set the enabled lyrics sites

gsettings set org.nemo.preferences			inherit-folder-viewer		true	#Make folders inherit their parents' view type
gsettings set org.nemo.preferences			date-format			'iso'	#Use the ISO date format

gsettings set org.gnome.gnome-screenshot		include-pointer			true	#Include the pointer in screenshots

gsettings set org.x.editor.preferences.editor		auto-indent			true	#Enable auto indent
gsettings set org.x.editor.preferences.editor		auto-save			true	#Enable auto saving files
gsettings set org.x.editor.preferences.editor		bracket-matching		true	#Highlight matching brackets
gsettings set org.x.editor.preferences.editor		display-line-numbers		true	#Show line numbers
gsettings set org.x.editor.preferences.editor		display-right-margin		true	#Show right margin
gsettings set org.x.editor.preferences.editor		right-margin-position		80	#Set the right margin to 80 characters
gsettings set org.x.editor.preferences.editor		highlight-current-line		true	#Highlight the current line
gsettings set org.x.editor.preferences.editor		prefer-dark-theme		true	#Use dark theme when possible

gsettings set org.gnome.Terminal.Legacy.Settings	menu-accelerator-enabled	false	#Disable the menu accelerator in the terminal
gsettings set org.gnome.Terminal.Legacy.Profile		audible-bell			true	#Enable the terminal bell
gsettings set org.gnome.Terminal.Legacy.Profile		exit-axtion			'hold'	#Hold the terminal open after the command exits

gsettings set org.gnome.calculator			show-thousands			true	#Show thousands separator



sudo apt autoremove -qq -y
dpkg -l | grep ^rc | awk '{print $2}' | xargs sudo apt purge -qq -y

