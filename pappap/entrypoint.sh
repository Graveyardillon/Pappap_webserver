#!/bin/sh

DB_USER=${DATABASE_USER:-postgres}

bin="/app/bin/pappap"
eval "$bin eval \"Pappap.Release.migrate\""

# start the elixir application

exec "$bin" "start"
