# KAG Dedicated Server (Docker)

Run a [King Arthur's Gold](https://kag2d.com/) dedicated server in Docker. Image: `ghcr.io/nerif-tafu/kag-dedicatedserver`.

## Running

**Quick start (no persistent data):**

```bash
docker run --rm -d -p 50301:50301/tcp -p 50301:50301/udp \
  -e NAME="My Server" -e RCON_PASSWORD="your-rcon-password" \
  ghcr.io/nerif-tafu/kag-dedicatedserver:latest
```

**With persistent data (one volume, zero manual setup):**

Mount a single `data/` directory. The container creates `data/Security`, `data/Mods`, and `data/mods.cfg` if missing, and writes default Security config so the game and `SUPERADMIN_USERS` work immediately.

```bash
docker run --rm -d -p 50301:50301/tcp -p 50301:50301/udp \
  -e NAME="My Server" -e RCON_PASSWORD="secret" -e SUPERADMIN_USERS="MyUsername" \
  -v "$(pwd)/data:/data" \
  ghcr.io/nerif-tafu/kag-dedicatedserver:latest
```

Optional: put `autoconfig.cfg` in `data/` to use a full custom config instead of env-generated one.

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
| `SUPERADMIN_USERS` | (empty) | KAG usernames (not display names) as super admins; comma or semicolon separated. Entrypoint updates `superadmin.cfg` in `data/Security` when mounted. |

### Any autoconfig key (KAG_ prefix)

Override any `autoconfig.cfg` key via env: use the `KAG_` prefix plus the config key.

```bash
-e KAG_sv_gravity=12 -e KAG_sv_maxping=400
```

Set `SUPERADMIN_USERS` and the entrypoint updates the superadmin list in `data/Security`. If you put `autoconfig.cfg` in `data/`, the server uses it instead of generating one from env.
