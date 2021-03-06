#!/bin/bash

TRANSFERQUEUE="dtq"
RSYNC=/usr/bin/rsync
RSYNCFLAGS="-avx --no-o --no-g"

# Note that rsync always verifies that each transferred  file  was
# correctly  reconstructed  on  the  receiving  side by checking a
# whole-file checksum that is generated  as  the  file  is  trans-
# ferred. The rsync --checksum option is a method whereby the files
# choosen to be transfered are judged by checksum differences on
# the receiving and sending end.

#default walltime for transfer job.
SKIPREADTEST=""
CWALLTIME="72:00:00"
WALLTIME="200:00:00"
CMEM="16gb"
CNCPUS="2"
DEPEND="afterok"
DEPENDANY="afterany"
PROJECT="FFbigdata"
#PROJECT="FFgenomics"
NAME="pjob"
QSUBEXTRAFLAGS=""
KEEPFQ=""

MEM="64gb"
NCPUS="6"


function usage {
cat << _HERE
usage $1 --from|-f <source> --to|-t <dest> --job|-j <folderlist> options
from, to and project must be specified.
where options are:
--project|-P <project> = project for PBS submission
--from|-f <path> = the source of the data
--to|-t <path> = the destination of temporary process space
--output|-o <path> = the destination of results
--plimit|-p <int eg. 1, 2, 3, etc> = the limit of parallel job to run concurrently
--job|-j <file containing list of folder/file name> = the list of folder/file names to run gatk from the source(--from|-f).
--keepfq|-kfq <path> = the destination of fq files

--skip|-notest - skip testing of readable source. Useful if called from a node and /rds is the source which is not available on the calling node.

--walltime|-w <walltime> (default $WALLTIME)
--ncpus|-ncpus <ncpus> (default $NCPUS)
--mem|-m <mem> (default $MEM)

-N|-n|--name <name> = set the copyjob name. (default "pjob");

--rflags|-rf <rsync extra flags> - any extra rsync flags you may require.


_HERE

exit 0
}


while [ $# -gt 0 ]
do
	case $1 in
	--help | -h)
		usage $0
		shift
		;;
	--skip | -notest)
		shift
		SKIPREADTEST="yes"
		;;
	--log | -l)
		shift
		LOG="$1"
		shift
		;;
	--name | -n | -N)
		shift
		NAME="$1"
		shift
		;;
	--from | -f)
		shift
		from="$1"
		shift
		;;
	--to | -t)
		shift
		to="$1"
		shift
		;;
	--output | -o)
		shift
		RESULTS="$1"
		shift
		;;
	--keepfq | -kfq)
		shift
		KEEPFQ="$1"
		shift
		;;

	--rflags | -rf)
		shift
		rsyncflags="$1"
		shift
		;;
	--qflags | -qf)
		shift
		QSUBEXTRAFLAGS="$1"
		shift
		;;
	--job | -j)
		shift
		job="$1"
		shift
		;;
	--plimit | -p)
		shift
		PLIMIT="$1"
		shift
		;;
	--depend | -d)
		shift
		DEPEND="$1"
		shift
		;;
	--walltime | -w)
		shift
		WALLTIME="$1"
		shift
		;;
	--project | -P)
		shift
		PROJECT="$1"
		shift
		;;
	--mem | -m)
		shift
		MEM="$1"
		shift
		;;
	--ncpus | -ncpus)
		shift
		NCPUS="$1"
		shift
		;;
	*)
		echo Unknown arg $1
		usage $0
		exit 1
		break
		;;
	esac
done


function checkjobflags {
	# Check if there's a -I - interactive makes no sense in this context.
	iflag=$(echo $1 | egrep -w -e -I)
	if [ ! -z "$iflag" ]
	then
		echo "Interactive flag -I makes no sense in this context"
		exit 1
	fi
}
function checkpath {
	fpath=$1
	isfrom=$2

	if [ -z $SKIPREADTEST ]
	then
		f=${fpath:0:1}
		if [ "$f" != "/" ]
		then
			echo path $fpath should be a full pathname.
			exit 1
		fi
		if [ ! -z $isfrom ]
		then
			# This deals with wildcards. ie from="/bla/blo/*"
			for p in $fpath
			do
				if [ ! -r $p ]
				then
					echo from path $p is not readable.
					exit 1
				fi
			done
		fi
	fi
}

if [ -z "$from" ]
then
	echo A source \(--from or -f\) must be specified.
	exit 1
else
	echo [INFO] rsync from $from
fi
if [ -z "$to" ]
then
	echo A destination \(--to or -t\) must be specified.
	exit 1
