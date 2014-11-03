#!/bin/bash -e
if [ "${TOOLS_DIR}" == "" ]; then
  echo "TOOLS_DIR env var not set. Bailing out"
  exit 1
fi

if [ ! -d "${TOOLS_DIR}/cloud9" ]; then
  echo "Installing cloud9"
  mkdir -p "${TOOLS_DIR}/cloud9"
  git clone --depth=1 "https://github.com/ajaxorg/cloud9.git" "${TOOLS_DIR}/cloud9"
  (
    cd "${TOOLS_DIR}/cloud9"
    npm install
  )
fi

exit 0
