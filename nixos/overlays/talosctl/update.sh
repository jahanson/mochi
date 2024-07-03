#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=/etc/nix/inputs/nixpkgs/ -i bash -p curl jq common-updater-scripts gnused nix coreutils

set -euo pipefail

latestVersion="$(curl -s "https://api.github.com/repos/siderolabs/talos/releases?per_page=1" | jq -r ".[0].tag_name" | sed 's/^v//')"
currentVersion=$(nix-instantiate --eval -E "with import /etc/nix/inputs/nixpkgs {}; talosctl.version or (lib.getVersion talosctl)" | tr -d '"')

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "talosctl is up-to-date: $currentVersion"
  exit 0
fi

update-source-version talosctl "$latestVersion"