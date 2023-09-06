#! /bin/bash

install_font () {
	echo Installing Iosevka font...;
	wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Iosevka.zip;
	mkdir -p $HOME/.local/share/fonts;
	mkdir font;
	cd font;
	unzip ../Iosevka.zip;
	mv ./* $HOME/.local/share/fonts/;
	fc-cache -v;
	cd ..;
	
	echo "Clearing Iosevka install files";
	rm -rf font;
	rm Iosevka.zip


}

ROOT_DIR=$(git rev-parse --show-toplevel)

ln -s -T $ROOT_DIR/nvim $HOME/.config/nvim

install_font
