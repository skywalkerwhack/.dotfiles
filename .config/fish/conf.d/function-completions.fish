# Completions for functions defined in config.fish.
# Kept separate so config.fish only contains function definitions.

# Wrapper functions inherit completions from the underlying command.
complete -e -c rm
complete -c rm -w rm

complete -e -c cp
complete -c cp -w cp

complete -e -c mv
complete -c mv -w mv

complete -e -c man
complete -c man -w man

complete -e -c dotfiles
complete -c dotfiles -w git

complete -e -c ncdu-root
complete -c ncdu-root -w ncdu

complete -e -c n
complete -c n -w nnn

# Commands that intentionally take no arguments should not complete files.
for cmd in \
    list-top-10-installed-packages-by-size \
    activate-python-virtualenv \
    git-auto-push-main \
    list-ssh-client-ip-addresses \
    show-command-history-frequency \
    create-c-project \
    backup-sync-directory-to-r2 \
    git-conventional-commit
    complete -e -c $cmd
    complete -c $cmd -f
end

# boot-iso takes an ISO image as its first argument, then passes the rest to qemu.
complete -e -c boot-iso
complete -c boot-iso -n 'test (count (commandline -opc)) -eq 1' \
    -k -a '(__fish_complete_suffix .iso)' -d 'ISO image'
complete -c boot-iso -n 'test (count (commandline -opc)) -gt 1' \
    -a -boot -a -cpu -a -drive -a -enable-kvm -a -m -a -machine \
    -a -net -a -nic -a -smp -a -usb -a -vga \
    -d 'QEMU option'

# ship-pr forwards args to `gh pr create`, so expose the common create flags.
complete -e -c ship-pr
complete -c ship-pr -l assignee -r -d 'Assign people by login'
complete -c ship-pr -l base -r -d 'Base branch'
complete -c ship-pr -l body -r -d 'Pull request body'
complete -c ship-pr -l body-file -r -F -d 'Read body from file'
complete -c ship-pr -l draft -d 'Create as draft'
complete -c ship-pr -l fill -d 'Autofill from commits'
complete -c ship-pr -l fill-first -d 'Autofill from first commit'
complete -c ship-pr -l fill-verbose -d 'Autofill with commit bodies'
complete -c ship-pr -l head -r -d 'Branch to use as head'
complete -c ship-pr -l label -r -d 'Add label'
complete -c ship-pr -l milestone -r -d 'Add milestone'
complete -c ship-pr -l no-maintainer-edit -d 'Disable maintainer edits'
complete -c ship-pr -l project -r -d 'Add to project'
complete -c ship-pr -l reviewer -r -d 'Request reviewers'
complete -c ship-pr -l template -r -F -d 'Use template file'
complete -c ship-pr -l title -r -d 'Pull request title'
complete -c ship-pr -l web -d 'Open browser instead of prompting'

# mirror-sync expects source and target remotes/URLs.
complete -e -c mirror-sync
complete -c mirror-sync -f
complete -c mirror-sync -n 'test (count (commandline -opc)) -eq 1' \
    -a '(git remote 2>/dev/null)' -d 'Source remote'
complete -c mirror-sync -n 'test (count (commandline -opc)) -eq 2' \
    -a '(git remote 2>/dev/null)' -d 'Target remote'

# git-setup supports an optional -m message and an optional target directory.
complete -e -c git-setup
complete -c git-setup -s m -r -d 'Initial commit message'
complete -c git-setup -a '(__fish_complete_directories "" "Directory")' \
    -d 'Target directory'

# git-clone-to-temp-dir takes a repository URL/path.
complete -e -c git-clone-to-temp-dir
complete -c git-clone-to-temp-dir -f
complete -c git-clone-to-temp-dir -a '(__fish_complete_directories "" "Repository path")' \
    -d 'Local repository path'

# litterbox uploads a file and optionally accepts an expiration.
complete -e -c litterbox
complete -c litterbox -n 'test (count (commandline -opc)) -eq 1' -F -d 'File to upload'
complete -c litterbox -n 'test (count (commandline -opc)) -eq 2' \
    -a '1h 12h 24h 72h' -d 'Expiration'
