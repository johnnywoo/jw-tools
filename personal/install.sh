#!/bin/bash

# changes CWD! luckily we don't care
realpath()
{
	cd "$1"
	pwd
}

fld=$(realpath "$(dirname "$0")")

echo -ne "Installing inputrc... "
if [ -e "$HOME/.inputrc" ]
then
	echo "already exists"
else
	ln -s "$fld/inputrc" $HOME/.inputrc
	echo "done"
fi

echo -ne "Installing profile... "
profile_fname=$(ls -1 "$HOME/.bash_profile" "$HOME/.bash_login" "$HOME/.profile" 2>/dev/null | head -n 1)
[ -z "$profile_fname" ] && profile_fname="$HOME/.profile" && touch "$profile_fname"

if grep "$fld" "$profile_fname" >/dev/null 2>&1
then
	echo "already installed"
else
	echo '' >> "$profile_fname"
	echo 'PS1_COLOR=white # red green blue yellow cyan pink gray white' >> "$profile_fname"
	echo "source $fld/bash-profile" >> "$profile_fname"
	echo "done (you can change PS1_COLOR in \~/$(basename $profile_fname))"
fi