#!/bin/bash

set -e

# Vérification des variables d'environnement requises
if [ -z "$SSH_HOST" ] || [ -z "$SSH_USER" ] || [ -z "$REMOTE_PORTS" ] || [ -z "$LOCAL_PORTS" ]; then
  echo "ERROR: Required variables (SSH_HOST, SSH_USER, REMOTE_PORTS, LOCAL_PORTS) are missing."
  exit 1
fi

# Vérifier que TAILSCALE_PARAM est défini
if [ -z "$TAILSCALE_PARAM" ]; then
  echo "ERROR: TAILSCALE_PARAM is required but not set."
  exit 1
fi

# Démarrage de Tailscale
echo "Starting Tailscale..."
tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &

sleep 5
echo "Connecting to Tailscale with: tailscale up ${TAILSCALE_PARAM}"
tailscale up ${TAILSCALE_PARAM}

# Vérifier que Tailscale est bien actif
if ! tailscale status; then
  echo "ERROR: Tailscale failed to start."
  exit 1
fi

# Copier la clé SSH
if [ -f "/tmp/id_rsa" ]; then
    echo "Copying SSH key..."
    cp /tmp/id_rsa /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
else
    echo "ERROR: SSH key is missing. Please mount your private key to /tmp/id_rsa."
    exit 1
fi

# Nettoyage des logs au démarrage
echo "" > /var/log/ssh-tunnel/tunnel.log

# Générer la configuration logrotate
envsubst < /logrotate.template > /etc/logrotate.d/ssh-tunnel

# Construire la commande de tunnel SSH
TUNNEL_CMD=""
REMOTE_PORT_ARRAY=($REMOTE_PORTS)
LOCAL_PORT_ARRAY=($LOCAL_PORTS)

for i in "${!LOCAL_PORT_ARRAY[@]}"; do
  TUNNEL_CMD="$TUNNEL_CMD -L 0.0.0.0:${LOCAL_PORT_ARRAY[$i]}:${REMOTE_PORT_ARRAY[$i]}"
done

echo "Starting SSH tunnel to $SSH_USER@$SSH_HOST"
echo "Configured tunnels:"
for i in "${!LOCAL_PORT_ARRAY[@]}"; do
  echo "- ${LOCAL_PORT_ARRAY[$i]} -> ${REMOTE_PORT_ARRAY[$i]}"
done

# Démarrer autossh pour maintenir le tunnel actif
exec autossh -M 0 \
  -o "StrictHostKeyChecking=no" \
  -o "UserKnownHostsFile=/dev/null" \
  -o "ServerAliveInterval=60" \
  -o "ServerAliveCountMax=3" \
  -N $TUNNEL_CMD $SSH_USER@$SSH_HOST
