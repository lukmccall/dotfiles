# Aliases. Each one is added only if its tools are installed.

(( $+commands[bat] )) && alias cat="bat -pp"
(( $+commands[pnpm] )) && alias p="pnpm"
(( $+commands[kubectl] )) && alias k="kubectl"
