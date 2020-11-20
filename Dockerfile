FROM registry.digitalocean.com/watheia/theia-server:common as common

FROM common as theia

ARG GITHUB_TOKEN

# Use "latest" or "next" version for Theia packages
ARG version=latest

# Optionally build a striped Theia application with no map file or .ts sources.
# Makes image ~150MB smaller when enabled
ARG strip=false
ENV strip=$strip

USER theia
WORKDIR /home/theia
ADD $version.package.json ./package.json

RUN if [ "$strip" = "true" ]; then \
    yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn theia download:plugins && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean \
    ;else \
    yarn --cache-folder ./ycache && rm -rf ./ycache && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && yarn theia download:plugins \
    ;fi

FROM registry.digitalocean.com/watheia/theia-server:common

# Comment any of these out to remove language support
FROM registry.digitalocean.com/watheia/theia-server:dart
FROM registry.digitalocean.com/watheia/theia-server:dotnet
FROM registry.digitalocean.com/watheia/theia-server:php
FROM registry.digitalocean.com/watheia/theia-server:python
FROM registry.digitalocean.com/watheia/theia-server:ruby
FROM registry.digitalocean.com/watheia/theia-server:swift

WORKDIR /home/theia

COPY --from=theia --chown=theia:theia /home/theia /home/theia

RUN chmod g+rw /home && \
    mkdir -p /home/project && \
    mkdir -p /home/theia/.pub-cache/bin && \
    mkdir -p /usr/local/cargo && \
    mkdir -p /usr/local/go && \
    mkdir -p /usr/local/go-packages && \
    chown -R theia:theia /home/project && \
    chown -R theia:theia /home/theia/.pub-cache/bin && \
    chown -R theia:theia /usr/local/cargo && \
    chown -R theia:theia /usr/local/go && \
    chown -R theia:theia /usr/local/go-packages

# Theia application
## Needed for node-gyp, nsfw build
RUN apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Change permissions to make the `yang-language-server` executable.
RUN chmod +x ./plugins/yangster/extension/server/bin/yang-language-server

USER theia
EXPOSE 3000
# Configure Theia
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins  \
    # Configure user Go path
    GOPATH=/home/project

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENTRYPOINT [ "node", "/home/theia/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]
