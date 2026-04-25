# syntax=docker/dockerfile:1.5
# =============================================================================
# Apache Kafka 3.9.1 — KRaft single-node broker
# Scala 2.13 | Java 17 | Ubuntu 22.04
#
# Spark side uses:
#   org.apache.spark:spark-sql-kafka-0-10_2.13:4.0.2
#   org.apache.spark:spark-token-provider-kafka-0-10_2.13:4.0.2
#
# Broker compatibility note:
# Spark Structured Streaming Kafka integration supports Kafka brokers 0.10+.
# Kafka 3.9.1 / Scala 2.13 is used here to keep a modern Java 17-compatible
# broker aligned with the Scala 2.13 Spark stack.
# =============================================================================

FROM eclipse-temurin:17-jre-jammy

ARG KAFKA_VERSION=3.9.1
ARG SCALA_VERSION=2.13

ENV KAFKA_VERSION=${KAFKA_VERSION} \
    SCALA_VERSION=${SCALA_VERSION} \
    KAFKA_HOME=/opt/kafka \
    PATH=/opt/kafka/bin:${PATH}

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
 && apt-get install -y --no-install-recommends bash curl ca-certificates procps netcat-openbsd \
 && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    curl -fsSL "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" -o /tmp/kafka.tgz; \
    mkdir -p /opt; \
    tar -xzf /tmp/kafka.tgz -C /opt; \
    mv "/opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}" "${KAFKA_HOME}"; \
    rm -f /tmp/kafka.tgz; \
    mkdir -p /var/lib/kafka/data

RUN cat > /usr/local/bin/start-kafka.sh <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

: "${KAFKA_NODE_ID:=1}"
: "${KAFKA_PROCESS_ROLES:=broker,controller}"
: "${KAFKA_CONTROLLER_QUORUM_VOTERS:=1@kafka:9093}"
: "${KAFKA_LISTENERS:=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093,PLAINTEXT_HOST://0.0.0.0:9094}"
: "${KAFKA_ADVERTISED_LISTENERS:=PLAINTEXT://kafka:9092,PLAINTEXT_HOST://localhost:9094}"
: "${KAFKA_LISTENER_SECURITY_PROTOCOL_MAP:=PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT}"
: "${KAFKA_CONTROLLER_LISTENER_NAMES:=CONTROLLER}"
: "${KAFKA_INTER_BROKER_LISTENER_NAME:=PLAINTEXT}"
: "${KAFKA_LOG_DIRS:=/var/lib/kafka/data}"
: "${KAFKA_AUTO_CREATE_TOPICS_ENABLE:=true}"
: "${KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR:=1}"
: "${KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR:=1}"
: "${KAFKA_TRANSACTION_STATE_LOG_MIN_ISR:=1}"
: "${KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS:=0}"
: "${KAFKA_NUM_PARTITIONS:=3}"

CONFIG_FILE="${KAFKA_HOME}/config/kraft/server.properties"
mkdir -p "${KAFKA_LOG_DIRS}" "$(dirname "${CONFIG_FILE}")"

cat > "${CONFIG_FILE}" <<CONFIG
node.id=${KAFKA_NODE_ID}
process.roles=${KAFKA_PROCESS_ROLES}
controller.quorum.voters=${KAFKA_CONTROLLER_QUORUM_VOTERS}
listeners=${KAFKA_LISTENERS}
advertised.listeners=${KAFKA_ADVERTISED_LISTENERS}
listener.security.protocol.map=${KAFKA_LISTENER_SECURITY_PROTOCOL_MAP}
controller.listener.names=${KAFKA_CONTROLLER_LISTENER_NAMES}
inter.broker.listener.name=${KAFKA_INTER_BROKER_LISTENER_NAME}
log.dirs=${KAFKA_LOG_DIRS}
auto.create.topics.enable=${KAFKA_AUTO_CREATE_TOPICS_ENABLE}
offsets.topic.replication.factor=${KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR}
transaction.state.log.replication.factor=${KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR}
transaction.state.log.min.isr=${KAFKA_TRANSACTION_STATE_LOG_MIN_ISR}
group.initial.rebalance.delay.ms=${KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS}
num.partitions=${KAFKA_NUM_PARTITIONS}
CONFIG

if [[ ! -f "${KAFKA_LOG_DIRS}/meta.properties" ]]; then
  CLUSTER_ID="$(kafka-storage.sh random-uuid)"
  kafka-storage.sh format --ignore-formatted --cluster-id "${CLUSTER_ID}" --config "${CONFIG_FILE}"
fi

exec kafka-server-start.sh "${CONFIG_FILE}"
SCRIPT

RUN chmod +x /usr/local/bin/start-kafka.sh

EXPOSE 9092 9093 9094
VOLUME ["/var/lib/kafka/data"]

ENTRYPOINT ["/usr/local/bin/start-kafka.sh"]
