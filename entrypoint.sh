#!/bin/bash

set -e

# Check if required environment variables are set
if [ -z "$SSH_HOST" ] || [ -z "$SSH_USER" ] || [ -z "$REMOTE_PORTS" ] || [ -z "$LOCAL_PORTS" ]; then
  echo "ERROR: Required variables (SSH_HOST, SSH_USER, REMOTE_PORTS, LOCAL_PORTS) are missing."
  exit 1
fi

# Check if the SSH key exists in /tmp/ and copy it to /root/.ssh/
if [ -f "/tmp/id_rsa" ]; then
    echo "Copying SSH key to /root/.ssh/id_rsa..."
    cp /tmp/id_rsa /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
else
    echo "ERROR: SSH key is missing. Please mount your private key to /tmp/id_rsa."
    exit 1
fi

# Clear logs on container startup
echo "" > /var/log/ssh-tunnel/tunnel.log

# Generate logrotate config using environment variables
envsubst < /logrotate.template > /etc/logrotate.d/ssh-tunnel

# Build the SSH tunnel command
TUNNEL_CMD=""
LOCAL_PORT_ARRAY=($LOCAL_PORTS)
REMOTE_PORT_ARRAY=($REMOTE_PORTS)

for i in "${!LOCAL_PORT_ARRAY[@]}"; do
  TUNNEL_CMD="$TUNNEL_CMD -L ${LOCAL_PORT_ARRAY[$i]}:${REMOTE_PORT_ARRAY[$i]}"
done

echo "Starting SSH tunnel to $SSH_USER@$SSH_HOST" | tee -a /var/log/ssh-tunnel/tunnel.log
echo "Configured tunnels:" | tee -a /var/log/ssh-tunnel/tunnel.log
for i in "${!LOCAL_PORT_ARRAY[@]}"; do
  echo "- ${LOCAL_PORT_ARRAY[$i]} -> ${REMOTE_PORT_ARRAY[$i]}" | tee -a /var/log/ssh-tunnel/tunnel.log
done

# Start autossh to maintain the tunnel (disables host key checking)
exec autossh -M 0 \
  -o "StrictHostKeyChecking=no" \
  -o "UserKnownHostsFile=/dev/null" \
  -o "ServerAliveInterval=60" \
  -o "ServerAliveCountMax=3" \
  -o "Compression=yes" \
  -N $TUNNEL_CMD $SSH_USER@$SSH_HOST 2>&1 | tee -a /var/log/ssh-tunnel/tunnel.log
