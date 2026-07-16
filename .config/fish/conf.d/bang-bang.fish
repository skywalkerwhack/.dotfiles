function __history_previous_command
    if test -n "$history[1]"
        echo $history[1]
    end
end

set -l major (string split . "$FISH_VERSION")[1]
set -l minor (string split . "$FISH_VERSION")[2]

if test "$major" -gt 3; or test "$major" -eq 3 -a "$minor" -ge 6
    abbr --add !! --position anywhere --function __history_previous_command
end
