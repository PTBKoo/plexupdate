#!/bin/bash

# Script to automagically update Plex Media Server on Synology NAS
#
# Must be run as root.
#
# @source @martinorob https://github.com/martinorob/plexupdate
# @author @nitantsoni https://github.com/nitantsoni/

mkdir -p /tmp/plex/
cd /tmp/plex/

url=$(echo "https://plex.tv/api/downloads/5.json")
jq=$(curl -s ${url})

newversion=$(echo $jq | jq -r .nas.Synology.version)
echo "Latest version: $newversion"
curversion=$(synopkg version "Plex Media Server")
echo "Current version: $curversion"
if [ "$newversion" != "$curversion" ]
    then
    echo "Updated Version of Plex is available. Starting download & install."
    /usr/syno/bin/synonotify PKGHasUpgrade '{"[%HOSTNAME%]": $(hostname), "[%OSNAME%]": "Synology", "[%PKG_HAS_UPDATE%]": "Plex", "[%COMPANY_NAME%]": "Synology"}'
    cpu=$(uname -m)
    if [ "$cpu" = "x86_64" ]; 
        then
        url=$(echo $jq | jq -r ".nas.Synology.releases[1] | .url")
    else
        url=$(echo $jq | jq -r ".nas.Synology.releases[0] | .url")
    fi

    /bin/wget $url -P /tmp/plex/
    /usr/syno/bin/synopkg install /tmp/plex/*.spk && /usr/syno/bin/synopkg start "Plex Media Server" && rm -rf /tmp/plex/
else
    echo "No new version available"
fi
exit
