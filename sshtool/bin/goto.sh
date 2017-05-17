#!/bin/bash
# -------------------------------------------------------------------------- #
# Author       : T.Boot        teddy.boot@sogeti.nl
# Owner        : Sogeti B.V.
# -------------------------------------------------------------------------- #
# Syntax       : goto.sh
# Options      : -p <port>, -s, <servername | serverIP>
# -------------------------------------------------------------------------- #
# Purpose      : Create a puppetbackup on test and copy it to stepstone
# -------------------------------------------------------------------------- #
# Dependencies : Needs Linux (UNIX flavors are not supported)
#              : Needs nslookup
# -------------------------------------------------------------------------- #
# Changes      : may 16 2017 - Second rebuild                         (T.Boot)
# -------------------------------------------------------------------------- #
# Extra        : 
# -------------------------------------------------------------------------- #

#----------------------------------------------------------------------------#
#      --- Variables ---
#----------------------------------------------------------------------------#
scriptVersion="3.0.0"										# script version
scriptName="$(basename ${0})"								# script name
ymdDate="$(date '+%Y%m%d')"									# sane date

baseDir="/home/boottedd/bin/bash/sshtool" 					# base directory (default `echo ~`
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

#----------------------------------------------------------------------------#
#      --- Main ---
#----------------------------------------------------------------------------#

# Check the amount of parameters, if not odds then error else continue
nrArgs=$#
#echo "Number of arguments: $nrArgs" # only for debug/development purpose

if [ "${nrArgs}" -le "1" ]; then
	echo "Single or No parameters"
	portSet=`echo $1 | cut -d: -f2`
	paramPort=`echo $1 | cut -d: -f1`
	userSet=`echo $1 | cut -d@ -f1`
	paramUser=`echo $1 | cut -d@ -f2`
	# check if port is set
	if [ "${portSet}" == "$1" ]; then
		echo "No Port is set"
		# because no port is set check if user is set
		if [ "${userSet}" == "$1" ]; then
			# No user is set and no port is set so parameter is either hostname or config
			echo "No user is set"
			hostConfig="$1"
		else
			# User is set so second part of the parameter is either hostname or config 
			echo "User will be set to ${userSet}"
			hostConfig="${paramUser}"
		fi
	else
		# Port is set so first part of parameter is either hostname or config
		echo "Port will be set to ${portSet}"
		hostConfig="${paramPort}"
	fi
else
	echo "Multiple parameters"
fi

# Set parameter part as configfile name
profCfgFile="${cfgDir}/${hostConfig}.conf"
# Check if the config file exitst
if [ -a "${profCfgFile}" ]; then
	# Configfile exists so we will now read that
	echo "Profile set to ${profCfgFile}"
else
	# Config file does NOT exist so param-part is either a host or error. Set default configfile. 
	echo "No profile set Using default"
	profCfgFile="${cfgDir}/default.conf"
	hostName="${hostConfig}"
fi

if [ -a "${hostName}" ]; then
	echo "Hostname : ${hostName}"
else
	echo "No hostname set, checking configfile"
fi

