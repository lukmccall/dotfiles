# Expo monorepo shortcuts. Loaded only if ~/work/expo exists.

EXPO_DIR=$HOME/work/expo
[[ -d $EXPO_DIR ]] || return 0

alias cde="cd $EXPO_DIR"
cdp() { cd "$EXPO_DIR/packages/$1" }   # cdp expo-modules-core
cda() { cd "$EXPO_DIR/apps/$1" }       # cda bare-expo
