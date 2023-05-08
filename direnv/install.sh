#!/usr/bin/env bash

if command brew 2>/dev/null; then
  if brew ls --versions direnv > /dev/null; then
    brew upgrade direnv
  else
    brew install direnv
  fi
else
  echo "TODO: INSTALL direnv"
fi
