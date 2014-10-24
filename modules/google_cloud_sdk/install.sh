#!/bin/bash -e
if [ "${TOOLS_DIR}" == "" ]; then
  echo "TOOLS_DIR env var not set. Bailing out"
  exit 1
fi

if [ ! -d "${TOOLS_DIR}/google-cloud-sdk" ]; then
  echo "Installing google-cloud-sdk"
  (
    cd /tmp
    curl -L "https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz" \
         -o google-cloud-sdk.tar.gz
    tar -zxf google-cloud-sdk.tar.gz
    cp -a google-cloud-sdk "${TOOLS_DIR}/google-cloud-sdk"
    rm -f google-cloud-sdk.tar.gz
    rm -rf google-cloud-sdk
  )
  "${TOOLS_DIR}/google-cloud-sdk/install.sh" \
      --usage-reporting false \
      --path-update false \
      --bash-completion=false \
      --disable-installation-options \
      --rc-path /tmp/ignore
fi
