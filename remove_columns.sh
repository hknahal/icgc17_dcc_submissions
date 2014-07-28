#!/bin/bash
# title		: remove_columns.sh
# description	: This script will convert valid Release 16 submission files to structurally fit the current dictionary for Release 17 by removing columns no longer used.
# author	: Hardeep Nahal
# contact	: hardeep.nahal@oicr.on.ca
# institution	: Ontario Institute for Cancer Research, ICGC DCC
# date		: 2014-06-27
# version	: 0.1
# usage		: ./remove_columns.sh
# notes		: 
#
#	****  WARNING ****: This script will overwrite the previous Release 16 submission files in the current/specified directory
#
#===================================================================================================================================

usage="./remove_columns.sh [-h] [-i <input directory>] -- This script will migrate valid Release 16 submission files to Release 17, where:
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

# will remove columns from necessary files
function removeCol() {
   columnName=$1
   filePrefix=$2
   fileCmd=''
   tmpFile=''
   outputCmd=''
   for file in `ls ${inputDir} | grep ${filePrefix}`
   do
      C=1;
      fileName=${inputDir}${file}
      if [[ $fileName =~ gz$ ]];
         then
      	    fileCmd="gunzip -cd ${fileName} "
            tmpFile="${fileName%%.*}.tmp.gz"
      	    outputCmd="| gzip -c > ${tmpFile}"
      elif [[ $fileName =~ bz2$ ]];
         then
            fileCmd="bzip2 -cd ${fileName} "
            tmpFile="${fileName%%.*}.tmp.bz2"
      	    outputCmd="| bzip2 -c > ${tmpFile}"
      else
         fileCmd="cat ${fileName} "
         tmpFile="${fileName%%.*}.tmp"
         outputCmd="> ${tmpFile}"
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
      eval ${fileCmd} "| cut -f1-$(($C-1)),$(($C+1))-" ${outputCmd}
      wait
      mv ${tmpFile} ${fileName?}
      echo "Removed ${columnName} from ${fileName}"
   done
}

# Remove "analyzed_sample_type" and "analyzed_sample_type_other" from sample file(s)
removeCol "analyzed_sample_type" "sample"
removeCol "analyzed_sample_type_other" "sample"

# Remove "note" column from all other files
removeCol "note" "ssm_m"
removeCol 'note' 'ssm_p'
removeCol 'note' 'cnsm_m'
removeCol 'note' 'cnsm_p'
removeCol 'note' 'cnsm_s'
removeCol 'note' 'stsm_m'
removeCol 'note' 'stsm_p'
removeCol 'note' 'stsm_s'
removeCol 'note' 'sgv_m'
removeCol 'note' 'sgv_p'
removeCol 'note' 'pexp_m'
removeCol 'note' 'pexp_p'
removeCol 'note' 'jcn_m'
removeCol 'note' 'jcn_p'
removeCol 'note' 'exp_seq_m'
removeCol 'note' 'exp_array_m'
removeCol 'note' 'mirna_seq_m'
removeCol 'note' 'meth_seq_m'
removeCol 'note' 'meth_array_m'
