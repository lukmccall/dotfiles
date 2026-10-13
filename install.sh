#!/usr/bin/env bash
# Set up the dotfiles on macOS or Linux.
#
#   ./install.sh                     install tools, oh-my-zsh, nvm + Node, SDKMAN + Java, and link all packages
#   ./install.sh zsh git             the same, but link only these packages
#   ./install.sh --link-only [pkg]   only link the packages (do not install tools)
#
# Files that are in the way are moved to ~/.dotfiles-backup/<date>/.
set -euo pipefail

DOTFILES=$(cd "$(dirname "$0")" && pwd -P)
ALL_PACKAGES=(zsh git starship atuin ghostty bin)
OS=$(uname -s)

NVM_VERSION=v0.40.8
NODE_VERSION=22   # the default Node. Expo, partiful and test-kit all accept 22.
NPM_GLOBALS=(yarn eas-cli expo-cli @expo/ngrok @swmansion/argent)
JAVA_VERSION='17.0.20+1.1-zulu'   # SDKMAN identifier for the default Java. List: sdk list java

link_only=false
if [[ ${1:-} == --link-only ]]; then
  link_only=true
  shift
fi
packages=("$@")
[[ ${#packages[@]} -gt 0 ]] || packages=("${ALL_PACKAGES[@]}")

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }
has() { command -v "$1" >/dev/null 2>&1; }

install_tools() {
  if has brew; then
    info "Installing tools from the Brewfile"
    brew bundle --file "$DOTFILES/Brewfile" || warn "brew bundle did not install everything. See the output above."
    # Keep these on the installed version. brew upgrade and brew bundle skip pinned formulae.
    # pnpm: Expo needs pnpm ^12, and Homebrew has no pnpm@12 formula.
    brew pin pnpm
  elif [[ $OS == Linux ]] && has apt-get; then
    info "Installing tools with apt"
    sudo apt-get update
    sudo apt-get install -y zsh stow git curl zip unzip bat fd-find fzf jq direnv zoxide ccache
    warn "starship and atuin are not in apt. Install them from https://starship.rs and https://atuin.sh,"
    warn "or install Homebrew (https://brew.sh) and run this script again to use the Brewfile."
  else
    warn "No Homebrew and no apt. Install Homebrew (https://brew.sh) or install the tools in the Brewfile by hand."
    has stow || exit 1
  fi
}

install_oh_my_zsh() {
  local zsh_dir=$HOME/.oh-my-zsh
  local plugins_dir=$zsh_dir/custom/plugins
  if [[ ! -d $zsh_dir ]]; then
    info "Installing oh-my-zsh"
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir"
  fi
  for repo in zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting; do
    if [[ ! -d $plugins_dir/${repo#*/} ]]; then
      info "Installing ${repo#*/}"
      git clone --depth=1 "https://github.com/$repo.git" "$plugins_dir/${repo#*/}"
    fi
  done
}

install_node() {
  export NVM_DIR=$HOME/.nvm
  if [[ ! -d $NVM_DIR ]]; then
    info "Installing nvm $NVM_VERSION"
    # The official nvm installer adds lines to ~/.zshrc. Our zsh config already loads nvm.
    git -c advice.detachedHead=false clone --depth=1 --branch "$NVM_VERSION" https://github.com/nvm-sh/nvm.git "$NVM_DIR"
  fi

  set +eu   # nvm does not work with `set -e` and `set -u`
  . "$NVM_DIR/nvm.sh"
  if ! nvm ls "$NODE_VERSION" >/dev/null 2>&1; then
    info "Installing Node $NODE_VERSION"
    nvm install "$NODE_VERSION" || { warn "nvm install $NODE_VERSION failed"; set -eu; return 0; }
  fi
  nvm alias default "$NODE_VERSION" >/dev/null
  nvm use default >/dev/null

  local pkg missing=()
  for pkg in "${NPM_GLOBALS[@]}"; do
    npm ls -g "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    info "Installing global npm packages: ${missing[*]}"
    npm install -g "${missing[@]}" || warn "npm install -g did not install everything. See the output above."
  fi
  set -eu
}

install_java() {
  export SDKMAN_DIR=$HOME/.sdkman

  # SDKMAN needs Bash 4 or newer. macOS has Bash 3.2, so use the Homebrew Bash (Brewfile).
  local bash4
  for bash4 in "$(command -v bash)" /opt/homebrew/bin/bash /home/linuxbrew/.linuxbrew/bin/bash; do
    [[ -x $bash4 ]] && "$bash4" -c '(( BASH_VERSINFO[0] >= 4 ))' && break
    bash4=
  done
  if [[ -z $bash4 ]]; then
    warn "SDKMAN needs Bash 4 or newer. Install it (brew install bash) and run this script again."
    return 0
  fi

  if [[ ! -d $SDKMAN_DIR ]]; then
    info "Installing SDKMAN"
    # rcupdate=false: the installer does not edit ~/.zshrc. Our zsh config already loads SDKMAN.
    curl -fsSL "https://get.sdkman.io?rcupdate=false" | "$bash4"
  fi

  if [[ ! -d $SDKMAN_DIR/candidates/java/$JAVA_VERSION ]]; then
    info "Installing Java $JAVA_VERSION"
  fi
  # A child Bash, because SDKMAN does not work with `set -e` and `set -u`.
  "$bash4" -c '
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
    [[ -d $SDKMAN_DIR/candidates/java/$1 ]] || sdkman_auto_answer=true sdk install java "$1" || exit 1
    sdk default java "$1" >/dev/null
  ' _ "$JAVA_VERSION" || warn "Could not install Java $JAVA_VERSION. See the output above."
}

# Debian/Ubuntu install bat as "batcat" and fd as "fdfind".
link_debian_names() {
  [[ $OS == Linux ]] || return 0
  local pair from to
  for pair in batcat:bat fdfind:fd; do
    from=${pair%%:*} to=${pair##*:}
    if has "$from" && ! has "$to"; then
      ln -s "$(command -v "$from")" "$HOME/.local/bin/$to"
      info "Linked $from as ~/.local/bin/$to"
    fi
  done
}

link_packages() {
  local backup=$HOME/.dotfiles-backup/$(date +%Y-%m-%d-%H%M%S)
  local pkg src rel target

  # stow links a whole folder if it does not exist yet. These folders are also
  # used by other tools, so make them real folders first.
  mkdir -p "$HOME/.config" "$HOME/.local/bin"

  for pkg in "${packages[@]}"; do
    [[ -d $DOTFILES/$pkg ]] || { warn "No package: $pkg"; exit 1; }
    while IFS= read -r -d '' src; do
      rel=${src#"$pkg"/}
      target=$HOME/$rel
      if [[ -L $target && ! -e $target ]]; then
        rm "$target"   # broken link, for example from an old layout
      elif [[ -e $target || -L $target ]]; then
        [[ $(realpath "$target") == "$DOTFILES/$src" ]] && continue   # already linked
        mkdir -p "$(dirname "$backup/$rel")"
        mv "$target" "$backup/$rel"
        info "Moved ~/$rel to $backup/$rel"
      fi
    done < <(cd "$DOTFILES" && find "$pkg" \( -type f -o -type l \) -print0)
  done

  info "Linking: ${packages[*]}"
  stow --dir "$DOTFILES" --target "$HOME" --restow "${packages[@]}"
}

if ! $link_only; then
  install_tools
  install_oh_my_zsh
  install_node
  install_java
fi
link_packages
link_debian_names

if [[ $(basename "${SHELL:-}") != zsh ]]; then
  warn "Your login shell is not zsh. To change it: chsh -s \"\$(command -v zsh)\""
fi
info "Done. Open a new terminal. Put secrets and local settings in ~/.zshrc.local."
