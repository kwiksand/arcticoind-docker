#!/bin/sh
set -e
ARCTICCOIN_DATA=/home/arcticcoin/.arcticcoin
cd /home/arcticcoin/arcticcoind

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for arcticcoind"

  set -- arcticcoind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "arcticcoind" ]; then
  mkdir -p "$ARCTICCOIN_DATA"
  chmod 700 "$ARCTICCOIN_DATA"
  chown -R arcticcoin "$ARCTICCOIN_DATA"

  echo "$0: setting data directory to $ARCTICCOIN_DATA"

  set -- "$@" -datadir="$ARCTICCOIN_DATA"
fi

if [ "$1" = "arcticcoind" ] || [ "$1" = "arcticcoin-cli" ] || [ "$1" = "arcticcoin-tx" ]; then
  echo
  exec gosu arcticcoin "$@"
fi

echo
exec "$@"
