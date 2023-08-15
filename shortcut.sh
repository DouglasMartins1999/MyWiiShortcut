#!/bin/bash

usage_help="./shortcut.sh [GAMEPATH] [LOADER] [BASEWAD] [TITLEID] [EXTRAPARAMS] \\n\\n \
    [GAMEPATH] - Required: Path to game file (ex: /Users/myuser/games/ABCD01.wbfs) \\n \
    [LOADER] - Required: Wii game loader you use (ex: WiiFlow or USBLoaderGX) \\n \
    [BASEWAD] - Optional: Base WAD used to make your shortcut (default: marcan) \\n \
    [TITLEID] - Optional: Wii ID of your shortcut, must be different from your game ID and unique for each shortcut \\n \
    [EXTRAPARAMS] - Optional: Params passed to your loader (ex: ios=249)"

base_wad="$3"
wad_title="$4"

disc_id="$(./tools/wit ID6 $1)"
loaders=("WiiFlow" "USBLoaderGX")

disc_id_offset=""
config_offset=""

if [ ! -f "$1" ]; then
    echo -e "ERROR: Game file doesn't exists"
    echo -e $usage_help
    exit 1
fi

if [[ ! " ${loaders[*]} " == *" $2 "* ]]; then
    echo "ERROR: Loader name must be a valid option"
    echo $usage_help
    exit 1
fi

if [[ "$base_wad" == "" ]]; then
    base_wad="marcan"
    echo "BASEWAD not informed, $base_wad will be used"
fi

if [[ "$wad_title" == "" ]]; then
    wad_title="U${disc_id: 1:3}"
    echo "TITLEID not informed, $wad_title will be used"
fi


if [[ "$2" == "WiiFlow" ]]; then
    disc_id_offset="03EF98"
    config_offset="03EF15"

elif [[ "$2" == "USBLoaderGX" ]]; then
    disc_id_offset="03EA98"
    config_offset="03EA15"

fi

echo "Cleaning up TEMP folder"
rm -rf $PWD/tmp/*

echo "Extract banner from Game File"
$PWD/tools/wit EXTRACT "$1" --dest $PWD/tmp/bnr --files +opening.bnr &> /dev/null

echo "Generating WAD"
$PWD/wadgen.sh "$disc_id" "$wad_title" "$PWD/tmp/bnr/DATA/files/opening.bnr" "$PWD/loaders/$2.dol" "$PWD/base/$base_wad" "$disc_id_offset" "$config_offset" "$5"

echo "Cleaning up TEMP folder"
rm -rf $PWD/tmp/*