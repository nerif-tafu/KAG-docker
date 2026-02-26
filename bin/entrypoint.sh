#!/bin/bash

set -e

# Single /data mount: bootstrap structure if needed, then symlink so one volume = persistent data, zero manual setup
if [[ -d /data ]]; then
	mkdir -p /data/Security /data/Mods
	[[ -f /data/mods.cfg ]] || touch /data/mods.cfg
	# Bootstrap Security defaults if empty (cattle: mount empty data/ and go)
	if [[ ! -f /data/Security/superadmin.cfg ]]; then
		cat > /data/Security/superadmin.cfg << 'SUPER'
name = Super Admin
users =
roles = rcon;
commands = ALL;
features = always_change_team; ban_immunity; freeze_immunity; ignore_immunity; join_full; kick_immunity; map_vote; mark_any_team; mark_player; mute_immunity; name_mouseover; name_mouseover_spectator; pingkick_immunity; skip_votewait; spectator; view_collapses; view_rcon; vote_cancel;
assign = admin; vip; normal; premium;
SUPER
		cat > /data/Security/seclevs.cfg << 'SECLEVS'
levels_active = 1
levels_files = ../Security/superadmin.cfg; ../Security/normal.cfg;
SECLEVS
		cat > /data/Security/normal.cfg << 'NORMAL'
name = Normal
users =
roles =
commands =
features =
assign =
NORMAL
	fi
	rm -rf /opt/KAG/Security /opt/KAG/Mods
	rm -f /opt/KAG/mods.cfg
	ln -sf /data/Security /opt/KAG/Security
	ln -sf /data/Mods /opt/KAG/Mods
	ln -sf /data/mods.cfg /opt/KAG/mods.cfg
	[[ -f /data/autoconfig.cfg ]] && rm -f /opt/KAG/autoconfig.cfg && ln -sf /data/autoconfig.cfg /opt/KAG/autoconfig.cfg
fi

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
		# Update users line (robust for CRLF/whitespace on mounted Security)
		awk -v u="$users_line" 'BEGIN { done=0 } /^[[:space:]]*users[[:space:]]*=/ { print "users = " u; done=1; next } { print } END { if (!done) print "users = " u }' \
			/opt/KAG/Security/superadmin.cfg > /opt/KAG/Security/superadmin.cfg.tmp && \
			mv /opt/KAG/Security/superadmin.cfg.tmp /opt/KAG/Security/superadmin.cfg
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
	# Always ensure seclevs.cfg + normal.cfg load our superadmin (fixes stale PVC from older runs)
	cat > /opt/KAG/Security/seclevs.cfg << 'SECLEVS'
levels_active = 1
levels_files = ../Security/superadmin.cfg; ../Security/normal.cfg;
SECLEVS
	cat > /opt/KAG/Security/normal.cfg << 'NORMAL'
name = Normal
users =
roles =
commands =
features =
assign =
NORMAL
fi

exec "$@"
