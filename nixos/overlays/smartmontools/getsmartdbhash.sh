#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=/etc/nix/inputs/nixpkgs/ -i bash -p nix
set -euo pipefail

dbrev="5613"
drivedbBranch="RELEASE_7_4"
url="https://sourceforge.net/p/smartmontools/code/${dbrev}/tree/trunk/smartmontools/drivedb.h?format=raw";

echo "Fetching hash for URL: $url"

hash=$(nix-prefetch-url "$url")
sri=$(nix-hash --type sha256 --flat --base32 --to-sri "$hash")

echo "Hash: $hash"
echo "Sri: $sri"
