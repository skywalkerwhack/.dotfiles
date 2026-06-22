# fish_config theme choose "Rosé Pine"

# COMMAND WRAPPERS
function rm
    command rm -I $argv
end

function cp
    command cp -i $argv
end

function mv
    command mv -i $argv
end

# THESE SOCALLED MODERN UNIX SOFTWARES ARE SOMETIMES USEFUL BUT MOSTLY ANOYING.
# :(
# alias cat='bat --paging=never'
# alias less='bat --paging=always'
# alias du='dust'
# alias df='duf'
# alias ls='lsd -l'
# alias find='fd'
# alias tree='tree -C' <- this one does not count
function dotfiles
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" $argv
end

function arch-upgrade
    sudo pacman -Syu $argv
end

function list-top-10-installed-packages-by-size
    expac '%m\t%n' | sort -rn | head -10 | numfmt --to=iec-i --suffix=B --format='%.1f' --field=1 | column -t
end

function top-10-packages
    list-top-10-installed-packages-by-size $argv
end

function edit-fish-config
    vim ~/.config/fish/config.fish
end

function activate-python-virtualenv
    source ~/projects/py/virenv/bin/activate.fish
end

function activate-virenv
    activate-python-virtualenv $argv
end

function boot-iso
    qemu-system-x86_64 -m 2G -cdrom $argv[1] -nographic $argv[2..-1]
end

function ncdu-root
    sudo ncdu --exclude /proc --exclude /sys --exclude /dev / $argv
end

function git-auto-push-main
    set -l timestamp (date +%F_%T)

    git add .
    and git commit -m "update $timestamp"
    and git push origin main
end

function ship-pr
    gh pr create $argv
    and gh pr merge --squash --delete-branch
    and git fetch --prune
    and git pull --tags
end

function list-ssh-client-ip-addresses
    journalctl -u sshd | grep -oP 'from \K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -u
end

function ssh-source-ips
    list-ssh-client-ip-addresses $argv
end

# SOME ENVS
set -x PATH $HOME/.local/bin $PATH
set -x PATH $HOME/go/bin $PATH
set -x PATH $HOME/.cargo/bin $PATH
set -x PATH $HOME/.local/share/nvim/mason/bin/ $PATH
# set -x PATH $HOME/.local/share/nvim/mason/bin $PATH
set -x http_proxy 'http://127.0.0.1:10808'
set -x https_proxy 'http://127.0.0.1:10808'
set -x HTTP_PROXY 'http://127.0.0.1:10808'
set -x HTTPS_PROXY 'http://127.0.0.1:10808'
# set -x TERM xterm-256color
set -x GEM_HOME (gem env user_gemhome)
set -x PATH $GEM_HOME/bin $PATH
set -x RUSTUP_DIST_SERVER https://mirrors.tuna.tsinghua.edu.cn/rustup

# SOME FUNCTIONS
function show-command-history-frequency
    history | awk '{print $1}' | sort | uniq --count | sort --numeric-sort --reverse | head -10
end

function hiscal
    show-command-history-frequency $argv
end

function start-syncthing
    syncthing >/dev/null &
end

function create-c-project
    mkdir -p {src,include,build,bin,tests} && touch src/main.c include/.gitkeep README.md Makefile
end

function backup-sync-directory-to-r2
    if test (id -u) -eq 0
        echo "Please run as a non-root user"
        return 1
    end

    if rclone lsf "r2:backup/" >/dev/null 2>&1
        echo "Remote is reachable. Starting backup."
    else
        echo "Remote is not reachable."
        return 1
    end

    set -l backup_archive_directory "$HOME/sync/BACKUP/archlinux"

    mkdir -p \
        "$backup_archive_directory/rclone" \
        "$backup_archive_directory/dot_ssh"

    cp -a "$HOME/.config/rclone/rclone.conf" "$backup_archive_directory/rclone/"
    cp -a "$HOME/.ssh" "$backup_archive_directory/dot_ssh/"

    pacman -Qqe >"$backup_archive_directory/pkglist.txt"

    set -l encrypted_archive_filename "backup_"(date +%Y%m%d_%H%M%S)".tar.gz.gpg"

    echo "Streaming backup to r2..."

    tar -C "$HOME/sync" -czf - BACKUP \
        | gpg --batch --yes \
        --passphrase-file "$HOME/.gpg-passphrase" \
        --no-symkey-cache \
        --symmetric \
        --output - \
        | rclone rcat "r2:backup/$encrypted_archive_filename"

    or return 1

    echo "Backup finished."
