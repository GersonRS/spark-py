FROM spark:3.5.4-scala2.12-java17-python3-ubuntu

WORKDIR $SPARK_HOME/jars

USER ${spark_uid}

# Baixe as dependências usando o iceberg-spark-runtime
RUN java -jar ivy-2.5.1.jar -dependency org.apache.iceberg iceberg-spark-runtime-3.5_2.12 1.7.1 \
  -retrieve "./[artifact]-[revision](-[classifier]).[ext]" -types "jar"
# Baixe as dependências usando o hadoop-aws
RUN java -jar ivy-2.5.1.jar -dependency org.apache.hadoop hadoop-aws 3.4.1 \
  -retrieve "./[artifact]-[revision](-[classifier]).[ext]" -types "jar"
# Baixe as dependências usando o hadoop-common
RUN java -jar ivy-2.5.1.jar -dependency org.apache.hadoop hadoop-common 3.4.1 \
  -retrieve "./[artifact]-[revision](-[classifier]).[ext]" -types "jar"

# Setup for the Prometheus JMX exporter.
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar /prometheus/
RUN chmod 644 /prometheus/jmx_prometheus_javaagent-0.11.0.jar

RUN mkdir -p /etc/metrics/conf
COPY conf/metrics.properties /etc/metrics/conf
COPY conf/prometheus.yaml /etc/metrics/conf

RUN chown -R spark:spark $SPARK_HOME/jars

WORKDIR $SPARK_HOME/work-dir

ENTRYPOINT ["/opt/entrypoint.sh"]
