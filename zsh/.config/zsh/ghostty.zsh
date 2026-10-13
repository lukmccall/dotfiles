# Ghostty: keep the prompt on the last line of the window, like the Warp input box.
# Loaded only in Ghostty.
[[ $TERM_PROGRAM == ghostty ]] || return 0

# Before each prompt, move the cursor to the last line. This runs before the
# other precmd hooks, so their output (for example direnv) is at the bottom too.
_prompt_at_bottom() { print -n -- "\e[${LINES};1H" }

# New session only: scroll the text that is already on the screen
# ("Last login: ...", startup messages) down, so it sits above the prompt.
_startup_text_to_bottom() {
  precmd_functions=(${precmd_functions:#_startup_text_to_bottom})
  local reply typed row tty_state
  tty_state=$(stty -g < /dev/tty)
  stty -echo < /dev/tty                      # do not show the terminal's reply
  print -n -- '\e[6n' > /dev/tty             # ask the terminal for the cursor row
  IFS= read -rs -t 0.5 -d R reply < /dev/tty
  stty $tty_state < /dev/tty
  [[ $reply == *$'\e['* ]] || return 0
  typed=${reply%%$'\e['*}                    # keys typed during startup
  [[ -n $typed ]] && print -z -- "$typed"    # give them back to the line editor
  row=${${reply##*$'\e['}%%;*}
  (( row > 1 && row < LINES )) && print -n -- "\e[$(( LINES - row ))T"
}
precmd_functions=(_startup_text_to_bottom _prompt_at_bottom "${precmd_functions[@]}")

# Ctrl+L (Cmd+K also sends Ctrl+L): clear the screen, prompt on the last line.
_clear_screen_prompt_at_bottom() {
  zle -I
  print -n -- "\e[H\e[2J\e[${LINES};1H"
}
zle -N clear-screen-prompt-at-bottom _clear_screen_prompt_at_bottom
bindkey '^L' clear-screen-prompt-at-bottom

# atuin: keep the prompt on the last line when the search closes.
# atuin runs `zle -I` before it opens its UI. On the last line this scrolls
# the screen by one line. With `inline_height = 0` (~/.config/atuin/config.toml)
# atuin uses the alternate screen, which restores the screen when it closes,
# so we skip `zle -I` while atuin's widgets run.
if (( $+functions[_atuin_search] )); then
  _atuin_without_zle_trash() {
    function zle { [[ $1 == -I ]] || builtin zle "$@" }
    { "$@" } always { unfunction zle }
  }
  _atuin_search_at_bottom() { _atuin_without_zle_trash _atuin_search "$@" }
  zle -N atuin-search _atuin_search_at_bottom
fi
