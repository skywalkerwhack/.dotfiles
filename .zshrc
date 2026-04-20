# Created by newuser for 5.9



# =========================
# THEME (if using a prompt manager like starship)
# =========================
# fish_config theme choose "Rosé Pine"
# (no direct equivalent in zsh unless using a theme framework)

# =========================
# ALIASES
# =========================
alias fastfetch='fastfetch -l arch'
alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'
alias vi='nvim'

# modern unix aliases (optional)
# alias cat='bat --paging=never'
# alias less='bat --paging=always'
# alias du='dust'
# alias df='duf'
# alias ls='lsd -l'
# alias find='fd'

alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
alias archrolling='sudo pacman -Syu'
alias config_fish='vim ~/.config/fish/config.fish'
alias virenv='source ~/projects/py/virenv/bin/activate'

# =========================
# ENVIRONMENT VARIABLES
# =========================
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

export http_proxy='http://127.0.0.1:10808'
export https_proxy='http://127.0.0.1:10808'
export HTTP_PROXY='http://127.0.0.1:10808'
export HTTPS_PROXY='http://127.0.0.1:10808'

export GEM_HOME="$(gem env user_gemhome)"
export PATH="$GEM_HOME/bin:$PATH"

# =========================
# FUNCTIONS
# =========================

hiscal() {
  history 1 | awk '{print $2}' | sort | uniq -c | sort -nr | head -10
}

sy() {
  syncthing >/dev/null &
}

c_project() {
  mkdir -p src include build bin tests
  touch src/main.c include/.gitkeep README.md Makefile
}

man() {
  LESS_TERMCAP_mb=$(tput bold; tput setaf 2)
  LESS_TERMCAP_md=$(tput bold; tput setaf 6)
  LESS_TERMCAP_me=$(tput sgr0)
  LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
  LESS_TERMCAP_se=$(tput sgr0)
  LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7)
  LESS_TERMCAP_ue=$(tput sgr0)
  LESS_TERMCAP_mr=$(tput rev)
  LESS_TERMCAP_mh=$(tput dim)

  GROFF_NO_SGR=1 \
  command man "$@"
}

n() {
  # prevent nesting
  if [[ -n "$NNNLVL" && "$NNNLVL" -ne 0 ]]; then
    echo "nnn is already running"
    return
  fi

  export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

  command nnn "$@"

  if [[ -f "$NNN_TMPFILE" ]]; then
    source "$NNN_TMPFILE"
    rm -f "$NNN_TMPFILE"
  fi
}

litterbox() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: litterbox <file> [time]"
    return 1
  fi

  local file="$1"
  local time="${2:-1h}"

  curl -F "reqtype=fileupload" \
       -F "time=$time" \
       -F "fileToUpload=@$file" \
       https://litterbox.catbox.moe/resources/internals/api.php
}

gcm() {
  local TYPE SCOPE SUMMARY DESCRIPTION

  TYPE=$(gum choose fix feat docs style refactor test chore revert)
  SCOPE=$(gum input --placeholder "scope")

  [[ -n "$SCOPE" ]] && SCOPE="($SCOPE)"

  SUMMARY=$(gum input --value "$TYPE$SCOPE: " --placeholder "Summary of this change")
  DESCRIPTION=$(gum write --placeholder "Details of this change")

  gum confirm "Commit changes?" && git commit -m "$SUMMARY" -m "$DESCRIPTION"
}

# =========================
# INTERACTIVE SHELL BLOCK
# =========================
if [[ -o interactive ]]; then
  fortune
  echo ""
  print -n "\e[5 q"
fi

# =========================
# PLUGINS / TOOLS
# =========================
eval "$(thefuck --alias)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(fnm env --use-on-cd --shell zsh)"

