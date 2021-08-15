#!/bin/sh

# validate-config.sh

# This script should not be run independently. It is called by Makefile to
# ensure that certain parameters are sane in combination with the existing 
# /etc/yalpack.conf file, (or the new file at src/etc/yalpack.conf, if the 
# former is not present.

# $1 is SBINDIR from Makefile
# $2 is TMP from Makefile
# $3 is VER from Makefile

getnewvars (){
unset NEWHEAD
unset NEWVAR
unset NEWROOT
unset NEWTMP
unset NEWSBIN

NEWHEAD="$(cat "$NEWCONF" | grep -m 1 HEAD\= | cut -d'=' -f2-)"
NEWVAR="$(cat "$NEWCONF" | grep -m 1 VARBKUP\= | cut -d'=' -f2-)"
NEWROOT="$(cat "$NEWCONF" | grep -m 1 ROOTHOME\= | cut -d'=' -f2-)"
NEWTMP="$(cat "$NEWCONF" | grep -m 1 TMP\= | cut -d'=' -f2-)"
NEWSBIN="$(cat "$NEWCONF" | grep -m 1 SBINDIR\= | cut -d'=' -f2-)"
}

getoldvars (){
unset OLDHEAD
unset OLDVAR
unset OLDROOT
unset OLDTMP
unset OLDSBIN
	
OLDHEAD="$(cat "$OLDCONF" | grep -m 1 HEAD\= | cut -d'=' -f2-)"
OLDVAR="$(cat "$OLDCONF" | grep -m 1 VARBKUP\= | cut -d'=' -f2-)"
OLDROOT="$(cat "$OLDCONF" | grep -m 1 ROOTHOME\= | cut -d'=' -f2-)"
OLDTMP="$(cat "$OLDCONF" | grep -m 1 TMP\= | cut -d'=' -f2-)"
OLDSBIN="$(cat "$OLDCONF" | grep -m 1 SBINDIR\= | cut -d'=' -f2-)"
}

validatenew (){
COUNT1=0
for v in "$NEWHEAD" "$NEWVAR" "$NEWROOT" "$NEWTMP" "$NEWSBIN"; do
        COUNT1=$((COUNT1 + 1))
        COUNT2=0
        [ -z "$v" ] && echo && echo '      'One or more variables in $(tput smul)"$NEWCONF"$(tput rmul) is missing, contains a space, or is not && echo '   'an absolute file path. Exiting now. && echo && exit 1
        [ -n "$(echo "$v" | grep ' ')" ] && echo && echo '      'One or more variables in $(tput smul)"$NEWCONF"$(tput rmul) is missing, contains a space, or is not && echo '   'an absolute file path. Exiting now. && echo && exit 1
	[ "$(echo "$v" | cut -c1)" != "/" ] && echo && echo '      'One or more variables in $(tput smul)"$NEWCONF"$(tput rmul) is missing, contains a space, or is not && echo '   'an absolute file path. Exiting now. && echo && exit 1       
	for y in "$NEWHEAD" "$NEWVAR" "$NEWROOT" "$NEWTMP" "$NEWSBIN"; do
                COUNT2=$((COUNT2 + 1))
                if [ "$v" = "$y" ] && [ "$COUNT1" != "$COUNT2" ]; then
                        echo '  '$(tput smul)Warning!$(tput rmul) Two of the current variables have the same value.
                        echo '  'Exiting now. Please edit $(tput smul)"$NEWCONF"$(tput rmul).
                        echo
                        exit 1
                fi
        done
done
}

validateold (){
COUNT1=0
for v in "$OLDHEAD" "$OLDVAR" "$OLDROOT" "$OLDTMP" "$OLDSBIN"; do
        COUNT1=$((COUNT1 + 1))
        COUNT2=0
	[ -z "$v" ] && echo && echo '      'One or more variables in $(tput smul)"$OLDCONF"$(tput rmul) is missing, contains a space, or is not && echo '   'an absolute file path. Exiting now. && echo && exit 1
        [ -n "$(echo "$v" | grep ' ')" ] && echo && echo '      'One or more variables in $(tput smul)"$OLDCONF"$(tput rmul) is missing, contains a space, or is not && echo '   'an absolute file path. Exiting now. && echo && exit 1
	[ "$(echo "$v" | cut -c1)" != "/" ] && echo && echo '      'One or more variables in $(tput smul)"$OLDCONF"$(tput rmul) is missing, contains a space, or is not && echo '   'an absolute file path. Exiting now. && echo && exit 1       
	for y in "$OLDHEAD" "$OLDVAR" "$OLDROOT" "$OLDTMP" "$OLDSBIN"; do
                COUNT2=$((COUNT2 + 1))
                if [ "$v" = "$y" ] && [ "$COUNT1" != "$COUNT2" ]; then
                        echo '  '$(tput smul)Warning!$(tput rmul) Two of the current variables have the same value.
                        echo '  'Exiting now. Please edit $(tput smul)"$OLDCONF"$(tput rmul).
                        echo
                        exit 1
                fi
        done
done
}

