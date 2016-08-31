#!/bin/bash

usage() {
  echo "$ ./install.sh [options]"
  echo "options:"
  echo "-s,       for real-world deployment on a server"
  echo "-l,       for trail purpose on a local VM"
  exit 1;
}

while getopts ":hsl" opt; do
  case $opt in
    h)
      usage
      ;;
    s)
      echo "server" >&2
      OPTION="server"
      ;;
    l)
      echo "local" >&2
      OPTION="local"
      ;;
    \?)
      echo "Invalid Option"
      usage
      ;;
  esac
done

if [ $# -eq 0 ]
  then
    usage
fi

echo $OPTION/like
