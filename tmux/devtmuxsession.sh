#!/bin/bash

SESSION="dev"

# Check if session exists
tmux has-session -t $SESSION 2>/dev/null

if [ $? != 0 ]; then
    # Create new session with ghostly colors
    tmux new-session -d -s $SESSION -n code

    # Set ghostly colors for all windows/panes
    tmux set-option -t $SESSION -g status-bg colour236
    tmux set-option -t $SESSION -g status-fg colour250
    tmux set-option -t $SESSION -g window-status-current-bg colour238
    tmux set-option -t $SESSION -g window-status-current-fg colour251
    tmux set-option -t $SESSION -g pane-border-fg colour238
    tmux set-option -t $SESSION -g pane-active-border-fg colour250

    # Window 0: Coding
    tmux send-keys -t $SESSION:0 'nvim' C-m

    # Window 1: Docker/Podman
    tmux new-window -t $SESSION:1 -n docker
    tmux send-keys -t $SESSION:1 'podman ps' C-m

    # Window 2: Shell
    tmux new-window -t $SESSION:2 -n shell
fi

# Attach to session
tmux attach -t $SESSION

