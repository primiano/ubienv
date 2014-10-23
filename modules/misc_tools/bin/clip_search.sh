#!/bin/sh
# Remember to sudo apt-get install xsel first

which xsel >> /dev/null
if [ $? != 0 ]; then
  MSG="Please sudo apt-get install xsel before running $(basename $0)"
  echo "$MSG"
  xmessage "$MSG" &
  exit 1
fi

if [ "$1" == "" ]; then
  TARGET="chromium"
else
  TARGET="$1"
fi

CLIP="\"$(xsel)\""
CLIP_LEN=${#CLIP}
CLIP_QUOTED_AND_ENCODED=""

for (( pos=0 ; pos<CLIP_LEN ; pos++ )); do
  c=${CLIP:$pos:1}
  case "$c" in
    [-_.~a-zA-Z0-9] ) ord="${c}" ;;
    * )  printf -v ord '%%%02x' "'$c"
  esac
  CLIP_QUOTED_AND_ENCODED+="${ord}"
done

if [ "$TARGET" == "chromium" ]; then
URL="https://code.google.com/p/chromium/codesearch#search/sq=package:chromium&type=cs&q=$CLIP_QUOTED_AND_ENCODED"
elif [ "$TARGET" == "chromium-gyp" ]; then
URL="https://code.google.com/p/chromium/codesearch#search/sq=package:chromium&type=cs&q=$CLIP_QUOTED_AND_ENCODED file:gyp.?\$"
else  # Treat the 1st argument as the "package" queryS
URL="http://cs/#search/&type=cs&q=package:%5E$TARGET$%20$CLIP_QUOTED_AND_ENCODED"
fi

gnome-open "$URL"
