FROM java:8-jre-alpine

ARG MIRROR=http://mirror.netcologne.de/apache.org/
ENV KAFKA_VERSION=0.10.0.0 SCALA_VERSION=2.11
ENV KAFKA_HOME /opt/kafka

RUN apk update && \
    apk add bash coreutils wget && \
    mkdir /opt && \
    wget -q -O - $MIRROR/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz | tar -xzf - -C /opt && \
    mv /opt/kafka_$SCALA_VERSION-$KAFKA_VERSION $KAFKA_HOME && \
    mkdir -p /kafka && \
    apk del wget

COPY start-kafka.sh $KAFKA_HOME/start-kafka.sh

EXPOSE 9092
WORKDIR $KAFKA_HOME
CMD ["./start-kafka.sh"]
