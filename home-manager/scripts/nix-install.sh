#!/bin/zsh

find_and_execute_script() {
    local script_name="$1"
    shift
    
    local script_path
    
    script_path="$(which "${script_name}.sh" 2>/dev/null)"
    if [[ -n "$script_path" && -x "$script_path" ]]; then
        "$script_path" "$@"
        return $?
    fi
    
    script_path="$(which "$script_name" 2>/dev/null)"
    if [[ -n "$script_path" && -x "$script_path" ]]; then
        "$script_path" "$@"
        return $?
    fi
    
    echo "Error: Could not find executable script '$script_name' or '${script_name}.sh' in PATH"
    return 1
}

check_package_exists() {
    local package="$1"
    nix search nixpkgs "$package" >/dev/null 2>&1
    return $?
}

add_package() {
    local package="$1"
    local flake_file="$HOME/.config/nix-darwin/flake.nix"
    
    if [[ ! -f "$flake_file" ]]; then
        echo "Error: flake.nix not found at $flake_file"
        return 1
    fi
    
    local temp_file
    temp_file=$(mktemp)
    
    awk -v pkg="$package" '
        /environment.systemPackages = with nixpkgs.legacyPackages.aarch64-darwin; \[/ {
            print $0
            getline
            print $0 " " pkg
            next
        }
        { print }
    ' "$flake_file" > "$temp_file"
    
    if [[ $? -eq 0 ]]; then
        mv "$temp_file" "$flake_file"
        echo "Successfully added package '$package' to flake.nix"
        return 0
    else
        echo "Error: Failed to modify flake.nix"
        rm -f "$temp_file"
        return 1
    fi
}

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <package_name>"
    exit 1
fi

package_name="$1"

echo "Verifying package '$package_name' exists in nixpkgs..."
if ! check_package_exists "$package_name"; then
    echo "Error: Package '$package_name' not found in nixpkgs"
    exit 1
fi

echo "Adding package '$package_name' to flake.nix..."
if ! add_package "$package_name"; then
    echo "Error: Failed to add package to flake.nix"
    exit 1
fi

echo "Running nix-sync to apply changes..."
find_and_execute_script "nix-sync" -m "Add package: $package_name" || {
    echo "Error: Failed to sync changes"
    exit 1
}

echo "Successfully added and applied package '$package_name'"

