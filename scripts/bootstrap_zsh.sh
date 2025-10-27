#!/usr/bin/env bash
set -euo pipefail

# dotfiles 기준 경로 설정
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"
ANTIDOTE_HOME="${ANTIDOTE_HOME:-$ZDOTDIR/.antidote}"
PLUGINS_FILE="$DOTFILES_DIR/zsh/.config/zsh/.zsh_plugins.txt"
DEFAULT_STOW_PACKAGES=(atuin btop nvim tmux yazi zsh zsh-abbr)

log() {
  printf '[zsh-bootstrap] %s\n' "$1"
}

install_mac_deps() {
  if ! command -v brew >/dev/null 2>&1; then
    log 'Homebrew가 없습니다. https://brew.sh 에서 설치 후 다시 실행하세요.'
    return
  fi

  local packages=(antidote fzf zoxide atuin yazi stow)
  for pkg in "${packages[@]}"; do
    if ! brew list "$pkg" >/dev/null 2>&1; then
      log "brew install ${pkg} 실행"
      brew install "$pkg"
    else
      log "${pkg} 이미 설치됨"
    fi
  done
}

install_debian_deps() {
  if ! command -v sudo >/dev/null 2>&1; then
    log 'sudo를 찾을 수 없습니다. 필요한 패키지를 수동으로 설치하세요.'
    return
  fi

  local packages=(build-essential pkg-config libssl-dev zsh git curl fzf zoxide stow)
  log 'apt 패키지 설치 확인'
  sudo apt-get update
  sudo apt-get install -y "${packages[@]}"

  if ! command -v atuin >/dev/null 2>&1; then
    log 'atuin이 없어 공식 설치 스크립트를 실행합니다.'
    curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | sh
  fi

  if ! command -v yazi >/dev/null 2>&1; then
    log 'yazi를 cargo로 설치합니다 (Rust 필요).'
    if ! command -v cargo >/dev/null 2>&1; then
      log 'cargo가 없어 rustup 설치 스크립트를 실행합니다.'
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
      export PATH="$HOME/.cargo/bin:$PATH"
    fi
    cargo install --locked yazi-fm yazi-cli >/dev/null
  fi
}

install_antidote() {
  if [ -r /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]; then
    log 'Homebrew Antidote 감지됨'
    return
  fi

  if [ -d "$ANTIDOTE_HOME/.git" ]; then
    log 'Antidote 업데이트'
    git -C "$ANTIDOTE_HOME" pull --ff-only
    return
  fi

  log 'Antidote를 GitHub에서 클론합니다.'
  git clone https://github.com/mattmc3/antidote.git "$ANTIDOTE_HOME"
}

cleanup_legacy_links() {
  local legacy
  for legacy in atuin btop nvim tmux yazi zsh zsh-abbr; do
    local link_path="$HOME/.config/$legacy"
    if [ -L "$link_path" ]; then
      local target
      target=$(readlink "$link_path")
      if [[ "$target" == "$DOTFILES_DIR/.config/$legacy"* ]]; then
        log "이전 링크 제거: $link_path -> $target"
        rm "$link_path"
      fi
    fi
  done

  local zshenv_link="$HOME/.zshenv"
  if [ -L "$zshenv_link" ]; then
    local target
    target=$(readlink "$zshenv_link")
    if [[ "$target" == "$DOTFILES_DIR/.zshenv"* ]]; then
      log "이전 .zshenv 링크 제거"
      rm "$zshenv_link"
    fi
  fi
}

stow_packages() {
  if ! command -v stow >/dev/null 2>&1; then
    log 'stow를 찾을 수 없습니다. 설치 후 다시 실행하세요.'
    return 1
  fi

  local -a packages
  if [ -n "${STOW_PACKAGES:-}" ]; then
    read -r -a packages <<<"${STOW_PACKAGES}"
  else
    packages=(${DEFAULT_STOW_PACKAGES[@]})
  fi

  (
    cd "$DOTFILES_DIR" || return 1
    local pkg
    for pkg in "${packages[@]}"; do
      if [ ! -d "$pkg" ]; then
        log "패키지 디렉터리가 없습니다: $DOTFILES_DIR/$pkg"
        continue
      fi
      log "stow --restow ${pkg} 실행"
      if ! stow --restow "$pkg"; then
        log "${pkg} 패키지 stow 중 충돌이 발생했습니다. 기존 파일을 정리한 뒤 다시 실행하세요."
        return 1
      fi
    done
  )
}

preload_plugins() {
  local antidote_script

  if [ -r /opt/homebrew/opt/antidote/share/antidote/antidote.zsh ]; then
    antidote_script=/opt/homebrew/opt/antidote/share/antidote/antidote.zsh
  elif [ -r "$ANTIDOTE_HOME/antidote.zsh" ]; then
    antidote_script="$ANTIDOTE_HOME/antidote.zsh"
  else
    log 'Antidote 스크립트를 찾을 수 없어 프리패치를 건너뜁니다.'
    return
  fi

  if ! command -v zsh >/dev/null 2>&1; then
    log 'zsh가 없어 프리패치를 건너뜁니다.'
    return
  fi

  if [ ! -f "$PLUGINS_FILE" ]; then
    log "플러그인 목록 파일을 찾을 수 없어 프리패치를 건너뜁니다: $PLUGINS_FILE"
    return
  fi

  log 'Antidote로 플러그인 프리로드'
  ZDOTDIR="$ZDOTDIR" zsh -fc "source '$antidote_script'; antidote bundle '$PLUGINS_FILE' >/dev/null"
}

main() {
  case "$(uname -s)" in
    Darwin)
      install_mac_deps
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        install_debian_deps
      else
        log '지원하지 않는 패키지 관리자입니다. 필요한 도구를 수동 설치하세요.'
      fi
      ;;
    *)
      log '미지원 OS입니다. 수동 설치를 진행하세요.'
      ;;
  esac

  install_antidote
  mkdir -p "$(dirname "$ZDOTDIR")"

  cleanup_legacy_links

  if ! stow_packages; then
    log 'stow 작업이 실패해 스크립트를 종료합니다.'
    exit 1
  fi

  preload_plugins

  log '완료! 새로운 터미널을 열어 구성을 확인하세요.'
}

main "$@"
