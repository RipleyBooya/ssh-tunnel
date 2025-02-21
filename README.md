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
```sh
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
- `LOCAL_PORTS`: Ports inside the Docker network (mapped to `REMOTE_PORTS`).
- `-v /path/to/id_rsa:/tmp/id_rsa:ro`: **Mounts your SSH key securely** (using `/tmp/id_rsa` for better permissions).

---

### **2️⃣ Using `docker-compose.yml`**
For easier management, use **Docker Compose**:
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

---

## 📌 **Why use this image?**
✅ **Secure**: No need to expose services publicly.  
✅ **Simple**: Just set environment variables and run.  
✅ **Multi-Arch**: Works on **x86_64 (Intel/AMD)** and **ARM64 (Oracle Cloud, Raspberry Pi, etc.)**.  
✅ **Lightweight**: Uses **Alpine Linux** for minimal resource usage.  

---

## 📦 Pull & Run
```sh
docker pull ripleybooya/ssh-tunnel
docker run --rm -it ripleybooya/ssh-tunnel uname -m
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
- [Docker](https://www.docker.com/) - Apache 2.0 License

## 📜 License
This project is licensed under the **MIT License**.  
You are free to use, modify, and distribute it.  
Read the full license [here](https://opensource.org/licenses/MIT).  

📌 **Find the source code & contribute on [GitHub](https://github.com/RipleyBooya/ssh-tunnel)!**  


---

## 🤖 AI Assistance & Acknowledgment
This project was built with the help of an **AI-powered assistant (LLM)** to improve structure, efficiency, and documentation clarity.

## 🔗 Project Links & Contributions
This project is open-source and welcomes contributions!  

- 🛠 **Source Code & Issues:** [GitHub Repository](https://github.com/RipleyBooya/ssh-tunnel)  
- 🐳 **Docker Hub Page:** [Docker Image](https://hub.docker.com/r/ripleybooya/ssh-tunnel)  

If you find any issues or have suggestions, feel free to open a GitHub issue or contribute! 🚀  
