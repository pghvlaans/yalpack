#!/bin/sh

# yalpack install and SYMTREES generation script

# Copyright 2021 K. Eugene Carlson  Tsukuba, Japan
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# This script sets up the "SYMTREES" directory, if it is not already available. Needed
# for first-time installations and upgrades from yalpack-0.1.4 and earlier. It can also
# be used if the SYMTREES directory is deleted by mistake.
#
# Backup locations for the package trees are also set up, if they do not already exist.
# The default locations are /var/log/yalpack and /home/root/.yalpack. If this is not
# acceptable, please feel free to edit the locations here, as well as in pkginst, 
# pkgremove, pkgup and the recovery script at /usr/share/yalpack/restore-yalpack.
#
# Finally, the NEWFILES directory is set up and populated with lists of .new files
# associated with each package on the system. Please note that if multiple versions of
# a package have been installed, the .new files may (but probably don't) belong to
# previously-installed versions.

HEAD=/var/yalpack
PKGDATA="$HEAD"/pkgdata
PKGTREES="$PKGDATA"/TREES
SYMTREES="$PKGDATA"/SYMTREES
SYMDESTS="$PKGDATA"/.SYMDESTS
NEWFILES="$PKGDATA"/NEWFILES
PKGVERS="$PKGDATA"/VER

# Backups 

VARBKUP=/var/log/yalpack
ROOTHOME=/root
ROOTBKUP="$ROOTHOME"/.yalpack

echo '	'Checking for SYMTREE-related directories.

if [ -d "$SYMTREES" ] && [ -d "$SYMDESTS" ]; then
        echo '	'All clear!
 	echo
else
	echo '	'Sometihing is missing.
	echo
	echo '	'Preparing $(tput smul)"$SYMTREES"$(tput rmul) now. Depending
	echo '	'on how many yalpack-made packages are installed on the system,
	echo '	'this could take some time. Please wait.
	echo
	rm -rf "$SYMTREES" "$SYMDESTS"
	mkdir -p "$PKGTREES" "$SYMTREES" "$SYMDESTS"
	# Needed to avoid potential pkgremove errors
	touch "$SYMTREES"/PLACEHOLDER
	touch "$SYMDESTS"/PLACEHOLDER
	find "$PKGTREES"/* -type f | while read -r f; do
	tree="$(basename "$f")"
	# Checking for files installed under symlinked paths and documenting the non-symlinked
	# file path, as well as symlinks pointing to destinations not provided by the package.
	while read -r line; do
		if [ -f "$line" ] || [ -h "$line" ] || [ -d "$line" ]; then
			unset LINK
			LINK="$(readlink -e "$line")" || true
			# Trying to avoid doubles
			if [ -n "$LINK" ] && \
			[ "$LINK" != "$line" ] && \
			[ -z "$(grep -x "$LINK" "$f")" ] && \
			[ -z "$(grep -x "$LINK".new "$f")" ]; then
				echo "$line" to "$LINK" >> "$SYMTREES"/"$tree"
				echo "$LINK" >> "$SYMDESTS"/"$tree"
			fi
		fi
	done < "$f"
	done
	echo
	echo '	'Thank you for your patience. The $(tput smul)"$SYMTREES"$(tput rmul) directory and
	echo '	'any associated files have been made.
	echo
fi

echo '	'Updating or creating $(tput smul)"$NEWFILES"$(tput rmul).
echo
mkdir -p "$NEWFILES"
echo '	'Generating lists of $(tput smul).new$(tput rmul) files now.
find "$PKGTREES"/* -type f | while read -r f; do
	g="$(basename "$f")"
	unset VER
	VER="$(cat "$PKGVERS"/"$g")"
	[ -n "$VER" ]; echo "$g"-"$VER", updated' '"$(date)" > "$NEWFILES"/"$g"
	[ -z "$VER" ]; echo "$g", updated' '"$(date)" > "$NEWFILES"/"$g"
	while read -r file; do
		h="${file%.new}"
		# Only existing .new files are written in. 
		[ "$file" != "$h" ] && [ -f "$file" ] && echo "$file" >> "$NEWFILES"/"$g"
	done < "$f"
	# Don't keep empty NEWFILE documents.
	unset NEWLENGTH
	NEWLENGTH="$(wc -l "$NEWFILES"/"$g" | cut -d' ' -f1)"
	[ "$NEWLENGTH" = "1" ] && rm -f "$NEWFILES"/"$g"
done
echo
echo '	'Done. The lists \(if any\) can be found in $(tput smul)"$NEWFILES"$(tput rmul).
echo
echo '	'Moving on to the backups.
echo
echo '	'Checking for a backup package tree directory at $(tput smul)"$VARBKUP"$(tput rmul).
if [ -d "$VARBKUP" ]; then
	echo '	'$(tput smul)"$VARBKUP"$(tput rmul) is present.
	echo
else
	echo '	'Setting up the $(tput smul)"$VARBKUP"$(tput rmul) backup location...
	echo
	mkdir -pv "$VARBKUP"
	cp "$PKGDATA"/TREES/* "$VARBKUP"
	echo
	echo '	'Done. Moving on to the $(tput smul)"$ROOTBKUP"$(tput rmul) backup.
	echo
fi

echo '	'Checking for a backup package tree directory at $(tput smul)"$ROOTBKUP"$(tput rmul).
if [ -d "$ROOTBKUP" ]; then
	echo '	'$(tput smul)"$ROOTBKUP"$(tput rmul) is present.
	echo
else
	if [ -d "$ROOTHOME" ]; then
	        echo	
		mkdir -pv "$ROOTBKUP"
		cp "$PKGDATA"/TREES/* "$ROOTBKUP"
		echo
		echo '	'Done with backups.
		echo
	else
		echo '	'It appears that your root user has no home directory. This
		echo '	'install script will not take the responsibility of making
		echo '	'one.
		echo
		echo '	'Using two separate backup locations is highly recommended.
		echo '	'Please consider changing the $(tput smul)"ROOTHOME"$(tput rmul) and/or $(tput smul)"ROOTBKUP"$(tput rmul)
		echo locations in the script and running it again.
		echo
	fi
fi

echo '	'$(tput smul)Script completed!$(tput rmul) The installation will now proceed.
