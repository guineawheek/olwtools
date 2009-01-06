#!/bin/sh

# VolWheel - set the volume with your mousewheel
# Author : Olivier Duclos <olivier.duclos gmail.com>

PACKAGE=volwheel

# if [[ $UID -ne 0 ]]; then
#     echo "You must be root to install $PACKAGE."
#     exit 1
# fi

DESTDIR=
if [[ "$1" =~ ^--destdir=.+ ]]; then
    DESTDIR=$(echo $1 | cut -d = -f 2)
fi

PREFIX=/usr
if [[ "$1" =~ ^--prefix=.+ ]]; then
    PREFIX=$(echo $1 | cut -d = -f 2)
    PREFIX=${PREFIX:-/usr}
fi

PREFIX=$DESTDIR$PREFIX
BINDIR=$PREFIX/bin
LIBDIR=$PREFIX/lib/$PACKAGE
DATAROOTDIR=$PREFIX/share/$PACKAGE

install -v -d {$BINDIR,$LIBDIR,$DATAROOTDIR}
install -v -m755 volwheel $BINDIR
install -v -m644 lib/* $LIBDIR
cp      -v -r icons $DATAROOTDIR/

echo
echo "$PACKAGE has been succesfully installed."