end

function backup
    backup-sync-directory-to-r2 $argv
end

function mirror-sync
    if test (count $argv) -lt 2
        echo "Usage: mirror-sync <source-remote> <target-remote>"
        return 1
    end

    set -l source_remote $argv[1]
    set -l target_remote $argv[2]

    # =========================
    # Temp repo (ephemeral)
    # =========================
    set -l temporary_repo_directory (mktemp -d)

    if test -z "$temporary_repo_directory"
        echo "Failed to create temp directory"
        return 1
    end

    echo "📦 Working directory: $temporary_repo_directory"

    # Cleanup on exit
    function __mirror_sync_cleanup --on-event fish_exit
        if test -d "$temporary_repo_directory"
            rm -rf "$temporary_repo_directory"
            echo "🧹 Cleaned up /tmp workspace"
        end
    end

    # =========================
    # Clone mirror into /tmp
    # =========================
    echo "🔄 Cloning mirror from $source_remote ..."

    git clone --mirror "$source_remote" "$temporary_repo_directory/repo.git"
    or return 1

    cd "$temporary_repo_directory/repo.git"
    or return 1

    # =========================
    # Push to target mirror
    # =========================
    echo "🚀 Pushing branches ..."
    git push --all "$target_remote"
    or return 1

    echo "🚀 Pushing tags ..."
    git push --tags "$target_remote"
    or return 1

    echo "✅ Done."
end

function git-setup
    set -l commit_message "Initial commit"

    if test (count $argv) -ge 2
        if test "$argv[1]" = -m
            set commit_message "$argv[2]"
            set -e argv[1..2]
        end
    end

    set -l target_directory "."

    if test (count $argv) -gt 0
        set target_directory $argv
    end

    mkdir -p "$target_directory"; and cd "$target_directory"

    if test -d .git
        echo ".git directory already exists, aborting"
        return 1
    end

    git init \
        && git add . \
        && git commit --allow-empty -m "$commit_message"
end

function git-clone-to-temp-dir --description "Clone a git repo into a temporary directory"
    set temporary_clone_directory (mktemp -d)

    if not test -d "$temporary_clone_directory"
        echo "Failed to create temp directory"
        return 1
    end

    git clone --depth=1 $argv[1] "$temporary_clone_directory"
    or begin
        rm -rf "$temporary_clone_directory"
        return 1
    end

    cd "$temporary_clone_directory"

    echo "Cloned into: $temporary_clone_directory"
end

function git-tmp
    git-clone-to-temp-dir $argv
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
function n
    # nnn cd on quit config
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
function litterbox
    # Usage: upload_file <file> [time]
    if test (count $argv) -eq 0
        echo "Usage: upload_file <file> [time]"
        return 1
    end
    set upload_file_path $argv[1]
    if test (count $argv) -ge 2
        set upload_expiration $argv[2]
    else
        set upload_expiration 1h
    end
    curl -F "reqtype=fileupload" -F "time=$upload_expiration" -F "fileToUpload=@$upload_file_path" https://litterbox.catbox.moe/resources/internals/api.php
end
function git-conventional-commit
    # Choose commit type
    set commit_type (gum choose fix feat docs style refactor test chore revert)

    # Get optional scope
    set commit_scope (gum input --placeholder "scope")

    # Wrap scope in parentheses if not empty
    if test -n "$commit_scope"
        set commit_scope "($commit_scope)"
    end

    # Build summary with prefilled value
    set commit_summary (gum input --value "$commit_type$commit_scope: " --placeholder "Summary of this change")

    # Detailed description
    set commit_description (gum write --placeholder "Details of this change")

    # Confirm and commit
    gum confirm "Commit changes?"; and git commit -m "$commit_summary" -m "$commit_description"
end

# FORTUNE IN INTERACTIVE SHELLS
if status is-interactive
    # Fortune for you
    fortune
    echo ""
    echo -ne "\e[5 q"
end

# FUCK, STARSHIP AND ZOXIDE.
thefuck --alias | source
starship init fish | source
zoxide init --cmd cd fish | source
