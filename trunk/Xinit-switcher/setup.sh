#!/bin/sh

# Xinit-switcher installation script

HELPDIR="/usr/local/man/man1/"
BINDIR="/usr/local/bin"

if (test ! -d $HELPDIR); then
   mkdir $HELPDIR
fi
cp Xinit-switcher.1.gz $HELPDIR

cp Xinit-switcher $BINDIR

echo "If you didn't see any error message, then Xinit-switcher has been installed successfully.\n"

