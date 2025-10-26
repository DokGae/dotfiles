#!/usr/bin/env zsh
# Atuin Configs
eval "$(atuin init zsh)"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

alias vi='nvim'
alias vim='nvim'

# Yazi with cd on quit
function yy() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Alias for convenience
alias y='yy'

# Keep the original yz function as backup
function yz() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi --cwd-file="$tmp" "$@"
  if [ -f "$tmp" ]; then
    local cwd="$(cat "$tmp")"
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      cd "$cwd"
    fi
    rm -f "$tmp"
  fi
}
# PATH configuration
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Make zsh-autosuggestions readable but subtly faded vs prompt
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#9ca3af'

# Yazi-inspired palette for ls/eza using truecolor codes to match Ghostty + Yazi theme
export LS_COLORS='di=01;38;2;148;163;184:fi=38;2;250;250;250:ln=01;38;2;34;211;238:or=01;38;2;248;113;113:mi=01;38;2;248;113;113:pi=38;2;163;163;163:so=01;38;2;34;211;238:bd=01;38;2;251;191;36:cd=01;38;2;251;191;36:su=01;38;2;248;113;113:sg=01;38;2;248;113;113:tw=01;38;2;251;191;36:ow=01;38;2;251;191;36:st=01;38;2;251;191;36:ex=01;38;2;52;211;153:*.app/=01;38;2;129;140;248:*.sh=01;38;2;52;211;153:*.bash=01;38;2;52;211;153:*.zsh=01;38;2;52;211;153:*.fish=01;38;2;52;211;153:*.py=01;38;2;52;211;153:*.rb=01;38;2;52;211;153:*.go=01;38;2;52;211;153:*.rs=01;38;2;52;211;153:*.js=01;38;2;52;211;153:*.ts=01;38;2;52;211;153:*.tsx=01;38;2;52;211;153:*.jsx=01;38;2;52;211;153:*.json=38;2;163;163;163:*.yml=38;2;163;163;163:*.yaml=38;2;163;163;163:*.toml=38;2;163;163;163:*.ini=38;2;163;163;163:*.conf=38;2;163;163;163:*.cfg=38;2;163;163;163:*.env=38;2;209;213;219:*.env.*=38;2;209;213;219:*.lock=38;2;115;115;115:README=01;38;2;250;250;250:LICENSE=01;38;2;250;250;250:*.md=38;2;188;188;188:*.markdown=38;2;188;188;188:*.mdx=38;2;188;188;188:*.txt=38;2;163;163;163:*.log=38;2;115;115;115:*.jpg=38;2;45;212;191:*.jpeg=38;2;45;212;191:*.png=38;2;45;212;191:*.gif=38;2;45;212;191:*.svg=38;2;45;212;191:*.webp=38;2;45;212;191:*.bmp=38;2;45;212;191:*.tiff=38;2;45;212;191:*.ico=38;2;45;212;191:*.mp4=38;2;167;139;250:*.mkv=38;2;167;139;250:*.mov=38;2;167;139;250:*.avi=38;2;167;139;250:*.mp3=38;2;251;113;133:*.flac=38;2;251;113;133:*.wav=38;2;251;113;133:*.ogg=38;2;251;113;133:*.zip=38;2;251;191;36:*.tar=38;2;251;191;36:*.gz=38;2;251;191;36:*.bz2=38;2;251;191;36:*.7z=38;2;251;191;36:*.rar=38;2;251;191;36:*.tgz=38;2;251;191;36:*.pdf=38;2;56;189;248:*.doc=38;2;56;189;248:*.docx=38;2;56;189;248:*.ppt=38;2;56;189;248:*.pptx=38;2;56;189;248:*.xls=38;2;56;189;248:*.xlsx=38;2;56;189;248:*.sql=38;2;163;163;163:*.sqlite=38;2;163;163;163:*.db=38;2;163;163;163:.*=38;2;209;213;219'
export EZA_COLORS="$LS_COLORS"
export EXA_COLORS="$LS_COLORS"

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# Basic zsh options
setopt AUTO_CD
setopt PROMPT_SUBST
setopt MENU_COMPLETE
setopt AUTO_LIST
setopt COMPLETE_IN_WORD

