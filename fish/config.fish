# Add local binary path to the PATH variable
set -gx PATH /home/$USER/.local/bin $PATH

# Initialize Oh My Posh with your theme configuration
oh-my-posh init fish --config /home/$USER/.cache/oh-my-posh/themes/kushal.omp.json | source

set -U fish_greeting ""

set -Ux fish_features no-keyboard-protocols
