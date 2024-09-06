#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix

VERSION=$(curl -H 'X-Ubuntu-Series: 16' https://api.snapcraft.io/api/v1/snaps/details/termius-app | jq '.version')
DOWNLOAD_URL=$(curl -H 'X-Ubuntu-Series: 16' https://api.snapcraft.io/api/v1/snaps/details/termius-app | jq '.download_url' -r)
SHASUM=$(curl -H 'X-Ubuntu-Series: 16' https://api.snapcraft.io/api/v1/snaps/details/termius-app | jq '.download_sha512' -r)
SRI512SUM=$(nix-hash --type sha512 --to-sri $SHASUM)

echo "The latest SRI for version $VERSION is "
echo "$SRI512SUM"
