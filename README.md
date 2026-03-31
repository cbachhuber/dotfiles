# My Dotfiles

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](/LICENSE)

The script and config files in this folder allow you to quickly set up your Ubuntu installation with a reasonable developer configuration. See section [Compatibility](#compatibility) for supported OSs.

## Downloading

Clone the repository and run

```shell
./install.sh
```

### Setup arguments

By default, [install.sh](./install.sh) will work through all setup steps for zsh, git, and vim.
If you only want select a subset of these steps, use the below flags.
As soon as a flag is given, the other steps are not implicitly executed, they need to be called explicitly per flag as well.

- Flag `-g` or `--configure-git` guides you through common git configuration steps such as setting up your git user name and mail, git pager, global excludesFile, and git aliases.
- Flag `-v` or `--configure-vim` guides you through common [neovim](https://github.com/neovim/neovim) configuration steps such as sourcing `~/.zshrc` and installing essential plugins such as [vim-fugitive](https://github.com/tpope/vim-fugitive), [vim-airline](https://github.com/vim-airline/vim-airline), and [vim-nerdtree](https://github.com/scrooloose/nerdtree).
- Flag `-z` or `--configure-zsh` guides you through common zsh and [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) configuration steps such as setting zsh as your default shell and installing oh-my-zsh plugins such as [Powerlevel 10k](https://github.com/romkatv/powerlevel10k) and [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions).
- Flag `-h` or `--help` displays a help menu and exits the script.

## Compatibility

|              |      Git         |         Vim      |        ZSH       |
|--------------|------------------|------------------|------------------|
| Ubuntu 22.04 |:heavy_check_mark:|:heavy_check_mark:|:heavy_check_mark:|
| Ubuntu 24.04 |:heavy_check_mark:|:heavy_check_mark:|:heavy_check_mark:|
