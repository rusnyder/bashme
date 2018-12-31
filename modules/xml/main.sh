#! /usr/bin/env bash

# Preload python environment
load_module python

# Ensure the xml2json module is loaded
load_git_submodule xml2json

# Load the xml2json script onto the path
load_bin xml xml2json/xml2json.py xml2json
