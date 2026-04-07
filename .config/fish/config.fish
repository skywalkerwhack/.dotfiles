# fish_config theme choose "Rosé Pine"

# aliases
alias fastfetch='fastfetch -l arch'
alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'
alias vi='nvim'
alias cat='bat --paging=never'
alias less='bat --paging=always'
alias du='dust'
alias df='duf'
alias ls='lsd -l'
alias find='fd'
alias tree='tree -C'
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'

# ENV
set -x PATH $HOME/go/bin $PATH
set -x PATH $HOME/.cargo/bin $PATH
set -x PATH $HOME/.local/share/nvim/mason/bin/ $PATH
# set -x PATH $HOME/.local/share/nvim/mason/bin $PATH
set -x http_proxy 'http://127.0.0.1:10808'
set -x https_proxy 'http://127.0.0.1:10808'
set -x HTTP_PROXY 'http://127.0.0.1:10808'
set -x HTTPS_PROXY 'http://127.0.0.1:10808'
#set -x TERM xterm-256color

function hiscal
    history | awk '{print $1}' | sort | uniq --count | sort --numeric-sort --reverse | head -10
end

function sy
    syncthing >/dev/null &
end

function c_project
    mkdir -p {src,include,build,bin,tests} && touch src/main.c include/.gitkeep README.md Makefile
end

function man
    set -lx LESS_TERMCAP_mb (tput bold; tput setaf 2) # green
    set -lx LESS_TERMCAP_md (tput bold; tput setaf 6) # cyan
    set -lx LESS_TERMCAP_me (tput sgr0)
    set -lx LESS_TERMCAP_so (tput bold; tput setaf 3; tput setab 4) # yellow on blue
    set -lx LESS_TERMCAP_se (tput rmso; tput sgr0)
    set -lx LESS_TERMCAP_us (tput smul; tput bold; tput setaf 7) # white
    set -lx LESS_TERMCAP_ue (tput rmul; tput sgr0)
    set -lx LESS_TERMCAP_mr (tput rev)
    set -lx LESS_TERMCAP_mh (tput dim)
    set -lx LESS_TERMCAP_ZN (tput ssubm)
    set -lx LESS_TERMCAP_ZV (tput rsubm)
    set -lx LESS_TERMCAP_ZO (tput ssupm)
    set -lx LESS_TERMCAP_ZW (tput rsupm)
    set -lx GROFF_NO_SGR 1 # For Konsole and Gnome-terminal

    command man $argv
end

# nnn cd on quit config
function n
    # Block nesting of nnn in subshells
    if test "(env NNNLVL | string split '=' | tail -1 | string trim)" -eq 0
        echo "nnn is already running"
        return
    end

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
    # see. To cd on quit only on ^G, remove the "set -x" and make sure not to
    # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
    #      set -x NNN_TMPFILE (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME/.config; or echo $HOME/.config)/nnn/.lastd
    set -x NNN_TMPFILE (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME/.config; or echo $HOME/.config)/nnn/.lastd

    # Unmask ^Q (, ^V etc.) (if required, see stty -a) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    # The command builtin allows one to alias nnn to n, if desired, without
    # making an infinitely recursive alias
    command nnn $argv

    if test -f "$NNN_TMPFILE"
        source "$NNN_TMPFILE"
        rm -f -- "$NNN_TMPFILE" >/dev/null
    end
end

# Fortune for you
fortune
echo ""

thefuck --alias | source
starship init fish | source
zoxide init --cmd cd fish | source
