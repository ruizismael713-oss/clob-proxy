#!/bin/bash
set -e
echo "Starting TOR..."
tor -f /etc/tor/torrc &
sleep 5
echo "TOR started. Launching proxy..."
export HTTPS_PROXY=socks5://127.0.0.1:9050
exec gunicorn server:app --bind 0.0.0.0:${PORT:-8080}