main (){
NEWCONF=src/etc/yalpack.conf
NEWBKUP="$NEWCONF".yal
OLDCONF=/etc/yalpack.conf
OLDBKUP="$OLDCONF".yal

getnewvars
validatenew

# Upgrades from pre-0.2.0 versions will not have /etc/yalpack.conf. If the file
# does not exist, offer to copy it in.

unset COPIEDCONF

if [ ! -f "$OLDCONF" ]; then
	echo
	echo '	'$(tput smul)"$OLDCONF"$(tput rmul) was not found. This file will be needed once the new scripts are
	echo '	'in place. $(tput smul)"$NEWCONF"$(tput rmul) has the following variable values:
	echo
	echo '		'HEAD="$NEWHEAD"
	echo '		'VARBKUP="$NEWVAR"
	echo '		'ROOTHOME="$NEWROOT"
	echo '		'TMP="$NEWTMP"
	echo '		'SBINDIR="$NEWSBIN"
	echo
	echo '	'To copy $(tput smul)"$NEWCONF"$(tput rmul) to $(tput smul)"$OLDCONF"$(tput rmul) now, enter y. To exit, enter any other
	echo '	'character.
	unset INPUT
	read -r INPUT && [ "$INPUT" != "y" ] && echo && echo '	'Exiting now. See $(tput smul)\"Customization\"$(tput rmul) for details about $(tput smul)yalpack.conf$(tput rmul). && echo && exit 6
	echo
	cp -v "$NEWCONF" "$OLDCONF"
	chown root:root "$OLDCONF"
	chmod 644 "$OLDCONF"
	COPIEDCONF=yes
fi	

cp --preserve "$NEWCONF" "$NEWBKUP"
cp --preserve "$OLDCONF" "$OLDBKUP"

getoldvars
[ "$COPIEDCONF" != yes ] && validateold

echo
echo '	'Configuration self-consistency tests passed.
echo

# If the current values for SBINDIR and TMP are different from the values passed from Makefile,
# the upgrade will fail. Addressing now.
cp --preserve "$NEWCONF" "$NEWCONF.2"
cp --preserve "$OLDCONF" "$OLDCONF.2"

if [ "$OLDTMP" != "$2" ] || [ "$NEWTMP" != "$2" ]; then
	echo '	'There is a potential problem with TMP:
	echo
	if [ "$COPIEDCONF" = yes ]; then 
		echo '		'yalpack.conf: TMP="$OLDTMP"
	else
		echo '		'NEW: TMP="$NEWTMP"
		echo '		'OLD: TMP="$OLDTMP"
	fi
	echo '		'Makefile: TMP="$2"
	echo
	if [ "$NEWTMP" != "$2" ] && [ "$COPIEDCONF" != yes ]; then
		echo '	'TMP in "$NEWCONF" does not match the value from Makefile. This will not cause the
		echo '	'upgrade to fail. To change the value of TMP in "$NEWCONF", enter y. To continue
		echo '	'as-is, enter any other character.
		unset INPUT
		read -r INPUT && if [ -n "$INPUT" ] && [ "$INPUT" = "y" ]; then
			sed -i "s|=$NEWTMP|=$2|g" "$NEWCONF.2"
		elif [ -n "$INPUT" ] && [ "$INPUT" != "y" ]; then
			echo
			echo '	'Once "$NEWCONF".new has been moved to replace "$NEWCONF", be sure to use
			echo '	'DESTDIR calls, etc. with the new value of TMP.
			echo
		fi
	fi
	if [ "$OLDSBIN" != "$2" ]; then
		echo '	'Because TMP in "$OLDCONF" does not match the value passed from Makefile,
		echo '	'the upgrade or installation will fail. To change the value of TMP in
		echo '	'"$OLDCONF", enter y. To exit, enter any other character.
		unset INPUT
		read -r INPUT && if [ -n "$INPUT" ] && [ "$INPUT" = "y" ]; then
			sed -i "s|=$OLDTMP|=$2|g" "$OLDCONF.2"
			[ "$COPIEDCONF" = yes ] && sed -i "s|=$OLDTMP|=$2|g" "$NEWCONF.2"
		elif [ -n "$INPUT" ] && [ "$INPUT" != "y" ]; then
			echo
			cp --preserve "$OLDBKUP" "$OLDCONF"
			echo '	'Exiting now.
			echo
			exit 5
		fi
	fi
fi

if [ "$OLDSBIN" != "$1" ] || [ "$NEWSBIN" != "$1" ]; then
	echo '	'There is a potential problem with SBINDIR:
	echo
	if [ "$COPIEDCONF" = yes ]; then 
		echo '		'yalpack.conf: SBINDIR="$OLDSBIN"
	else
		echo '		'NEW: SBINDIR="$NEWSBIN"
		echo '		'OLD: SBINDIR="$OLDSBIN"
	fi
	echo '		'Makefile: SBINDIR="$1"
	echo
	if [ "$NEWSBIN" != "$1" ] && [ "$COPIEDCONF" != yes ]; then
		echo '	'Because SBINDIR in "$NEWCONF" does not match the value passed from Makefile,
		echo '	'the yalpack scripts will not be operational once "$OLDCONF".new is copied
		echo '	'to "$OLDCONF". To change the value of SBINDIR in "$NEWCONF" now,
		echo '	'enter y. To continue as-is, enter any other character.
		unset INPUT
		read -r INPUT && if [ -n "$INPUT" ] && [ "$INPUT" = "y" ]; then
			sed -i "s|=$NEWSBIN|=$1|g" "$NEWCONF.2"
		elif [ -n "$INPUT" ] && [ "$INPUT" != "y" ]; then
			echo
			echo '	'Once the upgrade is complete, be sure to edit SBINDIR in "$OLDCONF".new
			echo '	'to match the location of the sbin-type yalpack scripts before running
			echo '	'/usr/share/yalpack/newfiles.
			echo
		fi
	fi
	if [ "$OLDSBIN" != "$1" ]; then
		echo '	'Because SBINDIR in "$OLDCONF" does not match the value passed from Makefile,
		echo '	'the upgrade or installation will fail. To change the value of SBINDIR in
		echo '	'"$OLDCONF", enter y. To exit, enter any other character.
		unset INPUT
		read -r INPUT && if [ -n "$INPUT" ] && [ "$INPUT" = "y" ]; then
			sed -i "s|=$OLDSBIN|=$1|g" "$OLDCONF.2"
			[ "$COPIEDCONF" = yes ] && sed -i "s|=$OLDSBIN|=$1|g" "$NEWCONF.2"
		elif [ -n "$INPUT" ] && [ "$INPUT" != "y" ]; then
			echo
			echo '	'Exiting now.
			echo
			exit 5
		fi
	fi
	OLDSBIN="$(cat "$OLDCONF.2" | grep -m 1 SBINDIR\= | cut -d'=' -f2-)"
	NEWSBIN="$(cat "$NEWCONF.2" | grep -m 1 SBINDIR\= | cut -d'=' -f2-)"
	echo
	echo '	'Continuing. The sbin-type scripts will be installed under "$1".
	echo
fi

# Now that the changes in the previous loop (if any) are complete, move the .2 files back.
mv "$NEWCONF".2 "$NEWCONF"
mv "$OLDCONF".2 "$OLDCONF"

# For the final confirmation step, it's very important that the variables and the actual
# contents of the current config file match. Checking again to be safe.
getoldvars
validateold

getnewvars
validatenew

if [ "$1" != "$OLDSBIN" ]; then
	echo '	'Warning! The values for SBINDIR in "$OLDCONF" and Makefile
	echo '	'do not match! The attempted upgrade or installation will fail.
	echo '	'Stopping installation now.
	echo
	exit 1
fi

if [ "$2" != "$OLDTMP" ]; then
	echo '	'Warning! The values for TMP in "$OLDCONF" and Makefile
	echo '	'do not match! The attempted upgrade or installation will fail.
	echo '	'Stopping installation now.
	echo
	exit 1
fi

echo
rm -f "$NEWBKUP" "$OLDBKUP"
echo
}

main "$1" "$2" "$3"
