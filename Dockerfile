#
# Dockerfile for ELK Audio OS Yocto builds
#

# Pull base image
FROM ubuntu:22.04

# Define variables used in the Dockerfile
ARG USERNAME=yoctouser
ARG GROUPNAME=yocto
ARG UID=1000
ARG GID=1000

ARG ELK_SDK_DOWNLOAD_URL="https://github.com/elk-audio/elkpi-sdk/releases/download/1.0.0/elk-glibc-x86_64-elkpi-audio-os-image-cortexa72-raspberrypi4-64-toolchain-1.0.0.sh"
ARG JUCE_DOWNLOAD_URL="https://github.com/juce-framework/JUCE/releases/download/8.0.4/juce-8.0.4-linux.zip"
ARG ELK_SDK_BASEPATH=/SDKs/elkpi/

# Set shell
SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Update package sources and add i386 architecture
RUN \
 apt-get update -q && \
 dpkg --add-architecture i386 && \
 apt-get update -q && \
 apt-get -qy upgrade

# Create group
RUN groupadd -g $GID $GROUPNAME

# Timezone / locale
RUN \
 apt-get install -qy tzdata && \
 apt-get install -qy locales && \
 sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
 locale-gen

ENV TZ=Europe/Rome
ENV LC_ALL en_US.UTF-8 
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  

# Install required packages
RUN \
 apt-get install -qy \
    alsa-utils \
    build-essential \
    byobu \
    chrpath \
    cmake \
    cmake-curses-gui \
    cpio \
    curl \
    debianutils \
    diffstat \
    dos2unix \
    file \
    gawk \
    gcc-multilib \
    git \
    htop \
    iproute2 \
    iputils-ping \
    ladspa-sdk \
    libasound2-dev \
    libcurl4-openssl-dev  \
    libfontconfig1-dev \
    libfreetype-dev \
    libglu1-mesa-dev \
    libjack-jackd2-dev \
    liblz4-tool \
    libncurses-dev \
    libsdl1.2-dev \
    libwebkit2gtk-4.0-dev \
    libx11-dev \
    libxcomposite-dev \
    libxcursor-dev \
    libxext-dev \
    libxinerama-dev \
    libxrandr-dev \
    libxrender-dev \
    lz4 \
    man \
    mesa-common-dev \
    meson \
    mtools \
    ninja-build \
    openssl \
    parted \
    picocom \
    pylint \
    python3 \
    python3-git \
    python3-jinja2 \
    python3-pexpect \
    python3-pip \
    rsync \
    socat \
    software-properties-common \
    subversion \
    sudo \
    sysstat \
    texinfo \
    tftpd-hpa \
    tmux \
    u-boot-tools \
    unzip \
    vim \
    wget \
    xterm \
    xz-utils  \
    zip \
    zstd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install python pakages required by KAS
RUN pip3 install --no-input distro jsonschema PyYAML kconfiglib

# Clone KAS repository
RUN git clone https://github.com/siemens/kas.git /opt/kas && \
    cd /opt/kas && \
    git fetch --all --tags && \
    git checkout tags/4.0

# Download and setup Elk SDK
WORKDIR /tmp
RUN wget -O elkpi-sdk.sh $ELK_SDK_DOWNLOAD_URL && \
    chmod +x elkpi-sdk.sh && \
    /tmp/elkpi-sdk.sh -y -d $ELK_SDK_BASEPATH && \
    rm -f elkpi-sdk.sh


# Create user without password
RUN \
 useradd -rm -d /home/$USERNAME -s /bin/bash -G sudo -g $GROUPNAME -u $UID $USERNAME && \
 passwd -d $USERNAME && \
 echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


# Avoid sudo warning message
RUN touch /home/$USERNAME/.sudo_as_admin_successful

# Setup JUCE inside SDK and example project in user directory
RUN wget -O juce.zip $JUCE_DOWNLOAD_URL && \
    unzip juce.zip && \
    cd JUCE && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$ELK_SDK_BASEPATH/sysroots/cortexa72-elk-linux/usr/ .. && \
    make -j 4 && \
    make install && \
    cd ../examples/CMake && \
    mkdir -p /home/$USERNAME/examples && \
    cp -r AudioPlugin /home/$USERNAME/examples

# Apply patch to example CMake conf. for VST3 crosscompilation with Elk SDK
WORKDIR /home/$USERNAME/examples/AudioPlugin
RUN dos2unix CMakeLists.txt
RUN patch CMakeLists.txt <<EOF
@@ -21,7 +21,7 @@
 # included JUCE directly in your source tree (perhaps as a submodule), you'll need to tell CMake to
 # include that subdirectory as part of the build.
 
-# find_package(JUCE CONFIG REQUIRED)        # If you've installed JUCE to your system
+find_package(JUCE CONFIG REQUIRED)        # If you've installed JUCE to your system
 # or
 # add_subdirectory(JUCE)                    # If you've put JUCE in a subdirectory called JUCE
 
@@ -51,7 +51,8 @@
     PLUGIN_MANUFACTURER_CODE Juce               # A four-character manufacturer id with at least one upper-case character
     PLUGIN_CODE Dem0                            # A unique four-character plugin id with exactly one upper-case character
                                                 # GarageBand 10.3 requires the first letter to be upper-case, and the remaining letters to be lower-case
-    FORMATS AU VST3 Standalone                  # The formats to build. Other valid formats are: AAX Unity VST AU AUv3
+    FORMATS VST3                                # The formats to build. Other valid formats are: AAX Unity VST AU AUv3
+    VST3_AUTO_MANIFEST FALSE
     PRODUCT_NAME "Audio Plugin Example")        # The name of the final executable, which can differ from the target name
EOF

RUN unix2dos CMakeLists.txt && \
    rm -f CMakeLists.txt.orig && \
    rm -rdf /tmp/JUCE && \
    rm -f /tmp/juce.zip

# Set file permissions
RUN chown -R $USERNAME:$GROUPNAME /home/$USERNAME

# Set display
ENV DISPLAY :0

# Set user
USER $USERNAME

# Set home
ENV HOME /home/$USERNAME

# Define working directory
WORKDIR /home/$USERNAME

# Path environment
ENV PATH="${PATH}:/opt/kas"

SHELL ["/bin/bash", "-l", "-i"]

# Define default command
ENTRYPOINT ["/bin/bash", "-l", "-i"]

