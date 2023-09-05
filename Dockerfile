FROM debian:bookworm as builder

RUN apt-get update -q
RUN apt-get install -y build-essential automake libgensio-dev libyaml-dev libtool

COPY ser2net /usr/src/ser2net
WORKDIR /usr/src/ser2net

RUN ./reconf
RUN ./configure --prefix=/opt/ser2net --sysconfdir=/etc --sbindir=/opt/ser2net/bin
RUN make
RUN make install

FROM debian:bookworm

ENV PATH=/opt/ser2net/bin:$PATH
# directory for configuration
RUN mkdir /ser2net

RUN apt-get update -q && \
  apt-get install --no-install-recommends --yes libgensio4 libyaml-0-2 && \
  rm -rf /var/lib/apt/lists/*
COPY --from=builder /opt/ser2net /opt/ser2net