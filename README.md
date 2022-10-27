**Fork of:** [odoo/docker](https://github.com/odoo/docker) | [Docker Hub Page](https://hub.docker.com/_/odoo)

**The changes I did to this fork:**
- Install Odoo from github source
- Option to Install in Visual Studio Code Remote Container
- Add debugpy to image and implement attach-hook for remote debugging
- Bind mount external addons folders as Volumes in the container

**Setup your Environment**
- Check the .env File and set the desired values and direcotries

**Setup as Visual Studio Code DevContainer:**
- To Install as Visual Studio Code DevContainer install the Microsoft Dev Containers Extension.
- Open the Folder in VsCode and hit F1 -> Dev Containers: Reopen in Container

**Setup as normal Docker Container:**
```shell
docker-compose up -d --build
```

I used non-default ports to be exposed externally to prevent collisions with existing containers for other Odoo Installations.

**Debugging with VSCode using following launch.json:**
- This applies only if used as normal docker container.
- If used as VsCode DevContainer a working launch.json is automatically setup.
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
