#!/usr/bin/env bash

# Author: Ivan Lopes (lopesivan)
# E-mail: ivanlopes (at) id.uff.br
# Author: Authmane Terki (authmane512)
# E-mail: authmane512 (at) protonmail.ch
# Blog: https://medium.com/@authmane512
# Source: https://github.com/authmane512/android-project-template
# Tutorial: https://medium.com/@authmane512/how-to-do-android-development-faster-without-gradle-9046b8c1cf68
# This project is on public domain
#
# Hello! I've made this little script that allow you to init, compile and run an Android Project.
# I tried to make it as simple as possible to allow you to understand and modify it easily.
# If you think there is a very important missing feature, don't hesitate to do a pull request on Github and I will answer quickly.
# Thanks!

set -e


yaml(){
        local template_file="init.yaml"
        local template_name="$template_file"

        tput bold tput setb 3
        echo -n "-> "
        tput setaf 2
        echo "$template_name"
        tput sgr0
        cat <<-EOF > "$template_file"
name: Your App Name
package: your.pkg.name
sdk:
  dir: ${HOME}/.config/Android/Sdk
  build-tools: 30.0.2
  plataforms: 33
EOF
}
# if exist file `_f' then remove.
_f=init.yaml
test ! -e $_f && { echo $_f not Found >&2; yaml; exit 1; }

APP_NAME="$( shyaml get-value name < init.yaml )"
PACKAGE_NAME=""$( shyaml get-value package < init.yaml )""

SDK_DIR=$( shyaml get-value sdk.dir < init.yaml )
BUILD_TOOLS=$( shyaml get-value sdk.build-tools < init.yaml )
PLATAFORMS=$( shyaml get-value sdk.plataforms < init.yaml )

AAPT="${SDK_DIR}/build-tools/${BUILD_TOOLS}/aapt"
DX="${SDK_DIR}/build-tools/${BUILD_TOOLS}/dx"
ZIPALIGN="${SDK_DIR}/build-tools/${BUILD_TOOLS}/zipalign"
APKSIGNER="${SDK_DIR}/build-tools/${BUILD_TOOLS}/apksigner"
PLATFORM="${SDK_DIR}/platforms/android-${PLATAFORMS}/android.jar"

init() {
	rm README.md
	echo "Making ${PACKAGE_NAME}..."
	mkdir -p "$PACKAGE_DIR"
	mkdir obj
	mkdir bin
	mkdir -p res/layout
	mkdir res/values
	mkdir res/drawable

	sed "s/{{ PACKAGE_NAME }}/${PACKAGE_NAME}/" "template_files/MainActivity.java" > "$PACKAGE_DIR/MainActivity.java"
	sed "s/{{ PACKAGE_NAME }}/${PACKAGE_NAME}/" "template_files/AndroidManifest.xml" > "AndroidManifest.xml"
	sed "s/{{ APP_NAME }}/${APP_NAME}/" "template_files/strings.xml" > "res/values/strings.xml"
	cp "template_files/activity_main.xml" "res/layout/activity_main.xml"
	rm -rf template_files
}

build() {
	echo "Cleaning..."
	rm -rf obj/*
	rm -rf "$PACKAGE_DIR/R.java"

	echo "Generating R.java file..."
	$AAPT package -f -m -J src -M AndroidManifest.xml -S res -I $PLATFORM

	echo "Compiling..."
	ant compile -Dplatform=$PLATFORM

	echo "Translating in Dalvik bytecode..."
	$DX --dex --output=classes.dex obj

	echo "Making APK..."
	$AAPT package -f -m -F bin/app.unaligned.apk -M AndroidManifest.xml -S res -I $PLATFORM
	$AAPT add bin/app.unaligned.apk classes.dex

	echo "Aligning and signing APK..."
	# $APKSIGNER sign --ks debug.keystore --ks-pass "pass:android" --ks-key-alias "ivanlopes.eng.br" bin/app.unaligned.apk
    jarsigner -verbose -storepass android -sigalg MD5withRSA -digestalg SHA1 -keystore debug.keystore bin/app.unaligned.apk ivanlopes.eng.br
	$ZIPALIGN -f 4 bin/app.unaligned.apk bin/app.apk
}


run() {
	echo "Launching..."
	adb install -r bin/app.apk
	adb shell am start -n "${PACKAGE_NAME}/.MainActivity"
}

uninstall() {
	echo "Remove..."
	adb uninstall "${PACKAGE_NAME}"
}

PACKAGE_DIR="src/$(echo ${PACKAGE_NAME} | sed 's/\./\//g')"


case $1 in
	init)
		init
		;;
	build)
		build
		;;
	uninstall)
		uninstall
		;;
	run)
		run
		;;
	yaml)
		yaml
		;;
	build-run)
		build
		run
		;;
	*)
		echo "error: unknown argument"
        echo "usage: $0 [init|build|run|yaml|build-run]"
		;;
esac
