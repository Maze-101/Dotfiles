if status is-interactive
    alias ff='fastfetch'
    alias c='code'
    alias gc='git commit'
    alias p='poweroff'
    alias r='sudo reboot now'
    alias s='sudo pacman -S'
    alias up='sudo pacman -Syu'
    alias l='setxkbmap -layout us,ara -option grp:alt_shift_toggle'
    alias tt='tt -showwpm -n 25'
    alias cdo='code ~/dotfiles/'
    alias mdwm='cd ~; ./dotfiles/scripts/make.sh; cd -'
    alias y='yazi'
end

starship init fish | source

set -gx TERMINAL "st"
set -gx BROWSER "brave"
set -gx NOTES "obsidian"
set -gx IDE "code"
set -gx LAUNCHER "rofi -show drun"
