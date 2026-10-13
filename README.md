# dotfiles

zsh, git, starship, atuin and Ghostty config for macOS and Linux. [GNU Stow](https://www.gnu.org/software/stow/) links the files into `$HOME`.

## Install

```sh
git clone git@github.com:lukmccall/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` does these steps:

1. It installs the tools. It uses the `Brewfile` when Homebrew is available, otherwise apt.
2. It installs oh-my-zsh and the `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins.
3. It installs nvm, makes Node `NODE_VERSION` (22) the default, and installs the global npm packages in `NPM_GLOBALS`.
4. It installs SDKMAN and makes Java `JAVA_VERSION` (Zulu 17) the default.
5. It links the packages with stow. Files that are in the way go to `~/.dotfiles-backup/<date>/`.

To link only some packages, and not install tools:

```sh
./install.sh --link-only zsh git starship
```

You can run the script again. It skips the files that are already linked.

## Packages

Each top-level folder is a stow package. Its content mirrors `$HOME`.

| Package    | Files |
|------------|-------|
| `zsh`      | `~/.zshrc`, `~/.config/zsh/*.zsh` |
| `git`      | `~/.gitconfig`, `~/.config/git/ignore` |
| `starship` | `~/.config/starship.toml` |
| `atuin`    | `~/.config/atuin/config.toml` |
| `ghostty`  | `~/.config/ghostty/` |
| `bin`      | Scripts in `~/.local/bin/` |

## zsh layout

`~/.zshrc` loads these files from `~/.config/zsh/`:

| File            | Loads when |
|-----------------|------------|
| `os-darwin.zsh` | macOS. Homebrew, Ruby 3.4 on PATH. |
| `os-linux.zsh`  | Linux. Linuxbrew if it is installed. |
| `env.zsh`       | Always. Locale, `~/.local/bin`, cargo, bun, ccache. |
| `nvm.zsh`       | nvm is installed. Puts the default Node on PATH without `nvm use` (that costs about 0.4 s). |
| `sdkman.zsh`    | SDKMAN is installed. Java on PATH and `JAVA_HOME`. Loads before `android.zsh`. |
| `aliases.zsh`   | Always. Each alias only if its tool is installed. |
| `android.zsh`   | The Android SDK folder exists. |
| `expo.zsh`      | `~/work/expo` exists. |
| `ghostty.zsh`   | The terminal is Ghostty. Keeps the prompt on the last line. |

## Settings for one machine (not in git)

- `~/.zshrc.local`: secrets and local settings. `~/.zshrc` loads it at the end.
- `~/.gitconfig.local`: for example a work email. `~/.gitconfig` includes it.

Do not put tokens or passwords in this repo. For secrets that only one project needs, use a `.envrc` file in that project (direnv).

## Node and Java

Node comes from nvm, not Homebrew. Global npm packages belong to one Node version, so install them again after `nvm install` of a new version (`nvm install 24 --reinstall-packages-from=22`).

iOS projects store the Node path in `ios/.xcode.env.local`, because Xcode does not load the shell config. After you change the Node version, run `pod install` again, or update `NODE_BINARY` in that file.

Java comes from SDKMAN, not Homebrew. `JAVA_HOME` is `~/.sdkman/candidates/java/current`, so it follows `sdk default java <version>`. SDKMAN needs Bash 4 or newer; on macOS the `Brewfile` installs it. In Android Studio and IntelliJ, add the JDK from `~/.sdkman/candidates/java/current` (or use the `JAVA_HOME` option for the Gradle JDK).

## Linux notes

- Install zsh with the system package manager, so that `chsh -s "$(command -v zsh)"` works.
- With apt, `install.sh` links `batcat` as `bat` and `fdfind` as `fd` in `~/.local/bin`.
- The SDKMAN installer needs `zip` and `unzip`. `install.sh` installs them with apt.
- starship and atuin are not in apt. Use Homebrew for Linux and the `Brewfile`, or their own installers.
- Android Studio puts the SDK in `~/Android/Sdk`. `android.zsh` looks there.
