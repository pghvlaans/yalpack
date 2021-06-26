#!/bin/sh

# This script should not be run independently; it is meant to be called from Makefile
# in the course of "make package."
#
# $1 is the incoming version of yalpack.
# $2 is SBINDIR, as set in Makefile.

HEAD=/var/yalpack
PKGDATA=$HEAD/pkgdata
PKGTREES=$PKGDATA/TREES

# Avoiding potential complications if "YALPACK-OUTGOING" was retained after a failed 
# pkgremove or pkgup call.
rm -f "$PKGTREES"/YALPACK-OUTGOING
if [ -f "$PKGTREES/yalpack" ]; then
	# If yalpack is already installed with a package tree, use the new pkgup.
	"$2"/pkgup yalpack yalpack-"$1"
else
	# Otherwise, use the new pkginst.
	"$2"/pkginst yalpack-"$1"
fi
