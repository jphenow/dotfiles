#!/usr/bin/env bash

if brew ls --versions rbenv > /dev/null; then
  brew upgrade rbenv
else
  brew install rbenv
fi
