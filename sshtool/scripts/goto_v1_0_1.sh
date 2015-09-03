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

function _checkConfig() {
  if [ -n "$1" -a "$1" == "-s" ] ; then
    # - is profile config file present
    [[ -a "${profCfgFile}" ]] || \
      echo "_checkEnv" "configuration file not found (${profCfgFile})"
      # report on screen
  else
    # - is profile config file present
    [[ -a "${profCfgFile}" ]]    || \
      _errorHndlr "_checkEnv" "configuration file not found (${profCfgFile})"

    # - are entries present
    grep -qv "^#" ${profCfgFile} || \
      _errorHndlr "_checkEnv" "no entries found in ${profCfgFile}"
  fi
}

function _parseConfig() {
  # parse configuration file

  . "${profCfgFile}"

}

function _sshConnect() {
	sshParameters="${userNames[$userID]}@${serverNames[$addressID]}.${serverDomain}"
	[[ -z ${portNr} ]] || sshParameters="$sshParameters -p ${portNr}"
	clear
	${SSH} ${sshParameters}
	exit 0
}

function _showList() {
	case "$1" in
		user)
			for userName in ${!userNames[*]}; do
					printf "%4d: %s\n" $userName ${userNames[$userName]}
			done
			;;
		server)
			for serverName in ${!serverNames[*]}; do
				printf "%4d: %s\n" $serverName ${serverNames[$serverName]}
			done
			;;
	esac
}



#----------------------------------------------------------------------------#
#      --- Main ---
#----------------------------------------------------------------------------#

# Check the amount of parameters
nrArgs=$#
echo "$nrArgs"


if [ "$1" == "postnl" ]
then
	. "${cfgDir}/postnl.conf"
	echo "Select a server"
	_showList server
	echo -n "Enter choice (1/2/...) "
	read addressID
	userNames[1]="${userCurrent}"
	echo "Which User would you like to login with"
	_showList user
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
	
	