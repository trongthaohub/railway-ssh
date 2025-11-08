#!/bin/bash

echo "=== Starting SSH service ==="
service ssh start

# Check Ngrok token
if [ -z "$NGROK_AUTH_TOKEN" ]; then
    echo "Error: Set your Ngrok token:"
    echo "export NGROK_AUTH_TOKEN=<your_token_here>"
    exit 1
fi

# Login to Ngrok
ngrok config add-authtoken $NGROK_AUTH_TOKEN

# Start SSH tunnel
echo "=== Starting SSH tunnel via Ngrok ==="
ngrok tcp 22 --region ap > /tmp/ngrok.log 2>&1 &
sleep 5

# Detect aaPanel port dynamically
AAPANEL_PORT=$(cat /www/server/panel/data/port.pl 2>/dev/null || echo 8888)
echo "Detected aaPanel port: $AAPANEL_PORT"

# Start HTTP tunnel for aaPanel
echo "=== Starting HTTP tunnel for aaPanel ==="
ngrok http $AAPANEL_PORT --region ap > /tmp/ngrok-web.log 2>&1 &
sleep 5

# Display tunnel info
echo "=== SSH Tunnel Info ==="
curl -s localhost:4040/api/tunnels | grep -Eo "tcp://[0-9a-zA-Z.-]+:[0-9]+"

echo "=== aaPanel / Web Tunnel Info ==="
curl -s localhost:4040/api/tunnels | grep -Eo "https://[0-9a-zA-Z.-]+:[0-9]+"

# Keep container alive
python3 -m http.server 8080 >/dev/null 2>&1 &
echo "Container keep-alive running on port 8080."
