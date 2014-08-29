FROM ubuntu:14.04
MAINTAINER Chelsea Zhang <chelsea@bluelabs.com>

# Based on https://github.com/denibertovic/logstash-forwarder-dockerfile/blob/master/Dockerfile

RUN apt-get update

# install deps
RUN apt-get install -y wget git golang ruby ruby-dev build-essential && apt-get clean

# clone logstash-forwarder
RUN git clone git://github.com/elasticsearch/logstash-forwarder.git /tmp/logstash-forwarder
RUN cd /tmp/logstash-forwarder && git checkout v0.3.1 && go build

# Install fpm
RUN gem install fpm

# Build deb
RUN cd /tmp/logstash-forwarder && make deb
RUN dpkg -i /tmp/logstash-forwarder/*.deb

# Cleanup
RUN rm -rf /tmp/*

VOLUME /conf

CMD /opt/lumberjack/bin/lumberjack -config /conf/logstash-forwarder.json

# To pick up historical logs, run the previous command with the flag -from-beginning=true. However, if this flag is present and existing logs have already been indexed, they will be duplicated.