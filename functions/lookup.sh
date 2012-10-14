#! /bin/false
# Source this file from within your script file.
#
# It will set up the specified environment variables
# associated with the specified keywords.
#
# The --key and --namespace options are used
# to further distinguish the lookup.
#
# --version <integer>
#  *** Mandatory! *** Minimum required version number
#  to be used for the lookup.sh interface. The example
#  invocation above represents the current version number
#  of this script.
# --key defaults to the name of the host, which will not
# be retrieved by using any of the system functions, but
# rather as the contents of the 'system-key' file
# in the configuration script directory (which is the only
# file *not* to be shared among hosts).
# --namespace defaults to the absolute path name of the
# invoking script, with '/' replaced by '_'.
# --script <scriptname> can be used to specify a different
# script than the caller's own script name.
#
# In order for the --namespace default to be effective,
# the script must be sourced before changing the
# current directory, or otherwise the absolute
# path name may not correctly be deduced if the
# parent script was invoked using a relative pathname.
#
# Example:
# . /usr/local/bin/xworld/functions/lookup.sh --version 1 \
#	SIZE --into GB LOGNAME
#
# will use the key and pathname of the parent script
# to construct a combined namespace, then retrieve
# the value of the key name "SIZE" and assign it to $GB;
# and retrieve value for key "LOGNAME" and assign it to
# $LOGNAME.
#
# By default, the name of the specified key will be the
# same as the name of the environment variable, unless
# the --into option is used after the key in order to
# specify the retrieved value to a different variable.
#
# Options:
# --into <varname>
#  Without --into, the specified key will also be used as
#  the name of the variable to obtain the requested value.
# --default <value>
#  will provide a default value to
#  be used if the settings file is not found instead
#  of giving an error.
# --multiline
#  returns the contents of all lines of the settings file
#  instead of just the first line.
#  With multiline, all lines will be terminated with newline
#  characters. Without --multiline, the first newline character
#  terminates the value and will not be part of the value.
# --from "filename"
#  Does not read or write the specified setting, but rather
#  assign the pathname of the resulting settings file
#  to the specified variable.
# --from "system-key"
#  Does not read or write any setting, but rather
#  assign the system key of the local host to the specified
#  variable. This system key will typically be the hostname,
#  but can in fact be anything the administrator has set up to
#  be for the local system.
#  However, the key will always disambiguate the current system
#  from any other systems.


die_pm7csrzj8zcp2p5kh63vcrxia() {
	echo "ERROR in 'lookup.sh' (called from '$0'): $*" >& 2
	false; exit
}


