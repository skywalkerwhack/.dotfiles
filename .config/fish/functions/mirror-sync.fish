function mirror-sync
    if test (count $argv) -lt 2
        echo "Usage: mirror-sync <source-remote> <target-remote>"
        return 1
    end

    set -l source_remote $argv[1]
    set -l target_remote $argv[2]
    set -l temporary_repo_directory (mktemp -d)
    or return 1

    echo "📦 Working directory: $temporary_repo_directory"

    if git clone --mirror "$source_remote" "$temporary_repo_directory/repo.git"
        echo "🔄 Cloned mirror from $source_remote"
        cd "$temporary_repo_directory/repo.git"

        echo "🚀 Pushing to $target_remote ..."
        if git push --mirror "$target_remote"
            echo "✅ Mirror sync completed successfully."
        else
            echo "⚠️  --mirror push failed, falling back to --all + --tags..."
            if git push --all "$target_remote"; and git push --tags "$target_remote"
                echo "✅ Mirror sync completed (using fallback method)."
            else
                echo "❌ Push failed"
            end
        end
    else
        echo "❌ Clone failed"
    end

    cd $HOME

    echo "🧹 Cleaning up temporary files..."
    rm -rf "$temporary_repo_directory"
    and echo "✅ Workspace cleaned."
    or echo "⚠️  Failed to clean temporary directory (manual removal may be needed)"
end
