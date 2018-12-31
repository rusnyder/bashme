#! /usr/bin/env bash

# Fixes issue that was causing key signing to fail
GPG_TTY="$(tty)"
export GPG_TTY
