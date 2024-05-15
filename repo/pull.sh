#!/usr/bin/env bash
#

wget https://maven-central.storage-download.googleapis.com/maven2/com/google/guava/guava/11.0.2/guava-11.0.2.jar
wget https://maven-central.storage-download.googleapis.com/maven2/org/apache/logging/log4j/log4j-to-slf4j/2.17.2/log4j-to-slf4j-2.17.2.jar
wget http://archive.cloudera.com/gplextras/misc/ext-2.2.zip
gsutil cp gs://goog-dataproc-bigtop-repo-us-central1/2_2_deb12_20240424_125600-RC01/pool/contrib/o/oozie/oozie-client_5.2.1-1_all.deb .
gsutil cp gs://goog-dataproc-bigtop-repo-us-central1/2_2_deb12_20240424_125600-RC01/pool/contrib/o/oozie/oozie_5.2.1-1_all.deb .
