#!/usr/bin/env bash
# exit on error
set -o errexit

# Load project-local deployment settings before Rails initializes. In
# particular, database.yml reads DATABASE_URL before Rails initializers run.
if [[ -f .env ]]; then
  set -a
  source .env
  set +a
fi

bundle install
bundle exec rake db:migrate
bundle exec rake db:seed
