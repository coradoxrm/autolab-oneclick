#!/usr/bin/env bash
#####################################
## Initialization & Helper Functions
#####################################
shopt -s extglob
set -e
set -o errtrace
set -o errexit

# Email and signup link are Base64-coded to prevent scraping
OUR_EMAIL=`echo -n 'YXV0b2xhYi1kZXZAYW5kcmV3LmNtdS5lZHU=' | base64 -d`
LIST_SIGNUP=`echo -n 'aHR0cDovL2VlcHVybC5jb20vYlRUT2lU' | base64 -d`
SCRIPT_PATH="${BASH_SOURCE[0]}";

AUTOLAB_PATH="${HOME}/Autolab";

# Colorful output
_red=`tput setaf 1`
_green=`tput setaf 2`
_orange=`tput setaf 3`
_blue=`tput setaf 4`
_purple=`tput setaf 5`
_cyan=`tput setaf 6`
_white=`tput setaf 6`
_reset=`tput sgr0`

# Log file
LOG_FILE=`mktemp`

# Global helpers
log()  { printf "${_green}%b${_reset}\n" "$*"; printf "\n%b\n" "$*" >> $LOG_FILE; }
logstdout() { printf "${_green}%b${_reset}\n" "$*" 2>&1 ; }
warn() { printf "${_orange}%b${_reset}\n" "$*"; printf "%b\n" "$*" >> $LOG_FILE; }
fail() { printf "\n${_red}ERROR: $*${_reset}\n"; printf "\nERROR: $*\n" >> $LOG_FILE; }

# Traps for completion and error
cleanup() {
    ERR_CODE=$?
    log "\nThank you for trying out Autolab! For questions and comments, email us at $OUR_EMAIL.\n"
    [ -z "$PSWD_REMINDER" ] || logstdout "As a final reminder, your MySQL root password is: $PSWD_REMINDER."
    unset MYSQL_ROOT_PSWD
    unset PSWD_REMINDER
    exit ${ERR_CODE:-0}
}

err_report() {
    ERR_CODE=$?

    # Ignore Ctrl-C interrupts
    if [ $ERR_CODE == 130 ];
    then
        return
    fi

    # Handle normal errors
    ERR_LINE=`sed -n "$1p" < $SCRIPT_PATH | sed -e 's/^[ \t]*//'`
    warn "Failed command: $ERR_LINE"
    fail "Line $1 of script has return value $ERR_CODE. The log file is saved at $LOG_FILE."
    exit $ERR_CODE
}

trap 'cleanup' EXIT
trap 'err_report $LINENO' ERR


############################################
## Setup Task Specifications
############################################

environment_setup() {
  log "[1/5] Installing docker and docker-compose"
  sudo apt-get -y -qq update
  #install relative packages
  sudo apt-get install -y -qq vim git curl python-pip
  #install docker
  curl -sSL https://get.docker.com/ | sh
  #install docker-compose
  pip install docker-compose
  log "[1/5] Done"
}

source_file_download() {
  log "[2/5] Downloading source file..."
  git clone https://github.com/autolab/Tango.git
  git clone https://github.com/autolab/Autolab
  log "[2/5] Done"
}

make_volumes() {
  log "[3/5] make volumes..."

  mkdir Autolab/courses
  sudo chown -R 9999:9999 Autolab/courses

  log "[3/5] Done"
}

init_docker() {
  log "[4/5] Init docker images and containers..."
  docker-compose up -d
  sleep 10
  log "[4/5] Done"
}


init_database() {
  log "[5/5] Init database..."

  docker-compose run --rm -e RAILS_ENV=production web rake db:create
  docker-compose run --rm -e RAILS_ENV=production web rake db:migrate
  docker-compose run --rm -e RAILS_ENV=production web rake db:seed

  log "[5/5] Done"
}

congrats() {
  log "[Congratulations! Autolab installation finished]\n
  - Open your browser and visit ${_orange}localhost:80${_reset} you will see the landing page\n
  - Log in with the initial account we create for you to try:\n${_orange}
  - Username: admin@foo.bar\n
  - password: 12345678
  ${_reset}
  - Contact us if you have any questions!"
}

#########################################################
## Main Entry Point
#########################################################
environment_setup
source_file_download
make_volumes
init_docker
init_database
congrats
