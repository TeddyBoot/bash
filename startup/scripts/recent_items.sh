#!/bin/bash
# -------------------------------------------------------------------------- #
# Author       : T.Boot        teddy.boot@sogeti.nl
# Owner        : Sogeti B.V.
# -------------------------------------------------------------------------- #
# Syntax       : recent_items.sh
# Options      : <open | lock | status>
# -------------------------------------------------------------------------- #
# Purpose      : add or not files to the list of recent items
# -------------------------------------------------------------------------- #
# Dependencies : Needs Linux (UNIX flavors are not supported)
# -------------------------------------------------------------------------- #
# Changes      : oct 28 2015 - First rebuild                          (T.Boot)
# -------------------------------------------------------------------------- #
# Extra        : 
# -------------------------------------------------------------------------- #

#----------------------------------------------------------------------------#
#      --- Variables ---
#----------------------------------------------------------------------------#
scriptVersion="1.0"											# script version
scriptName="$(basename ${0})"								# script name
ymdDate="$(date '+%Y%m%d')"									# sane date

baseDir="/home/boottedd/git/bash/startup"					# base directory
binDir="${baseDir}/scripts"									# scripts / bin directory
logDir="${baseDir}/logs"									# log directory
tmpDir="${baseDir}/temp"									# temp directory
cfgDir="${baseDir}/conf"									# configuration file directory

param="$1"

#----------------------------------------------------------------------------#
#      --- Functions ---
#----------------------------------------------------------------------------#

# ------------------------------------------------------------------ #
# Function : _defineCommand
# Syntax   : _defineCommand
# Input    : <lock|open|status>
# Output   : Command to execute
# ------------------------------------------------------------------ #
function _defineCommand() {
	case "$param" in
		open)
			execCmd="sudo chattr -i"
			;;
		lock)
			execCmd="sudo chattr +i"
			;;
		status)
			execCmd="lsattr"
			;;
		*)
			echo "There is no or an incorrect value given as parameter. Please use only the following: open|lock|status"
			exit 1
			;;
	esac
}

# ------------------------------------------------------------------ #
# Function : _checkExec
# Syntax   : _checkExec
# Input    : 
# Output   : Message with correct or incorrect
# ------------------------------------------------------------------ #
function _checkExec() {
	attribs=$(lsattr ~/.local/share/recently-used.xbel)
	case "$param" in
		open)
			tmpVar=$(expr substr "$attribs" 5 1)
			if [ "${tmpVar}" == "i" ]; then
				echo "Something went wrong, try manually"
				exit 1
			else
				echo "All is wel, Recent Files now open"
				exit 0
			fi
			;;
		lock)
			tmpVar=$(expr substr "$attribs" 5 1)
			if [ "${tmpVar}" == "i" ]; then
				echo "All is wel, Recent Files are now locked"
				exit 0
			else
				echo "Something went wrong, try manually"
				exit 1
			fi
			;;
		status)
			tmpVar=$(expr substr "$attribs" 5 1)
			if [ "${tmpVar}" == "i" ]; then
				echo "Recent Files are currently locked"
			else
				echo "Recent Files are currently open"
			fi
			exit 0
			;;
	esac
}
#----------------------------------------------------------------------------#
#      --- Main ---
#----------------------------------------------------------------------------#

# Determine what to do
_defineCommand

# Execute command
${execCmd} ~/.local/share/recently-used.xbel

# Check if all is well
_checkExec 