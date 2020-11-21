FROM registry.digitalocean.com/watheia/theia-server:common

# Comment any of these out to remove language support
FROM registry.digitalocean.com/watheia/theia-server:dart
FROM registry.digitalocean.com/watheia/theia-server:dotnet
FROM registry.digitalocean.com/watheia/theia-server:php
FROM registry.digitalocean.com/watheia/theia-server:python
FROM registry.digitalocean.com/watheia/theia-server:ruby
FROM registry.digitalocean.com/watheia/theia-server:swift

ARG GITHUB_TOKEN

WORKDIR /home/theia

ADD package.json ./package.json
ADD lerna.json ./lerna.json
ADD yarn.lock ./yarn.lock
ADD theia-auth-extension/package.json ./theia-auth-extension/package.json
ADD theia-auth-extension/tsconfig.json ./theia-auth-extension/tsconfig.json
ADD theia-auth-extension/src/ ./theia-auth-extension/src/
ADD browser-app/package.json ./browser-app/package.json

RUN NODE_OPTIONS="--max_old_space_size=4096" yarn

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
RUN chmod +x ./browser-app/plugins/yangster/extension/server/bin/yang-language-server

USER theia
EXPOSE 3000

# Configure Theia
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/browser-app/plugins  \
    # Configure user Go path
    GOPATH=/home/project

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENTRYPOINT [ "node", "/home/theia/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]
