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
ymdDate="$(date '+%Y%m%d')"                             # date for in scripts

# -- script directories
baseDir="/home/boottedd/git/bash/startup"               # base directory
binDir="${baseDir}/scripts"                             # scripts / bin directory
logDir="${baseDir}/logs"                                # log directory
cfgDir="${baseDir}/conf"                                # configuration directory

# -- script specific
curUser="$(/usr/bin/whoami)"
dirListHome="
bin
Desktop
Documents
Downloads
Dropbox
git
Music
Pictures
Videos"
dirListOpt="
racktables
AzureCLi
vuze"
dirListVar="html"
dirListWork="work"
dirListYum="yum.repos.d"
dirListDb="databases"
destinationDir="/run/media/${curUser}/LacieExt/BackupFolder"

# -------------------------------------------------------------------------- #
# --- Functions ---
# -------------------------------------------------------------------------- #

# ------------------------------------------------------------------ #
# Function : _cycleDirs
# Syntax   : _cycleDirs <dirList>
# Input    : List of directories
# Output   : Execution of command(s) on list of directories
# ------------------------------------------------------------------ #
function _cycleDirs() {
	case $1 in
		home)
			originalDir="/home/boottedd"
			listName="${dirListHome}"
			destDir="${destinationDir}/home"
			;;
		var)
			originalDir="/var/www"
			listName="${dirListVar}"
			destDir="${destinationDir}/var"
			;;
		work)
			originalDir="/home"
			listName="${dirListWork}"
			destDir="${destinationDir}/"
			;;
		db)
			originalDir=""
			listName="${dirListDb}"
			destDir="${destinationDir}"
			;;
		opt)
			originalDir="/opt"
			listName="${dirListOpt}"
			destDir="${destinationDir}/opt"
			;;
		yum)
			originalDir="/etc"
			listName="${dirListYum}"
			destDir="${destinationDir}/yum"
			;;
	esac
	for dirRun in ${listName}; do
		# execute commands
		_commandExec $dirRun
		echo "${command} ${originalDir}/$dirRun ${destDir}"
		${command} ${originalDir}/$dirRun ${destDir}
	done
}

# ------------------------------------------------------------------ #
# Function : _commandExec
# Syntax   : _commandExec <directory>
# Input    : file or directory
# Output   : Command(s) with parameters to be executed
# ------------------------------------------------------------------ #
function _commandExec() {
	# Find all commands to be executed per directory
	if [ -d "${destDir}" ]; then
		#echo "This is a Directory and exists: ${destinationDir}/$1"
		command="sudo rsync -h -r -p -t -P --copy-links --delete"
	fi
}

# ------------------------------------------------------------------ #
# Function : _backupDb
# Syntax   : _bacupDb
# Input    : <none>
# Output   : database backup in sql file format
# ------------------------------------------------------------------ #
function _backupDb () {
	echo "Creating a backup of the database: /${dirListDb}/localhost_${ymdDate}.sql"
	mysqldump -u root --password="C007mac!" --all-databases > /${dirListDb}/localhost_${ymdDate}.sql
}

# -------------------------------------------------------------------------- #
# --- Main ---
# -------------------------------------------------------------------------- #

# Make database backup
_backupDb

# use rsync to backup all directories
_cycleDirs home

_cycleDirs var

_cycleDirs work

_cycleDirs opt

# Copy database backup
_cycleDirs db

# Copy yum repository settings
_cycleDirs yum