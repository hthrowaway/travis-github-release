#!/usr/bin/env bash

# NOTE: Bash on Travis's OSX is at version 3.x so don't go too crazy with Bash.

set -x
set -euo pipefail
IFS=$'\n\t'


TRAVIS_BRANCH="master"
TRAVIS_COMMIT_MESSAGE="merge foo bar into myname/gen 32

foobar"

set +eu



if [[ "${TRAVIS_BRANCH:-}" != "master" ]] && [[ -z "${TRAVIS_TAG:-}" ]]; then
  echo "You are not merging into master nor is a tag present."
  exit 1
fi

declare pattern
declare release_filename

# On merge to 'master', generate [jira_ticket_id].app.tgz release.
# Ticket name can safely be assumed based on the regexp /(gen[^0-9]+[0-9]+)/i.
if [[ "${TRAVIS_BRANCH:-}" == "master" ]]; then
  shopt -s nocasematch
  pattern="(gen[^0-9]+[0-9]+)[^0-9]*"
  if [[ "${TRAVIS_COMMIT_MESSAGE:-}" =~ $pattern ]];then
    declare jira_ticket_id
    jira_ticket_id=$(echo "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]')
    release_filename=${jira_ticket_id// /-} # replace spaces with hyphens
  else
    echo "ERROR: Unable to get JIRA branch name from the merge to master."
    set -x && exit 1
  fi
fi

# On tag, generate [GIT_TAG].tgz release
if [[ -n "${TRAVIS_TAG:-}" ]]; then
  release_filename="$TRAVIS_TAG"
fi

mv "${TRAVIS_BUILD_DIR}/build/release.tgz"  "${TRAVIS_BUILD_DIR}/build/${release_filename}.tgz"

set +x
