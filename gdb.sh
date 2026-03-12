#!/bin/sh

EMACS_PID=`pgrep emacs`

cd ~/emacs-git/src

echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope

exec -a debug-emacs kitty -e gdb /usr/bin/emacs $EMACS_PID
