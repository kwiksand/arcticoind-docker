#!/bin/bash

set -e
ARCTICCOIN_DATA=/home/arcticcoin/.arcticcoin
CONFIG_FILE=arcticcoin.conf

if [ -z $1 ] || [ "$1" == "arcticcoind" ] || [ $(echo "$1" | cut -c1) == "-" ]; then
  cmd=arcticcoind
  shift

  if [ ! -d $ARCTICCOIN_DATA ]; then
    echo "$0: DATA DIR ($ARCTICCOIN_DATA) not found, please create and add config.  exiting...."
    exit 1
  fi

  if [ ! -f $ARCTICCOIN_DATA/$CONFIG_FILE ]; then
    echo "$0: arcticcoind config ($ARCTICCOIN_DATA/$CONFIG_FILE) not found, please create.  exiting...."
    exit 1
  fi

  chmod 700 "$ARCTICCOIN_DATA"
  chown -R arcticcoin "$ARCTICCOIN_DATA"

  if [ -z $1 ] || [ $(echo "$1" | cut -c1) == "-" ]; then
    echo "$0: assuming arguments for arcticcoind"

    set -- $cmd "$@" -datadir="$ARCTICCOIN_DATA"
  else
    set -- $cmd -datadir="$ARCTICCOIN_DATA"
  fi

  exec gosu arcticcoin "$@"
elif [ "$1" == "arcticcoin-cli" ] || [ "$1" == "arcticcoin-tx" ]; then

  exec gosu arcticcoin "$@"
else
  echo "This entrypoint will only execute arcticcoind, arcticcoin-cli and arcticcoin-tx"
fi
