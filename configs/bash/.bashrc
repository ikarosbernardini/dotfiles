# =============================================================================
# Bash Configuration for Fedora Sway Atomic
# Author: Ikaros
# =============================================================================

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# =============================================================================
# Shell Options
# =============================================================================

# Append to history instead of overwriting
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Enable extended pattern matching
shopt -s extglob

# Enable recursive globbing with **
shopt -s globstar

# Autocorrect minor spelling errors in cd
shopt -s cdspell

# Case-insensitive globbing
shopt -s nocaseglob

# Enable programmable completion
shopt -s progcomp

# =============================================================================
# History Configuration
# =============================================================================

HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "

# Save history after each command
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# =============================================================================
# Environment Variables
# =============================================================================

# Default editor
export EDITOR='nvim'
export VISUAL='nvim'

# Default pager
export PAGER='less'
export LESS='-R --mouse --wheel-lines=3'

# Language
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# XDG directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Sway/Wayland specific
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export _JAVA_AWT_WM_NONREPARENTING=1

# PATH additions
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# FZF configuration
export FZF_DEFAULT_OPTS='
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#24283b,hl+:#7aa2f7
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#f7768e
  --color=marker:#9ece6a,spinner:#bb9af7,header:#7aa2f7
  --height 40% --layout=reverse --border --margin=1 --padding=1'

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# =============================================================================
# Aliases - General
# =============================================================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# List files
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -ltrh'
alias lS='ls -lSrh'

# Safer file operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Disk usage
alias df='df -h'
alias du='du -h'
alias duf='du -sh * | sort -hr'

# Process management
alias psg='ps aux | grep -v grep | grep -i'
alias topcpu='ps aux --sort=-%cpu | head -20'
alias topmem='ps aux --sort=-%mem | head -20'

# Network
alias ports='ss -tulanp'
alias myip='curl -s https://ifconfig.me && echo'

# =============================================================================
# Aliases - Applications
# =============================================================================

# Editor
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Tmux
alias t='tmux'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gp='git push'
alias gpu='git push -u origin HEAD'
alias gpl='git pull'
alias gf='git fetch'
alias gfa='git fetch --all'
alias gl='git log --oneline -20'
alias glg='git log --graph --oneline --decorate'
alias gd='git diff'
alias gds='git diff --staged'
alias gst='git stash'
alias gstp='git stash pop'
alias grb='git rebase'
alias grbi='git rebase -i'
alias gm='git merge'
alias grs='git reset'
alias grsh='git reset --hard'
alias gcp='git cherry-pick'

# Docker
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dprune='docker system prune -af'

# Kubernetes
alias k='kubectl'
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kl='kubectl logs -f'
alias ke='kubectl exec -it'
alias ka='kubectl apply -f'
alias kdel='kubectl delete'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# Fedora Atomic specific
alias rpm-ostree-update='sudo rpm-ostree upgrade'
alias flatpak-update='flatpak update -y'
alias system-update='rpm-ostree-update && flatpak-update'

# =============================================================================
# Aliases - Shortcuts
# =============================================================================

alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'
alias reload='source ~/.bashrc'

# Create and cd into directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.tar.xz)    tar xJf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick find
ff() {
    find . -type f -iname "*$1*"
}

fd_dir() {
    find . -type d -iname "*$1*"
}

# Quick grep in files
fif() {
    grep -rni "$1" --include="$2" .
}

# Git commit with message
gcam() {
    git add -A && git commit -m "$1"
}

# =============================================================================
# FZF Integration
# =============================================================================

# Source fzf if available
if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
    source /usr/share/fzf/shell/key-bindings.bash
fi

if [ -f /usr/share/fzf/shell/completion.bash ]; then
    source /usr/share/fzf/shell/completion.bash
fi

# FZF functions
# Interactive cd with fzf
fcd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf +m) && cd "$dir"
}

# Interactive file edit with fzf
fe() {
    local file
    file=$(fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}') && $EDITOR "$file"
}

# Interactive git branch checkout
fbr() {
    local branches branch
    branches=$(git branch -a --color=always | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf --ansi --preview 'git log --oneline --graph --color=always {1}' | sed 's/^\* //' | awk '{print $1}' | sed 's#remotes/origin/##') &&
    git checkout "$branch"
}

# Interactive git log
fgl() {
    git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview 'git show --color=always {2}' \
        --bind 'enter:execute(git show --color=always {2} | less -R)'
}

