# KAG Dedicated Server (Docker)

Run a [King Arthur's Gold](https://kag2d.com/) dedicated server in Docker. Image: `ghcr.io/nerif-tafu/kag-dedicatedserver`.

## Running

**Quick start (no volumes):**

```bash
docker run --rm -d -p 50301:50301/tcp -p 50301:50301/udp \
  -e NAME="My Server" -e RCON_PASSWORD="your-rcon-password" \
  ghcr.io/nerif-tafu/kag-dedicatedserver:latest
```

**With Security, Mods, and optional autoconfig** — create the folders/files on your host, then mount them:

```bash
docker run --rm -d -p 50301:50301/tcp -p 50301:50301/udp \
  -e NAME="My Server" -e RCON_PASSWORD="secret" \
  -v "$(pwd)/Security:/opt/KAG/Security" \
  -v "$(pwd)/Mods:/opt/KAG/Mods" \
  -v "$(pwd)/mods.cfg:/opt/KAG/mods.cfg" \
  ghcr.io/nerif-tafu/kag-dedicatedserver:latest
```

Omit any `-v` line you don’t use. Optional: add `-v "$(pwd)/autoconfig.cfg:/opt/KAG/autoconfig.cfg"` if you have a custom autoconfig.

## Configuration

### Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GAMEMODE` | CTF | Gamemode (e.g. CTF, TDM) |
| `NAME` | Default Server | Server name in browser |
| `DESCRIPTION` | (empty) | Server description |
| `MAX_PLAYERS` | 20 | Max players |
| `MAPCYCLE` | (empty) | Map cycle; empty = use Rules default |
| `SV_PASSWORD` | (empty) | Server password |
| `RCON_PASSWORD` | (empty) | RCON password (set for TCPR) |
| `PORT` | 50301 | Server port |
| `SUPERADMIN_USERS` | (empty) | KAG usernames (not display names) as super admins; comma or semicolon separated. Creates or updates `superadmin.cfg` / `seclevs.cfg` if Security isn’t mounted. |

### Any autoconfig key (KAG_ prefix)

Override any `autoconfig.cfg` key via env: use the `KAG_` prefix plus the config key.

```bash
-e KAG_sv_gravity=12 -e KAG_sv_maxping=400
```

## Mounts

| Use | Host path | Container path |
|-----|-----------|----------------|
| Security (admins, bans, seclevs) | `./Security` | `/opt/KAG/Security` |
| Mods | `./Mods` | `/opt/KAG/Mods` |
| Mod list | `./mods.cfg` | `/opt/KAG/mods.cfg` |
| Custom autoconfig | `./autoconfig.cfg` | `/opt/KAG/autoconfig.cfg` |

Copy the repo’s `Security/` folder and add your admins to `superadmin.cfg` (or use `SUPERADMIN_USERS`). If you mount your own `autoconfig.cfg`, the server uses it instead of generating one from env.
