#! /bin/false

# v2026.263
shift; # Drop initial non-option dummy argument.
i=$# p=0
while test $i != 0
do
	case $n in
		0)
			# Process and remove phase functions.
			p=`expr $p + 1`
			case $1 in
				-*) eval func_$p=${1#?} default_$p=false;;
				*) eval func_$p=$1 default_$p=true
			esac
			eval run_$p=maybe
			;;
		*)
			# Skip but preserve user arguments.
			set -- "$@" "$1"
			n=`expr $n - 1 || :`
	esac
	shift
	i=`expr $i - 1 || :`
done
case $# in
	0) # No user arguments - enable all phases according to their defaults.
		i=0
		while :
		do
			i=`expr $i + 1`
			eval run_$i=\$default_$i
			test $i = $p && break
		done
		;;
	*) # Some user arguments - enable and consume valid phase numbers.
		while test $# != 0
		do
			if
				expr x"$1" : x'[1-9][0-9]*$' > /dev/null \
				&& test $1 -le $p
			then
				eval v=\$run_$1
				case $v in
					maybe) eval run_$1=true;;
					*) break 2
				esac
			else
				break
			fi
			shift
		done
		case $# in
			0) ;;
			*) # Could not consume all user arguments: Show help.
				echo 'The following phases are available:'
				i=0
				while :
				do
					i=`expr $i + 1`
					eval dfl=\$default_$i func=\$func_$i
					echo "Phase $i: $func (default: $dfl)"
					test $i = $p && break
				done
				echo
				cat <<- '===='
				Either explicitly specify as arguments (order
				does not matter) the numbers of the phases to
				be actually run, or specify no arguments at
				all in order to run all phases defaulting to
				"true".
				====
				exit
		esac
esac
i_tap0m6t11y4lhki77rmzjpr7m=0
p_tap0m6t11y4lhki77rmzjpr7m=$p
dry_run_tap0m6t11y4lhki77rmzjpr7m=$dry_run
unset i n p v dry_run
while :
do
	i_tap0m6t11y4lhki77rmzjpr7m=`expr $i_tap0m6t11y4lhki77rmzjpr7m + 1`
	eval run=\$run_$i_tap0m6t11y4lhki77rmzjpr7m \
		func=\$func_$i_tap0m6t11y4lhki77rmzjpr7m
	case $run in
		true)
			echo "Executing phase # $i_tap0m6t11y4lhki77rmzjpr7m" \
				"(\"$func\")"
			set $func
			$dry_run_tap0m6t11y4lhki77rmzjpr7m \
				&& set echo SIMULATION: "$@"
			unset run func
			"$@"
	esac
	test $i_tap0m6t11y4lhki77rmzjpr7m = $p_tap0m6t11y4lhki77rmzjpr7m \
		&& break
done
