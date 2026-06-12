# Custom shell helpers. List them with `funcs`.
# Convention: trailing `## description` on the function definition line.

take() { ## mkdir -p and cd into it
  mkdir -p -- "$1" && cd -- "$1"
}

bak() { ## timestamped backup copy of a file
  cp -- "$1" "$1.bak.$(date +%s)"
}

up() { ## cd up N directories (default 1)
  local levels=${1:-1} path=""
  for ((i = 0; i < levels; i++)); do path+="../"; done
  cd "$path" || return
}

fkill() { ## fzf-pick a process and kill it (signal arg optional, default TERM)
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  [[ -n "$pid" ]] && echo "$pid" | xargs kill -"${1:-15}"
}

fcd() { ## fzf-pick a subdirectory and cd into it
  local dir
  dir=$(fd --type d --hidden --exclude .git | fzf) && cd "$dir"
}

fgco() { ## fzf-pick a git branch and check it out
  local branch
  branch=$(git branch --all | grep -v HEAD | sed 's/^[* ] //;s|^remotes/origin/||' | sort -u | fzf) \
    && git checkout "$branch"
}

fjco() { ## fzf-pick a jj bookmark and `jj edit` it
  local bookmark
  bookmark=$(jj bookmark list -T 'name ++ "\n"' | fzf) && jj edit "$bookmark"
}

extract() { ## extract an archive based on its extension
  [[ -f "$1" ]] || { echo "extract: '$1' is not a file" >&2; return 1; }
  case "$1" in
    *.tar.bz2 | *.tbz2) tar xjf "$1" ;;
    *.tar.gz | *.tgz) tar xzf "$1" ;;
    *.tar.xz | *.txz) tar xJf "$1" ;;
    *.tar.zst) tar --zstd -xf "$1" ;;
    *.tar) tar xf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.gz) gunzip "$1" ;;
    *.xz) unxz "$1" ;;
    *.zst) unzstd "$1" ;;
    *.zip) unzip "$1" ;;
    *.7z) 7z x "$1" ;;
    *.rar) unrar x "$1" ;;
    *) echo "extract: don't know how to handle '$1'" >&2; return 1 ;;
  esac
}

weather() { ## fetch weather for a city (defaults to IP location)
  curl -fsS "wttr.in/${1:-}"
}

genpass() { ## generate a random base64 password (default 24 chars)
  openssl rand -base64 "${1:-24}"
}

funcs() { ## list these custom functions
  awk -F'## ' '/^[a-z_]+\(\) \{ ##/ {sub(/\(\).*/, "", $1); printf "  %-10s %s\n", $1, $2}' \
    ~/.config/zsh/functions.zsh
}
