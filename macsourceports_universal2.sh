# game/app specific values
export APP_VERSION="1.5.0"
export ICONSDIR="."
export ICONSFILENAME="doom3"
export PRODUCT_NAME="dhewm3"
export EXECUTABLE_NAME="dhewm3"
export PKGINFO="APPLDHM3"
export COPYRIGHT_TEXT="DOOM 3 Copyright © 2004 id Software, Inc. All rights reserved."

#constants
source ../MSPScripts/constants.sh

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -G "Unix Makefiles" -DCMAKE_C_FLAGS_RELEASE="-arch x86_64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DOPENAL_LIBRARY=/usr/local/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/usr/local/opt/openal-soft/include ../neo -Wno-dev

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DOPENAL_LIBRARY=/opt/homebrew/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/opt/homebrew/opt/openal-soft/include ../neo -Wno-dev

# perform builds with make
cd ..
cd ${X86_64_BUILD_FOLDER}
make -j$NCPU

cd ..
cd ${ARM64_BUILD_FOLDER}
make -j$NCPU

cd ..

# create the app bundle
"../MSPScripts/build_app_bundle.sh"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" || exit 1;
fi

#lipo any app-specific things
lipo ${X86_64_BUILD_FOLDER}/base.dylib ${ARM64_BUILD_FOLDER}/base.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base/base.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/d3xp.dylib ${ARM64_BUILD_FOLDER}/d3xp.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base/d3xp.dylib" -create

#sign and notarize
"../MSPScripts/sign_and_notarize.sh" "$1"