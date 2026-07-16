function __history_previous_command
    echo $history[1]
end

abbr --add !! --position anywhere --function __history_previous_command
