#!/bin/bash
sudo rm /etc/nix/nix.conf
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/dotfiles/nix-darwin#haaawk-macbook
