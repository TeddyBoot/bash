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
#              : Needs nslookup
# -------------------------------------------------------------------------- #
# Changes      : aug 27 2015 - First rebuild                          (T.Boot)
#              : oct 29 2015 - List or not added to server setting    (T.Boot)
#			   : feb 29 2016 - Fixed problems with lists              (T.Boot)
# -------------------------------------------------------------------------- #
# Extra        : 
# -------------------------------------------------------------------------- #

#----------------------------------------------------------------------------#
#      --- Variables ---
#----------------------------------------------------------------------------#
scriptVersion="2.0.0"										# script version
scriptName="$(basename ${0})"								# script name
ymdDate="$(date '+%Y%m%d')"									# sane date

baseDir=`echo ~`						                    # base directory
binDir="${baseDir}/bin"						    			# scripts / bin directory
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
# Function : _setServerName
# Syntax   : _setServerName <servername>
# Input    : servername
# Output   : Server name and server Domain
# ------------------------------------------------------------------ #
function _setServerName() {
	if [[ "$1" =~ ":" ]]; then
		#echo "Portnumber given with server name. Set port number" # only for debug/development purpose
		portNr=`echo $1 | cut -d: -f2` # must be before the next line otherwise paramName will be changed to something without portnumber
		paraName=`echo $1 | cut -d: -f1`
	else
		paraName="$1"
	fi
	#echo "paraName = ${paraName}" # only for debug/development purpose
	if [[ "$paraName" =~ "." ]]; then
		#echo "ServerName has domain included" # only for debug/development purpose
		serverName=`echo $paraName | cut -d. -f1`
		serverDomain=`echo $paraName | cut -d. --complement -s -f1`
	else
		serverName="${paraName}"
		#echo "servername needs domain" # only for debug/development purpose
		if [ "${domainList}" == "list" ]; then
			for dName in ${!serverDomains[*]}; do
				nsLookUp=`nslookup ${serverName}.${serverDomains[${dName}]} | grep "Name:"`
				#echo "nsLookUp (${serverDomains[${dName}]}) = $nsLookUp" # only for debug/development purpose
				if [ -n "${nsLookUp}" ]; then
					#echo "correct dns = ${serverDomains[${dName}]}" # only for debug/development purpose
					serverDomain="${serverDomains[${dName}]}"
				fi
			done
		fi
	fi
}

# ------------------------------------------------------------------ #
# Function : _setUserName
# Syntax   : _setUserName <username>
# Input    : username
# Output   : username
# ------------------------------------------------------------------ #
function _setUserName() {
	if [ "$1" == "current" -o -z "$1" ]; then
		#echo "Using current userName " # only for debug/development purpose
		userName="${userCurrent}"
	else
		userName="$1"
	fi
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
			for usrName in ${!userNames[*]}; do
					printf "%4d: %s\n" "$usrName" "${userNames[$usrName]}"
			done
			;;
		server)
			for srvName in ${!serverNames[*]}; do
				sName=`echo ${serverNames[$srvName]} | cut -d: -f1`
				printf "%4d: %s\n" $srvName ${sName}
			done
			;;
	esac
}

# ------------------------------------------------------------------ #
# Function : _sshConnect
# Syntax   : _sshConnect
# Input    : 
# Output   : Connection to server
# ------------------------------------------------------------------ #
function _sshConnect() {
	sshParameters="-X ${userName}@${serverName}.${serverDomain}"
	[[ -z ${portNr} ]] || sshParameters="$sshParameters -p ${portNr}"
	clear
	#echo "${SSH} ${sshParameters}" # only for debug/development purpose
	${SSH} ${sshParameters}
	exit 0
}

#----------------------------------------------------------------------------#
#      --- Main ---
#----------------------------------------------------------------------------#

# Check the amount of parameters, if not odds then error else continue
nrArgs=$#
#echo "Number of arguments: $nrArgs" # only for debug/development purpose

# check if number of arguments/parameters is an even number. If so then error
if [ $((nrArgs%2)) -eq 0 ]; then
	_errorHndlr "Parameters check" "Syntax Error, this command requires a parameter. Usage: goto (-s,-p <port>) <servername(:portnr)/profilename>"
