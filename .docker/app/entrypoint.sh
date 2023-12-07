#!/usr/bin/env bash
set -e

rm -f /app/.internal_test_app/tmp/pids/server.pid
bundle exec rails engine_cart:generate
bundle install
#sleep 1000000000
exec bundle exec rake arclight:server["-p 3000 -b 0.0.0.0"]