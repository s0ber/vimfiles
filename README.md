vimfiles
========

Clone this repo from your home path.

```
cd ~
git clone git@github.com:s0ber/vimfiles.git .vim
```

Link your .vimrc to .vim/.vimrc.

```
ln -s ./.vim/.vimrc .vimrc
```

To make everything work, install all packages (this will be suggested when you first time opening vim).

Then compile c extension for **ctrlp-cmatcher**:

```
apt-get install python-dev
cd ~/.vim/bundle/ctrlp-cmatcher/
./install.sh
```
