FROM ubuntu:latest

# ENV vars for relevant directories
ENV STEAMCMD_DIR "/home/steam/steamcmd"
ENV HLDS_DIR "/home/steam/hlds"
ENV PORT 27015
ENV DEBIAN_FRONTEND noninteractive

# install basic dependencies
RUN dpkg --add-architecture i386
RUN apt -qq update \
    && apt -qqy install curl lib32gcc1 \
    unzip unrar p7zip-full

# user setup
RUN useradd -m steam
WORKDIR /home/steam
USER steam

# default server constants
ENV SV_LAN 0
ENV MAP "de_minidust2"
ENV MAXPLAYERS 16
ENV CS_HOSTNAME "cs_server_name"
ENV CS_PASSWORD "server_password"
ENV RCON_PASSWORD "rcon_password"

# Install steamcmd manually : multiverse needs EULA acceptance, won't work in docker
RUN mkdir -p $STEAMCMD_DIR
WORKDIR $STEAMCMD_DIR
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
WORKDIR /home/steam/
# link 32-bit libraries
RUN mkdir -p /home/steam/.steam
RUN ln -s $STEAMCMD_DIR/linux32 /home/steam/.steam/sdk32

# copy mods and maps archives
RUN mkdir -p /home/steam/addons
COPY [--chown=steam:steam] addons/* /home/steam/addons/

# copy steam and cs install/control tool to container
COPY cs_server.sh /bin/cs_server
COPY install_addon.sh /bin/install_addon

# mount volume for configs and scripts
RUN mkdir -p /home/steam/store && mkdir -p /home/steam/misc
RUN chown -R steam:steam /home/steam/store && chown -R steam:steam /home/steam/misc
VOLUME [ "/home/steam/store/", "/home/steam/misc" ]

# expose docker ports for external use
EXPOSE $PORT/tcp
EXPOSE $PORT/udp

# run the start counter strike dedicated server and wait for input in bash
CMD ["sh", "-c", "cs_server start & /bin/bash"]
