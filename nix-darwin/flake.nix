{
  description = "Darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager, nix-homebrew, homebrew-core, homebrew-cask }: {
    darwinConfigurations."charless-MacBook-Air" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        {
          nixpkgs.config.allowUnfree = true;

          users.users.charlesthompson = {
            home = "/Users/charlesthompson";
          };

          system.stateVersion = 5;

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            users.charlesthompson = { pkgs, ... }: {
              home = {
                stateVersion = "23.11";
                username = "charlesthompson";
                homeDirectory = "/Users/charlesthompson";
              };

              programs.home-manager.enable = true;

              programs = {
                git = {
                  enable = true;
                  userName = "Charles Thompson";
                  userEmail = "80548854+charliethompson217@users.noreply.github.com";
                };
              };
            };
          };

          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "charlesthompson";

            taps = {
              "homebrew/core" = homebrew-core;
              "homebrew/cask" = homebrew-cask;
            };

            mutableTaps = false;
          };

          environment = {
            systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];
            pathsToLink = [
              "/opt/homebrew/bin"
              "/opt/homebrew/sbin"
            ];
          };

          environment.systemPackages = with nixpkgs.legacyPackages.aarch64-darwin; [
            git python3 nodejs tree tmux htop
          ];

          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          services.nix-daemon.enable = true;

          security.pam.enableSudoTouchIdAuth = true;

          system.defaults = {
            dock = {
              autohide = true;
              orientation = "bottom";
              showhidden = true;
              launchanim = false;
              mru-spaces = false;
              show-recents = false;
              tilesize = 40;
              persistent-apps = [
                "/System/Applications/System Settings.app"
                "/System/Applications/Launchpad.app"
                "/System/Applications/App Store.app"
                "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
                "/System/Applications/Utilities/Terminal.app"
                "/System/Applications/Messages.app"
                "/System/Applications/FaceTime.app"
                "/System/Applications/Music.app"
                "/System/Applications/Notes.app"
              ];
              persistent-others = [
                
              ];
            };
            NSGlobalDomain = {
              AppleShowAllExtensions = true;
              InitialKeyRepeat = 15;
              KeyRepeat = 2;
              "com.apple.swipescrolldirection" = false;
              AppleEnableSwipeNavigateWithScrolls = false;
              AppleInterfaceStyle = "Dark";
              NSAutomaticInlinePredictionEnabled = false;
              "com.apple.mouse.tapBehavior" = 1;
            };
            alf.globalstate = 1;
            controlcenter.BatteryShowPercentage = true;
            finder.FXPreferredViewStyle = "Nlsv";
            finder.ShowPathbar = true;
            finder._FXShowPosixPathInTitle = true;
            loginwindow.GuestEnabled = false;
            loginwindow.LoginwindowText = "(937) 301-0499";
            menuExtraClock = {
              FlashDateSeparators = true;
              ShowAMPM = true;
              ShowDate = 1;
              ShowDayOfMonth = true;
              ShowDayOfWeek = true;
              ShowSeconds = true;
            };
            screencapture.location = "/Users/charlesthompson/screenshots";
            screensaver.askForPassword = true;
            screensaver.askForPasswordDelay = 0;
            trackpad.Clicking = true;
            CustomUserPreferences = {
              "com.apple.Safari" = {
                "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
              };
            };
          };
        }
      ];
    };
  };
}
