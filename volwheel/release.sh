#!/bin/sh

# VolWheel - set the volume with your mousewheel
# Author : Olivier Duclos <olivier.duclos gmail.com>

cd `pwd`

PACKAGE=volwheel
VERSION=$(head -n1 ChangeLog | cut -d "v" -f2)

mkdir release
cp -R [!release*]* release
cp -R lib release
rm -rf release/*/.svn
rm -rf release/*/*/.svn
tar cvzf $PACKAGE-$VERSION.tar.gz release
rm -rf release
