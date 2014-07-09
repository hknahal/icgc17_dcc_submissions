#!/usr/bin/python
import gzip
import bz2
import fnmatch
import os
import sys, getopt
import re
import json
import collections

__title__	= "specimen_type_dcc_mapping.py"
__author__	= "Hardeep Nahal"
__email__	= "hardeep.nahal@oicr.on.ca"
__institution__	= "Ontario Institute for Cancer Research, ICGC DCC"
__date__	= "2014-06-18"
__version__	= "0.1"
__description__	= "Maps old DCC specimen_type terms to new DCC specimen_type terms used in Release 17 specimen.0.specimen_type.v3 codelist"
__usage__	= "python specimen_type_dcc_mapping.py -i <input directory name>"


inputDir = ''
log = open("dcc_specimen_type_mapping.log", "w") 			
mapping = collections.defaultdict(list)					
mappingFile = open("old_dcc_to_new_dcc_specimen_type.txt", "r") 	

try:
   opts, args = getopt.getopt(sys.argv[1:], "hi:", ["idir="])
except getopt.GetoptError:
      print 'specimen_type_dcc_mapping.py -i <input directory>'
      sys.exit(2)
for opt, arg in opts:
   if opt == '-h':
      print 'specimen_type_dcc_mapping.py -i <input directory>'
      sys.exit()
   elif opt in ("-i", "--idir"):
      inputDir = arg


""" Finds all specimen files in given directory """
def getFile(filePattern):
   allFiles = []
   dataFile = ''
   for file in os.listdir(inputDir):
      if fnmatch.fnmatch(file, filePattern):
         bz2_filePattern = "%s.txt.bz2"%filePattern
         gzip_filePattern = "%s.txt.gz"%filePattern
         if fnmatch.fnmatch(file, bz2_filePattern):
	   dataFile = bz2.BZ2File("%s/%s"%(inputDir,file), 'rb')
         elif (fnmatch.fnmatch(file, gzip_filePattern)):
           dataFile = gzip.open("%s/%s"%(inputDir,file), 'rb')
         else:
           dataFile = open("%s/%s"%(inputDir,file), 'r')
         allFiles.append(dataFile)
   return allFiles

""" Performs mapping between old and new specimen_type terms
    Ambigious specimen_types (bone marrow and lymph node) will be reported in log file
"""
def do_mapping(mappingFile, specimenFiles):
   mapping_content = mappingFile.readlines()
   mapping_content.pop(0)
   old_specimen_types = {}
   new_specimen_types = {}
   # store mapping
   for line in mapping_content:
      line.replace("\r","")
      data = line.split("\t")
      mapping[data[0]].append(data[2])
      old_specimen_types[data[0]] = data[1]
      new_specimen_types[data[2]] = data[3]
   mappingFile.close()
   # start processing specimen files
   for specimenFile in specimenFiles:
      log.write("INFO: Processing %s\n"%specimenFile.name)
      specimen_content = specimenFile.readlines()
      heading = specimen_content.pop(0)
      outputFile = (specimenFile.name).split("/")[-1]
      outputFile = outputFile + ".tmp"
      #outFile = open("%s/%s"%(inputDir, outputFile), "w")
      if fnmatch.fnmatch(specimenFile.name, "*.bz2"):
         outFile = bz2.BZ2File("%s/%s"%(inputDir, outputFile), 'wb')
      elif fnmatch.fnmatch(specimenFile.name, "*.gz"):
         outFile = gzip.open("%s/%s"%(inputDir, outputFile), 'wb')
      else:
         outFile = open("%s/%s"%(inputDir, outputFile), "w")
      outFile.write("%s"%heading)
      lineNum = 1
      for line in specimen_content:
         new_st = ''
         data = line.split("\t")
 	 # report ambigious specimen types: bone marrow and lymph node
         if ( (data[2] == '6') or (data[2] == '7') ):
             log.write("WARNING: [Line Number %s]: Release 16 specimen_type term %s (%s) is ambigious. Please specify whether %s is:\n"%(lineNum, data[2], old_specimen_types[data[2]], data[2]))
             comment = ''
             for sptype in mapping[data[2]]:
		comment += "\t%s: %s"%(sptype, new_specimen_types[sptype])
             log.write("WARNING: %s\n"%comment)
         elif ( (data[2] == '-777') or (data[2] == '-888') ):
             log.write("WARNING: [Line Number %s]: specimen_type cannot used invalid codes -777/-888. Please specify specimen_type for sample %s\n"%(lineNum, data[1]))
         else:
            new_specimen_type = mapping[data[2]][0]
            data[2] = new_specimen_type
         lineNum = lineNum + 1
         # Print new mapping to output file
         outFile.write("\t".join(data))
      log.write("INFO: Done processing %s\n"%specimenFile.name)
      outFile.close()
 
specimenFiles = getFile("specimen*")
do_mapping(mappingFile, specimenFiles)
log.close()
