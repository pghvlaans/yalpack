#!/bin/sh

# This is a sample script that will go from source tarball to installed
# yalpack package. Run from inside the extracted source tarball.

TMP=/tmp
PKGNAME= #package name
# If more than one version of a package should exist on the system at the 
# same time, leave VER blank and delete all references to VER, along with 
# their preceding hyphens.
VER= #version number
SOURCEDEST=$(pwd)
PKGDIR=$TMP/"$PKGNAME"-"$VER"
PKGDEST="$PKGDIR"/dest
JOB= #desired job tag

rm -rf "$PKGDIR"
mkdir -p "$PKGDEST"
echo "$PKGNAME" > "$PKGDIR"/NAME

# Instructions go here

# e.g.
# make clean
# make "$JOB"
# make DESTDIR="$PKGDEST" install
# DESTDIR="$PKGDEST" ninja install

# And then make and install the package

pkgmake "$PKGNAME"-"$VER"
pkginst "$PKGNAME"-"$VER"
