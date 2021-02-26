#! /usr/bin/env bash

# Alias the codeowners-validator command to include most common invocation
alias codeowners-validator='REPOSITORY_PATH="./" EXPERIMENTAL_CHECKS="notowned" GITHUB_ACCESS_TOKEN="${GITHUB_CODEOWNERS_VALIDATOR_TOKEN}" OWNER_CHECKER_ORGANIZATION_NAME="arceo-labs" codeowners-validator'
