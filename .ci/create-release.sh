#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

shopt -s nocasematch

if [[ "$TRAVIS_BRANCH" != "master" ]] && [[ -z "$TRAVIS_TAG" ]]; then
  echo "You are not merging into master nor is a tag present."
  exit 1
fi

declare pattern
declare RELEASE_FILENAME

# On merge to 'master', generate [jira_ticket_id].app.tgz release.
# Ticket name can safely be assumed based on the regexp /(gen[^0-9]+[0-9]+)/i.
if [[ "$TRAVIS_BRANCH" == "master" ]]; then
  shopt -s nocasematch
  pattern="(gen[^0-9]+[0-9]+)"
  if [[ "$TRAVIS_COMMIT_MESSAGE" =~ $pattern ]];then
    declare jira_ticket_id
    jira_ticket_id="${BASH_REMATCH[1]^^}" # convert to upper case
    export RELEASE_FILENAME=${jira_ticket_id// /-} # replace spaces with hyphens
  else
    echo "ERROR: Unable to get JIRA branch name from the merge to master."
    set -x && exit 1
  fi
fi

# On tag, generate [GIT_TAG].tgz release
if [[ -n "$TRAVIS_TAG" ]]; then
  export RELEASE_FILENAME="$TRAVIS_TAG"
fi

mv "${TRAVIS_BUILD_DIR}/build/release.tgz"  "${TRAVIS_BUILD_DIR}/build/${RELEASE_FILENAME}.tgz"
