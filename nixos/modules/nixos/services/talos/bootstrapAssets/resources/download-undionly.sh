#!/usr/bin/env nix-shell
#!nix-shell -i bash -p cacert curl --pure
#shellcheck shell=bash
set -eu -o pipefail

# Check if argument $1 is set
if [ -z "${1:-}" ]; then
    echo "Usage: $0 <path>"
    exit 1
fi

path="$1"

# Check is file exists and exit with success.
if [ -f "$path/undionly.kpxe" ]; then
    echo "File $path/undionly.kpxe already exists."
    exit 0
fi

echo "Downloading assets to $path"

# Check if the directory exists
if [ ! -d "$(dirname "$path")" ]; then
    echo "Error: "$path" does not exist."
    exit 1
fi

# Check if the path is writable
if [ ! -w "$path" ]; then
    echo "Error: $path is not writable."
    exit 1
fi

# Download the file
curl -o "$path/undionly.kpxe" http://boot.ipxe.org/undionly.kpxe
