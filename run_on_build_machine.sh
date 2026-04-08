#!/bin/sh

# Run this from a Yocto Build machine on AWS: Launch the elk-audio-os-builder
# container mounting volumes and setting user and group

BUILDS_DIR_HOST=$HOME/yocto_build_dir
IMAGES_DIR_HOST=$HOME/yocto_final_builds

DOCKER_USER=$(id -u)
DOCKER_GROUP=$(getent group yocto_users | cut -d: -f3)

sudo docker run --name kas -d --rm -it \
  -v $BUILDS_DIR_HOST:/yocto-hdd \
  -v $IMAGES_DIR_HOST:/really_big_hdd \
  -v $HOME:/home/yoctouser  \
  --user $DOCKER_USER:$DOCKER_GROUP \
  --group-add sudo elk-audio-os-builder

sudo docker attach kas

