FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl vim pigz rsync wget nano openjdk-8-jre git bzip2 zlib1g-dev libbz2-dev liblzma-dev libcurl4-openssl-dev python2.7 python-pip time parallel

RUN mkdir -p /data
RUN mkdir -p /opt/hg38_broad_bundle
RUN mkdir -p /opt/hg38_annovar
RUN mkdir -p /opt/Bismark
RUN mkdir -p /opt/ngsutils

WORKDIR /opt/ngsutils
RUN git clone https://github.com/FelixKrueger/Bismark.git /opt/Bismark
RUN git clone https://github.com/ngsutils/ngsutils.git /opt/ngsutils && make
#COPY /data/hg38/hg38_broad_bundle /opt/hg38_broad_bundle
#COPY /data/hg38/annotation/humandb /opt/hg38_annovar
COPY annovar /opt/annovar
COPY scripts /usr/local/bin

#install for python3
#RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
#    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.4.10-Linux-x86_64.sh -O ~/miniconda.sh && \
#    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
#    rm ~/miniconda.sh && \
#    /opt/conda/bin/conda clean -tipsy

ENV PATH="/data:/opt/bowtie:/opt/conda/bin:/opt/ngsutils/bin:/opt/Bismark:/opt/fastqc:/opt/trimmomatic/:/opt/bwa:/opt/samtools/bin:/opt/picard-tools:/opt/gatk:/opt/apache-spark/bin:/opt/annovar:/opt/vcftools:${PATH}"

WORKDIR /data
