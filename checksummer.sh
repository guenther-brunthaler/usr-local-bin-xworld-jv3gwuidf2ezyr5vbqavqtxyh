#! /bin/sh
# Create or verify a list of checksums, and a checksum of that list.
#
# The checksums are created from the files in directory tree $1, and paths in
# the checksums file are stored relative to the root of that tree.
#
# The files in the checksums file are sorted independent of locale, allowing
# to create consistent minimal diffs between different locales.
#
# When creating the checksums, only normal files are processed. Special files,
# including symlinks, are silently ignored. If you want to include symlinks,
# archive their contents as a normal symlink archive file before running this
# script.
#
# Copyright (c) 2017 Guenther Brunthaler. All rights reserved.
# 
# This script is free software.
# Distribution is permitted under the terms of the GPLv3.

set -e
cleanup() {
	rc=$?
	test -n "$TDIR" && rm -r -- "$TDIR"
	test $rc = 0 || echo "$0 failed!" >& 2
}
TDIR=
trap cleanup 0
trap 'exit $?' INT TERM HUP QUIT
oldIFS=$IFS

SEP=`printf '\034:'`; SEP=${SEP%:}
add_xcl() {
	exclusions=$exclusions${exclusions:+$SEP}$1
}

force=false
f=CKSUMS
f2=CKSUMSSUM
exclusions=;
fo=$f; f2o=$f2
while getopts Xx:c:a:f opt
do
	case $opt in
		x) add_xcl "$OPTARG";;
		X) add_xcl "$fo"; add_xcl "$f2o";;
		a) f=$OPTARG;;
		c) f2=$OPTARG;;
		f) force=true;;
		*) false || exit
	esac
done
shift `expr $OPTIND - 1`

save=
case $1 in
	create) save=true;;
	verify) save=false
esac
test $# != 2 && save=
: ${save:?"Usage: $0 [ <options> ... ] ( create | verify ) <dirtree>"}
dir=$2
test -d "$dir"
if $save
then
	if test -e "$f" || test -e "$f2"
	then
		$force
	fi
	> "$f"
	> "$f2"
else
	test -f "$f"
	if test -e "$f2"
	then
		test -f "$f2"
	else
		$force
	fi
fi

# Make $1 relative to canonical directory $2, or canonicalize $1. Result in $t.
mkrel() {
	local t2
	test -n "$1"
	t=`readlink -f -- "$1"`
	t2=${t#"$2/"}
	test x"$t2" != x"$t" && t=${t2##/}
	test -n "$t"
}
dir=`readlink -f -- "$dir"`
mkrel "$f" "$dir"; cf=$t
if $save || test -e "$f2"
then
	mkrel "$f2" "$dir"; cf2=$t
else
	cf2=
fi

fail() {
	echo "*** FAILURE ***" >& 2
	false || exit
}

success() {
	echo "*** SUCCESS ***" >& 2
}

# Like xargs, but path names are passed as complete lines without any quoting.
xargs_from_lines() {
	sed '
		s:^./::
		s:['\'\\\\\\\\']:'\\\\'&:g
		s:.*:'\''&'\'':
	' | xargs -E '' "$@"
}

cd "$dir"
if $save
then
	# Create checksums; store source paths relative to directory tree, and
	# sort them by source path in a locale-independent way.
	set find .
	test x"${cf#/}" = x"$cf" && set "$@" ! -path "./$cf"
	if test -n "$cf2" && test x"${cf2#/}" = x"$cf2"
	then
		set "$@" ! -path "./$cf2"
	fi
	oldIFS=$IFS; IFS=$SEP
	for x in $exclusions
	do
		IFS=$oldIFS
		mkrel "$x" "$dir"; x=$t
		test x"${x#/}" = x"$x" && set "$@" ! -path "./$x"
	done
	IFS=$oldIFS
	set "$@" ! -type l -type f
	"$@" | xargs_from_lines	cksum -- | LC_COLLATE=C sort -k 3 > "$cf"
	cksum -- "$cf" > "$cf2"
	read sum _ < "$cf2"
	echo "All checksums have been created successfully."
	echo "Top-level checksum is $sum."
	success
else
	TDIR=`mktemp -d -- "${TMPDIR:-/tmp}/${0##*/}.XXXXXXXXXX"`
	T=$TDIR/t1
	T2=$TDIR/t2

	# Compare factual file $T to should-be file $1 and bail out with a
	# diff if there are any differences.
	compare() {
		cmp -- "$1" "$T" > /dev/null && return
		echo "Checksum verification ***ERROR***!" >& 2
		diff -u -- "$1" "$T" || :
		echo
		echo "File legend for above 'diff' output:"
		echo "'---' = What should be."
		echo "'+++' = What actually is, and unfortunately different."
		fail
	}

	if test -n "$cf2"
	then
		cksum -- "$cf" > "$T"
		compare "$cf2"
		echo "Checksum in file '$f2' of" \
			"checksums file '$f' is correct."
	fi
	error=false
	while read -r _ _ path
	do
		test x"${path#/}" = x"$path" # Paths in file must be relative!
		if test ! -e "$path"
		then
			echo "MISSING ? $path"
			errors=true
		elif test -L "$path"
		then
			echo "UNSUPPORTED:SYMLINK ? $path"
			errors=true
		elif test -d "$path"
		then
			echo "UNSUPPORTED:DIRECTORY ? $path"
			errors=true
		elif ! test -f "$path"
		then
			echo "UNSUPPORTED:SPECIAL_FILE ? $path"
			errors=true
		elif test -r "$path"
		then
			printf '%s\n' "$path" >& 5
		else
			echo "UNREADABLE_FILE ? $path"
			errors=true
		fi
	done < "$cf" > "$T2" 5> "$T"
	xargs_from_lines cksum -- < "$T" >> "$T2"
	LC_COLLATE=C sort -k 3 "$T2" > "$T"
	compare "$cf"
	echo
	if $errors
	then
		# There are errors which already existed when the checksum
		# file was created. Complain anyway.
		grep -v -- '^[[:digit:]]' "$cf"
		echo "There checksum file '$f' contains the above errors!"
		fail
	else
		echo "All checksums match."
		success
	fi
fi
