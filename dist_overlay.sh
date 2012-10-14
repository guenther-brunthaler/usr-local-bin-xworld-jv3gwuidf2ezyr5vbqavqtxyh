#!/bin/bash
# distfiles overlay script - dist_overlay.sh
#
# version 0.2.3
# INSTALL
# - copy this script to /usr/local/bin
# - add FETCHCOMMAND="/usr/local/bin/dist_overlay.sh \${URI}" to make.conf
# - modify following var's to your needs or set it in make.conf
# var's in make.conf have higher priority
# see http://forums.gentoo.org/viewtopic.php?p=1535632
#

# a : seperated list to the directories containing distfiles
# (cd-rom/dvd-rom/samba/nfs are checked to be mount)
DISTDIRS="/usr/local/portage/distfiles"

# command for fetching the file, if it wasn't found.
#DIST_FETCH="/usr/local/bin/getdelta.sh" # for deltup user
DIST_FETCH="/usr/bin/wget"

#file for log activity, enter a empty string to disable log writing
DIST_LOG="/var/log/dist_overlay.log"

# set true for coping a file instead of making a link
DIST_COPY=false

# be more verbose
DIST_VERBOSE=false

#### planed for further releases
# other distfiles location which needs to be mounted
# (nfs,cd,dvd,samba,...)
# MOUNT_DISTDIRS=""

# set to true to search for distfiles in subdirectories
DIST_DEEPSCAN=true

# options for find in deepscan
DIST_DEEPSCAN_OPTS="-follow"

###########################################################
# ---! you do not need to change anything below this !--- #
# #
###########################################################
# include variables from gentoo make.globals and make.conf
source /etc/make.globals
source /etc/portage/make.conf
PORTAGE_RSYNC_EXTRA_OPTS

# some colors for colored output

if $COLOR; then
	RED="\033[01;31m"
	GREEN="\033[01;32m"
	YELLOW="\033[01;33m"
	BLUE="\033[01;34m"
	MAGENTA="\033[01;35m"
	CYAN="\033[01;36m"
	NORMAL="\033[00m"
	else
	RED=""
	GREEN=""
	YELLOW=""
	BLUE=""
	MAGENTA=""
	CYAN=""
	NORMAL=""
fi

# log writing stuff
write_log() {
	if [ -n "$DIST_LOG" ]; then
		stamp=`date +%s`
		echo "$stamp: $@" >> $DIST_LOG
	fi
	if ${DIST_VERBOSE} ; then
		echo " >>> $stamp: $@"
	fi
}

# deleting symlinks (from clean mode)
delete() {
	write_log "(DELETE/CLEAN) $DISTDIR/$1"
	echo -e "${RED}\n*${NORMAL} Deleting symlink $1 (no such file)\n";
	rm $DISTDIR/$1
}

# clean dead symlinks in $DISTDIR
clean() {
	link_files=`ls -l "$1"| grep ^l| awk '{print $9}'`
	for name in $link_files; do [ -f $name ] || delete $name; done
}

# copy or symlink distfile to $DISTDIR
get_distfile() {
	FILE="$1"
	DIR="$2"

	echo -e "${GREEN}file found!\n${NORMAL}"

	if ${DIST_COPY}; then
		write_log "(COPY) $1 ($DISTDIR)"
		echo -e "${GREEN} * ${NORMAL} copy file to distfiles\n\n"
		cp $2/$1 $DISTDIR
	else
		write_log "(SYMLINK) $1 ($DISTDIR -> $2)"
		echo -e "${GREEN} * ${NORMAL} make a link from file to distfiles\n\n"
		ln -sf $2/$1 $DISTDIR/$1
	fi

	FETCHED=true
	break
}

# search for distfiles in overlay
scan() {
	ORIG_URI="$1"
	NEW_FILE=$(basename "$ORIG_URI")

	echo -e "${GREEN}\n * ${NORMAL}searching for $NEW_FILE"
	DIR=`echo $DISTDIRS | cut -d ":" -f 1`

	i=1
	FETCHED=false

	while [[ -n "$DIR" ]]; do
		echo -ne " ${NORMAL}scanning $DIR ... "

		# DIST_DEEPSCAN for searching in subdirectories
		if ( ${DIST_DEEPSCAN} ); then
			DIST_FIND_RESULT=`find "$DIR" ${DIST_DEEPSCAN_OPTS} -name "$NEW_FILE"`
			if [ -n "$DIST_FIND_RESULT" ]; then
				get_distfile $NEW_FILE $DIR
			fi
		elif [ -e "$DIR/$NEW_FILE" ]; then
			get_distfile $NEW_FILE $DIR
		fi


		echo -e "${YELLOW}file not found.${NORMAL}"

		i=`expr $i + 1`
		DIR=`echo $DISTDIRS | cut -d ":" -f $i`
	done

	if ! ${FETCHED}; then
		write_log "(FETCH) $ORIG_URI"
		echo -e "${RED}\n * Requested file is not in distfiles overlay."
		echo -e "${GREEN} * ${NORMAL}Fetching file from original URI\n $ORIG_URI\n"
		$DIST_FETCH -O $DISTDIR/$NEW_FILE $ORIG_URI
	fi
}

case "$1" in
	"clean")
		clean $DISTDIR
		;;
	*)
		scan $1
		;;
esac

exit 0
