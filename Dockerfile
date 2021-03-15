FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

ENV SSL_VERSION=1.1.1j
ENV OTP_VERSION=OTP-23.1.4
ENV ELIXIR_VERSION=v1.11.3

RUN apt-get update && apt-get install -y vim git curl locate wget apt-transport-https apt-utils locales
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN echo "en_US UTF-8" >> /etc/locale.gen && locale-gen

WORKDIR "/root"

RUN apt-get update && apt-get install -y build-essential autoconf libncurses-dev m4 xsltproc libxml2-utils unixodbc-dev
RUN apt-get update && apt-get install -y --no-install-recommends libwxgtk3.0-gtk3-dev
RUN apt-get install -y zstd

RUN curl https://www.openssl.org/source/openssl-$SSL_VERSION.tar.gz -O && \
    tar -xzf openssl-$SSL_VERSION.tar.gz && \
    cd openssl-$SSL_VERSION && ./config && make depend && make && \
    mkdir -p /root/openssl-$SSL_VERSION/lib && \
    cp -r /root/openssl-$SSL_VERSION/libc* /root/openssl-$SSL_VERSION/lib/ && \
    cp -r /root/openssl-$SSL_VERSION/libs* /root/openssl-$SSL_VERSION/lib/

RUN mkdir -p /root/source && \
    git clone https://github.com/erlang/otp /root/source/otp && \
    cd /root/source/otp && \
    git checkout $OTP_VERSION
RUN cd /root/source/otp && \
    ./otp_build autoconf && ./configure --with-ssl=/root/openssl-$SSL_VERSION --disable-dynamic-ssl-lib && make -j4 && make install

RUN mkdir -p /root/source && \
    git clone https://github.com/elixir-lang/elixir.git /root/source/elixir && \
    cd /root/source/elixir && \
    git checkout $ELIXIR_VERSION && \
    make clean && make install && \
    mix local.hex --force && mix local.rebar --force

CMD ["/bin/bash"]
