FROM golang:1.15-alpine as builder

RUN apk add --no-cache \
  git \
  ca-certificates

ENV XCADDY_VERSION v0.1.5
# Configures xcaddy to build with this version of Caddy
ENV CADDY_VERSION v2.2.1
# Configures xcaddy to not clean up post-build (unnecessary in a container)
ENV XCADDY_SKIP_CLEANUP 1

RUN set -eux; \
  apkArch="$(apk --print-arch)"; \
  case "$apkArch" in \
  x86_64)  binArch='amd64'; checksum='3d71e90a4b4f3ebc55d79086d5fb4e36d675fd067435b0a2e37f50361e89ceb58a4b8eae43ea502d1b6d1522c3020f1791ffad9a9fbd374883c6202cf9ed67f7' ;; \
  armhf)   binArch='armv6'; checksum='243f58f32bba0b6295267ba78ed18c1b36dfd3c8af4ddbe1f8e1fe096a58cb3326d795b19ce06d87b8641fc17d6e8f1fd2ee372af7dca8c844544768cd05c418' ;; \
  armv7)   binArch='armv7'; checksum='51c212b44bf21e3d9feb841cb91c93289f5244d7276a7ce4b1eea73121855345190de77f4a87a3e4e1a93cccf6085133b8552de48687c2164277c0766d3404f0' ;; \
  aarch64) binArch='arm64'; checksum='13c3184699c20734a5718cad3e4ee8fed52df1eca21d0d3fa5d34a671990bfd1fae23824c7618c0cba1ceac6262b3225f85cbb37cd9c162935c2c367c623e1ea' ;; \
  ppc64el|ppc64le) binArch='ppc64le'; checksum='faf068bb6b6086881504699fb92f77f628e36297eda3651021fea40a06a2fa043453a729000d460e530b2772420071b65fdd3915abfdd4d47dbf820e3590393d' ;; \
  s390x)   binArch='s390x'; checksum='79527340291d9e2196079c87daabe6fed5f5e354dc3a4a37e59c684aeed910376b472e4d8969c3ae957f1af35272d46e669fa111fcb47bb90a0822aa039970ea' ;; \
  *) echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;;\
  esac; \
  wget -O /tmp/xcaddy.tar.gz "https://github.com/caddyserver/xcaddy/releases/download/v0.1.5/xcaddy_0.1.5_linux_${binArch}.tar.gz"; \
  echo "$checksum  /tmp/xcaddy.tar.gz" | sha512sum -c; \
  tar x -z -f /tmp/xcaddy.tar.gz -C /usr/bin xcaddy; \
  rm -f /tmp/xcaddy.tar.gz; \
  chmod +x /usr/bin/xcaddy;


RUN xcaddy build \
  --with github.com/greenpau/caddy-auth-portal \
  --with github.com/greenpau/caddy-auth-jwt \
  --with github.com/greenpau/caddy-trace && \
  mv caddy /usr/bin && \
  chmod +x /usr/bin/caddy

FROM alpine

ADD etc /etc
COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN apk update; apk upgrade; apk add --no-cache ca-certificates mailcap curl;

RUN set -eux; \
  mkdir -p \
  /var/caddy/config \
  /var/caddy/data \
  /var/www/html \
  /etc/gatekeeper/auth;

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/docker-library/golang/blob/1eb096131592bcbc90aa3b97471811c798a93573/1.14/alpine3.12/Dockerfile#L9
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

# Generate key for signing JWT tokens
RUN openssl genrsa -out /etc/gatekeeper/auth/sign_key.pem 2048

# See https://caddyserver.com/docs/conventions#file-locations for details
ENV XDG_CONFIG_HOME /var/caddy/config
ENV XDG_DATA_HOME /var/caddy/data
ENV GK_ACME_CA "https://acme-staging-v02.api.letsencrypt.org/directory"
ENV GK_ACME_EMAIL "theia-server.local"
ENV GK_SITE "127.0.0.1, theia-server.local"
ENV GK_GOOG_CLIENT_ID "***********-********************************.apps.googleusercontent.com"
ENV GK_GOOG_CLIENT_SECRET "*******-************"

VOLUME /var/caddy/config
VOLUME /var/caddy/data
VOLUME /var/www/html

EXPOSE 80
EXPOSE 443



CMD [ "caddy", "run", "--config", "/etc/caddy/Caddyfile" ]

