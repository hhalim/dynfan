#!/bin/bash

#Run dynfan.sh after reboot
tmux new-session -d -n dynfan
tmux send-keys -t dynfan "cd ~/
"
tmux send-keys -t dynfan "nohup ./dynfan.sh &
"