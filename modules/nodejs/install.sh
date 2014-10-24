#!/bin/bash -e
if [ "${TOOLS_DIR}" == "" ]; then
  echo "TOOLS_DIR env var not set. Bailing out"
  exit 1
fi

if [ "${NODE_JS_VER}" == "" ]; then
  echo "NODE_JS_VER env var not set. Bailing out"
  exit 1
fi

if [ ! -d "${TOOLS_DIR}/nvm" ]; then
  echo "Installing nvm and node ${NODE_JS_VER}"
  mkdir -p "${TOOLS_DIR}/nvm"
  git clone "https://github.com/creationix/nvm.git" "${TOOLS_DIR}/nvm"
  (
    cd "${TOOLS_DIR}/nvm"
    git checkout "$(git describe --abbrev=0 --tags)"
    source ./nvm.sh
    nvm install "${NODE_JS_VER}"
  )
fi

exit 0