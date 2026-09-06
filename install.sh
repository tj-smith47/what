#!/usr/bin/env bash
# Symlink `what` into PATH. Usage: ./install.sh [dir]   (default ~/.local/bin)
set -euo pipefail

dir=${1:-${PREFIX:-$HOME/.local/bin}}
src=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/what

mkdir -p "$dir"
ln -sfn "$src" "$dir/what"
echo "installed: $dir/what -> $src"

case ":$PATH:" in *":$dir:"*) ;; *) echo "warning: $dir is not on PATH" >&2 ;; esac
command -v claude >/dev/null || echo "warning: 'claude' not found on PATH" >&2
