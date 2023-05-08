#!/usr/bin/env bash

if command brew 2> /dev/null; then
  if brew ls --versions asdf > /dev/null; then
    brew upgrade asdf
  else
    brew install asdf
  fi
else
  echo "TODO: Install asdf: https://asdf-vm.com/guide/getting-started.html"
fi
