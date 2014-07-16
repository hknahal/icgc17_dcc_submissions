#!/usr/bin/perl
use PerlIO::gzip;
use PerlIO::via::Bzip2;

###############################################################################################################################################
#
# File: 	mapping_specimen_type.pl
# Author:	Hardeep Nahal
# Email:	hardeep.nahal@oicr.on.ca
# Institution:	Ontario Institute for Cancer Research, ICGC DCC
# Date:		2014-07-15
# Version:	0.1
# Description:	Maps old DCC specimen_type terms to new DCC specimen_type terms used in Release 17 specimen.0.specimen_type.v3 codelist
# Usage:	perl mapping_specimen_type.pl <input directory name (optional) >
# Note:		Please review log file for additional details after mapping is complete
# 
###############################################################################################################################################

my $inputDir = '';
if (scalar(@ARGV) != 0) {
   $inputDir = shift(@ARGV);
}

my @files;
my %mapping;

open(MAPPING, "<oldDCC_to_newDCC_specimen_type_mapping.txt") or die "Cannot open mapping file: $!\n";
open(LOG, ">DCC_specimen_type_mapping.log") or die "Cannot open log output file: $!\n";

# store specimen_type mapping in a hash
while(<MAPPING>)
{
	chomp($_);
	my @line = split(/\t/, $_);
	$mapping{$line[0]}{old_sp} = $line[1];
	$mapping{$line[0]}{new_id} = $line[2];
	if (!(exists($mapping{$line[0]})))
	{
		$mapping{$line[0]}{new_sp} = ();
	}
	push(@{$mapping{$line[0]}{new_sp}}, $line[3]);
}
close(MAPPING);

# Find all specimen files
if ($inputDir ne '') {
	opendir my $DIR, $inputDir or die "Cannot open $inputDir: $!\n";
	@files = grep { /specimen*/} readdir($DIR) or die "Cannot open directory $inputDir: $!\n";
	$inputDir = $inputDir . "/";
}
else{
	@files = glob("specimen*");
}

# Convert old Release 16 specimen_type IDs to new ones
for my $file (@files) {
	my $tempFile;
	my $header = 1;
	my $lineNum = 0;
	$file = $inputDir . $file;
	if ($file =~ /(.*)(.gz)$/) {
 		$tempFile = "$1.tmp.gz";  
		open FILE, "<:gzip", "$file" or die "Cannot read $file: $!\n";
		open TMP, ">:gzip", "$tempFile" or die "Cannot open temp file: $!\n";
	}
	elsif ($file =~ /(.*)(.bz2)$/) {
 		$tempFile = "$1.tmp.bz2";  
		open FILE, "<:via(Bzip2)", "$file" or die "Cannot read $file: $!\n";
		open TMP, ">:via(Bzip2)", "$tempFile" or die "Cannot open temp file: $!\n";
	}
	else {
		open(FILE, "<$file") or die "Cannot open $file: $!\n";
		$tempFile = "$file.tmp";
		print "tempFile = $tempFile\n";
		open(TMP, ">$tempFile") or die "Cannot open temp file: $!\n";
	}
	print LOG "INFO: Processing $file\n";
        while(<FILE>)
	{
		if ($header) { 
			$header = 0;
			print TMP $_;
			next;
		}
		$lineNum++;
		my @line = split(/\t/, $_);
		my $specimen_type = $line[2];
		if ( ($specimen_type eq "6") or ($specimen_type eq "7")) {
             		print LOG "WARNING: [Line Number $lineNum]: Release 16 specimen_type term $specimen_type ( $mapping{$specimen_type}{old_sp} ) is ambigious. Please specify whether $mapping{$specimen_type}{old_sp} is:\n\t" . join("\n\t", @{$mapping{$specimen_type}{new_sp}}) . "\n";
		}
		elsif ( ($specimen_type eq "-777") or ($specimen_type eq "-888") )
		{
             		print LOG "WARNING: [Line Number $lineNum]: specimen_type cannot used invalid codes -777/-888. Please specify specimen_type for specimen ID $line[1]\n";
		}
		else {
			$line[2] = $mapping{$specimen_type}{new_id};
		}
		print TMP join("\t", @line);
	}
	close(TMP);
	rename $tempFile, $file;
	print LOG "INFO: Finished converting $file\n";
}
print "specimen_type conversion complete. Please review DCC_specimen_type_mapping.log log file for additional details\n";
print LOG "INFO: specimen_type conversion complete.\n"; 

