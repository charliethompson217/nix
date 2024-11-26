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
      pkgs.nerdfonts
      pkgs.vim
      pkgs.neofetch
    ];

    file = {
      ".gitconfig".source = ./dotfiles/gitconfig;
      ".zshrc".source = ./dotfiles/zshrc;
      ".vimrc".source = ./dotfiles/vimrc;
      ".config/neofetch/config.conf".source = ./dotfiles/neofetch.conf;
      ".p10k.zsh".source = ./dotfiles/p10k.zsh;
    };

    sessionVariables = {
      EDITOR = "vim";
      ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };

  programs.home-manager.enable = true;

}