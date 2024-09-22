# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/

# Path to powerlevel10k theme
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# List of plugins used
plugins=(z vi-mode git sudo zsh-256color zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# In case a command is not found, try to find the package that has it
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]] ; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

# Detect the AUR wrapper
if pacman -Qi yay &>/dev/null ; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null ; then
   aurhelper="paru"
fi

function in {
    local pkg="$1"
    if pacman -Si "$pkg" &>/dev/null ; then
        sudo pacman -S "$pkg"
    else 
        "$aurhelper" -S "$pkg"
    fi
}

# Helpful aliases
alias  l='eza -lh  --icons=auto' # long list
alias ls='eza -1   --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list availabe package
alias pc='$aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias vc='code --disable-gpu' # gui code editor

# Handy change dir shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Ubuntu Config Aliases
# Config for vi-mode
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true
MODE_INDICATOR="%F{yellow}+%f"
bindkey 'jk' vi-cmd-mode
bindkey -M vicmd 'V' edit-command-line # this remaps `vv` to `V` (but overrides `visual-mode`)

# Alias List
alias myip="curl http://ipecho.net/plain; echo"
alias gac="git add . && git commit -a -m "
alias hs='history | grep'
alias mkcd='foo(){ mkdir -p "$1"; cd "$1" }; foo '
alias cursor="~/opt/cursor.AppImage --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland"

function cursor() {
    ~/opt/cursor.AppImage "$@"
}

# Working with git, make easier to push to remote
function acp() {
  git add .
  git commit -m "$1"
  git push
}

# Fuzzy Finder & with aliases
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
fzf_find_edit() {
    local file=$(
      fzf --query="$1" --no-multi --select-1 --exit-0 \
          --preview 'bat --color=always --line-range :500 {}'
    )
    if [[ -n "$file" ]]; then
        $EDITOR "$file"
    fi
}
alias fe='fzf_find_edit'

fzf_change_directory() {
    local directory=$(
      fd --type d | \
        fzf --query="$1" --no-multi --select-1 --exit-0 \
            --preview 'tree -C {} | head -100'
    )
    if [[ -n $directory ]]; then
        cd "$directory"
    fi
}

alias fcd='fzf_change_directory'

fzf_kill() {
    if [[ $(uname) == Linux ]]; then
        local pids=$(ps -f -u $USER | sed 1d | fzf | awk '{print $2}')
    elif [[ $(uname) == Darwin ]]; then
        local pids=$(ps -f -u $USER | sed 1d | fzf | awk '{print $3}')
    else
        echo 'Error: unknown platform'
        return
    fi
    if [[ -n "$pids" ]]; then
        echo "$pids" | xargs kill -9 "$@"
    fi
}

alias fkill='fzf_kill'

fzf_git_add() {
    local selections=$(
      git status --porcelain | \
        fzf --ansi \
            --preview 'if (git ls-files --error-unmatch {2} &>/dev/null); then
                           git diff --color=always {2}
                       else
                           bat --color=always --line-range :500 {2}
                       fi'
    )
    if [[ -n $selections ]]; then
        local additions=$(echo $selections | sed 's/M //g' | sed 's/?? //g')
        git add --verbose $additions
    fi
}

alias gadd='fzf_git_add'

# Alias for natural neovim look
alias kmp0='kitty @ set-spacing padding=0 margin=0'
alias nvimm='kmp0 && nvim'

# Alias untuk neovide menjadi nvide
alias nvide='neovide'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'

# Fixes "Error opening terminal: xterm-kitty" when using the default kitty term to open some programs through ssh
alias ssh='kitten ssh'

# Electron Apps
alias spotify='spotify --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland'
alias discord='discord --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland'
alias chrome='google-chrome-stable --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland'
alias figma='figma-linux --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland'
alias edge='microsoft-edge-stable --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#Display Pokemon
pokemon-colorscripts --no-title -r 1,3,6

# Path Configuration
export PATH=$PATH:/snap/bin
export PATH=/home/neonnex/nodejs/bin:$PATH
export PATH=$PATH:/home/neonnex/.cargo/bin
export PATH="/usr/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.fzf/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
# Set environment variable for Electron
export ELECTRON_OZONE_PLATFORM_HINT=auto

# env psql
export PATH="/usr/local/pgsql/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$PATH:$HOME/.config/composer/vendor/bin"
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export TEMPL_EXPERIMENT=rawgo

export PATH="$HOME/.local/bin:$PATH"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/neonnex/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/neonnex/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/neonnex/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/neonnex/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


alias python='/usr/bin/python3.7'
alias python3='/usr/bin/python3.7'