else
	echo [INFO] rsync to $to
fi
if [ -z "$job" ]
then
	echo A file list containing folder names \(--file or -f\) must be specified.
	exit 1
fi
if [ -z "$RESULTS" ]
then
	echo [INFO] Output folder for results not specified. Default to output to /project/RDS-SMS-FFbigdata-RW/results
	#Default results folder, use -o to change
	RESULTS="/project/RDS-SMS-FFbigdata-RW/results"
else
	echo [INFO] Storing results to $RESULTS
fi
if [ -z "$PLIMIT" ]
then
	echo [INFO] Parallel running limit not specified. Default to 1.
	PLIMIT=1
fi
if [ -z "$KEEPFQ" ]
then
	echo [INFO] Not keeping fastq files after processing.
else
	echo [INFO] Storing fastq input to $KEEPFQ
fi

QCOPYFLAGS="-q $TRANSFERQUEUE -P $PROJECT -j oe $QSUBEXTRAFLAGS"

# Check from and to as being full path names.
checkpath "$from" yes
checkpath "$to"

#copyDirs=""
#if [ -z "$LOG" ]
#then
#	while read folder           
#	do           
#		copyDirs=$copyDirs" $RSYNC $RSYNCFLAGS $rsyncflags $from/$folder $to;"           
#	done <$job
#	copy_from_sync_jobid=$(printf "#PBS -l select=1:ncpus=$NCPUS:mem=$MEM,walltime=$WALLTIME
#	#PBS -N $NAME"_start"
#	cd \$PBS_O_WORKDIR
#	time /bin/sh -c '$copyDirs'" | qsub $QCOPYFLAGS)
#else
#	while read folder           
#	do           
#		copyDirs=$copyDirs" $RSYNC $RSYNCFLAGS $rsyncflags $from/$folder $to;"           
#	done <$job
#	copy_from_sync_jobid=$(printf "#PBS -l select=1:ncpus=$NCPUS:mem=$MEM,walltime=$WALLTIME
#	#PBS -N $NAME"_start"
#	cd \$PBS_O_WORKDIR
#	time /bin/sh -c '$copyDirs'" | qsub $QCOPYFLAGS)
#
#fi

#if [ -z $copy_from_sync_jobid ]
#then
#	echo Submit of copy job failed.
#	exit 1
#fi

#copy_from_sync_jobid=$(echo $copy_from_sync_jobid | cut -d'.' -f 1)

# If there was a pbs job file specified, then submit it such that it depends
# on the copy job (usually afterok, but that can be changed with -d)

QFLAGS="-P FFbigdata -j oe $QSUBEXTRAFLAGS"
#QFLAGS="-P FFbigdata $QSUBEXTRAFLAGS"

let count=0
let pcount=0
copy_from_sync_jobid=""
next_accum_jobid=""
cur_accum_jobid=""
cur_joid=""

