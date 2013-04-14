#!/bin/bash

if [ -z "${CHROMIUM_VERSION}" ]; then
  CHROMIUM_VERSION="26.0.1410.63"
  CHROMIUM_SVN_REVISION="0"
fi

# Install rpm-build if not already installed.
if [ -n "$(rpm -q rpm-build | grep 'not installed')" ]; then
  echo -e "\n\nRPM-build not installed. Installing it.\n\n"
  sudo yum groupinstall development-tools
fi

# Create and setup the ~/rpmbuild directory.
# rpmdev-setuptree
mkdir -p ./rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Generate the RPM spec file.
echo -e "\nGenerating spec file ./rpmbuild/SPECS/chromium-${CHROMIUM_VERSION}.spec.\n"
cat << EOF > ./rpmbuild/SPECS/chromium-${CHROMIUM_VERSION}.spec
Name: chromium
Version: ${CHROMIUM_VERSION}
Release: ${CHROMIUM_SVN_REVISION}
Summary: Chromium open source web browser
License: BSD
Url: http://code.google.com/p/chromium/
Source: %{name}-%{version}.tgz

%description
Chromium is an open-source browser project that aims to build a safer, faster, and more stable way for all Internet users to experience the web. Upstream to Google Chrome.

%prep

%setup

%build

%install
mkdir %{buildroot}
cp -a * %{buildroot}/

%files
/opt/chromium
/usr/share/applications/chromium-devel.desktop
EOF

# Copy binary archive to ~/rpmbuild/SOURCES/.
echo -e "\nCopying chromium binary archive chromium-${CHROMIUM_VERSION}.tgz"
echo -e "to ./rpmbuild/SOURCES/.\n"
if [ -e "chromium-${CHROMIUM_VERSION}.tgz" ]; then
  cp "chromium-${CHROMIUM_VERSION}.tgz" ./rpmbuild/SOURCES/
else
  echo -e "Binary archive doesn't exist. Exiting.\n"
  exit
fi

# Build RPM.
echo -e "\nBuilding RPM ./rpmbuild/RPMS/x86_64/chromium-${CHROMIUM_VERSION}-${CHROMIUM_SVN_REVISION}.x86_64.rpm.\n"
rpmbuild --quiet --define '_topdir %(pwd)/rpmbuild' -bb ./rpmbuild/SPECS/chromium-${CHROMIUM_VERSION}.spec

# Copy generated RPM to this folder.
echo -e "\nGenerated RPM chromium-${CHROMIUM_VERSION}-${CHROMIUM_SVN_REVISION}.x86_64.rpm.\n"
cp rpmbuild/RPMS/x86_64/chromium-${CHROMIUM_VERSION}-${CHROMIUM_SVN_REVISION}.x86_64.rpm .

