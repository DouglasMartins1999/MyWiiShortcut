#!/bin/bash

usage_help="USAGE: ./wadgen.sh [DISCID] [TITLEID] [BANNER_PATH] [LOADER_PATH] [BASE_PATH] [DISCID_OFFSET] [CONFIG_OFFSET] [EXTRA_PARAMS] [OUTPUT_FILE] \\n\\n \
    [DISCID] - Required: Disc ID of game to be loaded with your shortcut (ex: RMCE01 for MK Wii) \\n \
    [TITLEID] - Required: Wii ID of your shortcut, must be different from your Disc ID and unique for each shortcut (ex: UMCE) \\n \
    [DISCID_OFFSET] - Required: Position offset in hexadecimal where your Disc ID must be written on your forwarder (ex: 03EF98 for WiiFlow) \\n \
    [CONFIG_OFFSET] - Required: Position offset in hexadecimal where loader params must be written on your forwarder (ex: 03EF15 for WiiFlow) \\n \
    [BANNER_PATH] - Required: File path to banner with image, sound, animation, etc, to be played on Wii Menu \\n \
    [LOADER_PATH] - Required: File path to loader to be used to load your game \\n \
    [BASE_PATH] - Required: Directory path to unpacked WAD to be used as base to your shortcut (use wadunpack if needed to unpack) \\n \
    [EXTRAPARAMS] - Optional: Params passed to your loader (ex: ios=249) \\n \
    [OUTPUT_FILE] - Optional: File path to generated .WAD file (default: ($PWD/[TITLEID] DISCID.wad))"

wad_out_file="$9"
temp_work_dir="$PWD/tmp/wad"
tools_dir="$PWD/tools"

required_files=("00000000.app" "00000001.app" "00000002.app" "title.cert" "title.tik" "title.tmd" "title.trailer")
missing_files=()

if [ "${#1}" != 6 ]; then
    echo -e "ERROR: DISCID length must be equal to 6 characters"
    echo -e $usage_help
    exit 1
fi

if [ "${#2}" != 4 ]; then
    echo -e "ERROR: TITLEID length must be equal to 4 characters"
    echo -e $usage_help
    exit 1
fi

if ! [[ $6 =~ ^[0-9a-fA-F]{5,}$ ]]; then
    echo -e "ERROR: $6 is not a valid DISCID_OFFSET - must be a hex string with at least 5 characters"
    echo -e $usage_help
    exit 1
fi

if ! [[ $7 =~ ^[0-9a-fA-F]{5,}$ ]]; then
    echo -e "ERROR: $7 is not a valid DISCID_OFFSET - must be a hex string with at least 5 characters"
    echo -e $usage_help
    exit 1
fi

if [ ! -f "$3" ] || [[ $3 != *.bnr ]]; then
    echo -e "ERROR: BANNER_PATH doesn't exists or doesn't have .bnr extension"
    echo -e $usage_help
    exit 1
fi

if [ ! -f "$4" ] || [[ $4 != *.dol ]]; then
    echo -e "ERROR: LOADER_PATH doesn't exists or doesn't have .dol extension"
    echo -e $usage_help
    exit 1
fi

if [ ! -d "$5" ]; then
    if [ ! -f "$5.wad" ]; then
        echo -e "ERROR: BASE_PATH doesn't exist, isn't a directory and/or no .WAD found"
        echo -e $usage_help
        exit 1
    else
        $tools_dir/wadunpacker "$5.wad" &> /dev/null
        mv $PWD/00* $5
        rm "$5.wad"
    fi
fi

for file in "${required_files[@]}"; do
    [ ! -f "$5/$file" ] && missing_files+=("$file")
done

if [ ${#missing_files[@]} -gt 0 ]; then
    echo -e "ERROR: Missing .WAD uncompressed files in BASE_PATH $5: ${missing_files[*]}"
    echo -e $usage_help
    exit 1
fi

if [[ "$wad_out_file" == "" ]]; then
    mkdir $PWD/dest/ &> /dev/null
    wad_out_file="$PWD/dest/$2 [$1].wad"
fi

echo "Clonning needed files"
cp -r $5 $temp_work_dir
cp $4 $temp_work_dir/00000001.app
cp $3 $temp_work_dir/00000000.app

echo "Recording DISC ID in forwarder"
hex="$(printf '%s' "$1" | xxd -p -u)"
printf '%s: %s' $6 $hex | xxd -r - $temp_work_dir/00000001.app

if [[ "$8" != "" ]]; then
    echo "EXTRA_PARAMS founded! Recording into forwarder"
    hex="$(printf '%s' "$8" | xxd -p -u)"
    printf '%s: %s' $7 $hex | xxd -r - $temp_work_dir/00000001.app
fi

echo "Packaging WAD File"
$tools_dir/wadpacker "$temp_work_dir" "$wad_out_file" -i "$2" -sign &> /dev/null

echo "File Saved in $wad_out_file"