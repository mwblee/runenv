#!/bin/bash

if [ -z $1 ]; then
        echo "Please specify a name for your run environment. E.g. rungatk.sh <username>"
        exit 0
        ENV_NAME=""
else
        ENV_NAME="--name ${1}"
fi

[ ! "$(docker volume ls | grep spark_maven)" ] && docker run -d --rm -v spark_maven:/opt bmwlee/usyd_spark_and_maven:latest
[ ! "$(docker volume ls | grep trimmomatic)" ] && docker run -d --rm -v trimmomatic:/opt/trimmomatic bmwlee/usyd_trimmomatic:latest
[ ! "$(docker volume ls | grep fastqc)" ] && docker run -d --rm -v fastqc:/opt/FastQC bmwlee/usyd_fastqc:latest
[ ! "$(docker volume ls | grep picardtools)" ] && docker run -d --rm -v picardtools:/opt/picard-tools bmwlee/usyd_picardtools:latest
[ ! "$(docker volume ls | grep samtools)" ] && docker run -d --rm -v samtools:/opt/samtools bmwlee/usyd_samtools:latest
[ ! "$(docker volume ls | grep bwa)" ] && docker run -d --rm -v bwa:/opt/bwa bmwlee/usyd_bwa:latest
[ ! "$(docker volume ls | grep gatk4)" ] && docker run -d --rm -v gatk4:/opt/gatk bmwlee/usyd_gatk4:latest
[ ! "$(docker volume ls | grep gatk3)" ] && docker run -d --rm -v gatk3:/opt/gatk bmwlee/usyd_gatk3:latest

docker run -it --rm $ENV_NAME \
	-v $PWD:/data \
	-v spark_maven:/opt \
	-v bwa:/opt/bwa \
	-v fastqc:/opt/fastqc \
	-v trimmomatic:/opt/trimmomatic \
	-v gatk3:/opt/gatk \
	-v picardtools:/opt/picard-tools \
	-v samtools:/opt/samtools \
	-v /data/hg38/hg38_broad_bundle:/opt/hg38_broad_bundle \
	-v /data/hg38/annotation/humandb:/opt/hg38_annovar \
	-v /data/annovar:/opt/annovar \
	-v /data/scripts:/usr/local/bin \
	-v /mnt/ffbigdata:/mnt/ffbigdata \
	-v /mnt/pffbigdata:/mnt/pffbigdata \
	bmwlee/usyd_runenv:latest
