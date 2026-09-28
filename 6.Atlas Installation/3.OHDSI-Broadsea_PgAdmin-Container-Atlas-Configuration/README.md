# Installation and Configuration Guide: OHDSI Broadsea, PgAdmin on Docker and Connect PgAdmin to Atlas

---

## **1. Installing OHDSI Broadsea**

OHDSI Broadsea is a Docker-based solution for deploying the OHDSI tool stack, including ATLAS and WebAPI, in a containerized environment. It simplifies the deployment and management of OHDSI components, making it easier to integrate with various database systems and analytical tools.

For the latest updates and releases, visit the official GitHub repository: [OHDSI Broadsea GitHub](https://github.com/OHDSI/Broadsea).

### Step 1: Open Command Prompt

- To open the Command Prompt in Windows, search for "cmd" in the Start Menu and press Enter, or press the `Windows key + R`, type "cmd," and press Enter.

#### WSL terminal
- Type `wsl` and press Enter. When launching WSL, it may not always default to the home directory of your Ubuntu distribution. You will have to manually change to the home directory of your Ubuntu distribution by typing `cd ~`

- To explicitly tell it to start in the default home directory, we type `wsl ~` and press Enter.

#### Ubuntu terminal
- Type `ubuntu` and press Enter. It will default to the home directory of your Ubuntu distribution.

### Step 2: Make sure docker compose is installed and verify installation

In a command-line terminal, execute the below commands

```bash
sudo apt update

```

```bash
sudo apt install docker-compose

```

```bash
sudo apt-get update

```

```bash
docker-compose --version

```

### Step 3: Clone OHDSI Broadsea Repository

```bash
git clone https://github.com/OHDSI/Broadsea.git

```

### Step 4: Start OHDSI Broadsea Containers

Navigate to the directory where this README.md file is located. In a command-line terminal, execute the following command to start the Broadsea Docker containers. If you are using Linux, you may need to prepend sudo to the command. Wait up to one minute for all containers to fully start.

```bash
cd Broadsea
docker compose --profile default up -d
```
> [!NOTE]
> In the web browser, open the URL "https://127.0.0.1". OHDSI containers; ATLAS, HADES & ARES should open


### Step 5: Verify Running Containers

```bash
docker ps -a

```

---

## **2. Installing PgAdmin on Docker and Connecting to Atlas**

The PgAdmin client allows you to interact with the database from your docker machine or a remote server

PgAdmin 4 is a popular web-based administration and management tool for PostgreSQL. It provides a user-friendly interface that lets you interact with your databases, execute SQL queries, monitor database performance, and much more, without having to navigate complex command lines.


### Step 6: Pull the pgAdmin 4 image using Docker

```bash
docker pull dpage/pgadmin4
```

### Step 7: To run pgAdmin (a web-based database management tool) and connect it to Broadsea Network, use:

```bash
docker run --name pgadmin-atlasdb -p 5050:80 -e PGADMIN_DEFAULT_EMAIL=youremailaddress -e PGADMIN_DEFAULT_PASSWORD=yourpassword --network broadsea_default -d dpage/pgadmin4

```
- Remember to replace `youremailaddress` and `yourpassword` with your email and password.

- The command above sets up a new Docker container named `pgadmin-atlasdb`, maps port 5050 on your machine to port 80 on the container, attaches the container to the Docker network broadsea_default and sets the default email and password to access the pgAdmin 4 interface.

### Step 8: Start the PgAdmin container and check if container is running

```bash
docker start pgadmin-atlasdb
```

```bash
docker ps -a
```
- Once the container is successfully running, you can access pgAdmin by navigating to `localhost:5050` in a web browser of your choice.

- You will then see a login prompt, you will be able to log in with the `e-mail address` and `password` that you specified **In Step 7** to see if everything is working.

### Step 9: Get the IP Address of the Atlas Database Container

After starting the necessary containers, retrieve the IP address of the ATLAS Database container. In your terminal, run

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' broadsea-atlasdb

```

- This will return an the IP address i.e `172.18.0.1` (this may or may not be true for you)

### Step 10: Register the Server in pgAdmin

After confirming successful login to pgAdmin 4 **In Step 8**,

- In pgAdmin, click "Register New Server".
- Under the "General" tab, give the server a name, e.g., "MyDB", "Test"...etc
- Under the "Connection" tab:
   - **Host name/address:** Paste the IP address from **Step 9**
   - **Maintenance database:** postgres
   - **Username:** postgres (or another name if you changed it)
   - **Password:** mypass (or whatever password you selected)
   - **Optional:** Set save password to true
- Click "Save" 
- You are now connected to the broadsea-atlasdb PostgreSQL database and you will be able to select your database server from the menu on the left side.


After successful installation and configuration, type `Exit` and press Enter. This will close the WSL-Linux terminal window.

Again, Type `Exit` and press Enter. This will close the command-line interface.

---

## **Troubleshooting**

For common troubleshooting steps, consult the [OHDSI Broadsea GitHub Issues page](https://github.com/OHDSI/Broadsea/issues) and the [PgAdmin Container Deployment](https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html).

---


