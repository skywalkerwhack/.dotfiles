# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# --------------------------------
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

export http_proxy='http://127.0.0.1:10808'
export https_proxy='http://127.0.0.1:10808'
export HTTP_PROXY='http://127.0.0.1:10808'
export HTTPS_PROXY='http://127.0.0.1:10808'
