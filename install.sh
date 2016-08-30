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
  log "[1/6] Installing docker and docker-compose"
  sudo apt-get -y update
  #install relative packages
  sudo apt-get install -y vim git curl python-pip
  #install docker
  curl -sSL https://get.docker.com/ | sh
  #install docker-compose
  pip install docker-compose
  log "[1/6] Done"
}

source_file_download() {
  log "[2/6] Downloading source file..."
  git clone https://github.com/autolab/Tango.git
  git clone https://github.com/autolab/Autolab
  log "[2/6] Done"
}

copy_config() {
  log "[3/6] Copying config files..."

  #should be added to Autolab master
  cp configs/Tango/start.sh Tango/start.sh
  cp configs/Autolab/Dockerfile Autolab/Dockerfile
  #cp configs/Autolab/seeds.rb Autolab/db/seeds.rb
  cp configs/Autolab/autolab.rake Autolab/lib/tasks/autolab.rake

  #User customize
  cp configs/Tango/config.py Tango/config.py
  cp configs/Autolab/autogradeConfig.rb Autolab/config/autogradeConfig.rb
  cp configs/Autolab/devise.rb Autolab/config/initializers/devise.rb
  cp configs/Autolab/nginx.conf Autolab/docker/nginx.conf
  cp configs/Autolab/production.rb Autolab/config/environments/production.rb

  cp configs/Autolab/autograde.rb Autolab/app/controllers/assessment/autograde.rb

  log "[3/6] Done"
}

make_volumes() {
  log "[4/6] make volumes..."

  mkdir Autolab/courses
  sudo chown -R 9999:9999 Autolab/courses

  log "[4/6] Done"
}

init_docker() {
  log "[5/6] Init docker images and containers..."
  docker-compose up -d
  sleep 10
  log "[5/6] Done"
}


init_database() {
  log "[6/6] Init database..."

  docker-compose run --rm -e RAILS_ENV=production web rake db:create
  docker-compose run --rm -e RAILS_ENV=production web rake db:migrate
  docker-compose run --rm -e RAILS_ENV=production web rake autolab:populate

  cp -R ./Autolab/examples/hello/ ./Autolab/courses/AutoPopulated/
  chown -R 9999:9999 ./Autolab/courses/AutoPopulated/hello/

  log "[6/6] Done"
}

congrats() {
  log "[Congratulations! Autolab installation finished]\n
  - Open your browser and visit ${_orange}localhost:80${_reset} you will see the landing page\n
  - Log in with the initial account we create for you to try:\n${_orange}
  - Username: admin@foo.bar\n
  - password: adminfoobar
  ${_reset}
  - Contact us if you have any questions!"
}

#########################################################
## Main Entry Point
#########################################################
environment_setup
source_file_download
copy_config
make_volumes
init_docker
init_database
congrats
