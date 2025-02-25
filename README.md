# 🛡️ SSH Tunnel - Secure Remote Access via SSH Tunnels
<p align="left">
  <img src="https://raw.githubusercontent.com/RipleyBooya/ssh-tunnel/refs/heads/main/ssh-tunnel.webp" alt="SSH Tunnel Logo" width="200"/>
</p>

## 🚀 **Quick Start**
For a fast setup, run:
```sh
docker run -d -e SSH_HOST=your-server -e SSH_USER=user \
  -v ~/.ssh/id_rsa:/tmp/id_rsa:ro ripleybooya/ssh-tunnel
```

## 📌 Why this image?
This container was created to **securely expose remote services via SSH tunnels**.  
Instead of exposing databases or other services to the public internet, this container allows you to **create secure SSH tunnels** inside a Docker network.  

### 🔥 **Use Cases:**
- Securely connect to **remote databases** (PostgreSQL, MySQL, MariaDB).
- Access **internal services** (Redis, Elasticsearch, APIs) via SSH.
- Securely tunnel any service **without exposing it publicly**.

---

## 🚀 How to Use

### **1️⃣ Run with `docker run`**
```bash
docker run -d --name ssh-tunnel \
  -e SSH_HOST="your-server.com" \
  -e SSH_USER="your-username" \
  -e REMOTE_PORTS="127.0.0.1:5432 127.0.0.1:443" \
  -e LOCAL_PORTS="15432 8443" \
  -v /path/to/id_rsa:/tmp/id_rsa:ro \
  --network=my_docker_network \
  ripleybooya/ssh-tunnel
```

📌 **Explanation:**
- `SSH_HOST`: The remote server where SSH tunnels will be established.
- `SSH_USER`: The SSH user on the remote server.
- `REMOTE_PORTS`: Ports from the remote server (format: `127.0.0.1:PORT`).
- `LOCAL_PORTS`: Ports inside the Docker container (mapped to `REMOTE_PORTS`).
- `LOGROTATE_FREQUENCY`: Logrotate Frequency (default to `daily`).
- `LOGROTATE_ROTATE`: Logrotate rotation to keep (default to `7`).
- `LOGROTATE_COMPRESS`: Logrotate compression (default to `compress`).
- `-v /path/to/id_rsa:/tmp/id_rsa:ro`: **Mounts your SSH key securely** (using `/tmp/id_rsa` for better permissions).


---

### **2️⃣ Using `docker-compose.yml`**
For easier management, use **Docker Compose**:

#### **2️⃣.1️⃣ Using a Custom Network (Recommended)**
```yaml
version: '3.8'

services:
  ssh-tunnel:
    image: ripleybooya/ssh-tunnel
    container_name: ssh-tunnel
    restart: always
    networks:
      - internal
    environment:
      SSH_HOST: "your-server.com"
      SSH_USER: "your-username"
      REMOTE_PORTS: "127.0.0.1:5432 127.0.0.1:443"
      LOCAL_PORTS: "15432 8443"
    volumes:
      - /path/to/id_rsa:/tmp/id_rsa:ro

networks:
  internal:
    driver: bridge
```

#### **2️⃣.2️⃣ Using Host Network Mode (Alternative)**
If you need the ports to be accessible outside Docker, use `network_mode: host` :

```yaml
version: '3.8'

services:
  ssh-tunnel:
    image: ripleybooya/ssh-tunnel
    container_name: ssh-tunnel
    restart: always
    network_mode: host  # Uses the host network instead of a Docker network
    environment:
      SSH_HOST: "your-server.com"
      SSH_USER: "your-username"
      REMOTE_PORTS: "127.0.0.1:5432 127.0.0.1:443"
      LOCAL_PORTS: "15432 8443"
    volumes:
      - /path/to/id_rsa:/tmp/id_rsa:ro
```
📌 Which mode to choose?

 - ✅ Custom network (default) → If services are inside Docker.
 - ✅ Host mode → If you want to expose the tunnel outside Docker.

---


## 🚀 Using with Tailscale
This version integrates Tailscale VPN for secure remote access & exposes the port to your tailnet.

To use the Tailscale version you need to append the `tailscale` tag: `ripleybooya/ssh-tunnel:tailscale`

