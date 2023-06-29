# ELK Audio OS builder

This repository contains the dockerfile needed to build the ELK Audio OS builder docker image.

ELK Audio OS builder uses [KAS](https://github.com/siemens/kas) tool to automate the bitbake configuration and build process.

## Howto

Configure and install the docker image on your system
  ```
  docker image build -t elk-audio-os-builder .
  ```

Run the container
  ```
  docker run --rm -it elk-audio-os-builder
  ```

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
