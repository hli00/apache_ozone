FROM trino:latest

USER root

#COPY ./trino_hive_jars/aws-java-sdk-bundle-1.11.1026.jar /usr/lib/trino/plugin/hive/
#COPY ./trino_hive_jars/hadoop-aws-3.3.1.jar /usr/lib/trino/plugin/hive/
#COPY ./trino_hive_jars/aws-java-sdk-bundle-1.11.1026.jar /usr/lib/trino/lib/
COPY ./trino_ozone_jars/ozone-filesystem-hadoop3-client-1.4.0.7.3.1.100-SNAPSHOT.jar /usr/lib/trino/plugin/iceberg/hdfs/

#RUN chown -R trino:trino /usr/lib/trino/plugin/hive/aws-java-sdk-bundle-1.11.1026.jar /usr/lib/trino/plugin/hive/hadoop-aws-3.3.1.jar

USER trino

#Command to build the image: docker build -t trino-iceberg-ofs:latest .