function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting

end

starship init fish | source
if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
else if test -f ~/.cache/ags/user/generated/terminal/sequences.txt
    cat ~/.cache/ags/user/generated/terminal/sequences.txt
end

alias pamcan=pacman
function claude
    if test (count $argv) -ge 1 -a "$argv[1]" = "setkey"
        ~/.local/bin/claude-setkey
    else
        /usr/bin/claude $argv
    end
end

# function fish_prompt
#   set_color cyan; echo (pwd)
#   set_color green; echo '> '
# end
set -l _ff_logo (~/.local/bin/hyde-shell fastfetch logo 2>/dev/null)
if test -n "$_ff_logo" -a -f "$_ff_logo"
    fastfetch --logo "$_ff_logo" --logo-type kitty --logo-height 18 --logo-width 24
else
    fastfetch
end
fish_add_path $HOME/go/bin
