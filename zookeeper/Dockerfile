FROM java:8-jre-alpine

ARG MIRROR=http://mirror.netcologne.de/apache.org/
ENV ZOOKEEPER_VERSION 3.4.8

RUN apk update && \
    apk add bash wget && \
    mkdir /opt && \
    wget -q -O - $MIRROR/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xzf - -C /opt && \
    mv /opt/zookeeper-$ZOOKEEPER_VERSION /opt/zookeeper && \
    mkdir -p /zookeeper && \
    apk del wget

COPY zoo.cfg /opt/zookeeper/conf/zoo.cfg

EXPOSE 2181
CMD ["/opt/zookeeper/bin/zkServer.sh", "start-foreground"]
