#! /usr/bin/env bash

# Fixes issue that was causing key signing to fail
export GPG_TTY=$(tty)
