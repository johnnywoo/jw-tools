#!/bin/bash
set -e

GIT_VERSION="1.7.3.5"
INSTALL_BASE="/usr/local" # will make base/git-v.v.v.v folder and link base/git to it
SOURCE_FOLDER="$HOME/sources"

[ -e "$SOURCE_FOLDER" ] || mkdir "$SOURCE_FOLDER"
cd "$SOURCE_FOLDER"

wget --no-verbose http://kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.bz2
tar xjf git-$GIT_VERSION.tar.bz2
cd git-$GIT_VERSION
./configure --prefix=$INSTALL_BASE/git-$GIT_VERSION
make
sudo make install
cd ..

[ -e "$INSTALL_BASE/git" ] && rm "$INSTALL_BASE/git"
ln -s "$INSTALL_BASE/git-$GIT_VERSION" "$INSTALL_BASE/git"

echo
echo
echo "Install complete"
echo "Now you only need to add $INSTALL_BASE/git/bin to your PATH"
echo
