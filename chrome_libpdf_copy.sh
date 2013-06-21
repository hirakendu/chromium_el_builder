#!/bin/bash

if [ -z "${CHROMIUM_VERSION}" ]; then
  # Unset by default, get current.
  # CHROMIUM_VERSION=26.0.1410.63
  # CHROMIUM_SVN_REVISION=192696
  true
fi

if [ -z "${CHANNEL}" ]; then
  CHANNEL="stable"
fi

if [ -n "${CHROMIUM_VERSION}" ]; then
  VERSION_RELEASE="-${CHROMIUM_VERSION}-${CHROMIUM_SVN_REVISION}."
else
  VERSION_RELEASE="_current_"
fi

ARCH="$(uname -i)"

RPM_FILE="google-chrome-${CHANNEL}${VERSION_RELEASE}${ARCH}.rpm"

# 1. Download Google Chrome.
echo -e "\n1. Downloading Google Chrome.\n"
if [ -f "${RPM_FILE}" ]; then
  echo -e "\nUsing existing ${RPM_FILE}.\n"
else
  echo -e "\nDownloading ${RPM_FILE}, ~ 55 MB.\n"
  if [ -n "${CHROMIUM_VERSION}" ]; then
    curl "https://dl.google.com/linux/chrome/rpm/stable/${ARCH}/${RPM_FILE}" -o "${RPM_FILE}"
  else
    curl "https://dl.google.com/linux/direct/${RPM_FILE}" -o "${RPM_FILE}"
  fi
fi

echo -e "\nInfo for ${RPM_FILE}:"
echo -e "  Version: $(rpm -qa -f ${RPM_FILE} --qf %{VERSION})"
echo -e "  Release (SVN revision): $(rpm -qa -f ${RPM_FILE} --qf %{RELEASE})"
echo ""

# 2. Extract RPM.
echo -e "\n2. Extracting ${RPM_FILE}.\n"
rm -rf google_chrome && mkdir google_chrome && cd google_chrome
rpm2cpio ../${RPM_FILE} | cpio -id --quiet
cd ..

# 3. Copy libpdf.so.
echo -e "\n3. Copying libpdf.so to /opt/chromium/.\n"
mkdir -p /opt/chromium/
sudo cp google_chrome/opt/google/chrome/libpdf.so /opt/chromium/
