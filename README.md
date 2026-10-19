*This project has been created as part of the 42 curriculum by manuelfe.*

# Inception

I designed and implemented a secure, multi-container web infrastructure using **Docker Compose**. The primary objective of this project was to locally deploy an NGINX server with exclusive TLS support, a WordPress instance driven by PHP-FPM, and a MariaDB database—all strictly isolated within dedicated networks and protected volumes according to 42 school requirements.

---

## 📌 Project Overview

For me, Inception represents the cornerstone project of the System Administration (SysAdmin) branch at 42. Its main goal is to teach how to design, configure, and orchestrate a professional, modular, and completely isolated microservices architecture using Docker.

A strict requirement of this project was **never to use pre-built images from Docker Hub** (such as official WordPress or MariaDB images). Instead, I built every container from scratch using custom `Dockerfiles` based on Debian, installing and configuring all services natively through custom Bash scripts. The entire stack is orchestrated by a single `docker-compose.yml` file running inside a dedicated Virtual Machine.

My infrastructure consists of three independent containers interconnected via a private bridge network:

* **NGINX (The Secure Entry Point):** The only container exposing ports to the outside world (port 443). It acts as a reverse proxy and exclusively accepts secure encrypted connections via TLS v1.2 or TLS v1.3. Plain HTTP traffic (port 80) is strictly prohibited.
* **WordPress + PHP-FPM (The Application Engine):** Hosts the website source code and CMS assets. Since NGINX does not natively interpret PHP code, I route all dynamic requests to this container via FastCGI on internal port 9000.
* **MariaDB (The Relational Database):** Persistently stores all users, posts, comments, and site configurations. It remains entirely isolated within the internal Docker network (port 3306) and is never accessible from outside the virtual machine.

---

## 🧠 Key Concepts Learned & Implemented

While engineering this stack, I explored foundational concepts that distinguish production-grade deployments from basic development environments:

### 1. Virtual Machines vs. Docker

Both technologies provide isolation, reproducibility, and resource management, but I applied Docker appreciating its core differences from full-system virtualization:

| Feature | Virtual Machine (VM) | Docker Container |
|---|---|---|
| **Architecture** | Runs a complete guest operating system with its own kernel, device drivers, and system services. | Shares the host kernel, packaging only binaries, runtime dependencies, and application code. |
| **Startup & Speed** | Takes minutes to boot as it emulates physical hardware and boots an entire OS. | Boots in seconds with negligible overhead and minimal memory consumption. |
| **Disk Footprint** | Requires heavy virtual disk images (typically 10 GB to 20 GB). | Uses lightweight, optimized layers (usually 50 MB to 250 MB). |

### 2. Docker Secrets vs. Environment Variables

I prioritized credentials security based on how sensitive data is exposed at runtime:

* **Environment Variables (`.env`):** Well-suited for non-sensitive configurations (database names, site URLs, usernames), but unsafe for credentials. Any inspect command (`docker inspect`) or inspection inside the container (`env`) reveals passwords in plain text, leaving traces across container metadata.
* **Docker Secrets:** Specifically built to protect critical information. Docker mounts secrets into a temporary, in-memory filesystem (`tmpfs`) at `/run/secrets/`. Passwords never touch container storage, do not persist to disk, and are never logged to container metadata.

### 3. Docker Bridge Network vs. Host Network

* **Docker Network (`bridge`):** The architecture of choice for this project. Docker instantiates a software bridge, assigning a private subnet and internal IPs to containers. This guarantees full port isolation, explicit forwarding, and internal DNS resolution by service name.
* **Host Network:** Drops container network isolation completely, binding container services directly to the host's physical network interfaces. This removes the segmentation mandated by the project guidelines.

### 4. Docker Volumes vs. Bind Mounts

* **Bind Mounts:** Explicitly attach a precise directory on the host (`/home/manuelfe/data/...`) directly into the container. I used bind mounts to satisfy the project's strict requirement for persistent data storage on host directories.
* **Docker Volumes:** Managed exclusively by the Docker daemon within `/var/lib/docker/volumes/`, offering seamless portability when direct access to physical host paths is not required.

---

## 🚀 Setup & Deployment Guide

Follow these steps sequentially inside your VM to clone, build, and deploy the entire environment:

### 1. Clone the repository
Connect to your VM via SSH, navigate to your home directory, and clone the repository:
```bash
git clone <YOUR_INCEPTION_REPOSITORY_URL> inception
cd inception
```

### 2. Prepare physical storage directories
Create the required host bind-mount directories and ensure your user owns them to prevent permission denied errors:
```bash
sudo mkdir -p /home/manuelfe/data/mariadb
sudo mkdir -p /home/manuelfe/data/wordpress
sudo chown -R $USER:$USER /home/manuelfe/data
```

### 3. Configure environment variables & secrets
Set up your environment variables and secrets inside the `srcs/` directory:
* `srcs/.env` (public configurations: domain, database names, administrative usernames).
* `srcs/secrets/` (plaintext secret files containing database root/user passwords and WordPress user passwords).

### 4. Build and run the infrastructure
Launch the stack using the provided Makefile:
```bash
make
```

### 5. Verify running containers
Ensure all three containers are healthy and running:
```bash
docker ps
```

### 6. Access the website
To access the website from your host machine's browser, map your VM's IP address to your domain name.

Edit `/etc/hosts` on your host machine:
```text
<YOUR_VM_IP_ADDRESS>       manuelfe.42.fr
```

Open your browser and navigate to:
```text
https://manuelfe.42.fr
```

*(Because the self-signed SSL certificate was generated locally using OpenSSL, accept the security bypass warning upon your first visit).*

---

## 📚 References & Documentation

* [Inception Tutorial - Medium (@imyzf)](https://medium.com/@imyzf/inception-3979046d90a0)
* [Docker Nginx + WordPress + MariaDB Architecture Guide (dev.to)](https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok)
* [Official Docker Compose Documentation](https://docs.docker.com/compose/)
* [Official NGINX FastCGI & TLS Documentation](https://nginx.org/en/docs/)