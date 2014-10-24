#!/bin/bash -e
if [ "${TOOLS_DIR}" == "" ]; then
  echo "TOOLS_DIR env var not set. Bailing out"
  exit 1
fi

if [ ! -d "${TOOLS_DIR}/depot_tools" ]; then
  mkdir -p "${TOOLS_DIR}/depot_tools"
  git clone "https://chromium.googlesource.com/chromium/tools/depot_tools.git" \
            "${TOOLS_DIR}/depot_tools"
fi

exit 0