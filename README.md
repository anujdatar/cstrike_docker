# cstrike_docker

Counter Strike 1.6 server using docker

Probably works best if you clone the git repo anyway and run everything through there.
Image only contains basic ubuntu with steamcmd. First start of container will install the Counter Strike Dedicated Server.
Done in order to minimize docker image size. 

Container start also starts a HLDS CStrike server. based on the default server settings or any changes you may have made in the ./store folder cfgs.

## Usage
```bash
docker pull anujdatar/cs-16-server

docker run -dit --name <container-name> -v $(pwd)/store:/home/steam/store/ -v $(pwd)/misc:/home/steam/misc -p 27015:27015 -p 27015:27015/udp anujdatar/cs-16-server
```

If you wish to edit default server settings:
    - ./store/constants.sh -> starting map, server name, passwords
    - ./store/cfgs/*.cfg -> banned players, ips, other server settings

Then start docker container

## Building image manually

1. Clone [github repository](https://github.com/anujdatar/cstrike_docker)

2. Build docker image
    ```bash
    docker build -t <image-name/tag> .
    ```

3. Edit Server configs -> the `store` folder
    - ./store/constants.sh -> starting map, server name, passwords
    - ./store/cfgs/*.cfg -> banned players, ips, other server settings

4. Run docker container
    ```bash
    docker run -dit --name <container-name> -v $(pwd)/store:/home/steam/store/ -v $(pwd)/misc:/home/steam/misc -p 27015:27015 -p 27015:27015/udp <image-name/tag>
    ```

5. Container boots to bash. you can now run the server management script
    ```bash
    cs_server start
    or
    cs_server stop
    or
    cs_server restart
    or
    cs_server update
    ```
6. Adding more addons or maps -> the `misc` folder
    Copy archives of the stuff to ./misc folder which will be a mounted volume in the container.
    From here you can use the `install_addon` script to extract and copy addon/mod/map to desired location.
    You can also just copy files to the misc folder and copy them manually to the desired paths.
    You can also copy any customs scripts here whatever.

## Notes
For full version history check old repository [CS_16_docker](https://github.com/anujdatar/CS_16_docker), now archived. Bloated repository due to many many packing errors.
