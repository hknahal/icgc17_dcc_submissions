Migration of valid Release 16 Metadata and Primary Files to Release 17 (Dictionary version 0.9a)

IMPORTANT NOTES:
================

- These scripts will overwrite the original submission files
- These scripts can only be used on valid Release 16 submission files
- One submission files are processed, please upload to DCC submission system and validate.
- Files must be valid against current dictionary in order to be included in Release 17

Contents:
=========

After archive is decompressed, a folder will be created called "migrate_icgc16_to_icgc17" with the following contents:

1. migrate_icgc16_icgc17.sh
	A simple bash script that will modify validated Release 16 submission files to structurally conform to Release 17 data specifications by removing columns no longer required:
	- Remove 'analyzed_sample_type' and 'analyzed_sample_type_other' fields from 'sample' file
	- Remove 'note' column from all files
For more information, please see Release Notes available at http://docs.icgc.org/dictionary

2. specimen_type_mapping.py
	This Python script will map specimen_type DCC terms used in Release 16 to the current specimen_type codelist in Release 17. 

3. oldDCC_to_newDCC_specimen_type_mapping.txt
	A tab-delimited file consisting of a mapping between the old DCC specimen_type terms and the current DCC specimen_type terms. For more details, please review documentation at http://docs.icgc.org/specimen-type-mapping 


Requirements:
=============

- Linux
- Python:
  - at least Python 2.7

  Python Modules:
   - gzip		https://docs.python.org/2/library/gzip.html
   - bz2 		https://docs.python.org/2/library/bz2.html
   - fnmatch	 	https://docs.python.org/2/library/fnmatch.html
   - collections	https://docs.python.org/2/library/collections.html


Instructions:
=============

1. Run migrate_icgc16_to_icgc17.sh bash script to remove columns no longer needed

To execute:

	If running script within same folder as submission files (only Release 16 files should eb in this folder):
	   > ./migrate_icgc16_to_icgc17.sh  

	If running script one level up from input directory, you can use the "-i" flag to specify the directory where the Release 16 files reside:
	   > ./migrate_icgc16_to_icgc17.sh -i <name of directory where Release 16 submission files are located>


2. Convert old DCC specimen_type terms to new DCC specimen_type terms: 

To execute:

   	> python specimen_type_mapping.py -i <name of input directory>

NOTE: In most cases there is a one-to-many mapping between Release 16 specimen_type terms and Release 17 specimen_type terms. However, there are two previously used terms ("bone marrow" and "lymph node") which are ambigious (could be either normal or tumour) and will require the submitter to specify/convert these manually. Such cases will be reported in the DCC_specimen_type_mapping.log log file.


Example: If the specimen_type was specified as "7" (lymph node) in Release 16, you will need to chagne it to a more specific specimen type, either 107 (Normal - lymph node) or 119 (Metastatic tumour - lymph node)
_______________________________________________________________________________________________________________________
|			|			|			     	  		|		       |
| Old specimen_type:	| Old DCC codelist ID:	|  New specimen_type:	     	  		| New DCC Codelist ID: |
|=======================|=======================|===============================================|======================|
| lymph_node		|  7			| Normal – lymph node	         		|	107	       |
|			|  			| Metastatic tumour – lymph node  		|	119            |
|_______________________|_______________________|_______________________________________________|______________________|
| bone marrow		|  6			| Normal – bone marrow		  	        |	103	       |
|			| 			| Primary tumour – blood derived (bone marrow)  |	111	       |
|			| 			| Recurrent tumour – blood derived (bone marrow)|	116            |
|_______________________|_______________________|_______________________________________________|______________________|


3. Once files are converted, upload submission files to submission system at http://dcc.submissions.icgc.org and validate

For questions, please contact dcc-support@icgc.org
