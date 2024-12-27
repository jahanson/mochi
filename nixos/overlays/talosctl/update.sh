#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=/etc/nix/inputs/nixpkgs -i bash -p curl jq common-updater-scripts gnused nix coreutils perl nix-prefetch-git

set -euo pipefail

echo "Fetching latest version..."
latestVersion="$(curl -s "https://api.github.com/repos/siderolabs/talos/releases?per_page=1" | jq -r ".[0].tag_name" | sed 's/^v//')"
echo "Latest version: $latestVersion"

nixFile="$(realpath "$(dirname "$0")/default.nix")"
echo "Getting current version from $nixFile..."
currentVersion=$(grep 'version = ' "$nixFile" | cut -d'"' -f2)
echo "Current version: $currentVersion"

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "talosctl is up-to-date: $currentVersion"
  exit 0
fi

echo "Updating version in $nixFile from $currentVersion to $latestVersion"

# Create a temporary nix expression to get the vendor hash
tmpFile=$(mktemp)
cat > "$tmpFile" <<EOF
{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib }:

pkgs.buildGoModule rec {
  pname = "talosctl";
  version = "$latestVersion";

  src = pkgs.fetchFromGitHub {
    owner = "siderolabs";
    repo = "talos";
    rev = "v\${version}";
    hash = lib.fakeHash;
  };

  vendorHash = null;

  subPackages = [ "cmd/talosctl" ];
}
EOF

# Get the source hash
echo "Fetching source hash..."
srcHash=$(nix hash to-sri --type sha256 $(nix-prefetch-git --url https://github.com/siderolabs/talos --rev "v${latestVersion}" | jq -r .sha256))
echo "New source hash: $srcHash"

# Update version and source hash first
echo "Updating version and source hash..."
sed -i "s/version = \"${currentVersion}\"/version = \"${latestVersion}\"/" "$nixFile"
sed -i "s|hash = \"[^\"]*\"|hash = \"${srcHash}\"|" "$nixFile"

# Try to build it to get the vendor hash
echo "Building to get vendor hash..."
if ! buildOutput=$(nix-build "$tmpFile" 2>&1); then
  if vendorHash=$(echo "$buildOutput" | grep -oP 'got:.*' | cut -d: -f2- | tr -d " "); then
    echo "New vendor hash: $vendorHash"
    sed -i "s|vendorHash = \"[^\"]*\"|vendorHash = \"${vendorHash}\"|" "$nixFile"

    # Try building again with the new vendor hash
    echo "Verifying build with new vendor hash..."
    if nix-build -E "with import <nixpkgs> {}; callPackage $nixFile {}" --no-out-link; then
      echo "Build successful!"
    else
      echo "Error: Build failed with new vendor hash"
      exit 1
    fi
  else
    echo "Error: Could not extract vendor hash from build output"
    echo "Build output: $buildOutput"
    exit 1
  fi
else
  echo "Warning: Build succeeded without needing to update vendor hash"
fi

rm "$tmpFile"

echo "File contents after update:"
cat "$nixFile"
