#!/bin/bash

# Ensure "main" and "alt" sessions exist
tmux has-session -t main 2>/dev/null || tmux new-session -d -s main
tmux has-session -t alt 2>/dev/null || tmux new-session -d -s alt


# Prompt user to choose a session
echo "Choose a tmux session to attach to:"
echo "1) main"
echo "2) alt"
read -p "Enter your choice (1/2): " choice

case $choice in
    1)
        tmux attach-session -t main
        ;;
    2)
        tmux attach-session -t alt
        ;;

    *)
        echo "Invalid choice. Please enter 1 or 2."
        ;;
esac
