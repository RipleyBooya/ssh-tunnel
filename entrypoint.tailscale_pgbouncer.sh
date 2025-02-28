#!/bin/bash

set -e

# Vérification des variables d'environnement requises
if [ -z "$SSH_HOST" ] || [ -z "$SSH_USER" ] || [ -z "$REMOTE_PORTS" ] || [ -z "$LOCAL_PORTS" ]; then
  echo "ERROR: Required variables (SSH_HOST, SSH_USER, REMOTE_PORTS, LOCAL_PORTS) are missing."
  exit 1
fi

# Vérification des paramètres de Tailscale
if [ -z "$TAILSCALE_PARAM" ] && [ -z "$TAILSCALE_AUTH_KEY" ]; then
  echo "ERROR: Either TAILSCALE_PARAM or TAILSCALE_AUTH_KEY must be set."
  exit 1
fi

# Démarrage de Tailscale en arrière-plan
echo "Starting Tailscale..."
exec tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &

sleep 5

# Construction de la commande Tailscale
TS_CMD="tailscale up"

if [ -n "$TAILSCALE_AUTH_KEY" ]; then
  TS_CMD="$TS_CMD --auth-key=$TAILSCALE_AUTH_KEY"
fi

if [ -n "$TAILSCALE_PARAM" ]; then
  TS_CMD="$TS_CMD $TAILSCALE_PARAM"
fi

echo "Connecting to Tailscale with: $TS_CMD"

# Exécution sécurisée avec `eval` et capture des erreurs
if ! eval "$TS_CMD"; then
  echo "ERROR: Tailscale failed to start."
  exit 1
fi

# Vérification que Tailscale est bien actif
if ! tailscale status; then
  echo "ERROR: Tailscale is not running."
  exit 1
fi

# Vérification et copie de la clé SSH
if [ -f "/tmp/id_rsa" ]; then
    echo "Copying SSH key..."
    cp /tmp/id_rsa /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
else
    echo "ERROR: SSH key is missing."
    exit 1
fi

# Nettoyage des logs au démarrage
echo "" > /var/log/ssh-tunnel/tunnel.log

# Génération de la configuration logrotate
envsubst < /logrotate.template > /etc/logrotate.d/ssh-tunnel

# Construction de la commande SSH Tunnel
TUNNEL_CMD=""
LOCAL_PORT_ARRAY=($LOCAL_PORTS)
REMOTE_PORT_ARRAY=($REMOTE_PORTS)

for i in "${!LOCAL_PORT_ARRAY[@]}"; do
  TUNNEL_CMD="$TUNNEL_CMD -L 127.0.0.1:${LOCAL_PORT_ARRAY[$i]}:127.0.0.1:${REMOTE_PORT_ARRAY[$i]}"
done

echo "Starting SSH tunnel to $SSH_USER@$SSH_HOST"
echo "Configured tunnels:"
for i in "${!LOCAL_PORT_ARRAY[@]}"; do
  echo "- ${LOCAL_PORT_ARRAY[$i]} -> ${REMOTE_PORT_ARRAY[$i]}"
done

exec autossh -M 0 \
  -o "StrictHostKeyChecking=no" \
  -o "UserKnownHostsFile=/dev/null" \
  -o "ServerAliveInterval=60" \
  -o "ServerAliveCountMax=3" \
  -o "Compression=yes" \
  -N $TUNNEL_CMD $SSH_USER@$SSH_HOST &

# Attendre que le tunnel soit établi
sleep 5

# Démarrer PgBouncer après l'établissement du tunnel SSH
echo "Starting PgBouncer..."
exec pgbouncer /etc/pgbouncer/pgbouncer.ini
