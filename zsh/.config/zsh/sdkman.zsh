# SDKMAN (Java and other JVM tools). Loaded only if SDKMAN is installed.
# Puts candidates/*/current/bin on PATH and sets JAVA_HOME. Takes about 0.03 s.

export SDKMAN_DIR=${SDKMAN_DIR:-$HOME/.sdkman}
[[ -s $SDKMAN_DIR/bin/sdkman-init.sh ]] || return 0
source $SDKMAN_DIR/bin/sdkman-init.sh
