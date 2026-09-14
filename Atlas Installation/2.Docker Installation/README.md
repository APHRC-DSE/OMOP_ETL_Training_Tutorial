# Installation and Configuration Guide: Docker


## **Docker Installation**
Follow the guide below to install Docker on your system. For additional details, refer to the official [Docker Installation Guide](https://docs.docker.com/get-docker/).

### Step 1: Open Command Prompt

- To open the Command Prompt in Windows, search for "cmd" in the Start Menu and press Enter, or press the `Windows key + R`, type "cmd," and press Enter.

#### WSL terminal
- Type `wsl` and press Enter. When launching WSL, it may not always default to the home directory of your Ubuntu distribution. You will have to manually change to the home directory of your Ubuntu distribution by typing `cd ~`

- To explicitly tell it to start in the default home directory, we type `wsl ~` and press Enter.

#### Ubuntu terminal
- Type `ubuntu` and press Enter. It will default to the home directory of your Ubuntu distribution.


### Step 2: Update Package Index

```bash
sudo apt-get update
```

### Step 3: Install Required Packages
```bash
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

```

### Step 4: Add Docker’s Official GPG Key

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

### Step 5: Set Up the Stable Repository


```bash

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

```

### Step 6: Update Package Index Again

```bash
sudo apt-get update
```

### Step 7: Install Docker Engine

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io
```


### Step 8: Add User to Docker Group

```bash
sudo usermod -aG docker $USER
```
**Note: You may need to log out and log back in for the group changes to take effect**


### Step 9: Start and check Docker Service

```bash
sudo service docker start
```

```bash
sudo service docker restart
```

### Step 10: Verify Installation

```bash
sudo service docker status

```

```bash
sudo service docker stop

```

After successful installation, type `Exit` and press Enter. This will close the WSL-Linux terminal window.

Again, Type `Exit` and press Enter. This will close the command-line interface.



> [!TIP] 
> If you encounter issues with Docker installation, refer to the official [Docker Troubleshooting Guide](https://docs.docker.com/get-docker/) for support.

> [!NOTE] 
> It is recommended to periodically update your Docker images and containers to ensure security and performance improvements.



