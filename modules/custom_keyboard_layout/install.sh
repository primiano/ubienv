#!/bin/sh -e
if [ "${UBIENV_OS}" != "Linux" ]; then
  echo "Unsupported OS '${UBIENV_OS}'"
  exit 1
fi

THIS_FILE="$(realpath ""${BASH_SOURCE:-$0}"")"
THIS_DIR="$(realpath ""$(dirname """"${THIS_FILE}"""")"")"
SRC="${THIS_DIR}/xkb-it"
TGT="/usr/share/X11/xkb/symbols/it"
if [ "$(md5sum < ""${SRC}"")" != "$(md5sum < ""${TGT}"")" ]; then
  echo "Installing ${SRC} into ${TGT}"
  sudo dpkg-divert "${TGT}"
  sudo cp "${SRC}" "${TGT}"
fi

exit 0