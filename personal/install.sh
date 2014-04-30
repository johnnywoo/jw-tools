#!/bin/bash

realpath() {
	cd "$1"
	pwd
}

dir=$(realpath "$(dirname "$0")")

echo -ne "Installing inputrc... "
if [ -e "$HOME/.inputrc" ]
then
	echo "already exists"
else
	ln -s "$dir/inputrc" "$HOME/.inputrc"
	echo "done"
fi


echo -ne "Installing gitconfig... "
if [ -e "$HOME/.gitconfig" ]
then
	echo "already exists"
else
	ln -s "$dir/gitconfig" "$HOME/.gitconfig"
	echo "done"
fi


echo -ne "Installing profile... "
profile_fname=$(ls -1 "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.profile" 2>/dev/null | head -n 1)
[ -z "$profile_fname" ] && profile_fname="$HOME/.profile" && touch "$profile_fname"

if grep "$dir" "$profile_fname" &>/dev/null; then
	echo "already installed"
else
	echo >> "$profile_fname"
	echo 'PS1_COLOR=gray # red green blue yellow cyan pink gray white' >> "$profile_fname"
	echo '# we need this variable, please do not remove it' >> "$profile_fname"
	echo "JW_PERSONAL_DIR='$dir'" >> "$profile_fname"
	echo 'source "$JW_PERSONAL_DIR/bash-profile"' >> "$profile_fname"

	echo "done (you can change PS1_COLOR in ~/$(basename $profile_fname))"
fi
