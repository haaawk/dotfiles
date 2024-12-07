#!/bin/bash
cd ~/dotfiles/nix-darwin
nix flake update
darwin-rebuild switch --flake .#haaawk-macbook
cd -
