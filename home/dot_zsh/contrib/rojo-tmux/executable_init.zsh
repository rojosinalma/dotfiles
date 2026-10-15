#!/bin/bash

# True when a pane of session $1 runs an ssh whose target is the host this login came from
# ($SSH_CLIENT): attaching would make the two tmuxes render each other forever (silver<->tiny,
# 2026-10-15: one connection pushed 18 GB in two hours).
_tmux_session_loops_back() {
    local session=$1 client_ip=${SSH_CLIENT%% *} pane child target
    [ -n "$client_ip" ] || return 1
    for pane in $(tmux list-panes -s -t "$session" -F '#{pane_pid}' 2>/dev/null); do
        for child in $pane $(pgrep -P "$pane" -x ssh 2>/dev/null); do
            [ "$(ps -o comm= -p "$child" 2>/dev/null)" = "ssh" ] || continue
            target=$(ssh -G $(ps -o args= -p "$child" | cut -d' ' -f2-) 2>/dev/null | awk '$1=="hostname"{print $2; exit}')
            [ -n "$target" ] || continue
            [ "$target" = "$client_ip" ] && return 0
            getent ahosts "$target" 2>/dev/null | grep -q "^$client_ip " && return 0
        done
    done
    return 1
}

# Creates and attaches the next free alt-N session.
_tmux_new_alt() {
    local session_num=1
    while tmux has-session -t "alt-$session_num" 2>/dev/null; do
        session_num=$((session_num + 1))
    done
    tmux new-session -d -s "alt-$session_num"
    tmux attach-session -t "alt-$session_num"
}

tmux-init() {
    # Check if already inside a tmux session
    if [ -z "$TMUX" ]; then
        # Ensure "main" session exists
        tmux has-session -t main 2>/dev/null || tmux new-session -d -s main

        # Check if main session has any attached clients
        main_clients=$(tmux list-clients -t main 2>/dev/null | wc -l)

        if _tmux_session_loops_back main; then
            echo "main holds an ssh back to ${SSH_CLIENT%% *} (attaching would loop) - landing in a new alt session;"
            echo "close that pane and run tmux-init to use main"
            _tmux_new_alt
        elif [ "$main_clients" -eq 0 ]; then
            # No one is using main session, attach directly
            tmux attach-session -t main
        else
            # Main session is occupied, show prompt
            while true; do
                echo "Main session is already in use. Choose an option:"
                echo "1) main (occupied)"
                echo "2) Create new alt session"
                echo "0) Exit (or type 'quit')"
                echo -n "Enter your choice: "
                read -r choice

                case $choice in
                    1)
                        tmux attach-session -t main
                        break
                        ;;
                    2)
                        _tmux_new_alt
                        break
                        ;;
                    0|quit)
                        echo "Exiting..."
                        return 0
                        ;;
                    "")
                        # Empty input, just continue the loop to re-prompt
                        continue
                        ;;
                    *)
                        echo "Invalid choice. Please enter 1, 2, 0, or 'quit'."
                        ;;
                esac
            done
        fi
    else
        echo "Already inside a tmux session"
    fi
}

# Auto-run when script is executed directly (not sourced) and not already in tmux
[ -t 0 ] && [ -z "$TMUX" ] && tmux-init
