#!/bin/bash
set -e

DEVICE="${1:-fr245}"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
KEY="$PROJECT_DIR/developer_key.der"

# Generate developer key if missing
if [ ! -f "$KEY" ]; then
    echo "Generating developer signing key..."
    openssl genrsa -out "$PROJECT_DIR/developer_key.pem" 4096 2>/dev/null
    openssl pkcs8 -topk8 -inform PEM -outform DER \
        -in "$PROJECT_DIR/developer_key.pem" \
        -out "$KEY" -nocrypt 2>/dev/null
fi

mkdir -p "$BUILD_DIR"

# Create device-specific manifest (avoids newer device ID errors with SDK 3.x)
cat > "$PROJECT_DIR/manifest-build.xml" <<EOF
<?xml version="1.0"?>
<iq:manifest xmlns:iq="http://www.garmin.com/xml/connectiq" version="3">
    <iq:application entry="BasicApp" id="30EC35DBBB1044C2949843AB28388FAF"
        launcherIcon="@Drawables.LauncherIcon" name="@Strings.AppName"
        type="watchface" minSdkVersion="1.2.1">
        <iq:products>
            <iq:product id="$DEVICE"/>
        </iq:products>
        <iq:permissions/>
        <iq:languages>
            <iq:language>eng</iq:language>
        </iq:languages>
        <iq:barrels/>
    </iq:application>
</iq:manifest>
EOF

cat > "$PROJECT_DIR/monkey-build.jungle" <<EOF
project.manifest = manifest-build.xml
EOF

# Use docker if available, fall back to podman
if command -v docker &>/dev/null; then
    CONTAINER_CMD=docker
elif command -v podman &>/dev/null; then
    CONTAINER_CMD=podman
else
    echo "Error: docker or podman is required" >&2
    exit 1
fi

echo "Building for $DEVICE (using $CONTAINER_CMD)..."
$CONTAINER_CMD run --rm \
    -v "$PROJECT_DIR:/app:Z" \
    docker.io/kalemena/connectiq:latest \
    /opt/ciq/bin/monkeyc \
        -d "$DEVICE" \
        -f /app/monkey-build.jungle \
        -o "/app/build/kite-${DEVICE}.prg" \
        -y /app/developer_key.der \
        -r

echo "Done! Output: build/kite-${DEVICE}.prg"
