#!/usr/bin/env bash
set -e

rm -f /app/.internal_test_app/tmp/pids/server.pid
bundle install
bundle exec rails engine_cart:generate
bundle install
exec bundle exec rake arclight:server["-p 3000 -b 0.0.0.0"]