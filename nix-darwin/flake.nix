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
                  extraConfig = {
                    credential.helper = "osxkeychain";
                  };
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
            git python3 nodejs tree htop rustup neovim
          ];

          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          security.pam.services.sudo_local.touchIdAuth = true;

        }
      ];
    };
  };
}
