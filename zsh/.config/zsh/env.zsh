# Environment for all machines. Loaded after os-*.zsh.

export LANG=C.UTF-8 LC_ALL=C.UTF-8 LC_CTYPE=C.UTF-8

export BUN_INSTALL=$HOME/.bun
path=($HOME/.local/bin $HOME/.cargo/bin $BUN_INSTALL/bin $path)

(( $+commands[code] )) && export EDITOR="code --wait"

# ccache for native builds (CMake, Android NDK)
if (( $+commands[ccache] )); then
  export ANDROID_CCACHE=ccache CMAKE_C_COMPILER_LAUNCHER=ccache CMAKE_CXX_COMPILER_LAUNCHER=ccache
fi
