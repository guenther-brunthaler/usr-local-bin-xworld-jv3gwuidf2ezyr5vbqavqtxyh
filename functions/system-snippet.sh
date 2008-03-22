#!/bin/false
# $HeadURL"
# $Author: root $
# $Date: 2006-11-29T23:32:39.877454Z $
# $Revision: 457 $

# Call this snippet with a single argument:
# A path including a filename prefix.
#
# All files matching the current system will then
# be executed as snippets in the current shell context.
#
# It is therefore important that the snippets take
# care not to pollute the shell variable/function namespace
# without stringent reason.
#
# In order to be executed, the snippets must conform
# to the following name syntax:
# "PREFIX-NNxxx@SYSKEY.sh"
# where
# "PREFIX": The argument passed to this script.
# "NN": A 2-digit integer used for sorting, i. e. "50".
# "xxx": Optional arbitrary text, to describe the item.
# "SYSKEY": The string returned by 'get-system-key'.


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
	. /usr/local/bin/functions/lookup.sh --version 1 \
		SYSTEM_KEY --from system-key
	if [ "$1" = "--verbose" ]; then
		VERBOSE_65khet0pxstjidx3e59ig8j3j=1
		shift
	fi
	SUFFIX="${1%/*}"
	if [ "$SUFFIX" = "$1" ]; then
		warn$NS "Invalid snippet prefix '$1'!"
	elif [ ! -d "$SUFFIX" ]; then
		warn$NS "Invalid snippet directory '$SUFFIX'!"
	fi
	SUFFIX="@$SYSTEM_KEY.sh"
	for F_65khet0pxstjidx3e59ig8j3j in $1-??*$SUFFIX; do
		F="$F_65khet0pxstjidx3e59ig8j3j"
		test -f "$F" || continue
		info$NS "Sourcing snippet '$F'"
		true
		. "$F"
		ST="$?"
		F="$F_65khet0pxstjidx3e59ig8j3j"
		NS=_65khet0pxstjidx3e59ig8j3j
		if [ "$ST" -eq 0 ]; then
			info$NS "Snippet '$F' succeeded."
		else
			warn$NS "Snippet '$F' returned status $ST!"
		fi
	done
	unset -f info$NS warn$NS log$NS
}


call_65khet0pxstjidx3e59ig8j3j "$@"
unset -f call_65khet0pxstjidx3e59ig8j3j
