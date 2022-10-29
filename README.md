# Odoo Docker Image by Interise 

### Features:
- Option to Install in Visual Studio Code Remote Container (recommended)
- Python debugging with debugpy and a custom attach-hook
- Mount external addons folders as Volumes in the container
- Install Odoo from github source

# Setup

### Requirements
- Install [Visual Studio Code](https://code.visualstudio.com/download)
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop) for Windows/Mac or [Docker Engine](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce) for Linux  
- Install [docker-compose](https://docs.docker.com/compose/install/) (This is installed by default on Windows and Mac with Docker installation)

### Environment
- Check the `.env` File and set the desired values and direcotries
- In the `.env` file non-default ports are setup to be exposed externally to prevent collisions with existing containers for other Odoo Installations.
- By default the following external directories are mounted in the container:
  - `../addons-custom`
  - `../addons-extra`

## Setup as Visual Studio Code Dev Container (recommended):
- To Install as Visual Studio Code Dev Container install Visual Studio Code and the [Remote Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
- Open the Folder in VsCode and hit F1 -> Dev Containers: Reopen in Container
- To customize the Extensions which are preinstalled in the container you can edit the extensions section in the file `.devcontainer/devcontainer.json`
- A set of recommended VsCode Extensions is defined in `.devcontainer/.vscodeeee/extensions.json` which you may want to install in the DevContainer.

## Setup as standalone Docker Container:
```shell
docker-compose up -d --build
```


# Debugging

### When installed in Dev Container:
- A working launch.json config is automatically installed in the Dev Container.

### When installed as standalone Docker container:
- You may want to setup your project as Multi Workspace and add your local folders for addons and odoo source as projects to the Workspace. 
- Use this launch.json config and optionally adjust host and port to your settings in the `.env` file.

```json
{
	"version": "0.2.0",
	"configurations": [
		{
			"name": "Odoo: Attach",
			"type": "python",
			"request": "attach",
			"host": "localhost",
			"debugServer": 3001,
			"pathMappings": [
				{
					"localRoot": "/my/path/to/custom",
					"remoteRoot": "/odoo/addons-custom"
				},
				{
					"localRoot": "/my/path/to/extra",
					"remoteRoot": "/odoo/addons-extra"
				},
				{
					"localRoot": "/my/path/to/odoo-source",
					"remoteRoot": "/odoo/dist"
				}
			]
    	}
	]
}
```
