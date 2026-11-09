#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [[ -z "$WAYLAND_DISPLAY" && "$(tty)" = /dev/tty1 && $- == *i* ]]; 
	then exec niri-session
fi
