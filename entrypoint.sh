#!/bin/bash
set -e

echo "Installing/Updating Valheim Server..."
if ! /home/steam/steamcmd/steamcmd.sh \
    +force_install_dir /home/steam/.steam/valheim \
    +login anonymous \
    +app_update 896660 validate \
    +quit; then
    echo "ERROR: Failed to install/update Valheim server"
    exit 1
fi

echo "Starting Valheim Server..."
if ! cd /home/steam/.steam/valheim; then
    echo "ERROR: Valheim server directory not found at /home/steam/.steam/valheim"
    exit 1
fi

export SteamAppId=892970
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH

exec ./valheim_server.x86_64 \
    -name "${SERVER_NAME:-ValheimServer}" \
    -port ${SERVER_PORT:-2456} \
    -world "${WORLD_NAME:-Dedicated}" \
    -password "${SERVER_PASSWORD:-secret}" \
    -public ${SERVER_PUBLIC:-0} \
    -savedir /home/steam/valheim-server
