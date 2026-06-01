#!/bin/bash

# Function to kill process on a port
kill_port() {
    local port=$1
    local pid=$(lsof -t -i:"$port")
    if [ -n "$pid" ]; then
        echo "Killing process on port $port (PID: $pid)..."
        kill -9 "$pid"
    fi
}

# 1. Terminate existing processes on port 8000 and 4040 (ngrok API)
kill_port 8000
kill_port 4040

# 2. Start Python HTTP server in background
echo "Starting Python HTTP server on port 8000..."
python3 -m http.server 8000 > /dev/null 2>&1 &

# 3. Start ngrok in background
echo "Starting ngrok tunnel..."
ngrok http 8000 --log=stdout > /dev/null 2>&1 &

# 4. Wait for initialization
echo "Waiting for ngrok to initialize..."
sleep 5

# 5. Fetch and display the public tunnel URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o 'https://[^"]*\.ngrok-free\.app' | head -n 1)

if [ -n "$NGROK_URL" ]; then
    echo "Public URL: $NGROK_URL"
else
    echo "Failed to retrieve ngrok URL. Is ngrok installed and authenticated?"
    exit 1
fi
