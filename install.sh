#!/usr/bin/env bash
# Link mcuflash into ~/.local/bin and install its bash completion.
set -euo pipefail
repo="$(dirname "$(readlink -f "$0")")"
bin_dir="$HOME/.local/bin"
comp_dir="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions"
mkdir -vp "$bin_dir" "$comp_dir"
ln -sfv "$repo/mcuflash" "$bin_dir/mcuflash"
ln -sfv "$repo/completions/mcuflash.bash" "$comp_dir/mcuflash"
case ":$PATH:" in
    *":$bin_dir:"*) ;;
    *) echo "Note: $bin_dir is not on your PATH." ;;
esac
echo "Installed. Open a new shell for tab completion."
