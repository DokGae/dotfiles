#!/usr/bin/env bash
set -euo pipefail

# dotfiles 기준 경로 설정
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ZDOTDIR="${ZDOTDIR:-$HOME}"
ANTIDOTE_HOME="${ANTIDOTE_HOME:-$ZDOTDIR/.antidote}"
PLUGINS_FILE="$DOTFILES_DIR/zsh/.zsh_plugins.txt"

log() {
  printf '[zsh-bootstrap] %s\n' "$1"
}

install_mac_deps() {
  if ! command -v brew >/dev/null 2>&1; then
    log 'Homebrew가 없습니다. https://brew.sh 에서 설치 후 다시 실행하세요.'
    return
  fi

  local packages=(antidote fzf zoxide atuin yazi)
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

  local packages=(zsh git curl fzf zoxide)
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

link_file() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    log "원본 파일이 없습니다: $src"
    return 1
  fi

  if [ -L "$dest" ] || [ -f "$dest" ]; then
    log "기존 $dest를 새 링크로 교체합니다."
  fi

  ln -snf "$src" "$dest"
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

  link_file "$DOTFILES_DIR/zsh/.zshrc" "$ZDOTDIR/.zshrc"
  link_file "$DOTFILES_DIR/zsh/.zsh_plugins.txt" "$ZDOTDIR/.zsh_plugins.txt"

  preload_plugins

  log '완료! 새로운 터미널을 열어 구성을 확인하세요.'
}

main "$@"
