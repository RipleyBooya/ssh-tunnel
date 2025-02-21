# Use Alpine Linux
FROM alpine:latest

# Install required packages, including `gettext` for `envsubst`
RUN apk add --no-cache openssh-client autossh bash logrotate gettext

# Define required environment variables
ENV SSH_HOST=""
ENV SSH_USER=""
ENV REMOTE_PORTS=""
ENV LOCAL_PORTS=""

# Create necessary directories
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
RUN mkdir -p /var/log/ssh-tunnel && chmod 777 /var/log/ssh-tunnel

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
COPY logrotate.template /logrotate.template
RUN chmod +x /entrypoint.sh

# Run the entrypoint script
CMD ["/entrypoint.sh"]
