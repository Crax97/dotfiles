#! /bin/bash

ROOT_DIR=$(git rev-parse --show-toplevel)

ln -s -T $ROOT_DIR/nvim $HOME/.config/nvim
