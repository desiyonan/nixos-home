#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
HOST="${1:-root@s71.dnfn.tech}"

export NIX_SSHOPTS="-o IdentitiesOnly=yes -i ${HOME}/.ssh/id_ed25519 -i ${HOME}/.ssh/id_rsa"
SSH=(ssh ${NIX_SSHOPTS})

cd "$REPO_ROOT"

echo "=== build .#s71 (~2.5G) ==="
OUT=$(nix build '.#nixosConfigurations.s71.config.system.build.toplevel' --print-out-paths)
echo "system: $OUT"

echo "=== remote gc ==="
"${SSH[@]}" "$HOST" 'nix-collect-garbage -d || true; df -h /'

echo "=== copy closure ==="
nix copy --to "ssh://$HOST" "$OUT"

echo "=== switch ==="
"${SSH[@]}" "$HOST" "$OUT/bin/switch-to-configuration switch"

echo "=== verify ==="
"${SSH[@]}" "$HOST" 'hostname; readlink /run/current-system | xargs basename'
