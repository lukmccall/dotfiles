# macOS only. Loaded first by .zshrc.

[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
: ${HOMEBREW_PREFIX:=/opt/homebrew}

# The first entry wins. .zshrc removes the entries that do not exist.
path=(
  $HOMEBREW_PREFIX/opt/ruby@3.4/bin   # before the system Ruby
  $path
)
