# ELK Audio OS builder

This repository contains the dockerfile needed to build the ELK Audio OS builder docker image.

This Docker image contains the [Elk Audio SDK for Raspberry Pi](https://github.com/elk-audio/elkpi-sdk) and the [JUCE framework](https://github.com/juce-framework/JUCE) to cross-compile VST3 plugins for Elk Audio OS.

It also has the [KAS](https://github.com/siemens/kas) tool installed that can be used to automate the bitbake configuration and build process for an entire Elk Audio OS image.

## Setup

Configure and install the docker image on your system
```shell
docker image build -t elk-audio-os-builder .
```

If you're running on Mac with Apple Silicon, add the option `--platform linux/amd64` after build.

Please note that you may need some extra steps in order to run docker as a regular user without admin privileges.
If this is the case please refer to the docker documentation.

Run the container
```shell
docker run --name elk-audio-os -it --rm elk-audio-os-builder
```

If you're on Apple Silicon, you need again to pass the option `--platform linux/amd64` to the docker run command.


# Compile the JUCE AudioPlugin example

Inside the home directory of the container, there is a modified version of JUCE's CMake example for AudioPlugins pre-configured for this system.

You can test it with
```shell
cd ~/examples/AudioPlugin
mkdir -p build && cd build
source /SDKs/elkpi/environment-setup-cortexa72-elk-linux
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j`nproc`
```


# Build a full Yocto image for Elk Audio OS

For building images using the container we recommend to bind mount a drive or folder from your host or use a dedicated docker volume.
This way the build artifacts and images will not be lost when you stop the container.

Example to mount a directory from the host to the container
```shell
mkdir elk-yocto-build
docker run --name elk-audio-os -it --rm -v ./elk-yocto-build:/elk-yocto-build -w /elk-yocto-build elk-audio-os-builder
```

Build the image (Raspberrypi4 with ELK Audio OS 1.1.0 shown)
```shell
git clone https://github.com/elk-audio/elk-audio-kas-configs
run-kas build elk-audio-kas-configs/raspberrypi4/raspberrypi4-elk-audio-os-v1.1.0.yml
```

If you need to build the SDK run
```shell
run-kas build elk-audio-kas-configs/raspberrypi4/raspberrypi4-elk-audio-os-v1.1.0.yml -c populate_sdk
```


Copyright 2017-2025 Elk Audio AB, Stockholm, Sweden