# Set $NS to the absolute pathname of $1,
# remove the leading '/', and URL-encode any
# characters which may cause problems.
get_absname_pm7csrzj8zcp2p5kh63vcrxia() {
	local N D ORIG FROM INTO
	N=$1
	while :
	do
		# Already absolute?
		test x"${N#/}" != x"$N" && break
		# Filename only?
		if test ! -e "$N" && test x"${N#*/}" = x"$N"
		then
			N=`which -- "$N"`
			break
		fi
		# Must be relative to current directory.
		D=`pwd`
		N=$D${D:+/}$N
		break
	done
	if test ! -f "$N"
	then
		die_pm7csrzj8zcp2p5kh63vcrxia \
			"Cannot locate script '$N'!"
	fi
	# Strip leading slash.
	N=${N#/}
	ORIG=$N
	# Now "interpret" the path; i. e. resolve it step by step,
	# while keeping track of the resulting canonical path.
	NS=
	while test -n "$ORIG"
	do
		N=${ORIG%%/*}
		if test x"$N" = x"$ORIG"
		then
			ORIG=
		else
			ORIG=${ORIG#*/}
		fi
		case $N in
			.)	;;
			..)	NS=${NS%/*};;
			*)	NS=$NS${NS:+/}$N;;
		esac
	done
	# URL-encode problematic characters.
	for D in %25 ' 20' /2F @40 '$24' :3A; do
		FROM=${D%??}
		INTO=%${D#$FROM}
		ORIG=$NS
		NS=
		while test -n "$ORIG"
		do
			N=${ORIG%%$FROM*}
			if test x"$N" = x"$ORIG"
			then
				ORIG=
			else
				ORIG=${ORIG#*$FROM}
			fi
			NS=$NS${NS:+$INTO}$N
		done
	done
}


getval_pm7csrzj8zcp2p5kh63vcrxia() {
	if test -f "$SF"
	then
		if test -n "$ML"
		then
			VALUE=
			while read LINE
			do
				VALUE=$VALUE$LINE$NL
			done < "$SF"
		else
			read VALUE <"$SF"
		fi
	elif test -n "$HAVE_DFL"
	then
		VALUE=$DEFAULT
	else
		die_pm7csrzj8zcp2p5kh63vcrxia \
			"Cannot locate key '$KEY' (file '$SF')!"
	fi
}


get_from_pm7csrzj8zcp2p5kh63vcrxia() {
	case $1 in
		filename | system-key) OP=$1;;
		*)
			die_pm7csrzj8zcp2p5kh63vcrxia \
				"Unsupported --from argument '$1'!"
		;;
	esac
}


# Does the actual work.
process_pm7csrzj8zcp2p5kh63vcrxia() {
	local NAMESPACE_PREFIX NAMESPACE_SUFFIX NS SKEY SCRIPT
	local KEY VNAME VALUE DEFAULT HAVE_DFL SF ML LINE NL OP
	local NAMESPACE_BASE HNF REQUIRE IFACE EVAL
	# Change the following line to customize the
	# association settings database location.
	NAMESPACE_BASE="/usr/local/etc/config"
	# The following line will set the version
	# of the current interface.
	# Always keep in sync with the example
	# in the initial comments!
	IFACE=1
	#
	SCRIPT=$0
	while :
	do
		case $1 in
			--key) SKEY=$2;;
			--namespace) NS=$2;;
			--script) SCRIPT=$2;;
			--version) REQUIRE=$2;;
			-*)
				die_pm7csrzj8zcp2p5kh63vcrxia \
					"Unknown option '$1'!"
			;;
			*) break;;
		esac
		shift; shift
	done
	if test -z "$REQUIRE"
	then
		die_pm7csrzj8zcp2p5kh63vcrxia \
			"No interface version has been specified!"
	elif test "$REQUIRE" -gt "$IFACE"
	then
		die_pm7csrzj8zcp2p5kh63vcrxia \
			"The installed lookup.sh provides interface" \
			"version $IFACE, but '$0' requested" \
			"a newer version $REQUIRE!"
	fi
	if test "$REQUIRE" -ne "$IFACE"
	then
		VALUE=
		for LINE in \
			"The installed lookup.sh provides interface" \
			"version $IFACE, but '$0' requested the older" \
			"version $REQUIRE! Update the script a.s.a.p."
		do VALUE=$VALUE$LINE$'\n'
		done
		logger -p user.warning -t lookup.sh "$VALUE"
	fi
	test -n "$SKEY" || {
		HNF="$NAMESPACE_BASE/system_key_pm7csrzj8zcp2p5kh63vcrxia"
		test -f "$HNF" || {
			die_pm7csrzj8zcp2p5kh63vcrxia \
				"Missing selection key file '$HNF'!"
		}
		read SKEY < "$HNF" && test -n "$SKEY" || {
			die_pm7csrzj8zcp2p5kh63vcrxia \
				"Cannot determine selection key from '$HNF'!"
		}
	}
	test -n "$NS" || get_absname_pm7csrzj8zcp2p5kh63vcrxia "$SCRIPT"
	NAMESPACE_PREFIX="$NAMESPACE_BASE/$NS:"
	NAMESPACE_SUFFIX="@$SKEY"
	NL="$'\n'"
	while [ -n "$1" ]; do
		# The key name always comes *first*!
		KEY="$1"; shift
		# It is also the default for the destination variable name.
		VNAME="$KEY"
		HAVE_DFL=
		ML=
		OP=
		while true; do
			case "$1" in
				--into)
					# Option "--into <varname>".
					VNAME="$2"
					shift
				;;
				--default)
					# Option "--default <default_value>".
					DEFAULT="$2"
					HAVE_DFL=1
					shift
				;;
				--multiline) ML=1;;
				--from)
					get_from_pm7csrzj8zcp2p5kh63vcrxia \
						"$2"
					shift
				;;
				-*)
					die_pm7csrzj8zcp2p5kh63vcrxia \
						"Unknown option '$1'!"
				;;
				*) break;;
			esac
			shift
		done
		SF="$NAMESPACE_PREFIX$KEY$NAMESPACE_SUFFIX"
		while true; do
			case "$OP" in
				filename) VALUE="$SF";;
				system-key) VALUE="$SKEY";;
				*) getval_pm7csrzj8zcp2p5kh63vcrxia;;
			esac
			break
		done
		# Assign $VALUE to $VNAME:
		# Add the assignment statment to $EVAL.
		# We cannot eval yet: The requested target
		# variables may have the same name as our
		# own local work variables.
		EVAL="$EVAL${EVAL:+;}$VNAME=\"$VALUE\""
	done
	# Assign evaluation list to safe return variable.
	eval_pm7csrzj8zcp2p5kh63vcrxia="$EVAL"
}


# Undefine any functions or global variables defined
# by this module, excluding only itself.
cleanup_namespace_pm7csrzj8zcp2p5kh63vcrxia() {
	unset -f \
		get_from_pm7csrzj8zcp2p5kh63vcrxia \
		getval_pm7csrzj8zcp2p5kh63vcrxia \
		die_pm7csrzj8zcp2p5kh63vcrxia \
		get_absname_pm7csrzj8zcp2p5kh63vcrxia \
		process_pm7csrzj8zcp2p5kh63vcrxia
	unset \
		eval_pm7csrzj8zcp2p5kh63vcrxia
}


# Use functions and local variables where possible.
# Use global names for temporary functions names only.
# Tag all such temporary global names with UUIDs in
# order to minimize possible name clashes.
process_pm7csrzj8zcp2p5kh63vcrxia "$@"
# Perform assignments.
eval "$eval_pm7csrzj8zcp2p5kh63vcrxia" || {
	die_pm7csrzj8zcp2p5kh63vcrxia \
		"Could not evaluate" \
		">>>$eval_pm7csrzj8zcp2p5kh63vcrxia<<<!"
}
# Clean up all temporary globals.
cleanup_namespace_pm7csrzj8zcp2p5kh63vcrxia
unset -f cleanup_namespace_pm7csrzj8zcp2p5kh63vcrxia
