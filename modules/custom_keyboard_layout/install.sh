
#!/bin/bash -e
THIS_DIR="${BASH_SOURCE[0]%/*}"

if [ "${UBIENV_OS}" == "Linux" ]; then
  SRC="${THIS_DIR}/xkb-it"
  TGT="/usr/share/X11/xkb/symbols/it"
  if [ "$(md5sum < ""${SRC}"")" != "$(md5sum < ""${TGT}"")" ]; then
    echo "Installing ${SRC} into ${TGT}"
    sudo dpkg-divert "${TGT}"
    sudo cp "${SRC}" "${TGT}"
    sudo rm -f /var/lib/xkb/*.xkm > /dev/null 2>&1 || true
  fi
elif [ "${UBIENV_OS}" == "Darwin" ]; then
  if ! plutil -p  ~/Library/Preferences/com.apple.HIToolbox.plist \
     | grep italian-dev  > /dev/null 2>&1; then
    cp -a "${THIS_DIR}/Italian-dev.bundle" \
          "${HOME}/Library/Keyboard Layouts/"
#    sudo cp -a "${THIS_DIR}/Italian-dev.bundle" \
#                "/System/Library/Keyboard Layouts/"
  fi
else
  echo "Unsupported OS '${UBIENV_OS}'"
  exit 1
fi

exit 0