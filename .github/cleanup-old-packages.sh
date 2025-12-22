#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=false

usage() {
    echo "Usage: $0 [--force] [--help]"
    echo ""
    echo "Remove old package versions, keeping only the most recent semver version."
    echo ""
    echo "Options:"
    echo "  --force    Actually delete files (default is dry-run)"
    echo "  --help     Show this help message"
    echo ""
    echo "Directories cleaned: apt, yum, darwin, linux"
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Extract version from filename (e.g., dotsecenv_0.0.4_amd64.deb -> 0.0.4)
extract_version() {
    local filename="$1"
    echo "$filename" | sed -E 's/dotsecenv_([0-9]+\.[0-9]+\.[0-9]+)_.*/\1/'
}

# Get the latest version from a list of package files
get_latest_version() {
    local files=("$@")
    local versions=()

    for file in "${files[@]}"; do
        local version
        version=$(extract_version "$(basename "$file")")
        versions+=("$version")
    done

    # Sort versions and get the highest one
    printf '%s\n' "${versions[@]}" | sort -uV | tail -1
}

# Regenerate checksums.txt for a directory
regenerate_checksums() {
    local dir="$1"

    echo "  Regenerating checksums.txt..."

    cd "$dir"
    local pattern=""

    case "$dir" in
        */apt)    pattern="*.deb" ;;
        */yum)    pattern="*.rpm" ;;
        */darwin) pattern="*.tar.gz" ;;
        */linux)  pattern="*.tar.gz" ;;
    esac

    # Find package files (exclude .sig files)
    local file_list
    file_list=$(find . -maxdepth 1 -name "$pattern" ! -name "*.sig" -type f 2>/dev/null | sed 's|^\./||' | sort)

    if [[ -n "$file_list" ]]; then
        # Use shasum on macOS, sha256sum on Linux
        local sha_cmd="sha256sum"
        if ! command -v sha256sum &> /dev/null; then
            sha_cmd="shasum -a 256"
        fi

        echo "$file_list" | xargs $sha_cmd > checksums.txt
        local count
        count=$(echo "$file_list" | wc -l | tr -d ' ')
        echo "  Updated checksums.txt with $count files"
    else
        echo "  No package files found, removing checksums.txt"
        rm -f checksums.txt
    fi

    cd - > /dev/null
}

# Process a single directory
cleanup_directory() {
    local dir="$1"
    local extension="$2"
    local dir_name
    dir_name=$(basename "$dir")

    echo ""
    echo "=== Processing $dir_name ==="

    if [[ ! -d "$dir" ]]; then
        echo "  Directory not found: $dir"
        return
    fi

    # Find all package files
    local files=()
    while IFS= read -r line; do
        [[ -n "$line" ]] && files+=("$line")
    done < <(find "$dir" -maxdepth 1 -name "*$extension" ! -name "*.sig" -type f 2>/dev/null | sort)

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "  No package files found"
        return
    fi

    echo "  Found ${#files[@]} package file(s)"

    # Get the latest version
    local latest_version
    latest_version=$(get_latest_version "${files[@]}")
    echo "  Latest version: $latest_version"

    # Separate files to keep vs delete
    local to_delete=()
    local to_keep=()

    for file in "${files[@]}"; do
        local version
        version=$(extract_version "$(basename "$file")")

        if [[ "$version" == "$latest_version" ]]; then
            to_keep+=("$file")
        else
            to_delete+=("$file")
            # Also add corresponding .sig file if it exists
            if [[ -f "${file}.sig" ]]; then
                to_delete+=("${file}.sig")
            fi
        fi
    done

    echo "  Keeping ${#to_keep[@]} file(s) (version $latest_version)"
    for file in "${to_keep[@]}"; do
        echo "    + $(basename "$file")"
    done

    if [[ ${#to_delete[@]} -eq 0 ]]; then
        echo "  Nothing to delete"
        return
    fi

    echo "  Deleting ${#to_delete[@]} file(s):"
    for file in "${to_delete[@]}"; do
        echo "    - $(basename "$file")"
    done

    if [[ "$FORCE" == true ]]; then
        for file in "${to_delete[@]}"; do
            rm -f "$file"
            echo "    Deleted: $(basename "$file")"
        done
        regenerate_checksums "$dir"
    else
        echo "  [DRY-RUN] No files deleted. Use --force to delete."
    fi
}

# Main
echo "Package Cleanup Script"
echo "======================"
if [[ "$FORCE" == true ]]; then
    echo "Mode: FORCE (files will be deleted)"
else
    echo "Mode: DRY-RUN (no files will be deleted)"
fi

cleanup_directory "$SCRIPT_DIR/apt" ".deb"
cleanup_directory "$SCRIPT_DIR/yum" ".rpm"
cleanup_directory "$SCRIPT_DIR/darwin" ".tar.gz"
cleanup_directory "$SCRIPT_DIR/linux" ".tar.gz"

echo ""
echo "======================"
if [[ "$FORCE" == true ]]; then
    echo "Cleanup complete."
else
    echo "Dry-run complete. Use --force to actually delete files."
fi
