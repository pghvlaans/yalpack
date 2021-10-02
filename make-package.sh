#!/bin/sh

# This script should not be run independently; it is meant to be called from Makefile
# in the course of "make package."
#
# $1 is the incoming version of yalpack.
# $2 is SBINDIR, as set in Makefile.

CHOME=/etc/yalpack.conf

if [ -f "$CHOME" ]; then
	unset HEAD
	unset VARBKUP
	unset ROOTHOME
	unset TMP
	unset SBINDIR

	source "$CHOME"

	COUNT1=0
	for v in "$HEAD" "$VARBKUP" "$ROOTHOME" "$TMP" "$SBINDIR"; do
	        COUNT1=$((COUNT1 + 1))
	        COUNT2=0
	        [ -z "$v" ] && echo && echo '   'One or more variables in $(tput smul)"$CHOME"$(tput rmul) is missing, contains a space, or is not && echo '   'an absolute file path. Exiting now. && echo && exit 1
	        [ -n "$(echo "$v" | grep ' ')" ] && echo && echo '      'One or more variables in $(tput smul)"$CHOME"$(tput rmul) is missing, contains a space, or is not && echo '      'an absolute file path. Exiting now. && echo && exit 1
	        [ "$(echo "$v" | cut -c1)" != "/" ] && echo && echo '   'One or more variables in $(tput smul)"$CHOME"$(tput rmul) is missing, contains a space, or is not && echo '      'an absolute file path. Exiting now. && echo && exit 1
	        for y in "$HEAD" "$VARBKUP" "$ROOTHOME" "$TMP" "$SBINDIR"; do
	                COUNT2=$((COUNT2 + 1))
	                if [ "$v" = "$y" ] && [ "$COUNT1" != "$COUNT2" ]; then
	                        echo '  '$(tput smul)Warning!$(tput rmul) Two of the current variables have the same value.
	                        echo '  'Exiting now. Please edit $(tput smul)"$CHOME"$(tput rmul).
	                        echo
	                        exit 1
	                fi
	        done
	done
	PKGDATA="$HEAD"/pkgdata
	PKGTREES="$PKGDATA"/TREES
# This shouldn't happen, but a few default values are here as fallbacks.
else
	HEAD=/var/yalpack
	PKGDATA=$HEAD/pkgdata
	PKGTREES=$PKGDATA/TREES
fi

# Avoiding potential complications if "YALPACK-OUTGOING" was retained after a failed 
# pkgremove or pkgup call.
rm -f "$PKGTREES"/YALPACK-OUTGOING
if [ -f "$PKGTREES/yalpack" ]; then
	# If yalpack is already installed with a package tree, use the new pkgup.
	"$2"/pkgup -y yalpack yalpack-"$1"
	# A friendly reminder about /etc/yalpack.conf.new
	if [ -f "$CHOME.new" ]; then
		echo '	'The yalpack scripts will continue to use the values in "$CHOME"
		echo '	'until "$CHOME".new is copied over. See the comments in the
		echo '	'configuration document or /usr/share/doc/yalpack-"$1"/Customization for
		echo '	'steps to take before and after changing variables.
		echo
	fi
else
	# Otherwise, use the new pkginst.
	"$2"/pkginst yalpack-"$1"
fi
