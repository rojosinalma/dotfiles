#!/bin/bash

tmux-init() {
    # Check if already inside a tmux session
    if [ -z "$TMUX" ]; then
        # Ensure "main" session exists
        tmux has-session -t main 2>/dev/null || tmux new-session -d -s main

        # Check if main session has any attached clients
        main_clients=$(tmux list-clients -t main 2>/dev/null | wc -l)

        if [ "$main_clients" -eq 0 ]; then
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
                        # Find next available alt-# session name
                        session_num=1
                        while tmux has-session -t "alt-$session_num" 2>/dev/null; do
                            session_num=$((session_num + 1))
                        done
                        session_name="alt-$session_num"
                        tmux new-session -d -s "$session_name"
                        tmux attach-session -t "$session_name"
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

# Auto-run when script is executed directly (not sourced)
[ -t 0 ] && tmux-init
