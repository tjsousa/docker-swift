FROM armv7/armhf-ubuntu
MAINTAINER Tiago Sousa (tiago.joao@gmail.com)

# Install related packages and set LLVM 3.6 as the compiler
RUN apt-get -q update && \
    apt-get -q install -y \
    git \
    cmake \
    ninja-build \
    clang \
    uuid-dev \
    libicu-dev \
    icu-devtools \
    libbsd-dev \
    libedit-dev \
    libxml2-dev \
    libsqlite3-dev \
    swig \
    libpython-dev \
    libncurses5-dev \
    pkg-config \
    && rm -r /var/lib/apt/lists/*

# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little
ENV SWIFT_BUILD="$(mktemp -d)" \
    SWIFT_INSTALL=~/swift \
    PATH=/usr/bin:$PATH

# Download GPG keys, signature and Swift package, then unpack and cleanup
RUN git clone https://github.com/iachievedit/package-swift.git \
    && cd package-swift \
    && sh get.sh \
    && sh package.sh $SWIFT_BUILD | tee $SWIFT_BUILD/build-log.txt \
    && cd $SWIFT_BUILD/utils \
    && sh build-script --preset=buildbot_linux_armv7 install_destdir=$SWIFT_INSTALL/Swift-3.0-ARM/install installable_package=$SWIFT_INSTALL/Swift-3.0-ARM/swift.tar.gz | tee $SWIFT_BUILD/build-log.txt

# Print Installed Swift Version
RUN swift --version
