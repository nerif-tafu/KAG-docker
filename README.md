# Installing
First you need to install the docker daemon on your server.
If your server is running debian/ubuntu you can simply do
`sudo apt-get install docker.io -y && sudo systemctl start docker`

Then clone the repository
`git clone https://github.com/Harrison-Miller/kag-dedicatedserver.git`
`cd kag-dedicatedserver`

modify run.sh to have the proper configuration following the instruction below.
Then start your server with `./run.sh`

# Running
Create a script to start the docker container with the correct parameters

docker run --rm -d -p 50301:50301 harrisonmiller/kag-dedicatedserver:latest

You can copy the example script run.sh and the Security folder.
The security folder contains the Official KAG Server Admin Seclev.
You should also add your own name to the superadmin.cfg

# Configuration
Use the environment variables as needed to configure the basics of your server

docker run --rm -d -p 50301:50301 -e NAME="Verra's CTF" \
	-e DESCRIPTION="Vanilla CTF server hosted by Verra" harrisonmiller/kag-dedicatedserver:latest

Additional environment variables and their defaults
```
GAMEMODE="CTF"
NAME="Default Server"
DESCRIPTION=""
MAX_PLAYERS=20
MAPCYCLE=""
SV_PASSWORD=""
RCON_PASSWORD=""
PORT="50301"
```

### Super admin by name (SUPERADMIN_USERS)
Set one or more usernames as super admins via env (KAG **username**, not display name). Comma- or semicolon-separated.

```bash
-e SUPERADMIN_USERS="MyUsername"
-e SUPERADMIN_USERS="Admin1,Admin2,Admin3"
```

If `Security/superadmin.cfg` already exists (e.g. you mounted the Security folder), the entrypoint updates only the `users =` line. If it doesn’t exist, it creates a default `superadmin.cfg` with those users.

### Overriding any autoconfig value
You can set **any** key from `autoconfig.cfg` via environment variables by using the `KAG_` prefix. The rest of the variable name must match the config key exactly.

Examples:
```bash
# Set server gravity
-e KAG_sv_gravity=12

# Set max ping before kick
-e KAG_sv_maxping=400

# Override multiple options
-e KAG_sv_maxplayers=32 -e KAG_sv_maxping=500 -e KAG_g_debug=1
```

These override the values from the template (and the built-in env vars like `NAME`, `GAMEMODE`) if the container is starting with a fresh config.

# Mods, Security & autoconfig (mount your data)

Use **volume mounts** so the container uses your Mods, Security files, and optional custom autoconfig. Create the folders (and files) on your host, then mount them.

| What       | Host path      | Mount in container   |
|-----------|----------------|----------------------|
| **Mods**  | `./Mods`       | `/opt/KAG/Mods`      |
| **Mods list** | `./mods.cfg` | `/opt/KAG/mods.cfg`  |
| **Security**  | `./Security` | `/opt/KAG/Security`  |
| **autoconfig** | `./autoconfig.cfg` | `/opt/KAG/autoconfig.cfg` |

- **Security**: Copy the `Security` folder from this repo and add your admins to `superadmin.cfg`. Mount it so bans and seclevs persist.
- **Mods**: Create a `Mods` folder, put your mods in it, create `mods.cfg` listing them. Mount both so the server loads your mods.
- **autoconfig**: Optional. If you mount your own `autoconfig.cfg`, the server uses it and does not generate one from env vars. Create the file first (e.g. copy from `bin/autoconfig.cfg` and edit).

### docker run (all mounts)

```bash
docker run --rm -d -p 50301:50301/tcp -p 50301:50301/udp \
  -e NAME="My Server" -e RCON_PASSWORD="secret" \
  -v "$(pwd)/Security:/opt/KAG/Security" \
  -v "$(pwd)/Mods:/opt/KAG/Mods" \
  -v "$(pwd)/mods.cfg:/opt/KAG/mods.cfg" \
  -v "$(pwd)/autoconfig.cfg:/opt/KAG/autoconfig.cfg" \
  ghcr.io/nerif-tafu/kag-dedicatedserver:latest
```

Omit any `-v` line you don’t need (e.g. drop the Mods and mods.cfg lines if you don’t use mods; drop autoconfig if you rely on env-only config).

### docker-compose

In `docker-compose.yml` the same mounts are available. Uncomment the lines for Mods and/or autoconfig if you use them; Security is mounted by default.

```yaml
volumes:
  - ./Security:/opt/KAG/Security
  - ./Mods:/opt/KAG/Mods
  - ./mods.cfg:/opt/KAG/mods.cfg
  # - ./autoconfig.cfg:/opt/KAG/autoconfig.cfg
```
