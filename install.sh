#!/usr/bin/env bash
# For one-liner bootstrap install:
#   curl -s https://git.io/vVrP0 | bash
set -e

basedir="$( cd "$(dirname "$0")"; pwd )"
evaldir="\$HOME${basedir#$HOME}"

echo "Installing…"
gem list -i bundler >/dev/null 2>&1 || (gem install bundler && rbenv rehash)
bundle config build.thrift --with-cppflags='-D_FORTIFY_SOURCE=0'

# Ignore build failures; bigdata/impala subcommands are optional.
{ bundle check || (bundle install && rbenv rehash) || true
} >/dev/null 2>&1

echo "Setting up your Terminal environment…"
if grep -q "37 init" ~/.bash_profile; then
  if ! grep -q "$evaldir/bin/37" ~/.bash_profile; then
    echo "You have 37 configured, but in a different location!"
    echo "Remove this line from the .bash_profile file in your home directory then retry the install:"
    grep "37 init" ~/.bash_profile
    exit 1
  fi
else
  echo "eval \"\$(\"$evaldir/bin/37\" init -)\"" >> ~/.bash_profile
fi

echo "Done! Close this Terminal window and open a new one to start using 37."
