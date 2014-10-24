#!/bin/bash -e
source "${UBIENV_ROOT}/bashrc-utils"
THIS_DIR="${BASH_SOURCE[0]%/*}"
USER_PKG="${HOME}/.config/sublime-text-3/Packages/User"

if [ "$UBIENV_OS" == "Linux" ]; then
  USER_PKG="${HOME}/.config/sublime-text-3/Packages/User"
  if ! dpkg-query -W sublime-text > /dev/null 2>&1; then
    curl -L "http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3065_amd64.deb" \
         -o /tmp/sublime-text.deb
    sudo dpkg -i /tmp/sublime-text.deb
    rm -f /tmp/sublime-text.deb
    mkdir -p /home/primiano/.config/sublime-text-3/Packages/
  fi

elif [ "${UBIENV_OS}" == "Darwin" ]; then
  USER_PKG="${HOME}/Library/Application Support/Sublime Text 3/Packages/User"
  if [ ! -d "/Applications/Sublime Text.app/" ]; then
    ubienv::err "Please install Sublime Text 3 manually and press a key when done"
    read
    if [ ! -d "/Applications/Sublime Text.app/" ]; then
      ubienv::err "Could not find /Applications/Sublime Text.app/"
      exti 1
    fi
  fi
else
  echo "Unsupported OS '${UBIENV_OS}'"
  exit 1
fi

if [ "${USER_PKG}" != "" ]; then
  if [ -d "${USER_PKG}" ]; then
    rm -rf "${USER_PKG}"
  fi
  ubienv::symlink_if_changed "${THIS_DIR}/user_packages" \
                             "${USER_PKG}"
fi

exit 0
