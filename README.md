vimfiles
========

Clone this repo from your home path.

```
cd ~
git clone git@github.com:s0ber/vimfiles.git .vim
cd .vim
git remote add s0ber git@github.com:s0ber/vimfiles.git
```

Link your .vimrc to .vim/.vimrc.

```
ln -s ./.vim/.vimrc .vimrc
```

Install NeoBundle.

```
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
```

To make everything work, install all packages (this will be suggested when you first time opening vim).

Then compile c extension for **ctrlp-cmatcher**:

```
apt-get install python-dev
cd ~/.vim/bundle/ctrlp-cmatcher/
./install.sh
```

### Get latest version

```
cd ~/.vim
git pull s0ber master
```
