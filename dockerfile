#
# Dockerfile for ELK Audio OS Yocto builds
#

# Pull base image
FROM ubuntu:20.04

# Define variables used in the Dockerfile
ARG USERNAME=yoctouser
ARG GROUPNAME=yocto
ARG UID=1000
ARG GID=1000

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
    iputils-ping \
    libjack-jackd2-dev \
    liblz4-tool \
    libncurses-dev \
    libsdl1.2-dev \
    lz4 \
    man \
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
    vim \
    wget \
    xterm \
    xz-utils  \
    xz-utils \
    zip \
    zstd

# Cleanup apt
RUN rm -rf "/var/lib/apt/lists/*"

# Install python pakages required by KAS
RUN pip3 install --no-input distro jsonschema PyYAML kconfiglib

# Clone KAS repository
RUN git clone https://github.com/siemens/kas.git /opt/kas

# Create user without password
RUN \
 useradd -rm -d /home/$USERNAME -s /bin/bash -g $GROUPNAME -G sudo -u $UID $USERNAME && \
 passwd -d $USERNAME

# Avoid sudo warning message
RUN touch /home/$USERNAME/.sudo_as_admin_successful

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

# Define default command
CMD ["bash"]
