#!/bin/bash

# Name of your tmux session
SESSION_NAME="superfly"
BASE_DIR="workspace/superfly"

# Kill existing session if it exists
tmux kill-session -t $SESSION_NAME 2>/dev/null

# Start a new tmux session with an initial window and first split
tmux new-session -d -s $SESSION_NAME -n 'servers' -c ~/${BASE_DIR}/web # 1.1

# Create the initial layout
tmux split-window -h -c ~/${BASE_DIR}/fly-admin # 1.5
tmux split-window -v -t $SESSION_NAME:1.2 -c ~/${BASE_DIR}/ui-ex # 1.6
tmux split-window -v -t $SESSION_NAME:1.1 -c ~/${BASE_DIR}/web # 1.2
tmux split-window -v -t $SESSION_NAME:1.2 -c ~/${BASE_DIR}/web # 1.3
tmux split-window -h -t $SESSION_NAME:1.2 -c ~/${BASE_DIR}/web # 1.4

# send commands
tmux send-keys -t $SESSION_NAME:1.1 'bundle exec overmind start' C-m
tmux send-keys -t $SESSION_NAME:1.6 'sleep 3' C-m
tmux send-keys -t $SESSION_NAME:1.6 'mix phx.server' C-m
tmux send-keys -t $SESSION_NAME:1.5 'sleep 3' C-m
tmux send-keys -t $SESSION_NAME:1.5 'mix phx.server' C-m
tmux send-keys -t $SESSION_NAME:1.3 'tailscale funnel 4000' C-m
tmux send-keys -t $SESSION_NAME:1.4 'rails console' C-m

# Create additional windows for each project
# Web window
tmux new-window -c ~/${BASE_DIR}/web

# UI-ex window
tmux new-window -c ~/${BASE_DIR}/ui-ex

# Fly-admin window
tmux new-window -c ~/${BASE_DIR}/fly-admin

# Select the first window
tmux select-window -t $SESSION_NAME:1

# Attach to the session
tmux attach-session -t $SESSION_NAME
