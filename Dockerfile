FROM ubuntu:24.04

# Set ARG for steam user UID and export to ENV
ARG STEAM_UID=1000
ENV STEAM_UID=${STEAM_UID}

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    lib32gcc-s1 \
    ca-certificates \
    curl \
    locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Remove default ubuntu user if it exists and has the same UID as STEAM_UID
# This is necessary because Ubuntu 24.04 comes with a default 'ubuntu' user with UID 1000
RUN if id -u ubuntu >/dev/null 2>&1 && [ $(id -u ubuntu) -eq ${STEAM_UID} ]; then \
        userdel -r ubuntu; \
    fi

# Create steam user with specified UID
RUN useradd -m -u ${STEAM_UID} -s /bin/bash steam

# Set up directories
RUN mkdir -p /home/steam/steamcmd /home/steam/valheim-server /home/steam/.steam/sdk64 && \
    chown -R steam:steam /home/steam

# Switch to steam user
USER steam
WORKDIR /home/steam

# Download and install SteamCMD
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - -C /home/steam/steamcmd

# Create installation script
RUN echo '#!/bin/bash' > /home/steam/install_valheim.sh && \
    echo '/home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/valheim-server +login anonymous +app_update 896660 validate +quit' >> /home/steam/install_valheim.sh && \
    chmod +x /home/steam/install_valheim.sh

# Create startup script
RUN echo '#!/bin/bash' > /home/steam/start_valheim.sh && \
    echo 'cd /home/steam/valheim-server' >> /home/steam/start_valheim.sh && \
    echo 'export SteamAppId=892970' >> /home/steam/start_valheim.sh && \
    echo 'export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH' >> /home/steam/start_valheim.sh && \
    echo './valheim_server.x86_64 -name "${SERVER_NAME:-ValheimServer}" -port ${SERVER_PORT:-2456} -world "${WORLD_NAME:-Dedicated}" -password "${SERVER_PASSWORD:-secret}" -public ${SERVER_PUBLIC:-0}' >> /home/steam/start_valheim.sh && \
    chmod +x /home/steam/start_valheim.sh

# Expose Valheim server ports
EXPOSE 2456/udp
EXPOSE 2457/udp
EXPOSE 2458/udp

# Set working directory to valheim-server
WORKDIR /home/steam/valheim-server

# Default environment variables
ENV SERVER_NAME="ValheimServer"
ENV SERVER_PORT=2456
ENV WORLD_NAME="Dedicated"
ENV SERVER_PASSWORD="secret"
ENV SERVER_PUBLIC=0

# Entry point: install and start server
CMD ["/bin/bash", "-c", "/home/steam/install_valheim.sh && /home/steam/start_valheim.sh"]