fi

# if there are more than 1 arguments/parameters then split the arguments and link the correct ones together
if [ "$nrArgs" > "1" ]; then
	#echo "extract the parameters with values" # only for debug/development purpose
	COUNTER=1
	nrArgsMax=$((nrArgs - 1))
	# check all parameter sets until you reach the servername
	until [ $COUNTER -gt $nrArgsMax ];
	do
		param="${@: $COUNTER: 1}"
		#echo "parameter = ${param}" # only for debug/development purpose
		# check which parameters have been used and set the required values accordingly
		case $param in
			-p)
				# port parameter set setting portnumber setting
				countPlus=$COUNTER+1
				portNr="${@: $countPlus: 1}"
				;;
			*)
				# any parameters that are not in use will cause the program to give an error and stop
				_errorHndlr "Check of argruments" "Parameter ${param} cannot be used. Usage: goto (-s,-p <port>) <servername(:portnr)/profilename>"
				;;
		esac
		let COUNTER+=2
	done
fi

paramName="${@: -1}"

#echo "paramName = ${paramName}" # only for debug/development purpose

if [[ "$paramName" == "-s" ]]; then
	# using the silent profile
	#echo "Using the silent profile" # only for debug/development purpose
	_genLogger "Configuration file not found (${profCfgFile}), using the silent config file"
	profCfgFile="${cfgDir}/silent.conf"
	. ${profCfgFile}
elif [[ "${paramName}" =~ "." ]]; then
	# server name given
	#echo "No Profile given but server" # only for debug/development purpose
	_setServerName "${paramName}"
else
	#echo "profile name given" # only for debug/development purpose
	# check if profile config file exists
	serverListCheck=`grep -H ${paramName} ${cfgDir}/asml.txt`
	if [ ${serverListCheck} ]; then
		configFileName=`echo ${serverListCheck} | cut -d: -f1 | cut -d. -f1`
		serverName="${paramName}"
		profCfgFile="${configFileName}.conf"
	else
		profCfgFile="${cfgDir}/${paramName}.conf"
		#echo "Config File = ${profCfgFile}" # only for debug/development purpose
		# Error if config file does not exist
		[[ -a "${profCfgFile}" ]] || \
		_errorHndlr "ConfigFile check" "Configuration file not found (${profCfgFile})"
	fi
	. ${profCfgFile}
fi

#echo "check Config" # only for debug/development purpose

#echo "servernames = ${serverNames[*]}" # only for debug/development purpose

# Check if all variables have been set or set them

# Setting the servername from a config file
if [ "${serverList}" == "list" ]; then
	#echo "Checking if serverList is set to list" # only for debug/development purpose
	if [ -z "${serverNames[*]}" ]; then
		_errorHndlr "Check serverNames" "No ServerNames were found in your config"
	else
		echo "Select a server"
		_showList "server"
		echo -n "Enter choice (1/2/...)"
		read addressID
		servName="${serverNames[$addressID]}"
		_setServerName "${servName}"
	fi
else
	#echo "Checking if serverList is set to server" # only for debug/development purpose
	if [ -z "${serverName}" ]; then
		_errorHndlr "Check serverName" "No ServerName was found in your config"
	#else
		#echo "Server already set" # only for debug/development purpose
	fi
	_setServerName "${serverName}"
fi

# Setting the username from a config file
if [ "${userList}" == "list" ]; then
	#echo "Checking if userList is set to list" # only for debug/development purpose
	if [ -z "${userNames[*]}" ]; then
		_errorHndlr "Check userNames" "No userNames were found in your config"
	else
		echo "Select a user"
		_showList "user"
		echo -n "Enter choice (1/2/...)"
		read userID
		uName="${userNames[$userID]}"
		_setUserName "${uName}"
	fi
else
	_setUserName "${userName}"
fi


#echo "Username     = ${userName}" # only for debug/development purpose
#echo "server       = ${serverName}" # only for debug/development purpose
#echo "serverDomain = ${serverDomain}" # only for debug/development purpose
#echo "portNumber   = ${portNr}" # only for debug/development purpose

_sshConnect

echo "done"
