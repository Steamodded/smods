#!/bin/bash

# This script downloads Lovely and Steamodded and installs all the files to the right directories,
# then tries to update the launch options for Balatro by editing localconfig.vdf.
# (TODO: This second step currently seems to fail. What gives?)

set -e

for app in "steam" "steamwebhelper"; do
    if pgrep -x "$app" > /dev/null; then
        echo "Error: $app is running. Please close Steam completely before running this script." >&2
        exit 1
    fi
done

steam_roots=(
    ~/.local/share/Steam
    ~/.var/app/com.valvesoftware.Steam/.local/share/Steam
    ~/snap/steam/common/.local/share/Steam
    ~/.steam/steam
)

for dir in "${steam_roots[@]}"; do
    if [ -d "$dir" ]; then steam_root="$dir"; break; fi
done

if [ -z "$steam_root" ]; then
    echo "No Steam installation found in known locations." >&2
    exit 1
fi

balatro_path="$steam_root/steamapps/common/Balatro"
if [ ! -d "$balatro_path" ]; then
    echo "Balatro directory not found at $balatro_path" >&2
    exit 1
fi

balatro_appdata_path="$steam_root/steamapps/compatdata/2379780/pfx/drive_c/users/steamuser/AppData/Roaming/Balatro/"
if [ ! -d "$balatro_appdata_path" ]; then
    echo "Balatro appdata directory not found at $balatro_appdata_path" >&2
    exit 1
fi

localconfig_path=$(compgen -G "$steam_root/userdata/*/config/localconfig.vdf" | head -n 1)

echo "Downloading Lovely..."
lovely_url=$(curl -sL https://api.github.com/repos/ethangreen-dev/lovely-injector/releases/latest | grep -m1 -Eo 'https://[^#]+windows-msvc.zip' )
curl -sL $lovely_url > lovely.zip
unzip -oq lovely.zip
rm lovely.zip

echo "Downloading Steamodded..."
smod_url=$(curl -sL https://api.github.com/repos/Steamodded/smods/releases/latest | grep -Eo 'https://.*zipball/[^"]+')
curl -sL $smod_url > smod.zip
unzip -oq smod.zip
rm smod.zip

# This somewhat hacky Perl script looks for Balatro in localconfig.vdf, removes any
# existing LaunchOptions line, and adds a new one with the correct value.
perl -ne '
    $tabs = $` if /"2379780"$/;
    if (/^$tabs"2379780"$/ .. /^$tabs\}$/) {
        print qq($tabs\t"LaunchOptions"		"WINEDLLOVERRIDES=\"version=n,b\" %command%"\n) if /^$tabs\}$/;
        print unless /"LaunchOptions"/;
    } else { print; }
' $localconfig_path > $localconfig_path.tmp

if [ -n "$(diff $localconfig_path $localconfig_path.tmp)" ]; then
    echo "Updating Balatro Steam launch options"
    mv $localconfig_path.tmp $localconfig_path
else
    rm $localconfig_path.tmp
fi

echo "Installing..."
mv version.dll $balatro_path/version.dll
mkdir -p $balatro_appdata_path/Mods
cp -r Steamodded-* $balatro_appdata_path/Mods/
rm -r Steamodded-*
echo "Done! 🃏"
echo
echo "You may still need to manually update the launch options in Steam:"
echo ""
echo "- Open Steam"
echo "- Right click on Balatro"
echo -e "- Select \x1b[33mProperties...\x1b[0m"
echo -e "- Under \x1b[33mLaunch Options\x1b[0m, enter:"
echo ""
echo -e "  \x1b[33mWINEDLLOVERRIDES=\"version=n,b\" %command%\x1b[0m"
