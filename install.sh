#! /bin/bash

install_font () {
	FONT_TO_INSTALL=$1;
	if [[ $FONT_TO_INSTALL == "" ]]
	then
		FONT_TO_INSTALL = "Iosevka"
	fi
	echo Installing $FONT_TO_INSTALL font...;
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/$FONT_TO_INSTALL.zip;
	mkdir -p $HOME/.local/share/fonts;
	mkdir font;
	cd font;
	unzip ../$FONT_TO_INSTALL.zip;
	mv ./* $HOME/.local/share/fonts/;
	fc-cache -v;
	cd ..;
	
	echo "Clearing $FONT_TO_INSTALL install files";
	rm -rf font;
	rm $FONT_TO_INSTALL.zip
}

ROOT_DIR=$(git rev-parse --show-toplevel)
config() {
	if [[ "$1" == "" ]]
	then
		echo "link_config(): no arg, return";
		return;
	fi

	echo "Linking config for $1"
	(ln -s -T $ROOT_DIR/$1 $HOME/.config/$1 ) 2>/dev/null
}

FONT_TO_INSTALL="Iosevka"

config "nvim"
config "kitty"

FOUND_FONTS=$(find $HOME/.local/share/fonts -iname "$FONT_TO_INSTALL*.ttf")
if [[ "${#FOUND_FONTS}" == "0" || $@ == *"--force-install-fonts"* ]]
then
	install_font $FONT_TO_INSTALL
else
	echo Avoid installing fonts
fi
