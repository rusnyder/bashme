#! /usr/bin/env bash

# OpenSSL aliases
function __openssl_cmd()
{
  echo "# To verify a cert was signed by a ca"
  echo "openssl verify -verbose -CAfile [CA] [CERT]"
  echo
  echo "# To validate and print the contents of a cert"
  echo "openssl x509 -noout -text -in [CERT]"
}
alias openssl-cmd="__openssl_cmd"
