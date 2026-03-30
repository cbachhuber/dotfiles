#!/usr/bin/env bash

set -eu

if [ "$EUID" = 0 ]; then
    echo "Please call me without 'sudo'. The files created in this script otherwise have messed up access rights."
    exit 1
fi

PROGRAMS=false
CONFIGURE_GIT=false
CONFIGURE_VIM=false
CONFIGURE_ZSH=false

# Let the user clone this repo to any location
DOTFILES_PATH="$(
    cd "$(dirname "$0")"
    pwd -P
)"
CONFIG_FOLDER="$DOTFILES_PATH/config"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -p | --programs)
            PROGRAMS=true
            shift # past argument
            ;;
        -g | --configure-git)
            CONFIGURE_GIT=true
            shift # past argument
            ;;
        -v | --configure-vim)
            CONFIGURE_VIM=true
            shift # past argument
            ;;
        -z | --configure-zsh)
            CONFIGURE_ZSH=true
            shift # past argument
            ;;
        -h | --help)
            printf "Usage: %s [-o] [-p] [-g] [-z] [-v]\n
This script sets up your OS with a reasonable config and programs. 
Via flags, you have the option to execute a subset of the script steps. 
For more details, see README.md.\n
-p      Install programs
-g      Git configuration
-v      Neovim configuration
-z      Oh-my-zsh configuration\n" "$0"
            exit 0
            ;;
        *)                     # unknown option
            POSITIONAL+=("$1") # save it in an array for later
            shift              # past argument
            ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "$PROGRAMS" = false ] && [ "$CONFIGURE_GIT" = false ] &&
   [ "$CONFIGURE_ZSH" = false ] && [ "$CONFIGURE_VIM" = false ]; then
    PROGRAMS=true
    CONFIGURE_GIT=true
    CONFIGURE_ZSH=true
    CONFIGURE_VIM=true
fi

install_programs() {
    echo "Installing recommended programs"

    sudo apt update && sudo apt upgrade

    # Other tools
    sudo apt install -y p7zip-full htop iotop bmon

    # Essential dev tools
    sudo apt install -y neovim zsh git terminator curl build-essential tree
    sudo apt install -y powerline fonts-powerline
}

configure_git() {
    echo "Configuring git"
    sudo apt install -y git lsb-release

    UBUNTU_VERSION=$(lsb_release -rs | cut -d. -f1)
    if [ "$UBUNTU_VERSION" -ge 24 ]; then
        sudo apt install -y git-delta
    fi

    read -r -p "Enter your git user name (your full name, e.g. 'Max Maier': " GIT_NAME
    read -r -p "Enter your git mail address: " GIT_MAIL
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_MAIL"
    git config --global core.excludesFile "$CONFIG_FOLDER"/global_gitignore
    echo "[include]
    	path = /home/$(whoami)/.dotfiles/config/gitconfig" >>~/.gitconfig # $HOME expansion not supported in gitconfig, need absolute path
}

configure_neovim() {
    echo "Configuring NeoVim"
    sudo apt install -y neovim curl

    # Linking nvim to ~/.vimrc
    mkdir -p ~/.config/nvim
    touch ~/.config/nvim/init.vim
    echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc" >~/.config/nvim/init.vim

    # Install vim-plug
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # Backing up old vimrc, symlinking to vimrc of this repo
    if [ -f ~/.vimrc ]; then
        echo "Backing up old vimrc to $DOTFILES_PATH/backups/vimrc"
        mkdir -p "$DOTFILES_PATH"/backups
        mv ~/.vimrc "$DOTFILES_PATH"/backups/vimrc
    fi
    ln -s ~/.dotfiles/config/vimrc ~/.vimrc

    nvim -c 'PlugInstall|q|q' # Using vim-plug to install plugins from vimrc. Then, quit vim
}

configure_oh_my_zsh() {
    echo "Configuring Oh-my-zsh"
    sudo apt install -y zsh wget powerline

    # Download and install oh-my-zsh, but do not yet run it (would break this script)
    RUNZSH=no sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ZSH_CUSTOM=/home/$(whoami)/.oh-my-zsh/custom

    # Use oh-my-zsh to install zsh plugins
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM"/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting

    # Backing up old zshrc, symlinking to zshrc of this repo
    if [ -f ~/.zshrc ]; then
        echo "Backing up old zshrc to $DOTFILES_PATH/backups/zshrc"
        mkdir -p "$DOTFILES_PATH"/backups
        mv ~/.zshrc "$DOTFILES_PATH"/backups/zshrc
    fi

    ln -s "$CONFIG_FOLDER"/zshrc ~/.zshrc
    echo "Feel free to try out zsh by opening a new terminal (if you made zsh your default shell), or by executing 'zsh' in this terminal. powerlevel10k will ask you a couple of questions on the first zsh start."
}

if [ "$PROGRAMS" = true ]; then install_programs; fi
if [ "$CONFIGURE_GIT" = true ]; then configure_git; fi
if [ "$CONFIGURE_VIM" = true ]; then configure_neovim; fi
if [ "$CONFIGURE_ZSH" = true ]; then configure_oh_my_zsh; fi

exit 0
