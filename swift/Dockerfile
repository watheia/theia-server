FROM registry.digitalocean.com/watheia/theia-server:common

# Swift
ARG SWIFT_VERSION=5.2.4

RUN apt-get update \
    && apt-get install -y binutils libc6-dev libcurl4 libedit2 libgcc-5-dev libpython2.7 libsqlite3-0 libstdc++-5-dev libxml2 pkg-config tzdata zlib1g-dev \
    && curl -SLO https://swift.org/builds/swift-$SWIFT_VERSION-release/ubuntu1804/swift-$SWIFT_VERSION-RELEASE/swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz \
    && curl -SLO https://swift.org/builds/swift-$SWIFT_VERSION-release/ubuntu1804/swift-$SWIFT_VERSION-RELEASE/swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz.sig \
    && wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import - \
    && (    gpg --keyserver pool.sks-keyservers.net --refresh-keys Swift \
    || gpg --keyserver ipv4.pool.sks-keyservers.net --refresh-keys Swift \
    || gpg --keyserver pool.sks-keyservers.net --refresh-keys Swift \
    || gpg --keyserver pgp.mit.edu --refresh-keys Swift \
    || gpg --keyserver keyserver.pgp.com --refresh-keys Swift \
    || gpg --keyserver ha.pool.sks-keyservers.net --refresh-keys Swift \
    ) \
    && gpg --verify swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz.sig \
    && tar fxz swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz \
    && rm swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz swift-$SWIFT_VERSION-RELEASE-ubuntu18.04.tar.gz.sig \
    && mv swift-$SWIFT_VERSION-RELEASE-ubuntu18.04 /usr/local/swift \
    && ln -s /usr/local/swift/usr/bin/swift* /usr/bin \
    && ln -s /usr/local/swift/usr/bin/lldb* /usr/bin \
    && ln -s /usr/local/swift/usr/bin/sourcekit-lsp /usr/bin

