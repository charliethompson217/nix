{ config, pkgs, ... }:
{
  home = {
    username = "charlesthompson";
    homeDirectory = "/Users/charlesthompson";
    stateVersion = "23.05";
    
    packages = [
      pkgs.oh-my-zsh
      pkgs.zsh-autosuggestions
      pkgs.zsh-syntax-highlighting
      pkgs.powerline-fonts
      pkgs.zsh-powerlevel10k
      pkgs.neofetch
    ];

    file = {
      ".gitconfig".source = ./dotfiles/gitconfig;
      ".zshrc".source = ./dotfiles/zshrc;
      ".config/neofetch/config.conf".source = ./dotfiles/neofetch.conf;
      ".p10k.zsh".source = ./dotfiles/p10k.zsh;
      ".prettierrc".source = ./dotfiles/prettierrc;
      ".local/bin/nix-sync" = {
        source = ./scripts/nix-sync.sh;
        executable = true;
      };
     ".local/bin/nix-install" = {
        source = ./scripts/nix-install.sh;
        executable = true;
      };
      ".local/bin/nix-uninstall" = {
        source = ./scripts/nix-uninstall.sh;
        executable = true;
      };
    };

    sessionVariables = {
      EDITOR = "vim";
      ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    };
  };

  programs.zsh.enable = false;
  
  programs.home-manager.enable = true;

}
