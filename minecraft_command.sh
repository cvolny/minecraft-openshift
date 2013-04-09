#!/bin/bash
TMUX_SESSION="minecraft-volny"

tmux send -t $TMUX_SESSION "$*" C-m
