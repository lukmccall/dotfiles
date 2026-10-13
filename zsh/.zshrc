ZSH_CONF=${XDG_CONFIG_HOME:-$HOME/.config}/zsh

# --- PATH and environment ------------------------------------------------------
typeset -U path   # no duplicate PATH entries

case $OSTYPE in
  darwin*) source $ZSH_CONF/os-darwin.zsh ;;
  linux*)  source $ZSH_CONF/os-linux.zsh ;;
esac

source $ZSH_CONF/env.zsh

path=($^path(N-/))   # remove PATH entries that do not exist

# --- oh-my-zsh -----------------------------------------------------------------
export ZSH=$HOME/.oh-my-zsh
zstyle ':omz:update' mode auto   # update automatically without asking
ENABLE_CORRECTION=false
plugins=(git web-search)
[[ $OSTYPE == darwin* ]] && plugins+=(macos)
# Custom plugins (install.sh clones them). zsh-syntax-highlighting must be last.
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  [[ -d ${ZSH_CUSTOM:-$ZSH/custom}/plugins/$plugin ]] && plugins+=($plugin)
done
unset plugin
[[ -r $ZSH/oh-my-zsh.sh ]] && source $ZSH/oh-my-zsh.sh

# --- Shell tools (each one only if it is installed) ----------------------------
setopt histignorespace   # do not save commands that start with a space

(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow --disable-ai)"

# zoxide replaces `cd`. Claude Code gets the plain `cd`.
if (( $+commands[zoxide] )) && [[ $CLAUDECODE != 1 ]]; then
  eval "$(zoxide init --cmd cd zsh)"
fi

[[ -s $HOME/.bun/_bun ]] && source $HOME/.bun/_bun   # bun completions

# --- Aliases and optional parts ------------------------------------------------
# ghostty.zsh must load after direnv and atuin: it changes their hooks.
# sdkman.zsh must load before android.zsh: it sets JAVA_HOME.
for file in $ZSH_CONF/{nvm,sdkman,aliases,android,expo,ghostty}.zsh(N); do
  source $file
done
unset file

# --- This machine only ---------------------------------------------------------
# Secrets and local settings. This file is not in git.
if [[ -r ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi
