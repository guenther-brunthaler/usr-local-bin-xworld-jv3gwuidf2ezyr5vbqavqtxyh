#! /bin/sh
set -e
cleanup() {
	rc=$?
	test -n "$TDIR" && rm -r -- "$TDIR"
	test $rc = 0 || echo "$0 failed!" >& 2
}
TDIR=
trap cleanup 0

force=false
while getopts f opt
do
	case $opt in
		f) force=true;;
		*) false || exit
	esac
done
shift `expr $OPTIND - 1`

#TDIR=`mktemp -d "${TMPDIR:-/tmp}/${0##*/}.XXXXXXXXXX"`
f=symlinks_hwgc35lwxcnwgle7lmdv2n9th.txt
for dir
do
	test -d "$dir"
	if test -e "$dir/$f"
	then
		$force
	fi
	(
		cd "$dir"
		find . -type l | LC_COLLATE=C sort | while IFS= read -r L
		do
			test -L "$L" || exit
			echo "L:$L"
			echo "T:`readlink -- "$L"`"
		done > "$f"
		while IFS=: read -r K L
		do
			test L = "$K"
			IFS=: read -r K T
			test T = "$K"
			rm -- "$L"
		done < "$f"
	)
done
