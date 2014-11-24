#!/bin/bash -e
if [ "$UBIENV_OS" != "Linux" ]; then
  exit 0
fi

THIS_DIR="${BASH_SOURCE[0]%/*}"

# Disable the Nautilus prompt when plugging in the phone
gsettings set org.gnome.desktop.media-handling automount-open false

exit 0
