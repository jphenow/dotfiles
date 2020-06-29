#!/usr/bin/env bash

if brew ls --versions direnv > /dev/null; then
  brew upgrade direnv
else
  brew install direnv
fi
