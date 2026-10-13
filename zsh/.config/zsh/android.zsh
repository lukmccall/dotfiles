# Android development. Loaded only if the Android SDK is installed.

if [[ $OSTYPE == darwin* ]]; then
  export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
else
  export ANDROID_SDK_ROOT=$HOME/Android/Sdk
fi
if [[ ! -d $ANDROID_SDK_ROOT ]]; then
  unset ANDROID_SDK_ROOT
  return 0
fi

path+=($ANDROID_SDK_ROOT/{emulator,platform-tools,cmdline-tools/latest/bin}(N-/))
[[ -n $JAVA_HOME ]] && export STUDIO_GRADLE_JDK=$JAVA_HOME

alias muteemulators=disable-emulator-sound
