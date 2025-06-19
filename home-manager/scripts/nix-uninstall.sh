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

remove_package() {
    local package="$1"
    local flake_file="$HOME/.config/nix-darwin/flake.nix"
    
    if [[ ! -f "$flake_file" ]]; then
        echo "Error: flake.nix not found at $flake_file"
        return 1
    fi
    
    if ! grep -q "\b$package\b" "$flake_file"; then
        echo "Warning: Package '$package' not found in flake.nix"
        return 1
    fi
    
    local temp_file
    temp_file=$(mktemp)
    
    awk -v pkg="$package" '
        /environment.systemPackages = with nixpkgs.legacyPackages.aarch64-darwin; \[/ {
            print $0
            getline
            n = split($0, words, " ")
            new_line = ""
            for (i = 1; i <= n; i++) {
                if (words[i] != pkg && words[i] != "") {
                    if (new_line == "") {
                        new_line = words[i]
                    } else {
                        new_line = new_line " " words[i]
                    }
                }
            }
            if (match($0, /^[[:space:]]*/)) {
                indent = substr($0, 1, RLENGTH)
                print indent new_line
            } else {
                print new_line
            }
            next
        }
        { print }
    ' "$flake_file" > "$temp_file"
    
    if [[ $? -eq 0 ]]; then
        mv "$temp_file" "$flake_file"
        echo "Successfully removed package '$package' from flake.nix"
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

echo "Removing package '$package_name' from flake.nix..."
if ! remove_package "$package_name"; then
    echo "Error: Failed to remove package from flake.nix"
    exit 1
fi

echo "Running nix-sync to apply changes..."
find_and_execute_script "nix-sync" -m "Remove package: $package_name" || {
    echo "Error: Failed to sync changes"
    exit 1
}

echo "Successfully removed and applied package '$package_name'" 