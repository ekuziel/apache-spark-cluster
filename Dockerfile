# =============================================================================
# Apache Spark 4.0.2 + Gluten 1.6.0 (Velox backend)
# Scala 2.13 | Java 17 | Ubuntu 22.04
#
# Gluten JAR source (official Apache binary release):
# https://dlcdn.apache.org/gluten/1.6.0/apache-gluten-1.6.0-bin-spark-4.0.tar.gz
# Contains: gluten-velox-bundle-spark4.0_2.13-linux_amd64-1.6.0.jar
# =============================================================================

FROM spark:4.0.2-scala2.13-java17-python3-ubuntu

ARG GLUTEN_VERSION=1.6.0
ARG HUDI_VERSION=1.1.1

ENV SPARK_VERSION=4.0.2
ENV GLUTEN_VERSION=${GLUTEN_VERSION}
ENV HUDI_VERSION=${HUDI_VERSION}
ENV SPARK_LOG_DIR=/opt/spark/logs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# Use Spark image's built-in PySpark — do NOT install pyspark via pip.
# Installing pyspark pip package duplicates JARs and causes NoSuchMethodError
# when the pip JARs conflict with /opt/spark/jars/ (e.g. Gluten).
ENV PYTHONPATH=/opt/spark/python:/opt/spark/python/lib/py4j-src.zip:${PYTHONPATH}

USER root

# Set pipefail so pipes fail fast (hadolint DL4006)
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ---------------------------------------------------------------------------
# System tools
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Python packages
# ---------------------------------------------------------------------------
# CORE (Spark + Python)
RUN pip3 install --no-cache-dir \
    py4j \
    pandas \
    pyarrow \
    numpy \
    matplotlib \
    seaborn \
    "grpcio>=1.48.1" \
    "grpcio-status>=1.48.1"

# SPARK SPECIFIC
RUN pip3 install --no-cache-dir --no-deps \
    delta-spark==4.0.1

# JUPYTER + EXTENSIONS
RUN pip3 install --no-cache-dir \
    jupyterlab \
    ipywidgets \
    tqdm \
    plotly \
    itables \
    jupysql \
    duckdb \
    nbdime \
    nbstripout \
    black \
    ruff

# ---------------------------------------------------------------------------
# Iceberg + Delta + Avro + Hudi + Kafka connector JARs (Spark 4.0 / Scala 2.13)
# ---------------------------------------------------------------------------
RUN curl -fsSL \
    "https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-4.0_2.13/1.10.1/iceberg-spark-runtime-4.0_2.13-1.10.1.jar" \
    -o "${SPARK_HOME}/jars/iceberg-spark-runtime-4.0_2.13-1.10.1.jar" \
 && curl -fsSL \
    "https://repo1.maven.org/maven2/io/delta/delta-spark_2.13/4.0.1/delta-spark_2.13-4.0.1.jar" \
    -o "${SPARK_HOME}/jars/delta-spark_2.13-4.0.1.jar" \
 && curl -fsSL \
    "https://repo1.maven.org/maven2/io/delta/delta-storage/4.0.1/delta-storage-4.0.1.jar" \
    -o "${SPARK_HOME}/jars/delta-storage-4.0.1.jar" \
 && curl -fsSL \
    "https://repo1.maven.org/maven2/org/apache/spark/spark-avro_2.13/4.0.2/spark-avro_2.13-4.0.2.jar" \
    -o "${SPARK_HOME}/jars/spark-avro_2.13-4.0.2.jar" \
 && curl -fsSL \
    "https://repo1.maven.org/maven2/org/apache/spark/spark-sql-kafka-0-10_2.13/4.0.2/spark-sql-kafka-0-10_2.13-4.0.2.jar" \
    -o "${SPARK_HOME}/jars/spark-sql-kafka-0-10_2.13-4.0.2.jar" \
 && curl -fsSL \
    "https://repo1.maven.org/maven2/org/apache/spark/spark-token-provider-kafka-0-10_2.13/4.0.2/spark-token-provider-kafka-0-10_2.13-4.0.2.jar" \
    -o "${SPARK_HOME}/jars/spark-token-provider-kafka-0-10_2.13-4.0.2.jar" \
 && curl -fsSL \
    "https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.9.1/kafka-clients-3.9.1.jar" \
    -o "${SPARK_HOME}/jars/kafka-clients-3.9.1.jar" \
 && curl -fsSL \
    "https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.12.0/commons-pool2-2.12.0.jar" \
    -o "${SPARK_HOME}/jars/commons-pool2-2.12.0.jar" \
 && curl -fsSL \
    "https://repo1.maven.org/maven2/org/apache/hudi/hudi-spark4.0-bundle_2.13/${HUDI_VERSION}/hudi-spark4.0-bundle_2.13-${HUDI_VERSION}.jar" \
    -o "${SPARK_HOME}/jars/hudi-spark4.0-bundle_2.13-${HUDI_VERSION}.jar"

# ---------------------------------------------------------------------------
# Gluten/Velox JAR — extracted from official Apache binary tarball
# ---------------------------------------------------------------------------
RUN set -eux; \
    curl -fL \
      "https://dlcdn.apache.org/gluten/${GLUTEN_VERSION}/apache-gluten-${GLUTEN_VERSION}-bin-spark-4.0.tar.gz" \
      -o /tmp/gluten.tar.gz; \
    tar -xzf /tmp/gluten.tar.gz -C /tmp; \
    GLUTEN_JAR="$(find /tmp -type f -name 'gluten-velox-bundle-spark4.0_2.13-linux_amd64-*.jar' | head -1)"; \
    echo "Found Gluten JAR: ${GLUTEN_JAR}"; \
    test -n "${GLUTEN_JAR}"; \
    cp "${GLUTEN_JAR}" "${SPARK_HOME}/jars/gluten.jar"; \
    ls -lah "${SPARK_HOME}/jars/gluten.jar"; \
    rm -rf /tmp/gluten.tar.gz /tmp/apache-gluten-*

# ---------------------------------------------------------------------------
# Workspace + log directories
# ---------------------------------------------------------------------------
RUN mkdir -p /workspace/data /workspace/notebooks "${SPARK_LOG_DIR}"

# ---------------------------------------------------------------------------
# Config + entrypoint
# ---------------------------------------------------------------------------
COPY conf/spark-defaults.conf "${SPARK_HOME}/conf/spark-defaults.conf"
COPY conf/log4j2.properties   "${SPARK_HOME}/conf/log4j2.properties"
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r//' /entrypoint.sh && chmod +x /entrypoint.sh

WORKDIR /workspace
EXPOSE 8080 7077 4040 8888 18080 8081

ENTRYPOINT ["/entrypoint.sh"]
