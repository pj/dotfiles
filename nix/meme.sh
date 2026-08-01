# meme — print a meme in the terminal as a single character at its
# Supplementary PUA (Plane 16) code point. It's normal cell content, so —
# unlike an OSC 1337 inline image — it survives tmux redraws (an OSC 1337
# image only displays until the next redraw of any kind, since tmux doesn't
# track image bytes in its own screen buffer). Requires MemeTerminal (the
# iTerm2 fork at github:pj/iTerm2, branch memeterminal) with MemeFont.ttf
# installed and selected as the terminal font; other terminals show tofu.
#
# Usage:
#   meme <name>   # prints the character for <name>
#   meme          # lists available memes
#   meme-ls       # same listing, standalone
#
# Drop images into $MEME_DIR (default: ~/dotfiles/nix/memes) named however
# you like; reference them by filename without the extension.
#
# Code points are assigned by sorted position, not stored per-name: the Nth
# name (byte-order sorted, extension stripped, deduplicated) in $MEME_DIR
# gets U+100000 + N. emojifont's build_meme_mappings_from_dir (used by the
# Nix derivation that builds MemeFont.ttf, see dotfiles/nix/flake.nix) and
# commandline_thing's MemeCodepoint compute the exact same thing
# independently — there's no manifest file, so the font must be rebuilt
# whenever this directory's contents change or the two fall out of sync.

MEME_DIR="${MEME_DIR:-$HOME/dotfiles/nix/memes}"

# U+100000: start of the Supplementary Private Use Area (Plane 16). Matches
# commandline_thing's MemeCodepointBase.
MEME_CODEPOINT_BASE=1048576

meme() {
  if [ -z "$1" ]; then
    echo "Usage: meme <name>" >&2
    meme-ls >&2
    return 1
  fi

  local name="$1"
  # Byte-order sort (LC_ALL=C) so this matches Go's sort.Strings and
  # Python's sorted() regardless of the shell's locale — those are what
  # actually assign code points when the font is built.
  local stems
  stems=$(command ls "$MEME_DIR" 2>/dev/null | /usr/bin/sed 's/\.[^.]*$//' | LC_ALL=C /usr/bin/sort -u)

  local resolved
  resolved=$(printf '%s\n' "$stems" | /usr/bin/grep -Fx "$name")
  if [ -z "$resolved" ]; then
    # Case-insensitive fallback. More than one match (e.g. both "Pepe" and
    # "pepe" present as distinct entries) is ambiguous — bail rather than
    # silently picking one.
    local matches
    matches=$(printf '%s\n' "$stems" | /usr/bin/grep -ix "$name")
    local match_count
    match_count=$(printf '%s\n' "$matches" | /usr/bin/grep -c .)
    if [ "$match_count" -eq 1 ]; then
      resolved="$matches"
    elif [ "$match_count" -gt 1 ]; then
      echo "meme: '$name' is ambiguous, matches:" >&2
      printf '%s\n' "$matches" >&2
      return 1
    fi
  fi

  if [ -z "$resolved" ]; then
    echo "meme: no meme named '$name' in $MEME_DIR" >&2
    meme-ls >&2
    return 1
  fi

  local line
  line=$(printf '%s\n' "$stems" | /usr/bin/grep -nFx "$resolved" | /usr/bin/head -1 | /usr/bin/cut -d: -f1)
  local codepoint=$((MEME_CODEPOINT_BASE + line - 1))

  printf "\\U$(printf '%08X' "$codepoint")"
}

meme-ls() {
  if [ ! -d "$MEME_DIR" ]; then
    echo "meme: $MEME_DIR does not exist" >&2
    return 1
  fi
  echo "Available memes in $MEME_DIR:"
  command ls "$MEME_DIR" 2>/dev/null | /usr/bin/sed 's/\.[^.]*$//' | LC_ALL=C /usr/bin/sort -u
}
