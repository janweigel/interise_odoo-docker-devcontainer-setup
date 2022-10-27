# Odoo Docker Image by Interise 

## Features:
- Python Debuggin with debugpy and a custom attach-hook
- Option to Install in Visual Studio Code Remote Container
- Bind mount external addons folders as Volumes in the container
- Install Odoo from github source

# Setup

## Requirements
To use this docker compose file you should comply with this requirements:

- Install [Docker Desktop](https://www.docker.com/products/docker-desktop) for Windows/Mac or [Docker Engine](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce) for Linux  
- Install [docker-compose](https://docs.docker.com/compose/install/) (This is installed by default on Windows and Mac with Docker installation)

## Environment
- Check the .env File and set the desired values and direcotries
- The predefined ports are non-default ports to be exposed externally to prevent collisions with existing containers for other Odoo Installations.
- By default the following external directories are mounted in the container:
  - `../addons-custom`
  - `../addons-extra`

## Setup as Visual Studio Code Dev Container (recommended):
- To Install as Visual Studio Code Dev Container install Visual Studio Code and the [Remote Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
- Open the Folder in VsCode and hit F1 -> Dev Containers: Reopen in Container
- To customize the Extensions which are preinstalled in the container you can edit the extensions section in the file `.devcontainer/devcontainer.json`

## Setup as standalone Docker Container:
```shell
docker-compose up -d --build
```

In the `.env` filenon-default ports are used to be exposed externally to prevent collisions with existing containers for other Odoo Installations.

# Debugging
## When installed in Dev Container:
- A working launch.json config is automatically installed in the Dev Container.
## Debugging with VSCode using following launch.json:
- This applies only if used as standalone docker container.

```json
{
	"version": "0.2.0",
	"configurations": [
		{
			"name": "Odoo: Attach",
			"type": "python",
			"request": "attach",
			"debugServer": 3001,
			"host": "localhost",
		}
	]
}
```
