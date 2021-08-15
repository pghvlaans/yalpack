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
# This script sets up the "SYMTREES" directory, if it is not already available.
# Needed for first-time installations and upgrades from yalpack-0.1.4 and 
# earlier. It can also be used if the SYMTREES directory is deleted by mistake.
#
# Backup locations for the package trees are also set up, if they do not already
# exist. The default locations are /var/log/yalpack and /root/.yalpack. If this
# is not acceptable, change VARBKUP and ROOTHOME in /etc/yalpack.conf. See the
# explanatory comments in that document or
# /usr/share/doc/yalpack-0.2.0/Customization for details.
#
# Finally, the NEWFILES directory is set up and populated with lists of .new
# files associated with each package on the system. Please note that if multiple
# versions of a package have been installed, the .new files may belong to
# previously-installed versions.

unset HEAD
unset VARBKUP
unset ROOTHOME
unset TMP
unset SBINDIR

CHOME=/etc/yalpack.conf
HEAD="$(grep -m 1 HEAD\= "$CHOME" | cut -d'=' -f2-)"
VARBKUP="$(grep -m 1 VARBKUP\= "$CHOME" | cut -d'=' -f2-)"
ROOTHOME="$(grep -m 1 ROOTHOME\= "$CHOME" | cut -d'=' -f2-)"
TMP="$(grep -m 1 TMP\= "$CHOME" | cut -d'=' -f2-)"
SBINDIR="$(grep -m 1 SBINDIR\= "$CHOME" | cut -d'=' -f2-)"

if [ ! -f "$CHOME" ]; then
        echo
        echo Warning! $(tput smul)"$CHOME"$(tput rmul) was not found!
        echo The document can be found in its default state at
        echo $(tput smul)/usr/share/doc/yalpack-0.2.0/yalpack.conf.backup.$(tput rmul)
        echo
        echo Exiting now
        echo
        exit 1
fi

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
SYMTREES="$PKGDATA"/SYMTREES
SYMDESTS="$PKGDATA"/.SYMDESTS
NEWFILES="$PKGDATA"/NEWFILES
PKGVERS="$PKGDATA"/VER

# Backups 
ROOTBKUP="$ROOTHOME"/.yalpack-backup

TEMPDOC="$PKGDATA"/TEMPDOC

echo '	'Generating or regenerating the SYMTREE-related directories.
echo
rm -rf "$SYMTREES" "$SYMDESTS"
mkdir -p "$PKGTREES" "$SYMTREES" "$SYMDESTS"
# Needed to avoid potential pkgremove errors
touch "$SYMTREES"/PLACEHOLDER
touch "$SYMDESTS"/PLACEHOLDER
find "$PKGTREES"/* -type f | while read -r f; do
        rm -f "$PKGDATA"/SYMTEMP
        rm -f "$PKGDATA"/SYMTEMP2
        tree="$(basename "$f")"
        # Checking for files installed under symlinked paths and documenting the
        # non-symlinked file path.
        while read -r line; do
                # Checking for symlinks to directories in the package tree.
                [ -d "$line" ] && [ -h "$line" ] && echo "$line" >> "$PKGDATA"/SYMTEMP
	done < "$f"
	       
		# This grep will reveal those directories and all files/symlinks installed
	        # under them.
	        [ -f "$PKGDATA"/SYMTEMP ] && while read -r dir; do
	                grep ^"$dir" "$f" >> "$PKGDATA"/SYMTEMP2
	        done < "$PKGDATA"/SYMTEMP

	        # If the destinations are not in PKGTREE, list in SYMTREES.
	        [ -f "$PKGDATA"/SYMTEMP2 ] && while read -r sym; do
	                unset link
	                unset linkold
	                unset linkOK
	                unset linkoldOK

	                symold="${sym%.new}"

	                link="$(readlink -e "$sym")" || true
	                linkold="$(readlink -e "$symold")" || true

	                [ -n "$(echo "$link")" ] && linkOK=yes
	                [ -n "$(echo "$linkold")" ] && linkoldOK=yes

	                unset writeOK
	                unset writeoldOK

	                [ "$linkOK" = yes ] && [ -z "$(grep -m 1 -x "$link" "$f")" ] && writeOK=yes
	                [ "$linkoldOK" = yes ] && [ -z "$(grep -m 1 -x "$linkold" "$f")" ] && writeoldOK=yes

	                if [ "$writeOK" = yes ] && [ "$writeoldOK" = yes ]; then
	                        echo "$symold" to "$linkold" >> "$SYMTREES"/"$tree" && SYMTREEFLAG="WRITE"
	            		echo "$linkold" >> "$SYMDESTS"/"$tree"
		    	elif [ "$writeoldOK" = yes ] && [ -z "$link" ]; then
	                        echo "$symold" to "$linkold" >> "$SYMTREES"/"$tree" && SYMTREEFLAG="WRITE"
	            		echo "$linkold" >> "$SYMDESTS"/"$tree"
	                elif [ "$writeOK" = yes ] && [ -z "$linkold" ]; then
	                        echo "$sym" to "$link" >> "$SYMTREES"/"$tree" && SYMTREEFLAG="WRITE"
	            		echo "$link" >> "$SYMDESTS"/"$tree"
	                fi

	        done < "$PKGDATA"/SYMTEMP2
	done
# In case, by some coincidence, the last package examined contained files under
# a symlinked path.
rm -f "$PKGDATA"/SYMTEMP
rm -f "$PKGDATA"/SYMTEMP2
echo '	'The $(tput smul)"$SYMTREES"$(tput rmul) directory has been repopulated.

if [ -x "/usr/share/yalpack/newfiles" ]; then
	/usr/share/yalpack/newfiles
else
	echo
fi

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
		echo '	'Please consider changing the $(tput smul)"ROOTHOME"$(tput rmul) location in "$CHOME"
		echo '	'and running the script again.
		echo
	fi
fi

echo '	'$(tput smul)Script completed!$(tput rmul) The installation will now proceed.
