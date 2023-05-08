#!/usr/bin/env bash

if command brew 2> /dev/null; then
  if brew ls --versions rbenv > /dev/null; then
    brew upgrade rbenv
  else
    brew install rbenv
  fi
else
  echo "TODO: Install rbenv"
fi