echo "job submitted..."
while read folder
do          
	#line count
        ((count++))
	#parallel count
        ((pcount++))

	copy_from_sync_jobid="Job"count
	#check if folder or file
	echo "checkpath: " $from/$folder
	finalto=$to
	if [ -d "$from/$folder" ] 
	then
		#rsync from folder to folder
		echo "Found folder $from/$folder"
		#copy_from_sync_jobid=$(printf "#PBS -l select=1:ncpus=$CNCPUS:mem=$CMEM,walltime=$CWALLTIME
		##PBS -N $NAME"_"$folder"_start"
		#time $RSYNC $RSYNCFLAGS $rsyncflags $from/$folder $to" | qsub -W depend=$DEPENDANY$cur_accum_jobid $QCOPYFLAGS)
		time $RSYNC $RSYNCFLAGS $rsyncflags $from/$folder $to
		#update finalto path with folder, as $to need to be reuse
		finalto=$to/$folder
		#copy_from_sync_jobid=$(echo $copy_from_sync_jobid | cut -d'.' -f 1)
		echo $copy_from_sync_jobid", sync from $from/$folder to $to"
	else
		#rsync from file to folder
		echo "No folder found $from/$folder"
		#update finalto path with folder, as $to need to be reuse
		finalto=$to/${folder%.*}
		#copy_from_sync_jobid=$(printf "#PBS -l select=1:ncpus=$CNCPUS:mem=$CMEM,walltime=$CWALLTIME
		##PBS -N $NAME"_"$folder"_start"
		#mkdir $finalto; time $RSYNC $RSYNCFLAGS $rsyncflags $from/$folder $finalto" | qsub -W depend=$DEPENDANY$cur_accum_jobid $QCOPYFLAGS)
		mkdir $finalto && time $RSYNC $RSYNCFLAGS $rsyncflags $from/$folder $finalto
		#copy_from_sync_jobid=$(echo $copy_from_sync_jobid | cut -d'.' -f 1)
		echo $copy_from_sync_jobid", sync from $from/$folder to $finalto"
	fi
	
	copy_from_sync_jobid="Job"count
	#Run gatk
	if [ ! -z "$copy_from_sync_jobid" ]
	then
		#gatk_jobid=$(printf "#PBS -l select=1:ncpus=$NCPUS:mem=$MEM,walltime=$WALLTIME
		##PBS -N $NAME"_"$folder"_gatk"
		#/project/RDS-SMS-FFbigdata-RW/bg_rt/scripts/bwa_gatk.sh $folder $finalto $NCPUS" | qsub -W depend=$DEPENDANY$cur_accum_jobid -W depend=$DEPEND:$copy_from_sync_jobid $QFLAGS)
		gatk3_docker.sh $folder $finalto $NCPUS && annovar.sh $folder $finalto $NCPUS
		#gatk_jobid=$(echo $gatk_jobid | cut -d'.' -f 1)
		echo $gatk_jobid", run gatk"
	fi

	gatk_jobid="Job"count
	#rsync result back and remove rsync to folder
	if [ ! -z "$gatk_jobid" ]
	then
		if [ ! -z "$KEEPFQ" ]
		then
			#copy_back_to_jobid=$(printf "#PBS -l select=1:ncpus=$CNCPUS:mem=$CMEM,walltime=$CWALLTIME
			##PBS -N $NAME"_"${folder%.*}"_results"
			#mkdir -p $KEEPFQ/$(basename $finalto); mv $finalto/*fq* $KEEPFQ/$(basename $finalto); $RSYNC $RSYNCFLAGS $rsyncflags $finalto $RESULTS; rm -rf $finalto" | qsub -W depend=$DEPENDANY$cur_accum_jobid -W depend=$DEPEND:$copy_from_sync_jobid:$gatk_jobid $QCOPYFLAGS)
			#mkdir -p $KEEPFQ/$(basename $finalto); mv $finalto/*fq* $KEEPFQ/$(basename $finalto); time $RSYNC $RSYNCFLAGS $rsyncflags $finalto $RESULTS; rm -rf $finalto
			time $RSYNC $RSYNCFLAGS $rsyncflags $finalto $RESULTS; mkdir -p $KEEPFQ/$(basename $finalto); mv $RESULTS/$(basename $finalto)/*fq* $KEEPFQ/$(basename $finalto); rm -rf $finalto
		else
			#copy_back_to_jobid=$(printf "#PBS -l select=1:ncpus=$CNCPUS:mem=$CMEM,walltime=$CWALLTIME
			##PBS -N $NAME"_"${folder%.*}"_results"
			#rm $finalto/*.fq*; $RSYNC $RSYNCFLAGS $rsyncflags $finalto $RESULTS; rm -rf $finalto" | qsub -W depend=$DEPENDANY$cur_accum_jobid -W depend=$DEPEND:$copy_from_sync_jobid:$gatk_jobid $QCOPYFLAGS)
			rm $finalto/*.fq*; time $RSYNC $RSYNCFLAGS $rsyncflags $finalto $RESULTS; rm -rf $finalto
			#time $RSYNC $RSYNCFLAGS $rsyncflags $finalto $RESULTS
		fi
		copy_back_to_jobid=$(echo $copy_back_to_jobid | cut -d'.' -f 1)
		copy_back_to_jobid="Job"count
		echo "$copy_back_to_jobid, copy back results: $RSYNC $RSYNCFLAGS $rsyncflags $finalto $RESULTS"
		echo $finalto" jobid: "$copy_from_sync_jobid $gatk_jobid $copy_back_to_jobid
	fi

        #next_accum_jobid=$next_accum_jobid:$copy_from_sync_jobid:$gatk_jobid:$copy_back_to_jobid
        #cur_jobid=$cur_accum_jobid:$copy_from_sync_jobid:$gatk_jobid:$copy_back_to_jobid
        #if [[ "$pcount" -eq "$PLIMIT" ]];
        #then
        #        pcount=0
        #        cur_accum_jobid=$cur_accum_jobid$next_accum_jobid
        #        next_accum_jobid=""
        #fi

        #echo "Job: "$count "pcount: "$pcount" waiting jobid: "$cur_jobid
done <$job

echo "done"
exit 0
