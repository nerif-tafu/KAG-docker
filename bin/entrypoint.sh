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

# Super admin by name via SUPERADMIN_USERS (comma or semicolon separated usernames)
if [[ -n "$SUPERADMIN_USERS" ]]; then
	mkdir -p /opt/KAG/Security
	# Normalize to "User1; User2; " format (semicolon-delimited, per KAG seclev format)
	users_line=$(echo "$SUPERADMIN_USERS" | tr ',;' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$' | sed 's/$/;/' | tr -d '\n' | sed 's/;$/; /')
	if [[ -f /opt/KAG/Security/superadmin.cfg ]]; then
		escaped=$(echo "$users_line" | sed 's/\\/\\\\/g; s/&/\\&/g')
		sed -i "s|^users = .*|users = $escaped|" /opt/KAG/Security/superadmin.cfg
	else
		cat > /opt/KAG/Security/superadmin.cfg << EOF
name = Super Admin
users = $users_line
roles = rcon;
commands = ALL;
features = always_change_team; ban_immunity; freeze_immunity; ignore_immunity; join_full; kick_immunity; map_vote; mark_any_team; mark_player; mute_immunity; name_mouseover; name_mouseover_spectator; pingkick_immunity; skip_votewait; spectator; view_collapses; view_rcon; vote_cancel;
assign = admin; vip; normal; premium;
EOF
	fi
fi

exec "$@"
