FROM golang:1.3
MAINTAINER Chelsea Zhang <chelsea@bluelabs.com>

# Based on https://github.com/denibertovic/logstash-forwarder-dockerfile/blob/master/Dockerfile

RUN apt-get update

# install deps
RUN apt-get install -y wget git ruby ruby-dev build-essential && apt-get clean && gem install bundler

# clone logstash-forwarder
RUN git clone https://github.com/elasticsearch/logstash-forwarder.git /tmp/logstash-forwarder
RUN cd /tmp/logstash-forwarder && git checkout master && go build

# Build deb
RUN cd /tmp/logstash-forwarder && bundle install && make deb
RUN dpkg -i /tmp/logstash-forwarder/*.deb

# Cleanup
RUN rm -rf /tmp/*

VOLUME /conf

# We set a workdir, because state is tracked by writing .logstash-forwarder.new and renaming to .logstash-forwarder
WORKDIR /conf

CMD /opt/logstash-forwarder/bin/logstash-forwarder -quiet -config /conf/logstash-forwarder.json

# To pick up historical logs, run the previous command with the flag -from-beginning=true. However, if this flag is present and existing logs have already been indexed, they will be duplicated.
