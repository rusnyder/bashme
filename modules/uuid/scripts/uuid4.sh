#! /usr/bin/env bash

uuidgen | tr -d '\n' | tr '[:upper:]' '[:lower:]'
