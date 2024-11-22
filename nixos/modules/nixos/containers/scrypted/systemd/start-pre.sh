#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

podman rm -f scrypted || true
rm -f /run/scrypted.ctr-id