### **Run with `docker run`**
```bash
docker run -d --name ssh-tunnel-tailscale \
  -e SSH_HOST="your-server.com" \
  -e SSH_USER="your-username" \
  -e REMOTE_PORTS="127.0.0.1:5432 127.0.0.1:443" \
  -e LOCAL_PORTS="15432 8443" \
  -e TAILSCALE_AUTH_KEY="your-tailscale-auth-key" \
  -v /path/to/id_rsa:/tmp/id_rsa:ro \
  -v /path/to/tailscale/persistent/data:/var/lib/tailscale # Persistent Tailscale state, needed after initial key expiration
  -p 15432:15432  # (Optional) Also expose port on local network.
  -p 8443:8443  # (Optional) Also expose port on local network.
  --cap-add=NET_ADMIN \
  --device /dev/net/tun:/dev/net/tun \
  ripleybooya/ssh-tunnel:tailscale
```

📌 **Explanation:**
- `SSH_HOST`: The remote server where SSH tunnels will be established.
- `SSH_USER`: The SSH user on the remote server.
- `REMOTE_PORTS`: Ports from the remote server (format: `127.0.0.1:PORT`).
- `LOCAL_PORTS`: Ports inside the Docker container (mapped to `REMOTE_PORTS`).
- `TAILSCALE_AUTH_KEY`: Initial Tailscale Authentication Key (optionnal)

/!\ Must be empty if you want to use `TAILSCALE_PARAM`.

