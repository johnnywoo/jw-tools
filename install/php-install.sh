#!/bin/bash
set -e

PHP_VERSION="5.3.1"
INSTALL_BASE="/usr/local" # will make base/php-v.v.v.v folder and link base/php to it
SOURCE_FOLDER="$HOME/source"
APACHE_FOLDER="/usr/local/apache2"

# we will need root privs
if ! sudo whoami >/dev/null 2>&1
then
	echo "You need to sudo the script" 1>&2
	exit 1
fi

if [ ! -d "$APACHE_FOLDER" ]
then
	echo "No Apache found, mod_php will not be installed"
	APACHE_FOLDER=""
fi

[ -e "$SOURCE_FOLDER" ] || mkdir "$SOURCE_FOLDER"
cd "$SOURCE_FOLDER"

[ -e "php-$PHP_VERSION.tar.bz2" ] \
	|| wget "http://ru2.php.net/get/php-$PHP_VERSION.tar.bz2/from/this/mirror"

# removing prev sources
echo "Removing previous sources, if any"
rm -rf "$SOURCE_FOLDER/php-$PHP_VERSION"

echo "Removing previous installation, if any"
rm -rf "~/.pearrc.5.3"
sudo rm -rf "/usr/local/php-$PHP_VERSION"
[ "$APACHE_FOLDER" ] && sudo rm -rf "$APACHE_FOLDER/modules/libphp5-$PHP_VERSION.so"

echo "Unpacking sources distribution"
tar xjf "php-$PHP_VERSION.tar.bz2"
cd "php-$PHP_VERSION"

echo
echo "Configuring"

apxs_arg="--with-apxs2=$APACHE_FOLDER/bin/apxs"
[ -z "$APACHE_FOLDER" ] && apxs_arg=""

#export CFLAGS=" -O9 -pipe "
#export CPPFLAGS=" -O9 -pipe "
#export CXXFLAGS=" -O9 -pipe "
./configure \
--prefix=/usr/local/php-$PHP_VERSION \
$apxs_arg \
--with-zlib-dir=/usr/lib \
--with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
--enable-mbstring --enable-mbstring=all \
--with-gd --with-jpeg-dir=/usr/lib --with-png-dir=/usr/lib \
--enable-gd-native-ttf --with-freetype-dir=/usr/lib \
--with-iconv --with-openssl --enable-sockets --with-curl --with-xsl --with-bz2 \
> jw.configure.output

echo
echo "Compiling"

if ! make > jw.make.output
then
	echo "make failed" 1>&2
	exit 1
fi

echo
echo "Installing"

if [ "$APACHE_FOLDER" ]
then
	# moving existing apache module file
	so_file="$APACHE_FOLDER/modules/libphp5.so"
	# it's a link: remove it
	[ -h "$so_file" ] && sudo rm "$so_file"
	# it's not a link: rename it
	[ -e "$so_file" ] && sudo mv "$so_file" "$APACHE_FOLDER/modules/libphp5-orig.so"
fi

sudo make install

if [ "$APACHE_FOLDER" ]
then
	# install created its own libphp5.so
	sudo mv "$so_file" "$APACHE_FOLDER/modules/libphp5-$PHP_VERSION.so"
	sudo ln -s "$APACHE_FOLDER/modules/libphp5-$PHP_VERSION.so" "$so_file"
fi

cd ..

[ -e "$INSTALL_BASE/php" ] && sudo rm "$INSTALL_BASE/php"
sudo ln -s "$INSTALL_BASE/php-$PHP_VERSION" "$INSTALL_BASE/php"


echo
echo "Installing PEAR packages"

sudo pear upgrade-all
sudo pear config-set preferred_state devel
sudo pear install -al HTTP_Request
sudo pear install -al HTTP_Request2
sudo pear install -al Image_Graph
sudo pear install -al Mail
sudo pear install -al Mail_Mime
sudo pear install -al Text_Diff



echo
echo "Installing APC"
export PATH="$PATH:$APACHE_FOLDER/bin"
sudo $INSTALL_BASE/php/bin/pecl install apc > apc.install.output

echo
echo "Installing XDebug"
sudo $INSTALL_BASE/php/bin/pecl install xdebug > xdebug.install.output



echo
echo "Install complete"
echo "Now you only need to add to your PATH:"
echo "   $INSTALL_BASE/php/bin"
echo "Pear php include path:"
echo "   $INSTALL_BASE/php/pear/PEAR"
echo