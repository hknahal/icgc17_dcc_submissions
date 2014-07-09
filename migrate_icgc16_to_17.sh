#!/bin/bash
# title		: migrate_icgc16_17.sh
# description	: This script will convert valid Release 16 submission files to structurally fit the current dictionary for Release 17 by removing columns no longer used.
# author	: Hardeep Nahal
# contact	: hardeep.nahal@oicr.on.ca
# institution	: Ontario Institute for Cancer Research, ICGC DCC
# date		: 2014-06-27
# version	: 0.1
# usage		: ./migrate_icgc16_to_17.sh
# notes		: 
#
#	****  WARNING ****: This script will overwrite the previous Release 16 submission files
#
#========================================================================================================

usage="./migrate_icgc16_to_17.sh [-h] [-i <input directory>] -- This script will migrate valid Release 16 submission files to Release 17, where:
	-h show help text
	-i name of directory where Release 16 files reside (optional argument)

** WARNING: This script will overwrite the previous Release 16 submission files **

"

inputDir=''
while getopts hi: option
do
   case "${option}"
   in
     h) echo "$usage"
        exit;;
     i) inputDir="${OPTARG}/";;
     \?) echo "Illegal option\n" "$OPTARG" >&2
         echo "$usage" >&2
         exit 1;;
   esac
done


function remove_column() {
   columnName=$1
   filePrefix=$2
   fileCmd=''
   tmpFile=''
   outputCmd=''
   for file in `ls ${inputDir} | grep "${filePrefix}"`
   do
      C=1;
      fileName=${inputDir}${file}
      if [[ $fileName =~ gz$ ]];
         then
      	    fileCmd="gunzip -cd ${fileName} "
      	    outputCmd="| gzip -c > ${fileName%%.*}.tmp.gz"
            tmpFile="${fileName%%.*}.tmp.gz"
      elif [[ $fileName =~ bz2$ ]];
         then
            fileCmd="bzip2 -cd ${fileName} "
      	    outputCmd="| bzip2 -c > ${fileName%%.*}.tmp.bz2"
            tmpFile="${fileName%%.*}.tmp.bz2"
      else
         fileCmd="cat ${fileName} "
         outputCmd="> ${fileName%%.*}.tmp"
         tmpFile="${fileName%%.*}.tmp"
      fi
      for i in `${fileCmd} | head -n1`
      do 
         if [ $i = ${columnName} ] ;
            then 
              break; 
         else
            C=$(($C+1))
         fi 
      done
      #cutCmd="| cut -f1-$(($C-1)),$(($C+1))-"
      #eval ${fileCmd} ${cutCmd} ${outputCmd}
      eval ${fileCmd} "| cut -f1-$(($C-1)),$(($C+1))-" ${outputCmd}
      wait
      mv ${tmpFile} ${fileName?}
      echo "Removed ${columnName} from ${fileName}"
   done
}


# Remove "analyzed_sample_type" and "analyzed_sample_type_other" from sample file(s)
remove_column "analyzed_sample_type" "sample*"
remove_column "analyzed_sample_type_other" "sample*"

# Remove "note" column from all other files
remove_column "note" "ssm_m*"
remove_column 'note' 'ssm_p*'
remove_column 'note' 'cnsm_m*'
remove_column 'note' 'cnsm_p*'
remove_column 'note' 'cnsm_s*'
remove_column 'note' 'stsm_m*'
remove_column 'note' 'stsm_p*'
remove_column 'note' 'sgv_m*'
remove_column 'note' 'sgv_p*'
remove_column 'note' 'jcn_m*'
remove_column 'note' 'exp_seq_m*'
remove_column 'note' 'exp_array_m*'
remove_column 'note' 'mirna_seq_m*'
remove_column 'note' 'meth_seq_m*'
remove_column 'note' 'meth_array_m*'
