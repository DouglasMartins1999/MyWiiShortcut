# MyWiiShortcut
An MacOS & Linux native alternative to WiiGSC

MyWiiShortcut is a set of CLI tools/scripts to create game shortcuts/forwarders for Wii games in *nix systems - loading it with WiiFlow/USB Loader GX. This tool is (heavily) based on WiiGSC - a GUI wii game shortcut creator for Windows - most of assets were extracted from it.

This tool is available for Intel and Apple Silicon Macs running MacOS 11.x or later, and Linux systems using Intel (x64) or ARM64 processors - binaries was build in Ubuntu 16.04 LTS and should works on most of modern distros.

## How it works?
This script is only viable because of four tools: 

 - [WiiGSC](https://www.gamebrew.org/wiki/WiiGSC)
 - [Wiimms' ISO Tools (WIT)](https://wit.wiimm.de)
 - [WadTools by BFGR](https://github.com/libertyernie/wad-tools)
 - [Unix xxd](https://linux.die.net/man/1/xxd)

From **WiiGSC** were extracted WiiFlow/USB Loader GX loaders & base .wad files - with it, this script use **wadunpacker** from BFGR to unpack base, **wit** to extract game banner/icon/animation/sounds and place on unpacked .wad, uses **xxd** to override loader's default configs - to be able to boot some specific game with presets (if informed) - and **wadpacker** from BFGR to repack .wad installer file and sign it.

## How to use

> You will NEED a copy of wii `common-key.bin` to make this tool work. If you want to use, please google for it - I cannot put it here :)

Just extract package related to your system from Releases, place your `common-key.bin` in **keys** folder and run `shortcut.sh` script in a terminal, passing path to your game and your loader - WiiFlow / USBLoaderGX - like this:

    $ cd [path_you_extracted_package]
    $ ./shortcut.sh "/Users/myuser/games/ABCD01.wbfs" "WiiFlow"

A WAD file will be generated in **dest** folder in your current directory, and you can install it with any Wii Wad Installer

**WARNING!! Like on WiiGSC, only install .wads if you have a brick-safe Wii (with BootMii / Priiloader installed) - is know that forwarders for some games could brick your Wii, so is HEAVILY RECOMMENDED to make an backup of your NAND before any install.**

> Be careful to change current directory before run it - otherwise it won't be able to find necessary tools 

### Base WAD
If you want, you can change default wad used to make your shortcut - marcan is used by default 'cause it is smaller than others, but if some forwarder don't work with it, try another - comex, taiko, marcan & wanikoko is available in package

    $ ./shortcut.sh /Users/myuser/games/ABCD01.wbfs WiiFlow comex

### Changing Title ID
Title ID is an 4 digits identifier for your app/shortcut in Wii. It must be unique for everything installed on system, otherwise it'll override previous installed titles. By default, this script will take ID of game used and replace first character with **"U"** (ex: SLSEXJ will be packet into ULSE)

If by some reason it conflicts with another title/shortcut you have in your Wii, you can change it by passing like that

    $ ./shortcut.sh /Users/myuser/games/ABCD01.wbfs WiiFlow marcan ULSE

### Extra Params
WiiFlow can be customized to load a game in specific IOS, if you want it, you could pass

    $ ./shortcut.sh /Users/myuser/games/ABCD01.wbfs WiiFlow "" "" ios=249

Default base and default title ID will be used, and your game ABCD01.wbfs will be loaded with IOS 249


## Advanced usage
In `wadgen.sh` you can customize more things, for example:

 - Use a banner of one game to load any other
 - Use your own custom banners
 - Use an loader of your choice - not tested
 - Maybe, create shortcuts for GC games - also, not tested

Take a time to read usage in script - I hope it would be useful to you :)