FROM ubuntu:latest

ENV PATH="/opt/fastqc:/opt/trimmomatic/:/opt/bwa:/opt/samtools/bin:/opt/picard-tools:/opt/gatk:/opt/apache-spark/bin:/opt/apache-maven-3.5.2/bin:/opt/annovar:${PATH}"
RUN apt-get update && apt-get install -y zip vim-nox pigz rsync wget nano openjdk-8-jre

RUN mkdir -p /data
RUN mkdir -p /opt/hg38_broad_bundle
RUN mkdir -p /opt/hg38_annovar

#COPY /data/hg38/hg38_broad_bundle /opt/hg38_broad_bundle
#COPY /data/hg38/annotation/humandb /opt/hg38_annovar
COPY annovar /opt/annovar
COPY scripts /usr/local/bin
COPY wrapper.sh /home

WORKDIR /data

