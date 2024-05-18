#!/bin/bash

wait_for_postgres() {
  retries=0
  until mix ecto.setup; do
    echo >&2 "Waiting for Postgres to receive TCP connections..."
    retries=$((retries+1))
    if [[ $retries -lt 3 ]]; then
      sleep 1
    else
      echo >&2 "Postgres is not available after multiple retries. Exiting..."
      exit 1
    fi
  done
}

wait_for_postgres

if [[ ! $MIX_ENV || $MIX_ENV == "dev" ]]; then
  mix docs
fi

if [[ "$1" == "iex" ]]; then
  iex -S mix phx.server
elif [[ "$1" == "cover" ]]; then
  MIX_ENV=$(test mix coveralls.html --trace --seed 0)
  mix phx.server
else
  mix phx.server
fi
