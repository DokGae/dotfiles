export ZDOTDIR="${HOME}/.config/zsh"

# Make sure XDG runtime picks up the same directory when zsh is launched in
# restricted environments.
if [ -z "${XDG_CONFIG_HOME:-}" ]; then
  export XDG_CONFIG_HOME="${HOME}/.config"
fi

# Cargo 환경 변수 로드 (설치된 경우)
if [ -f "${HOME}/.cargo/env" ]; then
  . "${HOME}/.cargo/env"
fi
