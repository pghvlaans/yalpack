#!/bin/sh

# Just messing around with dialog a bit.

dialogger (){
unset lines
unset height

lines="$(echo "$1" | wc -l)"
height="$((4 + "$lines"))"
[ "$height" -gt "30" ] && height=30

dialog --title "$3" --no-collapse --"$2" "$1" "$height" 85 || { clear && exit ;}
}

kernelcheck (){
TITLE="$KERNELS"
if [ -z "$HOME" ]; then
	X="Please run as a user with a home directory."
	dialogger "$X" msgbox "$TITLE"
	return
fi

KLIST=$HOME/.kernellist
INDLIST="$KLIST"/list
mkdir "$KLIST"

cd "$KLIST" || exit

rm -f index.html || exit
wget https://kernel.org 2>&1 | dialog --title "$TITLE" --no-collapse --programbox 25 85

if [ ! -f index.html ]; then
	X="Looks like the download failed!"
	dialogger "$X" msgbox "$TITLE"
	return
fi

date > "$INDLIST"
echo >> "$INDLIST"
echo "Installed kernels:" >> "$INDLIST"
find /boot/* -maxdepth 0 -type f | grep vmlinuz-generic | cut -d'-' -f3- >> "$INDLIST"
grep -v "Latest Release" index.html | grep \<strong\> index.html | cut -d'>' -f3- | cut -d'<' -f1 >> "$INDLIST"

X="$(cat "$INDLIST")"
clear && dialogger "$X" msgbox "$TITLE"

rm -f index.html
}

updatecheck (){
TITLE=CHANGELOG
if [ -z "$HOME" ]; then
	X="Please run as a user with a home directory."
	dialogger "$X" msgbox "$TITLE"
	return
fi

unset X
unset MIRROR
MIRROR="$(grep -v ^\# /etc/slackpkg/mirrors)"

if [ -z "$MIRROR" ]; then
	X="/etc/slackpkg/mirrors has no mirror set!"
	dialogger "$X" msgbox "$TITLE"
	return
fi

if [ "$(echo "$MIRROR" | wc -l)" != "1" ]; then
	X="/etc/slackpkg/mirrors has too many mirrors set!"
	dialogger "$X" msgbox "$TITLE"
	return
fi

cd || exit
rm -f "$HOME"/ChangeLog.txt
wget "$MIRROR"/ChangeLog.txt 2>&1 | dialog --title "$TITLE" --no-collapse --programbox 25 85

if [ ! -f "$HOME/ChangeLog.txt" ]; then
	dialogger ""$HOME"/ChangeLog.txt was not found!" msgbox "$TITLE"
	return
fi

X="$(diff /var/lib/slackpkg/ChangeLog.txt "$HOME"/ChangeLog.txt)"
[ -z "$X" ] && X="No upgrades to do."
dialogger "$X" msgbox CHANGELOG
}

X="$(fortune)"
dialogger "$X" msgbox WELCOME

kernelcheck

updatecheck
clear
exit
