# nvm (Node version manager). Loaded only if nvm is installed.

export NVM_DIR=${NVM_DIR:-$HOME/.nvm}
[[ -s $NVM_DIR/nvm.sh ]] || return 0

# Load only the nvm command. `nvm use default` costs about 0.4 s per shell,
# so put the default Node on PATH directly. Global npm tools (argent, eas, yarn)
# must be on PATH from the start, so this is not lazy.
source $NVM_DIR/nvm.sh --no-use

() {
  local default=$(<$NVM_DIR/alias/default) 2>/dev/null
  # A version alias ("22", "22.23", "v22.23.3"): use the newest installed match.
  local -a dirs=($NVM_DIR/versions/node/v${default#v}{,.*}(N/nOn))
  if [[ $default =~ '^v?[0-9]+(\.[0-9]+)*$' && -n $dirs ]]; then
    export NVM_BIN=$dirs[1]/bin NVM_INC=$dirs[1]/include/node
    path=($NVM_BIN $path)
  else
    nvm use default --silent >/dev/null   # other aliases (lts/*, node): let nvm resolve them
  fi
}

# Completion for the nvm command
if [[ -r $NVM_DIR/bash_completion ]]; then
  autoload -U +X bashcompinit && bashcompinit
  source $NVM_DIR/bash_completion
fi
