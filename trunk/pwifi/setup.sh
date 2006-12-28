#!/bin/sh

# pWifi installation script


BINDIR="/usr/local/bin"
DATADIR="/usr/local/share/pwifi/"

cp pwifi $BINDIR

mkdir $DATADIR
cp gwifi.pm $DATADIR
cp gwifi.glade $DATADIR

echo "If you didn't see any error message, then pWifi has been installed successfully.\n"


