#!/bin/zsh

# Script to update nix-darwin and Home Manager configurations, returning to original directory

set -e  # Exit on any error

# Save the current directory
ORIGINAL_DIR=$(pwd)

NEW_COMMIT=false
COMMIT_MESSAGE="$(date)"
while getopts "nm:" opt; do
    case $opt in
        n) NEW_COMMIT=true ;;
        m) NEW_COMMIT=true; COMMIT_MESSAGE="$OPTARG" ;;
        *) echo "Usage: $0 [-n | -m <message>]"; exit 1 ;;
    esac
done

if [ "$NEW_COMMIT" = true ]; then
    cd ~/.config
    git add --all
    git commit -m "$COMMIT_MESSAGE" || { echo "Failed to create new commit"; exit 1; }
fi

echo "Updating nix-darwin configuration..."
cd ~/.config/nix-darwin || { echo "Failed to cd to ~/.config/nix-darwin"; exit 1; }
git add --all
git commit --amend --no-edit
nix flake update || { echo "Failed to update nix-darwin flake"; exit 1; }
git add --all
git commit --amend --no-edit
sudo darwin-rebuild switch --flake . || { echo "Failed to apply nix-darwin configuration"; exit 1; }

echo "Updating Home Manager configuration..."
cd ~/.config/home-manager || { echo "Failed to cd to ~/.config/home-manager"; exit 1; }
nix flake update
git add --all
git commit --amend --no-edit
nix build .#homeConfigurations.charlesthompson.activationPackage || { echo "Failed to build Home Manager configuration"; exit 1; }
./result/activate || { echo "Failed to activate Home Manager configuration"; exit 1; }

echo "Cleaning up old Nix generations..."
nix-collect-garbage || { echo "Failed to run garbage collection"; exit 1; }

source ~/.zshrc || { echo "Failed to source ~/.zshrc"; exit 1; }

cd "$ORIGINAL_DIR" || { echo "Failed to return to original directory"; exit 1; }
