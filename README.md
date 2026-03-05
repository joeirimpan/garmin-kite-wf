# Kite Watch Face

An animated Zerodha Kite watchface for Garmin's wearable lineup.

![](artwork/screen-f5s.png)

## Features

- Animates whenever you look at your watch.
- Includes Date, Battery Low indicator.
- When Bluetooth drops, the trail turns grey.

## Build from Source

Requires [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io/).

```bash
# Build for a specific device (default: fr245)
./build.sh fr245

# Other devices
./build.sh fr245m
./build.sh fenix5
```

Output: `build/kite-<device>.prg`

## Simulate

Run the watch face in the Connect IQ simulator (requires an X11 display):

```bash
# Start the simulator
docker run --rm -d \
  --name ciq-sim \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$(pwd)":/app \
  kalemena/connectiq:latest \
  /opt/ciq/bin/simulator

# Build and load the watch face
docker exec ciq-sim /opt/ciq/bin/monkeyc -d fr245 \
  -f /app/monkey-build.jungle \
  -o /app/build/kite-fr245.prg \
  -y /app/developer_key.der -r

docker exec ciq-sim /opt/ciq/bin/monkeydo /app/build/kite-fr245.prg fr245

# Stop the simulator
docker stop ciq-sim
```

> Replace `docker` with `podman` if needed.

## Install

1. Connect your Garmin watch via USB.
2. Mount it as a USB drive.
3. Copy the `.prg` file:
   ```bash
   cp build/kite-fr245.prg /path/to/GARMIN/GARMIN/Apps/
   ```
4. Safely eject the watch.
5. On the watch, go to **Settings → Watch Face** and select **Kite**.
