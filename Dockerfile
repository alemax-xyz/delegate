FROM library/ubuntu:bionic AS build

ENV LANG C.UTF-8

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y \
        software-properties-common \
        apt-utils
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y \
        wget

RUN mkdir -p /build/image
WORKDIR /build
RUN wget -nv http://delegate.hpcc.jp/anonftp/DeleGate/bin/linux/9.9.13/linux2.6-dg9_9_13.tar.gz && \
    tar -xvf linux2.6-dg9_9_13.tar.gz
RUN apt-get download \
        libstdc++6 \
        zlib1g \
        libssl1.0.0
RUN for file in *.deb; do dpkg-deb -x ${file} image/; done

WORKDIR /build/image
RUN rm -rf \
        usr/sbin \
        usr/share/man \
        usr/share/gdb \
        usr/share/gcc-5 \
        usr/share/doc \
 && mkdir -p \
        usr/bin \
        var/lib/delegate \
        var/spool/delegate \
        var/run/delegate \
        var/cache/delegate \
        var/log/delegate \
        etc/delegate \
 && cp ../dg9_9_13/DGROOT/bin/dg9_9_13 usr/bin/delegated \
 && touch etc/delegate.conf

COPY init/ etc/init/


FROM clover/common

ENV DGROOT /var/lib/delegate
ENV VARDIR /var/spool/delegate
ENV CACHEDIR /var/cache/delegate
ENV ETCDIR /etc/delegate
ENV LOGDIR /var/log/delegate
ENV ACTDIR /var/spool/act
ENV TMPDIR /tmp
ENV PIDDIR /var/run/delegate
ENV OWNER root/root

WORKDIR /

COPY --from=build /build/image /
