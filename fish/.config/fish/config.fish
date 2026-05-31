if status is-interactive
    bind \b backward-kill-word
    ###### basic navigation #####
    alias ff='fastfetch'
    alias cdo='code ~/dotfiles/'
    alias mdwm='cd ~; ./dotfiles/scripts/make.sh; cd -'
    ########### git #############
    alias gc='git commit'
    alias gp='git push -u origin main'
    ######### system ############
    alias p='poweroff'
    alias r='sudo reboot now'
    alias s='sudo pacman -S'
    alias up='sudo pacman -Syu'
    ####### touch typing ########
    alias tt='tt -showwpm -n 25'
end

fastfetch
starship init fish | source

##########################
#######  GLOBALS  ########
##########################  

set -gx TERMINAL "st"
set -gx BROWSER "brave"
set -gx NOTES "obsidian"
set -gx IDE "code"
set -gx LAUNCHER "rofi -show drun"
set -gx FILE_MANAGER "yazi"