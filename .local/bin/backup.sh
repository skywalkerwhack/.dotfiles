#!/usr/bin/env bash
set -euo pipefail

non_root() {
  if [[ "$EUID" -eq 0 ]]; then
    echo 'Please run as a non-root user'
    exit 1
  fi
}

non_root

check_remote() {
  rclone lsf 'r2:backup/' >/dev/null 2>&1
}

if check_remote; then
  echo 'Remote is reachable. Starting backup.'
else
  echo 'Remote is not reachable.'
  exit 1
fi

backup_arch_dir="$HOME/sync/BACKUP/archlinux"
mkdir -p \
  "$backup_arch_dir/rclone" \
  "$backup_arch_dir/dot_ssh"
cp -a "$HOME/.config/rclone/rclone.conf" "$backup_arch_dir/rclone/"
cp -a "$HOME/.ssh"  "$backup_arch_dir/dot_ssh/"

pacman -Qqe > "$backup_arch_dir/pkglist.txt"

archive_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz.gpg"

echo 'Streaming backup to r2...'
tar -C "$HOME/sync" -czf - BACKUP \
  | gpg --batch --yes --passphrase-file "$HOME/.gpg-passphrase" --no-symkey-cache --symmetric --output - \
  | rclone rcat "r2:backup/$archive_name"

echo 'Backup finished.'
