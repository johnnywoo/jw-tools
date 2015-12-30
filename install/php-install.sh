#!/bin/bash
set -e

PHP_VERSION="7.0.0"
INSTALL_BASE="/usr/local" # will make base/php-v.v.v.v folder and link base/php to it
SOURCE_FOLDER="$HOME/sources"

[ "$1" ] && PHP_VERSION="$1"

echo "Installing PHP $PHP_VERSION"

# we will need root privs
if ! sudo whoami &>/dev/null; then
	echo "You need to sudo the script" >&2
	exit 1
fi

[ -e "$SOURCE_FOLDER" ] || mkdir "$SOURCE_FOLDER"
cd "$SOURCE_FOLDER"

[ -e "php-$PHP_VERSION.tar.xz" ] \
	|| wget --no-verbose -O "php-$PHP_VERSION.tar.xz" "http://ru2.php.net/get/php-$PHP_VERSION.tar.xz/from/this/mirror"

# removing prev sources
echo "Removing previous sources of $PHP_VERSION, if any"
rm -rf "$SOURCE_FOLDER/php-$PHP_VERSION"

echo "Removing previous installation of $PHP_VERSION, if any"
rm -rf "~/.pearrc.5.3" "~/.pearrc.5.4" "~/.pearrc.5.5"
sudo rm -rf "/usr/local/php-$PHP_VERSION"

echo "Unpacking sources distribution"
tar xf "php-$PHP_VERSION.tar.xz"
cd "php-$PHP_VERSION"

echo
echo "Configuring"

mysql="--with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd"
echo "Installing MySQL as mysqlnd"
# [ -e /usr/bin/mysql_config ] \
#	&& mysql='--with-mysql=/usr --with-mysqli=/usr/bin/mysql_config --with-pdo-mysql=/usr'

pgsql=""
if [ -f /usr/bin/pg_config ]; then
	echo "Found $(/usr/bin/pg_config --version), let's have that too"
	pgsql=" --with-pgsql=/usr/bin --with-pdo-pgsql=/usr/bin"
elif [ -f /usr/pgsql-9.2/bin/pg_config ]; then
	echo "Found $(/usr/pgsql-9.2/bin/pg_config --version), let's have that too"
	pgsql=" --with-pgsql=/usr/pgsql-9.2/bin --with-pdo-pgsql=/usr/pgsql-9.2/bin"
elif [ -f /usr/pgsql-9.3/bin/pg_config ]; then
	echo "Found $(/usr/pgsql-9.3/bin/pg_config --version), let's have that too"
	pgsql=" --with-pgsql=/usr/pgsql-9.3/bin --with-pdo-pgsql=/usr/pgsql-9.3/bin"
else
	echo "pgSQL not found, driver will not be installed"
fi

#export CFLAGS=" -O9 -pipe "
#export CPPFLAGS=" -O9 -pipe "
#export CXXFLAGS=" -O9 -pipe "
./configure \
--prefix=/usr/local/php-$PHP_VERSION \
--with-zlib-dir=/usr/lib \
$mysql \
--enable-mbstring --enable-mbstring=all \
--with-gd --with-jpeg-dir=/usr/lib --with-png-dir=/usr/lib \
--enable-gd-native-ttf --with-freetype-dir=/usr/lib \
--with-iconv --with-openssl --enable-sockets --with-curl --with-xsl --with-bz2 \
--enable-fpm \
--enable-zip \
--enable-shmop --enable-sysvsem  --enable-sysvshm --enable-sysvmsg \
--enable-soap

echo
echo "Compiling"

if ! make; then
	echo "make failed" 1>&2
	exit 1
fi

echo
echo "Installing"

sudo make install

cd ..

# copying php.ini
if [ -e "$INSTALL_BASE/php/lib/php.ini" ]; then
	echo "Copying php.ini from current installation"
	sudo cp -P "$INSTALL_BASE/php/lib/php.ini" "$INSTALL_BASE/php-$PHP_VERSION/lib"
fi

# copying php-fpm.conf
if [ -e "$INSTALL_BASE/php/etc/php-fpm.conf" ]; then
	echo "Copying php-fpm.conf from current installation"
	sudo cp -P "$INSTALL_BASE/php/etc/php-fpm.conf" "$INSTALL_BASE/php-$PHP_VERSION/etc"
fi

[ -e "$INSTALL_BASE/php" ] && sudo rm "$INSTALL_BASE/php"
sudo ln -s "$INSTALL_BASE/php-$PHP_VERSION" "$INSTALL_BASE/php"


#sudo $INSTALL_BASE/php/bin/pear clear-cache &>/dev/null || true
#sudo $INSTALL_BASE/php/bin/pear upgrade-all


#echo
#echo "Installing XDebug"
#sudo $INSTALL_BASE/php/bin/pecl install xdebug > xdebug.install.output

#echo
#echo "Installing memcached"
#sudo $INSTALL_BASE/php/bin/pecl install memcached > memcached.install.output


echo
echo "Install complete"
echo "Now you only need to add to your PATH:"
echo "   $INSTALL_BASE/php/bin"
echo "Pear php include path:"
echo "   $INSTALL_BASE/php/pear/PEAR"
echo
