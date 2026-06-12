# Runs lua-language-server against the rendered Hyprland lua, using the
# hl.meta.lua stubs shipped with pkgs.hyprland for type info. Catches typo'd
# globals, undefined fields on typed namespaces (e.g. hl.dsp.window.foo), and
# wrong-arg-type calls on typed APIs (hl.bind, hl.exec_cmd, hl.dispatch).
#
# Does NOT catch wrong arg shapes for variadic `fun(...)` wrappers (most
# hl.dsp.* dispatcher constructors) — those need runtime checks.
#
# All lua is staged by the sample HM activation under home-files/.config/hypr/.
{ pkgs, hyprDir }:
pkgs.runCommand "hyprland-luals"
  {
    nativeBuildInputs = [
      pkgs.lua-language-server
      pkgs.jq
    ];
  }
  ''
    set -euo pipefail
    # Stage every lua file into a writable workspace so cross-module require()
    # resolves and diagnostics span the lot.
    work=$(mktemp -d)
    cp -L "${hyprDir}/"*.lua "$work/"
    cat > "$work/.luarc.json" <<EOF
    {
      "diagnostics": {
        "globals": ["hl"]
      },
      "workspace": {
        "library": ["${pkgs.hyprland}/share/hypr/stubs"]
      },
      "runtime": {
        "version": "LuaJIT"
      }
    }
    EOF

    export HOME=$(mktemp -d)
    # --check exits non-zero on problems, so don't let `set -e` short-circuit us
    # before we format the errors. luals writes problems to log/check.json.
    lua-language-server \
      --check "$work" \
      --logpath "$work/log" \
      --checklevel=Information \
      --check_format=json || true

    if [ -s "$work/log/check.json" ]; then
      probCount=$(jq '[.[][]] | length' < "$work/log/check.json")
      if [ "$probCount" -gt 0 ]; then
        echo "" >&2
        echo "luals found $probCount problem(s) in rendered hyprland lua:" >&2
        echo "" >&2
        jq -r '
          to_entries[]
          | .key as $file
          | .value[]
          | "  \($file | sub(".*/"; "")):\(.range.start.line + 1):\(.range.start.character + 1): [\(.code)] \(.message)"
        ' < "$work/log/check.json" >&2
        exit 1
      fi
    fi
    touch "$out"
  ''
