#!/bin/bash
# -------------------------------------------------------------------------- #
# Author       : T.Boot        teddy.boot@sogeti.nl
# Owner        : Sogeti B.V.
# -------------------------------------------------------------------------- #
# Syntax       : goto.sh
# Options      : -p <port>, <servername | serverIP>
# -------------------------------------------------------------------------- #
# Purpose      : Create a puppetbackup on test and copy it to stepstone
# -------------------------------------------------------------------------- #
# Dependencies : Needs Linux (UNIX flavors are not supported)
# -------------------------------------------------------------------------- #
# Changes      : aug 27 2015 - First rebuild                          (T.Boot)
# -------------------------------------------------------------------------- #
# Extra        : 
# -------------------------------------------------------------------------- #

#----------------------------------------------------------------------------#
#      --- Variables ---
#----------------------------------------------------------------------------#
scriptVersion="1.0"											# script version
scriptName="$(basename ${0})"								# script name
ymdDate="$(date '+%Y%m%d')"									# sane date

baseDir="/home/boottedd/git/bash/sshtool"					# base directory
binDir="${baseDir}/scripts"									# scripts / bin directory
logDir="${baseDir}/logs"									# log directory
tmpDir="${baseDir}/temp"									# temp directory
cfgDir="${baseDir}/conf"									# configuration file directory

SSH=`which ssh`
userCurrent=`whoami`
#----------------------------------------------------------------------------#
#      --- Functions ---
#----------------------------------------------------------------------------#

function _sshConnect() {
	sshParameters="${userNames[$userID]}@${serverNames[$addressID]}.${serverDomain}"
	[[ -z ${portNr} ]] || sshParameters="$sshParameters -p ${portNr}"
	clear
	${SSH} ${sshParameters}
	exit 0
}

function _showList() {
	#for var1
	echo "something"
}

#----------------------------------------------------------------------------#
#      --- Main ---
#----------------------------------------------------------------------------#

if [ "$1" == "postnl" ]
then
	. "${cfgDir}/postnl.conf"
	echo "Select a server"
	for serverName in ${!serverNames[*]}; do
		printf "%4d: %s\n" $serverName ${serverNames[$serverName]}
	done
	echo -n "Enter choice (1/2/...) "
	read addressID
	userNames[1]="${userCurrent}"
	echo "Which User would you like to login with"
	for userName in ${!userNames[*]}; do
		printf "%4d: %s\n" $userName ${userNames[$userName]}
	done
	echo -n "Enter choice (1/2/...)"
	read userID
	if [ "$userID" == "0" ]; then
		echo "${userCurrent}"
	else
		echo "${serverNames[$userID]}"
	fi
	for item in ${serverNames[*]}
	do
	    printf "   %s\n" $item
	done
	_sshConnect
fi
	
	