#! /bin/false
# qin - quote if necessary


# Prints $1 quoted as necessary for eval().
# Typical use: eval "$( qin "$CMD" )"
qin() {
	local OUT S IN C Q W
	IN=$1; S=; Q=
	while test -n "$IN"
	do
		C=$IN
		IN=${C#?}
		C=${C%$IN}
		case $C in
			'!') qin_flush 1; S=$S!;;
			"'") qin_flush 2; S=$S$C;;
			'"' | '`' | '$' | "\\")
				qin_flush 3;
				if test x"$Q" = x"1"
				then
					S=$S$C
				else
					S=$S\\$C
				fi
			;;
			" ") qin_flush 3; S=$S$C;;
			*) S=$S$C;;
		esac
	done
	qin_flush
	if test -z "$OUT"
	then
		qin_flush 2; qin_flush
	fi
	local IFS=
	printf "%s\n" "$OUT"
}


# Internally used.
# Helper for qin().
# $1 = "": We need no more quoting.
# $1 = 1: We need single quoting.
# $1 = 2: We need double quoting.
# $1 = 3: We need any quoting.
# $S: current output string segment.
# $Q: current quoting.
# $W: temporary.
# $OUT: Total output; already quoted.
qin_flush() {
	W=$1
	if test "$W" = 3
	then
		if test -n "$Q"
		then
			# Re-use current quoting.
			W=$Q
		else
			# Use double quotes as default.
			W=2
		fi
	fi
	if test -n "$W"
	then
		test -z "$Q" && Q=$W
		# No action if requested quoting is compatible.
		test x"$W" = x"$Q" && return
	fi
	# Default operation: Flush $S into $OUT.
	if test x"$Q" = x"1"
	then
		S="'$S'"
	elif test x"$Q" = x"2"
	then
		S="\"$S\""
	fi
	if test -n "$S"
	then
		OUT=$OUT$S
		S=
	fi
	# Finally, set requested quoting.
	Q=$W
}