# Disable beep sound
setopt NO_BEEP
setopt NO_LIST_BEEP
setopt NO_HIST_BEEP

# Initialize completion system BEFORE loading plugins
autoload -Uz compinit
# Only check for insecure directories once a day
if [[ -n ${ZDOTDIR}/.zcompdump(#qNmh+24) ]]; then
  compinit
else
  compinit -C
fi

# Load Antidote (Homebrew 우선, 실패 시 로컬 클론 사용)
if [ -r /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]; then
  source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
elif [ -r "${ANTIDOTE_HOME:-${ZDOTDIR:-$HOME}/.antidote}/antidote.zsh" ]; then
  source "${ANTIDOTE_HOME:-${ZDOTDIR:-$HOME}/.antidote}/antidote.zsh"
else
  echo "Antidote를 찾을 수 없습니다. dotfiles/scripts/bootstrap_zsh.sh를 실행해 설치해 주세요." >&2
fi

# Load plugins from ~/.zsh_plugins.txt
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

# FZF configuration - MUST be after antidote load
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border --color=fg:#d4d4d8,bg:#0a0a0a,hl:#fb923c,fg+:#f4f4f5,bg+:#1f2937,hl+:#fb923c,info:#38bdf8,prompt:#34d399,pointer:#fb7185,marker:#34d399,spinner:#34d399,header:#94a3b8'

# Configure fzf-tab
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags '--height=40%' '--layout=reverse' '--border' '--color=fg:#d4d4d8,bg:#0a0a0a,hl:#fb923c,fg+:#0a0a0a,bg+:#fafafa,hl+:#fb923c,info:#38bdf8,prompt:#34d399,pointer:#fb7185,marker:#34d399,spinner:#34d399,header:#94a3b8'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -la $realpath 2>/dev/null || echo "Directory: $realpath"'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath} 2>/dev/null || ls -la ${(Q)realpath} 2>/dev/null || echo ${(Q)realpath}'
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:*' switch-group ',' '.'

# Completion settings
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'

# Key bindings for fzf-tab
bindkey '^I' fzf-tab-complete  # Tab key
bindkey '^[[Z' fzf-tab-complete  # Shift-Tab

# Ensure Delete / Backspace keys behave consistently across terminals
bindkey '^?' backward-delete-char   # Backspace
bindkey '^H' backward-delete-char   # Ctrl-H terminals
bindkey '^[[3~' delete-char         # Delete key

# Initialize zoxide if installed
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"

  if command -v fzf &> /dev/null; then
    function z() {
      local helper="$HOME/.config/yazi/plugins/zoxide.yazi/rank_zoxide.sh"
      local helper_escaped selected fzf_status selected_path initial_query query_escaped start_bind change_bind preview_command

      if [[ ! -x "$helper" ]]; then
        echo "zoxide 랭킹 스크립트를 찾을 수 없습니다: $helper" >&2
        return 1
      fi

      helper_escaped=$(printf %q "$helper")
      initial_query="$*"
      query_escaped=$(printf %q "$initial_query")
      start_bind="start:reload(${helper_escaped} ${query_escaped})"
      change_bind="change:reload(${helper_escaped} {q})"

      preview_command="bash -c 'path=\"\$1\"; ls -la \"\$path\"' -- {2}"

      local -a fzf_cmd=(
        fzf
        --ansi
        --prompt='z > '
        --height=40%
        --layout=reverse
        --border
        --info=inline
        --disabled
        --no-sort
        --delimiter=$'\t'
        --with-nth=3
        --bind "$start_bind"
        --bind "$change_bind"
        --preview "${preview_command}"
        --preview-window=down,40%,border-top
      )

      if [[ -n "$initial_query" ]]; then
        fzf_cmd+=(--query="$initial_query")
      fi

      selected=$("${fzf_cmd[@]}")
      fzf_status=$?

      if (( fzf_status == 130 )); then
        return
      fi

      if (( fzf_status != 0 )); then
        [[ $# -gt 0 ]] && __zoxide_z "$@"
        return
      fi

      [[ -z "$selected" ]] && return

      local IFS=$'\t'
      read -r _ selected_path _ <<< "$selected"
      [[ -z "$selected_path" ]] && return

      builtin cd -- "$selected_path"
    }
  fi
fi

# Load Powerlevel10k theme configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Git functions
gcm() {
    git commit -m "$*"
}

# eza (modern ls replacement) aliases with icons
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza --icons --group-directories-first -la'
    alias l='eza --icons --group-directories-first -l'
    alias la='eza --icons --group-directories-first -a'
    alias tree='eza --icons --tree'
    # If you need original ls, use /bin/ls
    alias ols='/bin/ls'
else
    # Fallback to regular ls
    alias ll='ls -la'
    alias la='ls -A'
    alias l='ls -l'
fi

# Ensure compinit is called again after all plugins are loaded
autoload -Uz compinit && compinit

# fd abbreviations are already defined in ~/.config/zsh-abbr/user-abbreviations
# No need to add them again here


# fd with fzf integration
# This function wraps fd command to always pipe output to fzf
fd() {
    # Check if fd is actually installed (the real fd command)
    if ! command -v command fd &> /dev/null; then
        echo "Error: fd (fd-find) is not installed"
        return 1
    fi

    # Run fd with all arguments and pipe to fzf
    # Use command to call the real fd, not this function
    command fd "$@" | fzf --preview 'bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo {}'
}

# Alternative: If you want to keep original fd accessible
# Uncomment the line below to use 'fdf' for fd+fzf and keep 'fd' original
# alias fdf='fd "$@" | fzf --preview "bat --style=numbers --color=always --line-range :500 {} 2>/dev/null || cat {} 2>/dev/null || echo {}"'

# Default editor settings
export EDITOR='code'
export VISUAL='code'

# You can change the editor by updating these variables:
# export EDITOR='nvim'  # for Neovim
# export EDITOR='cursor'  # for Cursor
# export EDITOR='subl'  # for Sublime Text
source ~/.zshrc_yazi

# Zellij

# fzf로 세션 선택 후 접속


zj() {
  local out query selected
  out=$(zellij list-sessions --short | fzf --print-query)
  query=$(echo "$out" | head -n1)
  selected=$(echo "$out" | tail -n1)

  if [ -n "$selected" ] && [ "$selected" != "$query" ]; then
    # 👉 기존 세션 선택한 경우
    echo "세션 접속: $selected"
    zellij attach "$selected"
  elif [ -n "$query" ]; then
    # 👉 직접 입력한 경우 (또는 아무것도 선택 안 한 경우)
    echo "새 세션 생성: $query"
    zellij --session "$query"
  fi
}
# fzf로 세션 선택 후 삭제 (활성 세션도 강제 삭제)
zjd() {
  local s
  s=$(zellij list-sessions --short | fzf)
  [ -z "$s" ] && return

  if zellij delete-session --force "$s"; then
    echo "세션 삭제됨: $s"
  else
    echo "삭제 실패: $s" >&2
  fi
}


# kp: 지정한 포트를 점유 중인 프로세스를 자동 종료
kp() {
  if [[ -z "$1" ]]; then
    echo "⚠️  사용법: kp <포트번호>"
    return 1
  fi

  local port="$1"
  local pid=$(sudo lsof -t -i :$port)

  if [[ -z "$pid" ]]; then
    echo "✅ 포트 $port 를 사용하는 프로세스가 없습니다."
  else
    echo "🔍 포트 $port 사용 중 프로세스 PID: $pid"
    echo "🧨 종료 중..."
    sudo kill -9 $pid && echo "✅ 포트 $port 점유 프로세스 종료 완료"
  fi
}
