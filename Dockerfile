# This docker machine is able to compile and sign Lantern for Linux and
# Windows.

FROM fedora:21
MAINTAINER "The Lantern Team" <team@getlantern.org>

ENV GO_VERSION go1.5
ENV GOROOT /usr/local/go
ENV GOPATH /

ENV PATH $PATH:$GOROOT/bin

ENV WORKDIR /lantern
ENV SECRETS /secrets

# Go binary for bootstrapping.
ENV GO_PACKAGE_URL https://storage.googleapis.com/golang/go1.5.2.linux-amd64.tar.gz

# Updating system.
RUN yum -y update && yum clean all

# Requisites for building Go.
RUN yum install -y git tar gzip curl hostname && yum clean all

# Compilers and tools for CGO.
RUN yum install -y gcc gcc-c++ libgcc.i686 gcc-c++.i686 pkg-config && yum clean all

# Getting Go.
RUN curl -sSL $GO_PACKAGE_URL | tar -xvzf - -C /usr/local

# Requisites for bootstrapping.
RUN yum install -y glibc-devel glibc-static && yum clean all
RUN yum install -y glibc-devel.i686 glib2-static.i686 glibc-2.20-8.fc21.i686 libgcc.i686 && yum clean all

# Requisites for ARM
# ARM EABI toolchain must be grabbed from an contributor repository, such as:
# https://copr.fedoraproject.org/coprs/lantw44/arm-linux-gnueabi-toolchain/
RUN yum install -y yum-utils && \
  yum-config-manager --add-repo=https://copr.fedoraproject.org/coprs/lantw44/arm-linux-gnueabi-toolchain/repo/fedora-21/lantw44-arm-linux-gnueabi-toolchain-fedora-21.repo && \
  yum install -y arm-linux-gnueabi-gcc arm-linux-gnueabi-binutils arm-linux-gnueabi-glibc && \
  yum clean all

# Requisites for windows.
RUN yum install -y mingw32-gcc.x86_64 && yum clean all

# Requisites for building Lantern on Linux.
RUN yum install -y gtk3-devel libappindicator-gtk3 libappindicator-gtk3-devel && yum clean all
RUN yum install -y pango.i686 pango-devel.i686 gtk3-devel.i686 gdk-pixbuf2-devel.i686 cairo-gobject-devel.i686 \
  atk-devel.i686 libappindicator-gtk3-devel.i686 libdbusmenu-devel.i686 dbus-devel.i686 pkgconfig.i686 && \
  yum clean all

# Requisites for packing Lantern for Debian.
# The fpm packer. (https://rubygems.org/gems/fpm)
RUN yum install -y ruby ruby-devel make && yum clean all
RUN gem install fpm

# Requisites for packing Lantern for Windows.
RUN yum install -y osslsigncode mingw32-nsis && yum clean all

# Required for compressing update files
RUN yum install -y bzip2 && yum clean all

# Requisites for genassets.
RUN yum install -y nodejs npm && yum clean all
RUN npm install -g gulp

RUN mkdir -p $WORKDIR
RUN mkdir -p $SECRETS

# Expect the $WORKDIR volume to be mounted.
VOLUME [ "$WORKDIR" ]

WORKDIR $WORKDIR
