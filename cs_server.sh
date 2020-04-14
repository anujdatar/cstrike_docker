#! /bin/bash

# Script to manage the Counter Strike 1.6 Dedicated Server

load_config() {
  echo "Loading server configs"
  yes | cp -rfa ~/store/cfgs/* ~/hlds/cstrike/
}

store_config() {
  echo "Storing server configs"
  [ ! -d "~/store/cfgs" ] && mkdir -p ~/store/cfgs || true
  yes | cp -rfa ~/hlds/cstrike/server.cfg ~/store/cfgs/server.cfg
  yes | cp -rfa ~/hlds/cstrike/custom_server.cfg ~/store/cfgs/custom_server.cfg
  yes | cp -rfa ~/hlds/cstrike/listip.cfg ~/store/cfgs/listip.cfg
  yes | cp -rfa ~/hlds/cstrike/banned.cfg ~/store/cfgs/banned.cfg

  [ ! -d "~/store/cfgs/addons/podbot" ] && mkdir -p ~/store/cfgs/addons/podbots || true
  yes | cp -rfa ~/hlds/cstrike/addons/podbot/podbot.cfg ~/store/cfgs/addons/podbot/podbot.cfg
}

install() {
  cd $STEAMCMD_DIR
  echo "Installing Counter Strike 1.6 Dedicated server"
  # install hlds and cs server, needs to be done more than once sometimes
  ./steamcmd.sh +login anonymous +force_install_dir $HLDS_DIR +app_set_config 90 mod cstrike +app_update 90 validate +quit || true
  ./steamcmd.sh +login anonymous +force_install_dir $HLDS_DIR +app_set_config 90 mod cstrike +app_update 90 validate +quit || true

  # copy mods to server
  install_metamod
  install_amxmodx
  install_podbot

  # Install map packs
  echo "Installing map packs"
  # Install de_minidust2 and aa_dima maps
  echo "Installing \"Mini Dust 2\" and \"Dima\" maps"
  if [ -f ~/addons/minidust_dima.tar.gz ]; then
    tar xzf ~/addons/minidust_dima.tar.gz -C $HLDS_DIR/cstrike
  else
    echo "Unable to locate $HOME/addons/minidust_dima.tar.gz"
    echo "Please verify map archive and manually copy to server"
  fi

  # Install aim maps for CS 1.6
  echo "Installing AIM map pack"
  if [ -f ~/addons/aim_maps.tar.gz ]; then
    tar xzf ~/addons/aim_maps.tar.gz -C $HLDS_DIR
  else
    echo "Unable to locate $HOME/addons/aim_maps.tar.gz"
    echo "Please verify map archive and manually copy to server"
  fi

  # Install Untitled maps
  echo "Installing Untitled map pack"
  if [ -f ~/addons/cs_untitled_1_2.tar.gz ]; then
    tar xzf ~/addons/cs_untitled_1_2.tar.gz -C $HLDS_DIR
  else
    echo "Unable to locate $HOME/addons/cs_untitled_1_2.tar.gz"
    echo "Please verify map archive and manually copy to server"
  fi

  echo "Installation complete"

  # clean up addons & map tarballs
  echo "Cleaning up installation files"
  rm -r /home/steam/addons

  return 0
}

install_metamod() {
  # check if metamod is installed
  [ -d $HLDS_DIR/cstrike/addons/metamod ] && echo "MetaMod already installed" && return 0
  
  echo "Installing MetaMod on game server"
  if [ -f ~/addons/metamod-1.21.1.tar.gz ]; then
    mkdir -p $HLDS_DIR/cstrike/addons
    # extract metamod
    tar xzf ~/addons/metamod-1.21.1.tar.gz -C $HLDS_DIR/cstrike/addons/
    # copy liblist.gam to enable metamod on game server
    cp -fa ~/addons/liblist.gam $HLDS_DIR/cstrike/liblist.gam
    echo "MetaMod install complete"
  else 
    echo "Unable to locate $HOME/addons/metamod-1.21.1.tar.gz"
    echo "Please verify mod archive and manually copy to server"
    return 1
  fi
  return 0
}

check_metamod_install() {
  echo "Checking MetaMod installation"
  if [ -d $HLDS_DIR/cstrike/addons/metamod ]; then
    echo "MetaMod OK"
    return 0
  else
    echo "MetaMod not installed"
    install_metamod
    return
  fi
}

install_amxmodx() {
  # check if amxmodx is installed
  [ -d $HLDS_DIR/cstrike/addons/amxmodx ] && echo "AMXmodX MM already installed" && return 0

  check_metamod_install
  if [ $? -eq 1 ]; then
    echo "MetaMod Install unsuccessful. Unable to install AMXmodX"
    return 1
  fi

  echo "Installing AMXmodX MetaMod on game server"
  if [ -f ~/addons/amxmodx_cs-1.8.2_linux.tar.gz ]; then
    # extract amxmod
    tar xzf ~/addons/amxmodx_cs-1.8.2_linux.tar.gz -C $HLDS_DIR/cstrike/addons/
    # add amxmodx to metamod plugins list
    echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" >> $HLDS_DIR/cstrike/addons/metamod/plugins.ini
  else 
    echo "Unable to locate $HOME/addons/amxmodx_cs-1.8.2_linux.tar.gz"
    echo "Please verify mod archive and manually copy to server"
    return 1
  fi
  echo "AMXmodX install complete"
  return 0
}

install_podbot() {
  # check if podbot is installed
  [ -d $HLDS_DIR/cstrike/addons/podbot ] && echo "POD-bot MM already installed" && return 0

  check_metamod_install
  if [ $? -eq 1 ]; then
    echo "MetaMod Install unsuccessful. Unable to install AMXmodX"
    return 1
  fi

  echo "Install PoDBot MetaMod on game server"
  if [ -f ~/addons/podbot-3.0_22.tar.gz ]; then
    # extract podbot
    tar xzf ~/addons/podbot-3.0_22.tar.gz -C $HLDS_DIR/cstrike/addons/
    # add podbot to metamod plugins list
    echo "linux addons/podbot/podbot_mm_i386.so" >> $HLDS_DIR/cstrike/addons/metamod/plugins.ini
    # copy extra waypoints
    tar xzf ~/addons/waypoints.tar.gz -C $HLDS_DIR/cstrike/addons/podbot/
  else 
    echo "Unable to locate $HOME/addons/podbot-3.0_22.tar.gz"
    echo "Please verify mod archive and manually copy to server"
    return 1
  fi
  echo "PoDBot install complete"
  return 0
}

update() {
  echo "Updating CS:S Dedicated Server"
  ./steamcmd.sh +login anonymous +app_update 90 +quit
  echo "Update complete"
}

start() {
  # check Counter Strike 1.6 Dedicated Server install
  echo "Checking Counter Strike 1.6 Dedicated Server installation"
  [ ! -d "$HLDS_DIR/cstrike" ] && install || echo "Counter Strike 1.6 Dedicated Server installed"
  
  # check if hlds is running
  [ -n "$(pidof hlds_run)" ] && echo "Counter Strike 1.6 Dedicated Server is already running on port:$PORT" && return 1

  # load server constants
  [ -f ~/store/constants.sh ] && source ~/store/constants.sh || true

  load_config

  echo "Starting Counter Strike 1.6 Dedicated Server"
  cd $HLDS_DIR
  ./hlds_run -game cstrike -strictportbind -ip 0.0.0.0 -port $PORT +sv_lan $SV_LAN +map $MAP -maxplayers $MAXPLAYERS +hostname $CS_HOSTNAME +sv_password $CS_PASSWORD +rcon_password $RCON_PASSWORD &
}

stop() {
  # check if hlds is running
  [ -z "$(pidof hlds_linux)" ] && echo "Counter Strike 1.6 Dedicated Server not running" && return 1
  pkill hlds_linux
  pkill hlds_run
  # store_config
  echo "Counter Strike 1.6 Dedicated Server has been stopped"
  exit 0
}

restart() {
  # check if hlds is running
  [ -z "$(pidof hlds_linux)" ] && echo "Counter Strike 1.6 Dedicated Server not running" && return 1
  echo "Restarting Counter Strike 1.6 Dedicated Server"
  pkill hlds_linux
  pkill hlds_run
  start
}

term_handler() {
    echo -e "\nSIGTERM/SIGINT received"
    stop
}

trap term_handler SIGINT
trap term_handler SIGTERM

case $1 in
  install)
    install;;
  update)
    update;;
  start)
    start;;
  stop)
    stop;;
  restart)
    restart;;
  *)
    echo "Usage: cs_server [COMMAND]"
    echo "Available commands:"
    echo "  start: start cstrike server"
    echo "  stop: stop cstrike server"
    echo "  restart: restart cstrike server"
    echo "  update: update cstrike server"
    ;;
esac
