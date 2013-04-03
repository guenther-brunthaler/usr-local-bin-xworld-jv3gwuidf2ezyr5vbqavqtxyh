#! /bin/false
# Source this file from within your script file.
#
# This snippet requires a single argument $1: A path
# including a filename prefix.
#
# Note that passing arguments to the "." command is not*
# *portable!
#
# Use the "set" command to set the arguments for sourcing
# this script, use the --stop option to save old arguments
# after it.
#
# All files matching the current system will then be
# executed as snippets in the current shell context.
#
# It is therefore important that the snippets take care not
# to pollute the shell variable/function namespace without
# stringent reason.
#
# In order to be executed, the snippets must conform
# to the following name syntax:
# "PREFIX-NNxxx@SYSKEY.sh"
# where
# "PREFIX": The argument passed to this script.
# "NN": A 2-digit integer used for sorting, i. e. "50".
# "xxx": Optional arbitrary text, to describe the item.
# "SYSKEY": The string returned by 'get-system-key'.
#
# Options only valid after the single required argument:
#
# --stop
#   Stops argument processing, leaving the remaining
#   arguments set as $1 and onward. This is needed if it is
#   required to "save" previous arguments after the --stop,
#   which will become the current arguments again after
#   sourcing this script. Typically used as '--stop "$@"'.


log_65khet0pxstjidx3e59ig8j3j() {
	logger -p "local0.$1" -t system-snippet "$2"
}


info_65khet0pxstjidx3e59ig8j3j() {
	log_65khet0pxstjidx3e59ig8j3j info "$*"
	test -z "$VERBOSE_65khet0pxstjidx3e59ig8j3j" && return
	echo "INFO: $*" >& 2
}


warn_65khet0pxstjidx3e59ig8j3j() {
	echo "WARNING: $*" >& 2
	log_65khet0pxstjidx3e59ig8j3j warning "$*"
}


call_65khet0pxstjidx3e59ig8j3j() {
	local NS SYSTEM_KEY
	NS=_65khet0pxstjidx3e59ig8j3j
	local SUFFIX VERBOSE$NS ST F$NS F
	set -- --version 2 SYSTEM_KEY --from system-key --stop "$@"
	. /usr/local/bin/xworld/functions/lookup.sh
	if test x"$1" = x"--verbose"
	then
		VERBOSE_65khet0pxstjidx3e59ig8j3j=1
		shift
	fi
	SUFFIX="${1%/*}"
	if test x"$SUFFIX" = x"$1"
	then
		warn$NS "Invalid snippet prefix '$1'!"
	elif test ! -d "$SUFFIX"
	then
		warn$NS "Invalid snippet directory '$SUFFIX'!"
	fi
	SUFFIX="@$SYSTEM_KEY.sh"
	for F_65khet0pxstjidx3e59ig8j3j in $1-??*$SUFFIX
	do
		F="$F_65khet0pxstjidx3e59ig8j3j"
		test -f "$F" || continue
		info$NS "Sourcing snippet '$F'"
		true
		. "$F"
		ST=$?
		F=$F_65khet0pxstjidx3e59ig8j3j
		NS=_65khet0pxstjidx3e59ig8j3j
		if test "$ST" -eq 0
		then
			info$NS "Snippet '$F' succeeded."
		else
			warn$NS "Snippet '$F' returned status $ST!"
		fi
	done
	unset -f info$NS warn$NS log$NS
}


call_65khet0pxstjidx3e59ig8j3j "$@"
while test $# != 0
do
	if test x"$1" = x"--stop"
	then
		shift; break
	fi
	shift
done
unset -f call_65khet0pxstjidx3e59ig8j3j
