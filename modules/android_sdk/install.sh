#!/bin/sh -e
if [ "${TOOLS_DIR}" == "" ]; then
  echo "TOOLS_DIR env var not set. Bailing out"
  exit 1
fi

if [ "${UBIENV_OS}" == "Darwin" ]; then
  VER="adt-bundle-mac-x86_64-20140702"
elif [ "$UBIENV_OS" == "Linux" ]; then
  VER="adt-bundle-linux-x86_64-20140702"
else
  echo "Unsupported OS '${UBIENV_OS}'"
  exit 1
fi

if [ ! -d "${TOOLS_DIR}/android-sdk" ]; then
  echo "Installing android-sdk"
  (
    cd /tmp
    curl -L "https://dl.google.com/android/adt/${VER}.zip" \
         -o "adt-bundle.zip"
    unzip -oq adt-bundle.zip -x '*/eclipse/*'
    rm -f adt-bundle.zip
    cp -a "${VER}/sdk" "${TOOLS_DIR}/android-sdk/"
    rm -rf ${VER}
  )
fi

exit 0