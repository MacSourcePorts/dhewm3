# game/app specific values
APP_VERSION="1.5.0"
ICONSDIR="."
ICONSFILENAME="doom3"
PRODUCT_NAME="dhewm3"
EXECUTABLE_NAME="dhewm3"
PKGINFO="APPLDHM3"
COPYRIGHT_TEXT="DOOM 3 Copyright © 2004 id Software, Inc. All rights reserved."

# For parallel make on multicore boxes...
NCPU=`sysctl -n hw.ncpu`

# create makefiles with cmake
rm -rf build-x86_64
mkdir build-x86_64
cd build-x86_64
/usr/local/bin/cmake -G "Unix Makefiles" -DCMAKE_C_FLAGS_RELEASE="-arch x86_64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DOPENAL_LIBRARY=/Users/tomkidd/Documents/GitHub/MSPStore/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/Users/tomkidd/Documents/GitHub/MSPStore/opt/openal-soft/include -DSDL2_INCLUDE_DIRS=/usr/local/opt/sdl2/include/SDL2 -DSDL2_LIBRARIES=/usr/local/opt/sdl2/lib ../neo -Wno-dev

cd ..
rm -rf build-arm64
mkdir build-arm64
cd build-arm64
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DOPENAL_LIBRARY=/Users/tomkidd/Documents/GitHub/MSPStore/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/Users/tomkidd/Documents/GitHub/MSPStore/opt/openal-soft/include ../neo -Wno-dev

# perform builds with make
cd ..
cd build-x86_64
make -j$NCPU

cd ..
cd build-arm64
make -j$NCPU

cd ..

# non-app speficic values
WRAPPER_EXTENSION="app"
WRAPPER_NAME="${PRODUCT_NAME}.${WRAPPER_EXTENSION}"
CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
BUILT_PRODUCTS_DIR="release"
ICONS="${ICONSFILENAME}.icns"
BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"

# create the app bundle

# remove any existing app bundle
rm -rf "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

# make the app bundle directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" || exit 1;
fi
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" || exit 1;
fi
if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" || exit 1;
fi

lipo build-x86_64/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} build-arm64/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -create
lipo build-x86_64/base.dylib build-arm64/base.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base/base.dylib" -create

cp /Users/tomkidd/Documents/GitHub/MSPStore/Cellar/sdl2/2.0.16/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp /Users/tomkidd/Documents/GitHub/MSPStore/Cellar/openal-soft/1.21.1/lib/libopenal.1.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"

cp ${ICONSDIR}/${ICONS} "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;
echo -n ${PKGINFO} > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/PkgInfo" || exit 1;

# use install_name tool to point executable to bundled resources (probably wrong long term way to do it)
#modify x86_64
install_name_tool -change /usr/local/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change /usr/local/opt/openal-soft/lib/libopenal.1.dylib @executable_path/libopenal.1.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
#modify arm64
install_name_tool -change /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change /opt/homebrew/opt/openal-soft/lib/libopenal.1.dylib @executable_path/libopenal.1.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}

# create Info.Plist
PLIST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${EXECUTABLE_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>${ICONSFILENAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${PRODUCT_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>${APP_VERSION}</string>
    <key>CGDisableCoalescedUpdates</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>10.7</string>
    <key>LSMinimumSystemVersionByArchitecture</key>
    <dict>
        <key>x86_64</key>
        <string>10.7</string>
        <key>arm64</key>
        <string>11.0</string>
    </dict>
	<key>NSHumanReadableCopyright</key>
    <string>${COPYRIGHT_TEXT}</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <false/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
</dict>
</plist>
"
echo "${PLIST}" > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

echo "bundle done."

# user-specific values
# specify the actual values in a separate file called build_macos_values.local

# ****************************************************************************************
# identity as specified in Keychain
SIGNING_IDENTITY="Developer ID Application: Your Name (XXXXXXXXX)"

ASC_USERNAME="your@apple.id"

# signing password is app-specific (https://appleid.apple.com/account/manage) and stored in Keychain (as "notarize-app" in this case)
ASC_PASSWORD="@keychain:notarize-app"

# ProviderShortname can be found with
# xcrun altool --list-providers -u your@apple.id -p "@keychain:notarize-app"
ASC_PROVIDER="XXXXXXXXX"
# ****************************************************************************************

source build_macos_values.local

# Pre-notarized zip file (not what is shipped)
PRE_NOTARIZED_ZIP="${PRODUCT_NAME}_prenotarized.zip"

# Post-notarized zip file (shipped)
POST_NOTARIZED_ZIP="${PRODUCT_NAME}_notarized.zip"

# sign the resulting app bundle
echo "signing..."
codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}

if [ "$1" == "notarize" ]; then

    cd ${BUILT_PRODUCTS_DIR}

	# notarize app
	# script taken from https://github.com/rednoah/notarize-app

	# create the zip to send to the notarization service
	echo "zipping..."
	ditto -c -k --sequesterRsrc --keepParent ${WRAPPER_NAME} ${PRE_NOTARIZED_ZIP}

	# create temporary files
	NOTARIZE_APP_LOG=$(mktemp -t notarize-app)
	NOTARIZE_INFO_LOG=$(mktemp -t notarize-info)

	# delete temporary files on exit
	function finish {
		rm "$NOTARIZE_APP_LOG" "$NOTARIZE_INFO_LOG"
	}
	trap finish EXIT

	echo "submitting..."
	# submit app for notarization
	if xcrun altool --notarize-app --primary-bundle-id "$BUNDLE_ID" --asc-provider "$ASC_PROVIDER" --username "$ASC_USERNAME" --password "$ASC_PASSWORD" -f "$PRE_NOTARIZED_ZIP" > "$NOTARIZE_APP_LOG" 2>&1; then
		cat "$NOTARIZE_APP_LOG"
		RequestUUID=$(awk -F ' = ' '/RequestUUID/ {print $2}' "$NOTARIZE_APP_LOG")

		# check status periodically
		while sleep 60 && date; do
			# check notarization status
			if xcrun altool --notarization-info "$RequestUUID" --asc-provider "$ASC_PROVIDER" --username "$ASC_USERNAME" --password "$ASC_PASSWORD" > "$NOTARIZE_INFO_LOG" 2>&1; then
				cat "$NOTARIZE_INFO_LOG"

				# once notarization is complete, run stapler and exit
				if ! grep -q "Status: in progress" "$NOTARIZE_INFO_LOG"; then
					xcrun stapler staple "$WRAPPER_NAME"
					break
				fi
			else
				cat "$NOTARIZE_INFO_LOG" 1>&2
				exit 1
			fi
		done
	else
		cat "$NOTARIZE_APP_LOG" 1>&2
		exit 1
	fi

	echo "notarized"
	echo "zipping notarized..."

	ditto -c -k --sequesterRsrc --keepParent ${WRAPPER_NAME} ${POST_NOTARIZED_ZIP}

	echo "done. ${POST_NOTARIZED_ZIP} contains notarized ${WRAPPER_NAME} build."
fi