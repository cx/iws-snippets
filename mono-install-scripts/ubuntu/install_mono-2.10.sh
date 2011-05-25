#!/bin/bash -e

TOPDIR=$(pwd)
BUILDDIR=$TOPDIR/build
PREFIX=/opt/mono-2.10

export PATH=$PREFIX/bin:$PATH
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH


echo "updating existing system"
sudo apt-get update
sudo apt-get upgrade -y

echo "installing prerequisites"
sudo apt-get install -y build-essential libc6-dev g++ gcc libglib2.0-dev pkg-config git-core apache2 apache2-threaded-dev bison gettext autoconf automake libtool libpango1.0-dev libatk1.0-dev libgtk2.0-dev libtiff4-dev libgif-dev libglade2-dev

mkdir -p $BUILDDIR

echo
echo "downloading mono packages"
echo

cd $BUILDDIR

PACKAGES=("mono-2.10.2"
"libgdiplus-2.10"
"gtk-sharp-2.12.10"
"xsp-2.10.2"
"mod_mono-2.10")

URLS=("https://github.com/mono/mono/tarball/2.10.2"
"https://github.com/mono/libgdiplus/tarball/2.10"
"https://github.com/mono/gtk-sharp/tarball/2.12.10"
"https://github.com/mono/xsp/tarball/2.10.2"
"https://github.com/mono/mod_mono/tarball/2.10")


echo Downloading
count=${#PACKAGES[@]}
index=0
while [ "$index" -lt "$count" ]
do
	#only download it if you don't already have it. 
	if [ ! -f "${PACKAGES[$index]}.tar.gz" ]
	then
		wget --no-check-certificate -O "${PACKAGES[$index]}.tar.gz" "${URLS[@]:$index:1}"
	fi
	if [ -f "${PACKAGES[$index]}.tar.gz" ]
	then
		tar -zxvf "${PACKAGES[$index]}.tar.gz"
	fi
	
	let "index = $index + 1"
done


echo
echo "building mono packages"
echo

for i in "${PACKAGES[@]}"
do
	cd $BUILDDIR/$i
	./configure --prefix=$PREFIX
	make
	
	if [ "$i" = ${PACKAGES[0]} ]
	then
		sudo make install
	fi
done

echo
echo "installing mono packages"
echo

for i in "${PACKAGES[@]:1}"
do
	cd $BUILDDIR/$i
	sudo make install
done

cd $BUILDDIR
echo
echo "done"


