# ELK Audio OS builder

This repository contains the dockerfile needed to build the ELK Audio OS builder docker image.

This Docker image contains the [Elk Audio SDK for Raspberry Pi](https://github.com/elk-audio/elkpi-sdk) and the [JUCE framework](https://github.com/juce-framework/JUCE) to cross-compile VST3 plugins for Elk Audio OS.

It also has a configuration for the [KAS](https://github.com/siemens/kas) tool to automate the bitbake configuration and build process for an entire Elk Audio OS image.

## Setup

Configure and install the docker image on your system
  ```
  docker image build -t elk-audio-os-builder .
  ```

Run the container
  ```
  sudo docker run --name elk-audio-os -d --rm -it elk-audio-os-builder
  sudo docker attach elk-audio-os
  ```

# Compile the JUCE AudioPlugin example

Inside the home directory of the container, there is a modified version of JUCE's CMake example for AudioPlugins pre-configured for this system.

You can test it with
  ```
  cd ~/examples
  mkdir build && cd build
  cmake -DCMAKE_BUILD_TYPE=Release ..
  make -j`nproc`
  ```

# Build a full Yocto image for Elk Audio OS

Build the image (Raspberrypi4 with ELK Audio OS 1.0.0 shown)
  ```
  git clone https://github.com/elk-audio/elk-audio-kas-configs
  cd elk-audio-kas-configs
  run-kas build raspberrypi4/raspberrypi4-elk-audio-os-v1.0.0.yml
  ```

  If you need to build the SDK run
  ```
  run-kas build raspberrypi4/raspberrypi4-elk-audio-os-v1.0.0.yml -c populate_sdk
  ```

Copyright 2017-2023 Elk Audio AB, Stockholm, Sweden

