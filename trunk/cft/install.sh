#!/bin/sh

# cft installation script


HELPDIR="/usr/local/man/man1/"
BINDIR="/usr/local/bin"
CONFDIR="/usr/local/share/cft/"

if (test ! -d $HELPDIR); then
   mkdir $HELPDIR
fi
cp cft.1.gz $HELPDIR

cp cft $BINDIR

mkdir $CONFDIR
cp editor $CONFDIR
cp tmpl/* $CONFDIR

echo "If you didn't see any error message, then cft has been installed successfully."

