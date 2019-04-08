#! /usr/bin/env bash

# Helper function that joins the default-delimited stdin
# with the specified delimiter
#
# usage: join_by DELIMITER < file
function join_by()
{
  local IFS="$1"; shift; echo "$*";
}
export -f join_by
