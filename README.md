# Docker Valheim Dedicated Server

A Docker container project for running a Valheim dedicated server based on Ubuntu 24.04.

## Features

- Based on Ubuntu 24.04 LTS
- Configurable steam user UID
- Persistent game data with bind mounts
- Easy configuration via environment variables
- All necessary ports exposed

## Prerequisites

- Docker Engine 20.10 or later
- Docker Compose 1.29 or later
- At least 4GB of free disk space
- Ports 2456-2458/UDP available

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/xiahualiu/docker-valheim.git
   cd docker-valheim
   ```

2. Configure your server by editing the environment variables in `docker-compose.yml`

3. Start the server:
   ```bash
   docker compose up -d
   ```

4. View server logs:
   ```bash
   docker compose logs -f valheim
   ```

5. Stop the server:
   ```bash
   docker compose down
   ```

## Configuration

### Environment Variables

Configure your Valheim server by setting these environment variables in `docker-compose.yml`:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `SERVER_NAME` | Name of your server (visible in server browser) | `ValheimServer` |
| `SERVER_PORT` | Game port (UDP) | `2456` |
| `WORLD_NAME` | Name of the world/save file | `Dedicated` |
| `SERVER_PASSWORD` | Server password (minimum 5 characters) | `secret` |
| `SERVER_PUBLIC` | Set to 1 to list server publicly, 0 for private | `0` |

**Important Server Configuration Notes:**
- `SERVER_PASSWORD` must be at least 5 characters long or the server will fail to start
- `SERVER_NAME` can contain spaces and special characters, but keep it reasonable for display purposes
- `WORLD_NAME` determines the save file name - changing this will create a new world
- When `SERVER_PUBLIC` is set to 1, your server will appear in the public server list (requires proper port forwarding)
- Valheim uses three consecutive UDP ports starting from `SERVER_PORT` (default: 2456, 2457, 2458)

### Build Arguments

| Argument | Description | Default Value |
|----------|-------------|---------------|
| `STEAM_UID` | User ID for the steam user inside the container | `1000` |

To use a different UID, modify the `docker-compose.yml` file:

```yaml
build:
  args:
    STEAM_UID: 1001
```

**Note on Ubuntu 24.04 Compatibility:** Ubuntu 24.04 includes a default `ubuntu` user with UID 1000. The Dockerfile automatically removes this default user if it conflicts with the `STEAM_UID` you specify. This ensures the steam user can be created with your desired UID without conflicts.

### Ports

The following ports are exposed and should be forwarded:

| Port | Protocol | Description |
|------|----------|-------------|
| 2456 | UDP | Game port |
| 2457 | UDP | Query port |
| 2458 | UDP | Steam port |

## Data Persistence

The server data is stored in the `./valheim-data` directory on your host machine, which is bind-mounted to `/home/steam/.steam/valheim` in the container. This includes:

- World saves
- Configuration files
- Server binaries

**Important:** The first run will download the Valheim dedicated server files (~1GB), which may take several minutes.

## Building the Image

To build the Docker image manually:

```bash
docker build -t valheim-dedicated-server:latest .
```

With custom steam UID:

```bash
docker build --build-arg STEAM_UID=1001 -t valheim-dedicated-server:latest .
```

## Running without Docker Compose

If you prefer to use Docker directly:

```bash
docker run -d \
  --name valheim-server \
  -p 2456:2456/udp \
  -p 2457:2457/udp \
  -p 2458:2458/udp \
  -v $(pwd)/valheim-data:/home/steam/.steam/valheim \
  -e SERVER_NAME="My Valheim Server" \
  -e SERVER_PASSWORD="mypassword" \
  -e WORLD_NAME="MyWorld" \
  -e SERVER_PUBLIC=0 \
  valheim-dedicated-server:latest
```

## Updating the Server

To update the Valheim server to the latest version:

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

## Troubleshooting

### Server not appearing in server list

- Ensure ports 2456-2458/UDP are properly forwarded on your router
- Check firewall settings on your host machine
- Verify `SERVER_PUBLIC=1` if you want the server listed publicly

### Permission issues

- Make sure the `valheim-data` directory has proper permissions
- If needed, adjust the `STEAM_UID` build argument to match your host user ID

### Server crashes or won't start

- Check logs: `docker compose logs valheim`
- Ensure you have enough disk space
- Verify all required ports are available

## License

This project is licensed under the terms specified in the LICENSE file.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- [Valheim](https://www.valheimgame.com/) by Iron Gate Studio
- [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) by Valve Corporation
