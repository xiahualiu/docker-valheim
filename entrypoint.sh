#!/bin/bash
set -e

echo "Installing/Updating Valheim Server..."
/home/steam/steamcmd/steamcmd.sh \
    +force_install_dir /home/steam/.steam/valheim \
    +login anonymous \
    +app_update 896660 validate \
    +quit

echo "Starting Valheim Server..."
cd /home/steam/.steam/valheim
export SteamAppId=892970
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH

exec ./valheim_server.x86_64 \
    -name "${SERVER_NAME:-ValheimServer}" \
    -port ${SERVER_PORT:-2456} \
    -world "${WORLD_NAME:-Dedicated}" \
    -password "${SERVER_PASSWORD:-secret}" \
    -public ${SERVER_PUBLIC:-0} \
    -savedir /home/steam/valheim-server
