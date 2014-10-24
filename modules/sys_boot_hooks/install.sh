#!/bin/sh -e
if [ "$UBIENV_OS" != "Linux" ]; then
  exit 0
fi

THIS_DIR="${BASH_SOURCE[0]%/*}"
SRC="${THIS_DIR}/rc.local"
TGT="/etc/rc.local"
if [ "$(md5sum < ""${SRC}"")" != "$(md5sum < ""${TGT}"")" ]; then
  echo "Installing ${SRC} into ${TGT}"
  sudo dpkg-divert "${TGT}"
  sudo cp "${SRC}" "${TGT}"
  sudo chmod 755 "${TGT}"
fi
exit 0