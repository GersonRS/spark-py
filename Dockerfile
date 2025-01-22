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
# RUN curl -L -O http://search.maven.org/remotecontent?filepath=org/apache/ivy/ivy/2.3.0/ivy-2.3.0.jar
# RUN java -jar ivy-2.3.0.jar -dependency org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.7.1 -retrieve "lib/[artifact]-[revision](-[classifier]).[ext]"
RUN $SPARK_HOME/bin/spark-submit \
  --class "org.apache.spark.examples.SparkPi" \
  --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.7.1,org.apache.hadoop:hadoop-aws:3.4.1,org.apache.hadoop:hadoop-common:3.4.1 \
  --deploy-mode client \
  $SPARK_HOME/examples/jars/spark-examples_2.12-3.5.4.jar

# # Add the connector jar needed to access Google Cloud Storage using the Hadoop FileSystem API.
# ADD https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.431/aws-java-sdk-bundle-1.12.431.jar $SPARK_HOME/jars/aws-java-sdk-bundle-1.12.431.jar
# RUN chmod 644 $SPARK_HOME/jars/aws-java-sdk-bundle-1.12.431.jar
# ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.3.4/hadoop-common-3.3.4.jar $SPARK_HOME/jars/hadoop-common-3.3.4.jar
# RUN chmod 644 $SPARK_HOME/jars/hadoop-common-3.3.4.jar
# ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar $SPARK_HOME/jars/hadoop-aws-3.3.4.jar
# RUN chmod 644 $SPARK_HOME/jars/hadoop-aws-3.3.4.jar

# # Add iceberg connector jar needed to use Iceberg lakehouse format
# ADD https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.4_2.12/1.6.0/iceberg-spark-runtime-3.4_2.12-1.6.0.jar $SPARK_HOME/jars
# RUN chmod 644 $SPARK_HOME/jars/iceberg-spark-runtime-3.4_2.12-1.6.0.jar

# Setup for the Prometheus JMX exporter.
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar /prometheus/
RUN chmod 644 /prometheus/jmx_prometheus_javaagent-0.11.0.jar

RUN mkdir -p /etc/metrics/conf
COPY conf/metrics.properties /etc/metrics/conf
COPY conf/prometheus.yaml /etc/metrics/conf

RUN cp /root/.ivy2/jars/* $SPARK_HOME/jars/
RUN chmod -R 644 $SPARK_HOME/jars
RUN chown -R spark:spark $SPARK_HOME/jars
RUN rm -R /root/.ivy2/jars/

ENTRYPOINT ["/opt/entrypoint.sh"]
