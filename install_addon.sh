#! /bin/bash

if [ $1 = "--help" ]; then
echo
  echo "Usage: install_addon [archive_path]"
  echo
  echo "Note: please use absolute path here. you can cd into dir and use \$(pwd)/archive.*"
  echo
  exit 0
fi

# This is the ex function from .bashrc in Manjaro Linux
# I did not write this function. not sure who did.
ex() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1;;
      *.tar.gz)    tar xzf $1;;
      *.bz2)       bunzip2 $1;;
      *.rar)       unrar x $1;;
      *.gz)        gunzip $1;;
      *.tar)       tar xf $1;;
      *.tbz2)      tar xjf $1;;
      *.tgz)       tar xzf $1;;
      *.zip)       unzip $1;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1;;
      *)
        echo "'$1' not compatible, unable to extract archive"
        return 1;;
    esac
  else
    echo "'$1' is not a valid file"
    return 1
  fi
}

parentd_is_writable() {
  local TARGET_PATH=$1

  while true; do
    test -w $TARGET_PATH && return
    TARGET_PATH=$(echo $(dirname $TARGET_PATH))
    if [[ $TARGET_PATH == "/" ]]; then
      echo -e "\nTarget location '$1' is not writable: Permission denied\n"
      return 1
    fi
  done
}

# check if archive path entered is valid
if [ ! -f $1 ]; then
  echo
  echo "Unable to locate archive $1. Please enter absolute address"
  echo
  exit 1
fi

# get user input about install location
echo
echo "Where would you like to place the extracted files?"
echo "Select one of the following locations or enter manually:"
echo -e "  1.  $HLDS_DIR/ -> archive contains cstrike folder\n"
echo -e "  2.  $HLDS_DIR/cstrike -> archive contents go into cstrike, gfx/ maps/ or *.wad files, etc\n"
echo -e "  3.  $HLDS_DIR/cstrike/maps -> individual map files in archive, *.bsp *.nav *.res *.txt\n"
echo -e "  4.  $HLDS_DIR/cstrike/addons -> for specific addon, arc-files in addons folder\n"
echo -e "  5.  $HLDS_DIR/cstrike/addons/podbot/ -> podbot waypoints, archive contains wptdefault folder\n"
echo -e "  6.  $HLDS_DIR/cstrike/addons/podbot/wptdefault -> individual podbot waypoint files, *.pwf\n"
echo "Note: addons copied directly may need extra configuration after, check mod instructions"

read -p "Enter 1-6 or valid path >>  "
case $REPLY in
  1) TARGET_DIR="$HLDS_DIR";;
  2) TARGET_DIR="$HLDS_DIR/cstrike";;
  3) TARGET_DIR="$HLDS_DIR/cstrike/maps";;
  4) TARGET_DIR="$HLDS_DIR/cstrike/addons";;
  5) TARGET_DIR="$HLDS_DIR/cstrike/addons/podbot";;
  6) TARGET_DIR="$HLDS_DIR/cstrike/addons/podbot/wptdefault";;
  *) TARGET_DIR="$REPLY";;
esac

# make sure intendent install location is not write protected
parentd_is_writable $TARGET_DIR
if [ $? -eq 1 ]; then
  exit 1
fi

# tmp location for extraction
echo "Extracting archive to temporary location"
export EXTRACTION_DIR="/tmp/extracted"
mkdir -p $EXTRACTION_DIR

# extract archive to tmp location
cd $EXTRACTION_DIR
ex $1

# check if extraction success
if [ $? -eq 1 ]; then
  rm -rf $EXTRACTION_DIR
  echo "Archive extraction failed"
  exit 1
fi

# make target dir if doesn't exist
echo "Copying mod/map files to given path"
[ ! -d $TARGET_DIR ] && mkdir -p $TARGET_DIR || true

# copy contents of extracted archive to $HLDS_DIR/cstrike folder
cp -r $EXTRACTION_DIR/* $TARGET_DIR
echo "Copy successful"

# remove extracted archive contents from temp location
echo "Cleaning up temporary files"
rm -rf $EXTRACTION_DIR
