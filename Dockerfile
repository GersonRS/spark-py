#
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# FROM maven:3.9.9

# RUN mvn dependency:copy-dependencies -DoutputDirectory="/home" -DexcludeTransitive=true -Dartifact=org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.7.1

FROM spark:3.5.4-scala2.12-java17-python3-ubuntu

# Switch to user root so we can add additional jars and configuration files.
USER root
# USER ${spark_uid}
WORKDIR $SPARK_HOME/jars

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

ENTRYPOINT ["/opt/entrypoint.sh"]
