#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

. "$HOME/.local/bin/env"

if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec start-hyprland
fi
