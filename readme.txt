This project provides shell scripts for building an RPM package
of Chromium web-browser on Enterprise Linux distributions like CentOS.
Currently, it can be used for building Chromium 26 or 27 on
CentOS 6.4 and the resulting RPM should be installed on any EL 6.

Please read the details section before using the build script to learn about
the heavy system requirements and to customize the version, features and keys.
To create an RPM package of Chromium, simply run the build script,
  $ bash chromium_builder.sh
.

Install the generated RPM using rpm or yum,
  $ sudo yum install chromium-26.0.1410.63-192696.el6.x86_64.rpm
. The application is installed to /opt/chromium/ and the desktop file is
at /usr/share/applications/chromium-devel.desktop. An application menu entry
for Chromium browser should be generated in the Internet category.

The package installs the Chromium open source web browser and does not include
the addtional proprietary parts of Google Chrome. It can use the system plugins
for Flash and Java. To install the PDF plugin of Google Chrome, the libpdf.so
file can be copied from an existing Chrome installation or by using the
included helper script that downloads an RPM of Google Chrome, and extracts
and copies the libpdf.so,
  $ bash chrome_libpdf_copy.sh
. Another helper script is provided to install PepperFlash,
  $ bash chrome_pepperflash_copy.sh
.

Details:
========

The script chromium_builder.sh is mostly self-explanatory with inline comments,
additional details are provided here for completeness.
It installs pre-requisite packages, downloads chromium source code
and builds it according to instructions in
  https://code.google.com/p/chromium/wiki/LinuxBuildInstructions
. It also creates an installable RPM package after the build.

If no version information is provided, the internally hard-coded default
version (currently 26.0.1410.63) is used. To build a specific version, use e.g.,
  $ CHROMIUM_VERSION=27.0.1453.15 bash chromium_builder.sh
. The various current versions can be found at
  http://omahaproxy.appspot.com/
. Preferably use the current_version for stable channel and linux os.

The build requires Google API keys to be specified, as outlined in
  https://code.google.com/p/chromium/wiki/LinuxBuildInstructions
  https://sites.google.com/a/chromium.org/dev/developers/how-tos/api-keys.
After getting the keys, specify them by either editing the variables
  GOOGLE_API_KEY
  GOOGLE_DEFAULT_CLIENT_ID
  GOOGLE_DEFAULT_CLIENT_SECRET
in the script or provide them as environment variables.

The installation of pre-requisites requires password for sudo,
and is asked once at the early stages. Apart from the pre-requisites 
for Fedora setup at
  https://code.google.com/p/chromium/wiki/LinuxBuildInstructionsPrerequisites
other dependencies
  subversion git git-svn libgnome-keyring-devel cups-devel libXtst-devel libXt-devel pam-devel
for EL are installed. The dependency on speech-dispatcher application
and libraries is satsified by installing RPMs in speech_dispatcher/ folder,
blatantly obtained from
  http://li.nux.ro/download/nux/dextop/el6/x86_64/
.

The source code is downloaded from SVN for the specified version, as outlined in
  http://dev.chromium.org/developers/how-tos/get-the-code
. This is a fairly large download of ~ 1.2 GB over the internet and ~ 5.4 GB of
disk space. It takes about 20 minutes on a fast 100 Mbps, low latency (3ms)
connection. The source code is kept at folder chromium_build and archived
to chromium_build.tgz, ~ 1.5 GB, for future reuse.

The configuration is mostly default with provided API keys and proprietary
codecs enabled. A few additional patches specific to EL 6 are applied
and are in the patches/ folder.
These include a patch to compile with gcc-4.4 from
  http://code.google.com/p/v8/issues/detail?id=2093
, a patch to include GTK compatibility header, and a patch to add extern "C"
qualifiers for udev library headers. A patch to disable the startup message
about older GTK is disabled for chromium versions >= 27.
Lastly, a patch is applied to increase the space above tab bar by 4 pixels,
to aid in moving the window by dragging the window. This may be commented
out in the build script for default behaviour.

The build process is fairly intensive and takes about 80 minutes on
a system with quad core CPU, as observed on a notebook with
Intel Core i7 2630QM CPU, 20 GB of RAM, Samsung 830 SSD (read speed
of ~200 MB/s) mounted on ext4 with trim enabled, and CentOS 6.4 system.
The build is performed in folder chromium_build and expands to ~ 7.4 GB.
After the build, the binaries produced in folder chromium_build/src/out/Release
(~2.0 GB) are copied to the folder chromium-${CHROMIUM_VERSION}/opt/chromium
with the object and deps deleted to result in a size of ~ 250 MB.
Together with the XDG desktop file, a tar archive
chromium-${CHROMIUM_VERSION}.tgz, ~80 MB, is generated.

The default configuration results in a fat, statically linked binary
chromium_build/src/out/Release/chromium, ~ 120 MB, and may take time
to load. The upside is few installation dependencies(?).

While the tar archive can be extracted to the system, an RPM package
is created from the archive using the script chromium_rpm_packager.sh.
Temporary files are kept in the folder rpmbuild/.
The RPM package has name=chromium, version=${CHROMIUM_VERSION},
e.g., 26.0.1410.63, and release version that equals the SVN revision
(as can be found using the revision lookup tool at
http://omahaproxy.appspot.com/). This is similar to the convention
used for the official Google Chrome RPM packages at
  https://www.google.com/intl/en/chrome/browser/
. The current RPM generated is chromium-26.0.1410.63-192696.x86_64.rpm.

The generated RPM can be installed using yum. Proprietary addons can be
installed separately using helper scripts or otherwise, as mentioned
in the introduction. The scripts can use the environment variables
CHANNEL (stable|beta|dev) or CHROMIUM_VERSION (if currently
present in repository) as parameters.

The final disk space used is ~ 7.5 GB.

Misc:
=====
Credits: various inline references
Copyright: Hirakendu Das, 2013
License: BSD 3-clause
