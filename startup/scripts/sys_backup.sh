#!/bin/bash
# -------------------------------------------------------------------------- #
# Author       : T.Boot        teddy.boot@sogeti.nl
# Owner        : Sogeti B.V.
# -------------------------------------------------------------------------- #
# Syntax       : clonePuppetConfig.sh
# Options      : none
# -------------------------------------------------------------------------- #
# Purpose      : Clone a puppet configuration from the GIT(VSO) repository
# -------------------------------------------------------------------------- #
# Dependencies : Needs Linux
# -------------------------------------------------------------------------- #
# Changes      : Oct 27 2015 - First build                            (T.Boot)
# -------------------------------------------------------------------------- #
# Extra        : 
# -------------------------------------------------------------------------- #

# -------------------------------------------------------------------------- #
# --- Variables ---
# -------------------------------------------------------------------------- #

# -- script related
scriptVersion="1.0.0"                                   # script version
scriptName="$(basename ${0})"                           # script name
ymdDate="$(date '+%Y%m%d%H%M')"                         # sane date

# -- script directories
baseDir="/home/boottedd/git/bash/startup"               # base directory
binDir="${baseDir}/scripts"                             # scripts / bin directory
logDir="${baseDir}/logs"                                # log directory
cfgDir="${baseDir}/conf"                                # configuration directory

# -- script specific
curUser="$(/usr/bin/whoami)"
dirList="
bin
Desktop
Documents
Downloads
Dropbox
git
Music
Pictures
Videos
work"
originalDir="~/"
destinationDir="/run/media/${curUser}/LacieExt/BackupFolder/"


# -------------------------------------------------------------------------- #
# --- Functions ---
# -------------------------------------------------------------------------- #

# ------------------------------------------------------------------ #
# Function : _cycleDirs
# Syntax   : _cycleDirs <dirList>
# Input    : List of directories
# Output   : Execution of command(s) on list of directories
# ------------------------------------------------------------------ #
function _commandExec() {
	# Find all commands to be executed per directory
	if [ -d "${destinationDir}/$1" ]; then
		echo "This is a Directory and exists: ${destinationDir}/$1"
		command="rsync"
	else
		echo "This is NOT a Directory or does NOT exists: ${destinationDir}$1"
		command="cp -Rf"
	fi
}

# ------------------------------------------------------------------ #
# Function : _cycleDirs
# Syntax   : _cycleDirs <dirList>
# Input    : List of directories
# Output   : Execution of command(s) on list of directories
# ------------------------------------------------------------------ #
function _cycleDirs() {
	for dirRun in ${dirList}; do
		# execute commands
		_commandExec $dirRun
		echo "${command} ${originalDir}$dirRun ${destinationDir}$dirRun"
		${command} ${originalDir}$dirRun ${destinationDir}$dirRun
	done
}

# -------------------------------------------------------------------------- #
# --- Main ---
# -------------------------------------------------------------------------- #

# Copy or use Rsync to copy all files from ~/

#cp -Rf ~/ /run/media/${curUser}/LacieExt/BackupFolder/

# Testing part. should be deleted after first complete version
_cycleDirs