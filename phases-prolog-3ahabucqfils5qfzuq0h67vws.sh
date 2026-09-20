#! /bin/false

# Pass explicitly the numbers of all phases to run, or run all phases to be
# run by default. Any other arguments (including "-h" or "--help") will show
# a help text (which phase numbers refer to which phases).
#
# The functions themselves can use any variables desired. The framework
# invoking the functions uses UUID-based names for its own purpose, so there
# is no danger of unintended name collisions. The framework used the
# positional arguments between invocations, but the called functions are free
# to set and use the positional arguments during their invocation.
#
# v2026.263

set -e
dry_run=false
case $1 in
	--) shift
esac
n=$#; set not-an-option ${1+"$@"}

return

# Usage example in your script:

set -e
trap 'test $? = 0 || echo "\"$0\" failed" >& 2' 0
. phases-prolog-3ahabucqfils5qfzuq0h67vws.sh

set "$@" phase1_default
phase1_default() {
	...
}

set "$@" -phase2_nondefault
phase2_nondefault() {
	...
}

. phases-volatile-3ahabucqfils5qfzuq0h67vws.sh # Optional.
. phases-epilog-3ahabucqfils5qfzuq0h67vws.sh
