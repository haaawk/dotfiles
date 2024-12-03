{
  description = "haaawk's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-turso = {
      url = "github:tursodatabase/homebrew-tap";
      flake = false;
    };
    homebrew-sqld = {
      url = "github:libsql/homebrew-sqld";
      flake = false;
    };
  };

  outputs = inputs@{
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    homebrew-turso,
    homebrew-sqld,
    ... }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;
      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.alacritty
          pkgs.vim
          pkgs.neovim
          pkgs.git
          pkgs.tmux
        ];

      homebrew = {
        enable = true;
        brews = [
          "tursodatabase/tap/turso"
        ];
        casks = [
          "1password"
          "1password-cli"
          "cursor"
          "docker"
          "discord"
          "goland"
          "google-chrome"
          "logitune"
          "moom"
          "pycharm"
          "rustrover"
          "slack"
          "telegram"
          "the-unarchiver"
          "wireshark"
          "visual-studio-code"
          "zoom"
        ];
       onActivation.cleanup = "zap";
       onActivation.autoUpdate = true;
       onActivation.upgrade = true;
      };

      services.nix-daemon.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      programs.zsh.enable = true;

      environment.shells = with pkgs; [ bash zsh ];

      security.pam.enableSudoTouchIdAuth = true;

      home-manager.verbose = true;
      users.users.haaawk = {
        name = "haaawk";
        home = "/Users/haaawk";
        shell = pkgs.zsh;
      };
      home-manager.backupFileExtension = "backup";
      nix.configureBuildUsers = true;
      nix.useDaemon = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      system.keyboard = {
        enableKeyMapping = true;
        nonUS.remapTilde = true;
        remapCapsLockToEscape = true;
      };

      system.defaults = {
        dock = {
          autohide = true;
          mru-spaces = false;
          orientation = "bottom";
          show-recents = false;
          persistent-apps = [
            "/Applications/Google Chrome.app"
            "/Applications/Safari.app"
          ];
          persistent-others = [
            "/Users/haaawk"
            "/Users/haaawk/Downloads"
          ];
          static-only = false;
          tilesize = 256;
        };
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          CreateDesktop = false;
          NewWindowTarget = "Home";
          QuitMenuItem = true;
          ShowPathbar = true;
          ShowStatusBar = true;
          _FXShowPosixPathInTitle = true;
          _FXSortFoldersFirst = true;
        };
        menuExtraClock = {
          IsAnalog = false;
          FlashDateSeparators = false;
          ShowDayOfWeek = false;
          Show24Hour = true;
          ShowAMPM = false;
          ShowDate = 1;
          ShowDayOfMonth = true;
          ShowSeconds = false;
        };
        NSGlobalDomain = {
          _HIHideMenuBar = true;
          AppleInterfaceStyle = "Dark";
        };
      };

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          echo "setting up /Applications..." >&2
          rm -rf "/Applications/Nix Apps"
          mkdir -p "/Applications/Nix Apps"
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            cp -fHRL "$src" "/Applications/Nix Apps/"
            chmod -R +w "/Applications/Nix Apps/$app_name"
          done
        '';
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#haaawk-macbook
    darwinConfigurations."haaawk-macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        configuration
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.haaawk = import ./home.nix;
        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "haaawk";
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
              "tursodatabase/tap" = homebrew-turso;
              "libsql/homebrew-sqld" = homebrew-sqld;
            };
            mutableTaps = true;
          };
        }
      ];
    };
  };
}