# Interactive process kill
fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ -n "$pid" ]; then
        echo "$pid" | xargs kill -${1:-9}
    fi
}

# =============================================================================
# Bash Completion
# =============================================================================

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Kubectl completion
if command -v kubectl &>/dev/null; then
    source <(kubectl completion bash)
    complete -o default -F __start_kubectl k
fi

# Docker completion
if command -v docker &>/dev/null && [ -f /usr/share/bash-completion/completions/docker ]; then
    source /usr/share/bash-completion/completions/docker
fi

# =============================================================================
# Starship Prompt
# =============================================================================

# Initialize starship if available
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
else
    # Fallback prompt if starship is not installed
    # Git branch in prompt
    parse_git_branch() {
        git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    }

    # Colors
    RESET='\[\033[0m\]'
    RED='\[\033[0;31m\]'
    GREEN='\[\033[0;32m\]'
    YELLOW='\[\033[0;33m\]'
    BLUE='\[\033[0;34m\]'
    PURPLE='\[\033[0;35m\]'
    CYAN='\[\033[0;36m\]'
    WHITE='\[\033[0;37m\]'

    # Prompt
    PS1="${GREEN}\u${WHITE}@${CYAN}\h${WHITE}:${BLUE}\w${PURPLE}\$(parse_git_branch)${WHITE}\$ ${RESET}"
fi

# =============================================================================
# Starship Configuration (create ~/.config/starship.toml)
# =============================================================================

# Create starship config if it doesn't exist
if [ ! -f "$HOME/.config/starship.toml" ] && command -v starship &>/dev/null; then
    mkdir -p "$HOME/.config"
    cat > "$HOME/.config/starship.toml" << 'STARSHIP_EOF'
# Starship Configuration - Tokyo Night Theme

format = """
[╭─](fg:#414868)\
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$python\
$nodejs\
$rust\
$golang\
$docker_context\
$kubernetes\
$terraform\
$aws\
$cmd_duration\
$line_break\
[╰─](fg:#414868)\
$character"""

[username]
show_always = true
style_user = "fg:#7aa2f7 bold"
style_root = "fg:#f7768e bold"
format = '[$user]($style) '

[hostname]
ssh_only = false
style = "fg:#7dcfff"
format = '[@$hostname]($style) '
disabled = true

[directory]
style = "fg:#bb9af7 bold"
format = "[$path]($style)[$read_only]($read_only_style) "
truncation_length = 4
truncate_to_repo = true
read_only = " "
read_only_style = "fg:#f7768e"

[git_branch]
symbol = " "
style = "fg:#9ece6a"
format = '[$symbol$branch]($style) '

[git_status]
style = "fg:#e0af68"
format = '([$all_status$ahead_behind]($style) )'
conflicted = "="
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?${count}"
stashed = "*${count}"
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"

[python]
symbol = " "
style = "fg:#e0af68"
format = '[$symbol$version]($style) '

[nodejs]
symbol = " "
style = "fg:#9ece6a"
format = '[$symbol$version]($style) '

[rust]
symbol = " "
style = "fg:#ff9e64"
format = '[$symbol$version]($style) '

[golang]
symbol = " "
style = "fg:#7dcfff"
format = '[$symbol$version]($style) '

[docker_context]
symbol = " "
style = "fg:#7aa2f7"
format = '[$symbol$context]($style) '

[kubernetes]
symbol = "☸ "
style = "fg:#7aa2f7"
format = '[$symbol$context(\($namespace\))]($style) '
disabled = false

[terraform]
symbol = "󱁢 "
style = "fg:#bb9af7"
format = '[$symbol$workspace]($style) '

[aws]
symbol = " "
style = "fg:#e0af68"
format = '[$symbol$profile(\($region\))]($style) '

[cmd_duration]
min_time = 2_000
style = "fg:#565f89"
format = '[$duration]($style) '

[character]
success_symbol = "[❯](fg:#9ece6a)"
error_symbol = "[❯](fg:#f7768e)"
STARSHIP_EOF
fi

# =============================================================================
# Local Configuration
# =============================================================================

# Source local bashrc if it exists
if [ -f "$HOME/.bashrc.local" ]; then
    source "$HOME/.bashrc.local"
fi

# =============================================================================
# Welcome Message
# =============================================================================

# Display system info on login (optional, comment out if not desired)
if command -v fastfetch &>/dev/null; then
    fastfetch --logo small
elif command -v neofetch &>/dev/null; then
    neofetch --config none --bold off --colors 4 7 4 4 7 7
fi
