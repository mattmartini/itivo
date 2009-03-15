#!/bin/sh

volume_name="iTiVo"
source_dir="/Users/yoav/src/itivo/build/Release"
output_dir="/Users/yoav/Desktop/"

# *** SET VERSION
if [ $1 ]; then
    version=$1
else
    version="test"
fi

# *** SET DMG NAME
dmg_name="iTiVo-${version}.dmg"

# *** CREATE
hdiutil create "$output_dir/$dmg_name" -srcfolder $source_dir -ov -volname "$volume_name"
