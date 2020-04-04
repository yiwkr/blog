#!/bin/bash

chown -R jekyll:jekyll .

if [[ $# -eq 0 ]]; then
  bundle update
  bundle exec jekyll serve --host 0.0.0.0
  exit $?
fi

exec "$@"
