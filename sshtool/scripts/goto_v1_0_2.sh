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
#              : oct 29 2015 - List or not added to server setting    (T.Boot)
# -------------------------------------------------------------------------- #
# Extra        : 
# -------------------------------------------------------------------------- #

#----------------------------------------------------------------------------#
#      --- Variables ---
#----------------------------------------------------------------------------#
scriptVersion="1.0.2"											# script version
scriptName="$(basename ${0})"								# script name
ymdDate="$(date '+%Y%m%d')"									# sane date

baseDir="/home/boottedd/git/bash/sshtool"					# base directory
binDir="${baseDir}/scripts"									# scripts / bin directory
logDir="${baseDir}/logs"									# log directory
tmpDir="${baseDir}/temp"									# temp directory
cfgDir="${baseDir}/conf"									# configuration file directory

scriptLog="${logDir}/${scriptName%%.*}.${ymdDate}.run"
SSH=`which ssh`
userCurrent=`whoami`

#----------------------------------------------------------------------------#
#      --- Functions ---
#----------------------------------------------------------------------------#

# ------------------------------------------------------------------ #
# Function : _checkConfig
# Syntax   : _checkConfig
# Input    : none
# Output   : error message to stdout and logfile + exit
# ------------------------------------------------------------------ #
function _checkConfig() {
  if [ -n "$1" -a "$1" == "-s" ] ; then
    # - is profile config file present
    [[ -a "$1" ]] || \
      echo "_checkConfig" "configuration file not found (${profCfgFile})"
      # report on screen
  else
    # - is profile config file present
    [[ -a "${profCfgFile}" ]]    || \
      _errorHndlr "_checkConfig" "configuration file not found (${profCfgFile})"

    # - are entries present
    grep -qv "^#" ${profCfgFile} || \
      _errorHndlr "_checkConfig" "no entries found in ${profCfgFile}"
  fi
}

# ------------------------------------------------------------------ #
# Function : _errorHndlr
# Syntax   : _errorHndlr "action name" "some error message"
# Input    : location/action + error message
# Output   : full error message to stdout and logfile + exit
# ------------------------------------------------------------------ #
function _errorHndlr () {
  # log error message.
  errorLocation="$1"
  errorMessage="$2"

  # to file
  _genLogger "FATAL ERROR: ${errorMessage}"

  # to screen (if run from command line)
  if [[ "$( /usr/bin/tty )" != "not a tty" ]]
  then
    echo "
  A fatal error occurred.

    Script  : ${scriptName}
    Action  : ${errorLocation}
    Error   : ${errorMessage}

  Exiting now.
"
  fi
  _genLogger "exiting on fatal error"
  exit 1
}

# ------------------------------------------------------------------ #
# Function : _genLogger
# Syntax   : _genLogger "some message"
# Input    : log message
# Output   : date + log message are written to logfile
# ------------------------------------------------------------------ #
function _genLogger () {
  # log message to file, prefixed with date
  logMessage="$1"
  echo "$(date '+%Y%m%d %H:%M:%S') - ${logMessage}" >> ${scriptLog}
}

# ------------------------------------------------------------------ #
# Function : _parseConfig
# Syntax   : _parseConfig
# Input    : 
# Output   : error and exit or continue
# ------------------------------------------------------------------ #
function _parseConfig() {
  # parse configuration file

  . "${profCfgFile}"

}

# ------------------------------------------------------------------ #
# Function : _showList
# Syntax   : _showList <server|user>
# Input    : <server|user>
# Output   : list of users or servers printed on screen
# ------------------------------------------------------------------ #
function _showList() {
	case "$1" in
		user)
			for userName in ${!userNames[*]}; do
					printf "%4d: %s\n" "$userName" "${userNames[$userName]}"
			done
			;;
		server)
			for serverName in ${!serverNames[*]}; do
				sName=`echo ${serverNames[$serverName]} | cut -d: -f1`
				printf "%4d: %s\n" $serverName ${sName}
			done
			;;
	esac
}

function _determinePort () {
	if [[ ${serverNames[$addressID]} =~ .*:.* ]]
	then
		portCheck=`echo ${serverNames[$addressID]} | cut -d: -f2`
	else
		portCheck=""
	fi
	
	if [ "${portCheck}" != "" ]; then
		portNr="${portCheck}"
	elif [ -z $portNr ]; then
		echo "Port set to $portNr"
	else
		echo "Standard port is used"
	fi
}

function _determineServerName () {
	servName=`echo ${serverNames[$addressID]} | cut -d: -f1`
}

# ------------------------------------------------------------------ #
# Function : _sshConnect
# Syntax   : _sshConnect
# Input    : 
# Output   : Connection to server
# ------------------------------------------------------------------ #
function _sshConnect() {
	_determinePort
	_determineServerName
	sshParameters="-X ${userNames[$userID]}@${servName}.${serverDomain}"
	[[ -z ${portNr} ]] || sshParameters="$sshParameters -p ${portNr}"
	clear
	#echo "${SSH} ${sshParameters}"
	${SSH} ${sshParameters}
	exit 0
}


#----------------------------------------------------------------------------#
#      --- Main ---
#----------------------------------------------------------------------------#

# Check the amount of parameters, if not odds then error else continue
nrArgs=$#
echo "Number of arguments: $nrArgs"
[[ $((nrArgs%2)) -eq 0 ]] && errorMsg="Syntax error"
if [ "$errorMsg" == "Syntax error" ]; then
	echo "$errorMsg , Please check your command"
	exit 1
fi

# set profile specific settings or exit in case of an error
PROFILE="$1"
profCfgFile="${cfgDir}/${PROFILE}.conf"
logProf="${logDir}/${PROFILE}.${ymdDate}.log"
_checkConfig

# check all settings and set variables
_parseConfig

# select the server to connect to 
if [ "${serverList}" == "list" ]; then
	echo "Select a server"
	_showList server
	echo -n "Enter choice (1/2/...) "
	read addressID
else
	addressID="1"
	echo "Server = ${serverNames[$addressID]}"
fi

# select the username to login with
userNames[1]="${userCurrent}"
echo "Which User would you like to login with"
_showList user
echo -n "Enter choice (1/2/...)"
read userID

# Current user setting
if [ "$userID" == "0" ]; then
	echo "${userCurrent}"
else
	echo "${userNames[$userID]}"
fi

_sshConnect
	
