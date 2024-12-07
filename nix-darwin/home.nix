# home.nix
# home-manager switch

{ config, pkgs, ... }:
{
  home.username = "haaawk";
  home.homeDirectory = "/Users/haaawk";
  home.stateVersion = "23.05";

  # User specific packages
  home.packages = [];

  home.file = {
    # ".zshrc".source = ~/dotfiles/zshrc/.zshrc;
    # ".config/nvim".source = ~/dotfiles/nvim;
    # ".config/nix".source = ~/dotfiles/nix;
    # ".config/nix-darwin".source = ~/dotfiles/nix-darwin;
    # ".config/tmux".source = ~/dotfiles/tmux;
  };

  home.sessionVariables = {
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];
 
  programs.home-manager.enable = true;
  programs.zsh.enable = true;
  programs.zsh.initExtra = ''
    # Any additional configuration
    export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
  '';
}
