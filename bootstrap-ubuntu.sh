#!/usr/bin/env bash
# 
# Bootstrap script for setting up a new Ubuntu machine
# 
# This should be idempotent so it can be run multiple times.
#
# Notes:
# - This assumes that firefox is already installed
# - This assumes that GitHub is accessible and you are able
#       to clone repositories without issues (presumably that's
#       how you downloaded this...)
# - As-is, this is more of a GUIDE than a real run-it-once script.
#       Some of these items aren't idempotent and aren't worth spinning
#       up a new instance to test.
echo "Starting bootstrapping"

# Update apt
sudo apt update

# I'm leaning toward using snap packages when able,
# but some packages still focus toward apt releases or
# do not exist in snap at all.
APT_PACKAGES=(
    audacity
    evolution
    git
    jq
    neovim
    ripgrep
    vim
    wget
    zsh
)
echo "Installing apt packages..."
sudo apt install ${APT_PACKAGES[@]}

SNAP_PACKAGES=(
    bitwarden
    code
    curl
    spotify
    telegram-desktop
    zoom-client
)

# TODO: some of these might need a classic install
# NOTE: this appears to not be idempotent - this is an
#    issue with the snap binary: https://tinyurl.com/nr4m9kpf
echo "Installing snap packages..."
snap install ${SNAP_PACKAGES[@]}

echo "Configuring Firefox..."
./firefox/set-up-firefox-profile.sh benjamin

# https://ohmyz.sh/#install
echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# https://github.com/pyenv/pyenv-installer
echo "Installing and configuring pyenv..."
curl https://pyenv.run | bash
pyenv install 3.9.7
pyenv global 3.9.7

echo "Installing and configuring rbenv..."
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
rbenv install 2.7.4
rbenv global 2.7.4

echo "Installing and configuring nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
nvm install node

echo "Downloading repositories..."
[[ ! -d ~/Source ]] && mkdir ~/Source
REPOSITORIES=(
    sfotm/dotfiles
    sfotm/sfotm.github.io
)
for repo in "${REPOSITORIES[@]}"
do
    mkdir -p ~/Source/$repo
    git clone git@github.com:$repo ~/Source/$repo
done

echo "Configuring dotfiles..."
# oh-my-zsh likes including a default .zshrc that
# makes the dotfiles install panic
rm ~/.zshrc
~/Source/sfotm/dotfiles/install
source ~/.zshrc

echo "Bootstrapping complete"
