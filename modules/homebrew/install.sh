#!/bin/sh -e
if [ "${UBIENV_OS}" != "Darwin" ]; then
  exit 0
fi

if [ "${TOOLS_DIR}" == "" ]; then
  echo "TOOLS_DIR env var not set. Bailing out"
  exit 1
fi

if [ ! -d "${TOOLS_DIR}/homebrew/bin" ]; then
  mkdir -p "${TOOLS_DIR}/homebrew"
  (
    cd "${TOOLS_DIR}"
    curl -L "https://github.com/Homebrew/homebrew/tarball/master" | \
        tar xz --strip 1 -C homebrew
  )
fi

exit 0