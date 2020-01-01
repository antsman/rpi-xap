# HAH Portable
# Build notes http://www.dbzoo.com/livebox/portable
# Using jessie for gcc 4.9
FROM debian:jessie-slim as build

ARG LUA_VERSION=5.1
ARG SRC=/usr/src

# RUN apt-get update -qq && \
#     apt-get upgrade -y && \
#     rm -rf /var/lib/apt/lists/*

# Build packages required
RUN apt-get update -qq && \
    apt-get install -y -qq \
      build-essential libxml2-dev libcurl4-openssl-dev flex \
      git liblua${LUA_VERSION}-dev libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Prepare src folder
RUN mkdir -p $SRC && \
    cd $SRC && \
    # Get the code
    git clone --branch portable --single-branch https://github.com/dbzoo/hah.git portable && \
    # Include lua header files
    cp /usr/include/lua${LUA_VERSION}/* /usr/include/

# Build
RUN cd $SRC/portable && \
    make --silent install

# Final stage
FROM debian:jessie-slim

# User, home (app) and data folders
ARG USER=xap
ARG HOME=/home/$USER
ARG LUA_VERSION=5.1
ARG SRC=/usr/src
ARG LOGLEVEL=5
# 5 notice
# 6 info
# 7 debug

# Copy build result
COPY --from=build $SRC/portable/build/sysroot /

# Runtime packages required
RUN apt-get update -qq && \
    apt-get install -y -qq \
# dbzoo listed
      lua${LUA_VERSION} lua-filesystem lua-rex-posix lua-socket \
# extra required on rpi
      libssl1.0.0 libcurl3 \
# tools of interest
      procps net-tools sudo socat && \
    rm -rf /var/lib/apt/lists/*

# Prepare data folder
RUN mkdir -p $HOME && \
# Add $USER user so we aren't running as root
    adduser --home $HOME --no-create-home -gecos '' --disabled-password $USER && \
    chown -R $USER:$USER $HOME && \
# Still allow to sudo when have to ;) - with kloned, socat, apt +
    echo "$USER ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/$USER && \
# Prepare log folder
    mkdir -p /var/log/$USER && \
    chown -R $USER:$USER /var/log/$USER

# Copy in xap wrapper
COPY xap-wrapper.sh /

USER $USER
WORKDIR $HOME
ENV LOGLEVEL -d $LOGLEVEL

# Expose xap hub, klone
EXPOSE 3639/udp 80

CMD ["/xap-wrapper.sh"]
