# Tools that the dotfiles use. Works on macOS and on Homebrew for Linux.
# Install: brew bundle --file ~/dotfiles/Brewfile

# Shell
brew "zsh"
brew "stow"
brew "starship"
brew "atuin"
brew "zoxide"
brew "direnv"
brew "fzf"
brew "bat"
brew "fd"
brew "jq"

# Development
brew "ccache"
brew "pnpm"   # install.sh pins it: Expo needs pnpm ^12, and Homebrew has no pnpm@12
brew "kubernetes-cli"
tap "oven-sh/bun"
brew "oven-sh/bun/bun"

if OS.mac?
  brew "bash"   # SDKMAN needs Bash 4 or newer. macOS has Bash 3.2.

  # Keg-only packages. os-darwin.zsh adds them to PATH.
  brew "llvm"
  brew "binutils"
  brew "ruby@3.4"

  cask "ghostty"
  cask "font-fira-code-nerd-font"   # Ghostty font
end
