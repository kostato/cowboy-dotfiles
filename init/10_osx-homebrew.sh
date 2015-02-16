# OSX-only stuff. Abort if not OSX.
[[ "$OSTYPE" =~ ^darwin ]] || return 1

# Some tools look for XCode, even though they don't need it.
# https://github.com/joyent/node/issues/3681
# https://github.com/mxcl/homebrew/issues/10245
if [[ ! -d "$('xcode-select' -print-path 2>/dev/null)" ]]; then
  sudo xcode-select -switch /usr/bin
fi

# Install Homebrew.
if [[ ! "$(type -P brew)" ]]; then
  e_header "Installing Homebrew"
  true | ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
fi

if [[ "$(type -P brew)" ]]; then
  e_header "Updating Homebrew"
  brew doctor
  brew update

  # Install Homebrew recipes.
  recipes=(
    bash bash-completion
    coreutils moreutils findutils
    autoconf automake
    ssh-copy-id
    autossh screen
    git git-extras hub
    gdbm gnu-sed grc grep glib
    gettext
    tree sl
    lesspipe
    markdown pandoc
    man2html
    maven ant
    mongodb
    mysql
    redis
    sqlite
    node
    screen
    wget
    imagemagick --with-webp
  )

  # Install Homebrew Cask recipes
  cask_recipes=(
    alfred
    google-chrome
    google-chrome-canary
    imagealpha
    imageoptim
    gimp
    iterm
    macvim
    sublime-text
    the-unarchiver
    transmission
    virtualbox
    vlc
    caffeine
    dash
    flux
    grandperspective
    keepassx
    moom
    sequel-pro
    sourcetree
    textexpander
    istat-menus
    rescuetime
)

  list="$(to_install "${recipes[*]}" "$(brew list)")"
  if [[ "$list" ]]; then
    e_header "Installing Homebrew recipes: $list"
    brew install $list
  fi

  casklist="$(to_install "${cask_recipes[*]}" "$(brew cask list)")"
  if [[ "casklist" ]]; then
    e_header "Installing Homebrew Cask and recpes: $casklist"
    brew tap phinze/homebrew-cask
    brew install brew-cask
    brew cask install $casklist
  fi

  # This is where brew stores its binary symlinks
  local binroot="$(brew --config | awk '/HOMEBREW_PREFIX/ {print $2}')"/bin

  # bash
  if [[ "$(type -P $binroot/bash)" && "$(cat /etc/shells | grep -q "$binroot/bash")" ]]; then
    e_header "Adding $binroot/bash to the list of acceptable shells"
    echo "$binroot/bash" | sudo tee -a /etc/shells >/dev/null
  fi
  if [[ "$SHELL" != "$binroot/bash" ]]; then
    e_header "Making $binroot/bash your default shell"
    sudo chsh -s "$binroot/bash" "$USER" >/dev/null 2>&1
    e_arrow "Please exit and restart all your shells."
  fi

