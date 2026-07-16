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

    mkdir -p "$backup_archive_directory/rclone"

    cp -a "$HOME/.config/rclone/rclone.conf" "$backup_archive_directory/rclone/"

    pacman -Qqe >"$backup_archive_directory/pkglist.txt"

    set -l encrypted_archive_filename "backup_"(date +%Y%m%d_%H%M%S)".tar.gz.gpg"

    echo "Streaming backup to r2..."

    tar -C "$HOME/sync" -czf - BACKUP \
        | gpg --batch --yes \
        --passphrase-file "$HOME/.gpg-passphrase" \
        --no-symkey-cache \
        --symmetric \
        --output - \
        | rclone rcat "r2:backup/$encrypted_archive_filename" \
        ; or return 1

    echo "Backup finished."
end
