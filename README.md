*Este proyecto ha sido desarrollado como parte del currículo de 42 por manuelfe.*

# Inception

He diseñado e implementado una infraestructura web segura y multicontenedor utilizando **Docker Compose**. El objetivo de este proyecto ha sido levantar localmente un servidor NGINX con soporte TLS exclusivo, un entorno WordPress servido mediante PHP-FPM y una base de datos MariaDB, aislando cada componente en redes y volúmenes dedicados bajo las directrices estrictas del sujeto de 42.

---

## 📌 Descripción del Proyecto

Inception representa para mí el proyecto central de la rama de Sistemas (SysAdmin) en 42. Su propósito fundamental ha sido enseñarme a diseñar, configurar y desplegar una arquitectura de microservicios profesional, modular y completamente aislada utilizando Docker.

En este proyecto asumí la regla estricta de **no utilizar imágenes preconfiguradas de Docker Hub** (como las imágenes oficiales de WordPress o MariaDB). En su lugar, construí cada contenedor desde cero mediante `Dockerfiles` basados en Debian, instalando y configurando los servicios de manera nativa con mis propios scripts de Bash. Toda la infraestructura se orquesta a través de un único archivo `docker-compose.yml` ejecutado dentro de una máquina virtual.

Mi arquitectura se compone de tres contenedores independientes conectados mediante una red privada virtual tipo bridge:

* **NGINX (El punto de entrada seguro):** Es el único contenedor que expone puertos hacia el exterior (puerto 443). Actúa como proxy inverso y procesa exclusivamente conexiones cifradas con TLS v1.2 o TLS v1.3. He deshabilitado y prohibido por completo el tráfico en texto plano por HTTP (puerto 80).
* **WordPress + PHP-FPM (El procesador de contenidos):** Aloja el código fuente y los recursos del CMS. Dado que NGINX no interpreta PHP de forma nativa, canalizo las peticiones dinámicas hacia este contenedor a través del protocolo FastCGI en el puerto interno 9000.
* **MariaDB (La base de datos relacional):** Almacena de forma persistente los posts, usuarios, metadatos y configuraciones del sitio. Se encuentra completamente aislado en la red interna (puerto 3306), sin exponer ningún puerto al anfitrión físico.

---

## 🧠 Conceptos Clave Aprendidos y Aplicados

Durante el desarrollo de esta infraestructura profundicé en los fundamentos teóricos y prácticos que diferencian una solución en producción de un entorno de pruebas:

### 1. Máquinas Virtuales vs. Docker
Ambas tecnologías resuelven problemas de aislamiento, portabilidad y límites de recursos, pero apliqué Docker comprendiendo sus contrastes frente a la virtualización tradicional:

| Característica | Máquina Virtual (VM) | Contenedor Docker |
|---|---|---|
| **Arquitectura** | Incluye un sistema operativo invitado completo con su propio kernel y controladores. | Comparte el kernel del sistema anfitrión, empaquetando solo binarios y librerías necesarias. |
| **Rendimiento** | Tarda minutos en arrancar e impone un alto consumo constante de RAM y CPU. | Se inicializa en segundos con un consumo mínimo de recursos. |
| **Tamaño en disco** | Requiere imágenes pesadas (habitualmente entre 10 GB y 20 GB). | Utiliza capas optimizadas que oscilan entre 50 MB y 250 MB. |

### 2. Docker Secrets vs. Variables de Entorno
Comprendí que la seguridad de las credenciales depende del mecanismo de inyección:

* **Variables de entorno (`.env`):** Resultan idóneas para parámetros no críticos (nombres de base de datos, URLs o títulos), pero exponen datos confidenciales si se usan para contraseñas. Permanecen visibles en texto plano ante un comando `docker inspect` o al listar el entorno con `env`.
* **Docker Secrets:** Protegen la información crítica montando archivos temporales directamente sobre un sistema en memoria RAM (`tmpfs`) dentro de `/run/secrets/`. De este modo, evito que las contraseñas se escriban en el disco duro o queden expuestas en los metadatos de los contenedores.

### 3. Redes Docker (Bridge) vs. Red del Host
* **Docker Network (`bridge`):** Fue mi elección para el proyecto. Docker genera un conmutador virtual que asigna subredes e IPs privadas a cada servicio. Esto me permite aplicar aislamiento estricto, exigir mapeo selectivo de puertos y aprovechar la resolución de nombres DNS interna de Docker.
* **Host Network:** Elimina el aislamiento de red haciendo que el contenedor comparta directamente las interfaces y puertos del host, lo cual descarta la segmentación exigida en esta arquitectura.

### 4. Docker Volumes vs. Bind Mounts
* **Bind Mounts:** Mapean una ruta exacta del sistema de archivos del host (`/home/manuelfe/data/...`) dentro del contenedor. Los utilicé para cumplir con la persistencia explícita en las carpetas obligatorias del sujeto.
* **Docker Volumes:** Son gestionados completamente por el motor de Docker en rutas internas del sistema, ofreciendo mayor portabilidad cuando no se requiere acceso manual a las rutas del anfitrión.

---

## 🚀 Guía de Instalación y Puesta en Marcha

Detallo a continuación el procedimiento paso a paso para desplegar mi entorno en la máquina virtual.

### 1. Clonar el repositorio
Accedo a la máquina virtual por SSH, me sitúo en el directorio de usuario y clono el proyecto:
```bash
git clone <URL_DE_TU_REPOSITORIO_INCEPTION> inception
cd inception
```

### 2. Crear los directorios físicos persistentes
Creo las rutas del host donde se almacenarán los datos persistentes de la base de datos y de WordPress:
```bash
sudo mkdir -p /home/manuelfe/data/mariadb
sudo mkdir -p /home/manuelfe/data/wordpress
sudo chown -R $USER:$USER /home/manuelfe/data
```

### 3. Configurar variables de entorno y secretos
Coloco el archivo `.env` y los secretos en las rutas correspondientes del directorio `srcs/`:
* `srcs/.env` (variables públicas: URLs, nombres de base de datos, usuarios).
* `srcs/secrets/` (archivos individuales con las contraseñas de MariaDB y credenciales de WordPress).

### 4. Compilar y levantar la infraestructura
Ejecuto la regla principal de mi `Makefile`:
```bash
make
```

### 5. Verificar el estado de los servicios
Compruebo que los tres contenedores estén en ejecución y con sus estados de salud correctos:
```bash
docker ps
```

### 6. Acceso al sitio web
Para acceder desde el navegador de mi máquina anfitriona física, vinculo el dominio a la dirección IP de mi máquina virtual.

Edito el archivo `/etc/hosts` en el anfitrión físico:
```text
<IP_DE_TU_MAQUINA_VIRTUAL>       manuelfe.42.fr
```

Accedo desde el navegador a la URL segura:
```text
https://manuelfe.42.fr
```

*(Al tratarse de un certificado TLS autofirmado generado con OpenSSL, acepto la advertencia de seguridad en la primera visita).*

---

## 📚 Referencias y Documentación

* [Inception Tutorial - Medium (@imyzf)](https://medium.com/@imyzf/inception-3979046d90a0)
* [Docker Nginx + WordPress + MariaDB Architecture Guide (dev.to)](https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok)
* [Documentación oficial de Docker Compose](https://docs.docker.com/compose/)
* [Documentación oficial de NGINX con FastCGI y TLS](https://nginx.org/en/docs/)