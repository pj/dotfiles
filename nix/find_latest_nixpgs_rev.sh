#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash curl jq
# shellcheck shell=bash

# Just go with the revision that works for stable darwin. Might as well for now
# unless there's an issue.

# DERIVED FROM: https://checkoway.net/musings/nix/

set -euo pipefail

revision=$(curl --silent --show-error 'https://monitoring.nixos.org/prometheus/api/v1/query?query=channel_revision' \
  | jq -r '.data.result[]|select(.metric.status == "stable" and .metric.variant == "darwin").metric.revision')

echo $revision