(You can generate a key here: [Tailscale Keys](https://login.tailscale.com/admin/settings/keys))
- `TAILSCALE_PARAM`: full control over `tailscale up` options. Usefull if you plan to automate deployment with OAuth Client etc.

([tailscale up command parameters](https://tailscale.com/kb/1241/tailscale-up) & [Registering new nodes using OAuth credentials](https://tailscale.com/kb/1215/oauth-clients#registering-new-nodes-using-oauth-credentials)).
- `LOGROTATE_FREQUENCY`: Logrotate Frequency (default to `daily`).
- `LOGROTATE_ROTATE`: Logrotate rotation to keep (default to `7`).
- `LOGROTATE_COMPRESS`: Logrotate compression (default to `compress`).
- `-v /path/to/id_rsa:/tmp/id_rsa:ro`: **Mounts your SSH key securely** (using `/tmp/id_rsa` for better permissions).
- `-v /path/to/tailscale/persistent/data:/var/lib/tailscale`: Required for Persistent Tailscale state. (optionnal)


>  - Exposing ports with `-p PORT:PORT` is not mandatory to access the ports from a docker network or your Tailnet.
>  - Only usefull if you want your ports to be exposed to the local network.
{.is-info}

> Without [Registering new nodes using OAuth credentials](https://tailscale.com/kb/1215/oauth-clients#registering-new-nodes-using-oauth-credentials) or a persistent storage for `/var/lib/tailscale` after the initial key expire, the container will not be able to connect to your Tailnet.
> {.is-warning}



---

### **Using `docker-compose.yml`**

```bash
version: '3.8'
services:
  ssh-tunnel-tailscale:
    image: ripleybooya/ssh-tunnel:tailscale
    container_name: ssh-tunnel-tailscale
    restart: always
    environment:
      SSH_HOST: "your-server.com"
      SSH_USER: "your-username"
      REMOTE_PORTS: "127.0.0.1:5432 127.0.0.1:3306"
      LOCAL_PORTS: "5432 3306"
      TAILSCALE_PARAM: "--reset --auth-key='tskey-client-XXXXXXXXXXXXXXXXX-YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY?ephemeral=true&preauthorized=true' --advertise-tags=tag:dba --hostname=TS-DB-ACCESS"
    volumes:
      - /path/to/id_rsa:/tmp/id_rsa:ro
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
```

📌 **Explanation:**
- `SSH_HOST`: The remote server where SSH tunnels will be established.
- `SSH_USER`: The SSH user on the remote server.
- `REMOTE_PORTS`: Ports from the remote server (format: `127.0.0.1:PORT`).
- `LOCAL_PORTS`: Ports inside the Docker network (mapped to `REMOTE_PORTS`).
- `TAILSCALE_AUTH_KEY`: Initial Tailscale Authentication Key (optionnal)

/!\ Must be empty if you want to use `TAILSCALE_PARAM`.

(You can generate a key here: [Tailscale Keys](https://login.tailscale.com/admin/settings/keys))
- `TAILSCALE_PARAM`: full control over `tailscale up` options. Usefull if you plan to automate deployment with OAuth Client etc.

([tailscale up command parameters](https://tailscale.com/kb/1241/tailscale-up) & [Registering new nodes using OAuth credentials](https://tailscale.com/kb/1215/oauth-clients#registering-new-nodes-using-oauth-credentials)).
- `LOGROTATE_FREQUENCY`: Logrotate Frequency (default to `daily`).
- `LOGROTATE_ROTATE`: Logrotate rotation to keep (default to `7`).
- `LOGROTATE_COMPRESS`: Logrotate compression (default to `compress`).
- `/path/to/id_rsa:/tmp/id_rsa:ro`: **Mounts your SSH key securely** (using `/tmp/id_rsa` for better permissions).
- `ssh_tunnel_tailscale_data:/var/lib/tailscale`: Required for Persistent Tailscale state. (optionnal)

>  - Exposing ports with "`ports:`" is not mandatory to access the ports from a docker network or your Tailnet.
>  - Only usefull if you want your ports to be exposed to the local network.
{.is-info}

> Without [Registering new nodes using OAuth credentials](https://tailscale.com/kb/1215/oauth-clients#registering-new-nodes-using-oauth-credentials) or a persistent storage for `/var/lib/tailscale` after the initial key expire, the container will not be able to connect to your Tailnet.
> {.is-warning}

---

## 🔄 Automated Daily Builds for Security & Performance

This Docker image is rebuilt automatically **every day** to ensure it always includes:

✅ The latest security updates from the Alpine base image.

✅ The most recent versions of system dependencies.

✅ Potential performance improvements from the build process.

⚠ Note: These daily builds do not necessarily mean changes to the project itself.
If you're looking for actual updates to the codebase, please refer to the [commit history](https://github.com/RipleyBooya/ssh-tunnel/commits/main) or the [release tags](https://github.com/RipleyBooya/ssh-tunnel/releases).

---

## 📌 **Why use this image?**
✅ **Secure**: No need to expose services publicly.  
✅ **Simple**: Just set environment variables and run.  
✅ **Multi-Arch**: Works on **x86_64 (Intel/AMD)** and **ARM64 (Oracle Cloud, Raspberry Pi, etc.)**.  
✅ **Lightweight**: Uses **Alpine Linux** for minimal resource usage.  

---

## 📦 Pull & Run
```bash
docker pull ripleybooya/ssh-tunnel
docker run --rm -it ripleybooya/ssh-tunnel sh -c "uname -m && echo 'Container is working'"
```

🚀 **Now your remote services are accessible through secure SSH tunnels!**

---

## 🔖 Tags & Keywords
This image can be used for:
- 🛡️ **SSH Tunneling**
- 🔌 **Networking & Proxy**
- 🔒 **Security & Encryption**
- 🗄️ **Database Access (PostgreSQL, MySQL, MariaDB, etc.)**
- 🏗️ **Remote Service Exposure in Docker**

---

## 📜 Third-Party Licenses
This project is based on:
- [Alpine Linux](https://www.alpinelinux.org/) - MIT License
- [OpenSSH](https://www.openssh.com/) - BSD License
- [Tailscale](https://tailscale.com/) - MIT License
- [Docker](https://www.docker.com/) - Apache 2.0 License

## 📜 License
This project is licensed under the **MIT License**.  
You are free to use, modify, and distribute it.  
Read the full license [here](https://opensource.org/licenses/MIT).

---

## 🤖 AI Assistance & Acknowledgment
 - This project was built with the help of an **AI-powered assistant (LLM)** to improve structure, efficiency, and documentation clarity.
 - A big thank to [Xénophée](https://github.com/Xenophee) for the inspiration that started this project.


## 🏗️ How to Build the Image

If you want to build this image yourself, follow these steps:

### **1️⃣ Clone the Repository**
```bash
git clone https://github.com/RipleyBooya/ssh-tunnel.git
cd ssh-tunnel
```

### **2️⃣ Build for Multi-Architecture (`amd64` & `arm64`)**
```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  -t dockerhub_account/ssh-tunnel:latest \
  --push .
```

### **3️⃣ Verify the Image**
```bash
docker buildx imagetools inspect dockerhub_account/ssh-tunnel:latest
```

### **4️⃣ Test Locally**
```bash
docker run --rm -it dockerhub_account/ssh-tunnel sh -c "uname -m && echo 'Container is running successfully'"
```

Now your image is built and ready for use! 🚀


## 🔗 Project Links & Contributions
This project is open-source and welcomes contributions!  

- 🛠 **Source Code & Issues:** [GitHub Repository](https://github.com/RipleyBooya/ssh-tunnel)  
- 🐳 **Docker Hub Page:** [Docker Image](https://hub.docker.com/r/ripleybooya/ssh-tunnel)  
- 🇫🇷 **Version française (WikiJS):** [ltgs.wiki (FR)](https://ltgs.wiki/fr/InfoTech/Virt/Docker/ssh-tunnel) 
- 🇺🇸 **English version (WikiJS):** [ltgs.wiki (EN)](https://ltgs.wiki/en/InfoTech/Virt/Docker/ssh-tunnel) 

If you find any issues or have suggestions, feel free to open a GitHub issue or contribute! 🚀  
