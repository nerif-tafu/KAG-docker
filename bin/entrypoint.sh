#!/bin/bash

set -e

if [[ ! -f /opt/KAG/autoconfig.cfg ]]; then
	echo "Starting a server: $NAME"
	echo "$DESCRIPTION"
	echo "Gamemode: $GAMEMODE"
	echo "======================================="

	TCPR_ON="0"
	if [[ -n "$RCON_PASSWORD" ]]; then
	  TCPR_ON="1"
	fi

	cp /opt/KAG/autoconfig.cfg.tmpl /opt/KAG/autoconfig.cfg

	# Replace built-in placeholders in autoconfig.cfg
	sed -i "s/GAMEMODE/$GAMEMODE/g" /opt/KAG/autoconfig.cfg
	sed -i "s/NAME/$NAME/g" /opt/KAG/autoconfig.cfg
	sed -i "s/DESCRIPTION/$DESCRIPTION/g" /opt/KAG/autoconfig.cfg
	sed -i "s/MAX_PLAYERS/$MAX_PLAYERS/g" /opt/KAG/autoconfig.cfg
	sed -i "s/MAPCYCLE/$MAPCYCLE/g" /opt/KAG/autoconfig.cfg
	sed -i "s/SV_PASSWORD/$SV_PASSWORD/g" /opt/KAG/autoconfig.cfg
	sed -i "s/RCON_PASSWORD/$RCON_PASSWORD/g" /opt/KAG/autoconfig.cfg
	sed -i "s/PORT/$PORT/g" /opt/KAG/autoconfig.cfg
	sed -i "s/TCPR_ON/$TCPR_ON/g" /opt/KAG/autoconfig.cfg

	# Apply any KAG_<key> env vars to override or add config values
	# e.g. KAG_sv_gravity=10 or KAG_sv_maxping=400
	awk '
		BEGIN {
			for (k in ENVIRON) {
				if (k ~ /^KAG_/) {
					key = substr(k, 5)
					overrides[key] = ENVIRON[k]
				}
			}
		}
		/^[a-zA-Z0-9_]+ = / {
			key = $1
			if (key in overrides) {
				print key " = " overrides[key]
				delete overrides[key]
				next
			}
		}
		{ print }
		END {
			for (key in overrides)
				print key " = " overrides[key]
		}
	' /opt/KAG/autoconfig.cfg > /opt/KAG/autoconfig.cfg.new
	mv /opt/KAG/autoconfig.cfg.new /opt/KAG/autoconfig.cfg
fi

exec "$@"
