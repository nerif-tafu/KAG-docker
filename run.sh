#!/bin/bash

PORT=50301
SERVER_NAME="CTF"
SERVER_DESCRIPTION="Vanilla CTF server"
RCON_PASSWORD="password"

# Required: Security (copy repo Security/ and add admins to superadmin.cfg)
VOLUMES="-v $(pwd)/Security:/opt/KAG/Security"
# Optional: add these if you have Mods/ and mods.cfg
[[ -d Mods ]]          && VOLUMES="$VOLUMES -v $(pwd)/Mods:/opt/KAG/Mods"
[[ -f mods.cfg ]]      && VOLUMES="$VOLUMES -v $(pwd)/mods.cfg:/opt/KAG/mods.cfg"
# Optional: add if you have a custom autoconfig.cfg (copy from bin/autoconfig.cfg and edit)
[[ -f autoconfig.cfg ]] && VOLUMES="$VOLUMES -v $(pwd)/autoconfig.cfg:/opt/KAG/autoconfig.cfg"

docker run --rm -d -p $PORT:50301/tcp -p $PORT:$PORT/udp \
	-e NAME="$SERVER_NAME" -e DESCRIPTION="$SERVER_DESCRIPTION" -e RCON_PASSWORD="$RCON_PASSWORD" -e PORT="$PORT" \
	$VOLUMES \
	--name kag ghcr.io/nerif-tafu/kag-dedicatedserver:latest
