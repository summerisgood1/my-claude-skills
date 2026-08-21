#!/usr/bin/env bash
# Link every skill in this repo into the agent skills directories.
#
#   git clone git@github.com:summerisgood1/my-claude-skills.git ~/src/my-claude-skills
#   cd ~/src/my-claude-skills && ./install.sh
#
# Symlinks, so `git pull` is the update. Safe to re-run.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"

for dir in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
    mkdir -p "$dir"
    for skill in "$SRC"/*/; do
        name="$(basename "$skill")"
        ln -sfn "${skill%/}" "$dir/$name"
        echo "linked: $dir/$name"
    done
done
