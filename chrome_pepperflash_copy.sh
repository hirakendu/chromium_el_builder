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

# 3. Copy and setup PepperFlash files.
# Courtesy http://www.webupd8.org/2012/09/how-to-make-chromium-use-flash-player.html.
echo -e "\n3. Copying and setting up PepperFlash files.\n"
mkdir -p /opt/chromium/
sudo cp -a google_chrome/opt/google/chrome/PepperFlash /opt/chromium/
PEPPER_FLASH_VERSION="$(grep '"version":' google_chrome/opt/google/chrome/PepperFlash/manifest.json | grep -Po '(?<=version": ")(?:\d|\.)*')"
cat << EOF > chromium_pepperflash.desktop
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=Chromium
GenericName=Web Browser
Exec=/opt/chromium/chrome-wrapper %U --ppapi-flash-path=/opt/chromium/PepperFlash/libpepflashplayer.so --ppapi-flash-version=${PEPPER_FLASH_VERSION}
Terminal=false
Icon=/opt/chromium/product_logo_48.png
Type=Application
Categories=Application;Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;
EOF
sudo mv chromium_pepperflash.desktop /usr/share/applications/chromium-devel.desktop
