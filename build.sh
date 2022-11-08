#!/bin/bash

echo "download apktool"
apktool_url="https://github.com/iBotPeaches/Apktool/releases/download/v2.6.1/apktool_2.6.1.jar"
wget $apktool_url -q --show-progress -O apktool.jar

echo "download protonmail apk"
release_url="https://api.github.com/repos/ProtonMail/proton-mail-android/releases/latest"
apk_url=$(curl --silent ${release_url} | jq -r '.assets[0].browser_download_url')
wget "${apk_url}" -q --show-progress -O protonmail.apk

echo decode apk
java -jar apktool.jar d protonmail.apk --no-src
rm protonmail.apk

echo cleanup useless libs
rm -r protonmail/lib/{armeabi-v7a,x86*}

echo rebuild normal apk
java -jar apktool.jar b protonmail -o protonmail0.apk --use-aapt2

echo update manifest with new package id
sed -i -e 's/package="ch.protonmail.android/package="ch.protonmail.android1/g' protonmail/AndroidManifest.xml

sed -i -e 's/provider\ android:authorities="ch.protonmail.android/provider\ android:authorities="ch.protonmail.android1/g' protonmail/AndroidManifest.xml

echo build modified apk
java -jar apktool.jar b protonmail -o protonmail1.apk --use-aapt2
