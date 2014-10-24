#!/bin/bash -e
source "${UBIENV_ROOT}/bashrc-utils"

if [ "${UBIENV_OS}" != "Darwin" ]; then
  exit 0
fi

if [ "${BREW_HOME}" == "" ]; then
  echo "BREW_HOME env var not set. Bailing out"
  exit 1
fi

if [ ! -e "${BREW_HOME}/bin/brew" ]; then
  if ls "${BREW_HOME}/*" > /dev/null 2>&1; then
    mkdir -p "${BREW_HOME}"
    git clone "https://github.com/Homebrew/homebrew" "${BREW_HOME}"
  else
    ubienv::err "Cannot install homebrew. ${BREW_HOME} is not empty"
    exit 1
  fi
fi

exit 0