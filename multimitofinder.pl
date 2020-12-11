#!/usr/bin/env perl

use warnings;
use strict;
use Data::Dumper;

############################################################################
# Set the global variables
############################################################################
my($progname) = $0;

# Set for vertebrate mitochondrial coed with 4 processors and 10 GB memory
# Change for other run modes
my($settings) = "-o 2 -p 4 -m 10";

my($iter);
my($jter);
my($kter);
my($lter);
my($mter);
my($nter);
my($qter);

my($yter);
my($zter);

my($tempch1);
my($tempch2);
my($tempvar);
my($tempstr);
my @temparray;

my($verbose) = 0;

if ( @ARGV != 2 ) {
	print STDERR "Usage:\n  \$ $progname <ctlfile> <assembler>\n";
	print STDERR "  ctlfile   = tab delimited list of mitogenomes to assemble\n";
	print STDERR "              (read the comments in this code for format details)\n";
	print STDERR "  assembler = program used to assemble reads\n";
	print STDERR "              (megahit, metaspades, idba)\n";
	print STDERR "exiting...\n";
	exit;
}

my($ctlfile) = $ARGV[0];
my($asm)     = $ARGV[1];

# Default to megahit (the standard default for metaspades)
my($assembler) = "--megahit";
if ( lc($asm) eq "metaspades" ) { $assembler = "--metaspades"; }
elsif ( lc($asm) eq "idba" ) { $assembler = "--idba"; }
$asm = $assembler;

############################################################################
# Read the ctlfile - the format has one mitogenome per line in this order:
# 	0. Outfile name (e.g., Atlapetes_gutturalis_UWMB93636)
# 	1. Read type - S = Single end; P = Paired end
# 	2. Source - S = SRA; otherwise the path to the file
# 	3. Read file or SRR number
# 	4. Reference mitogenome (e.g., Passer_montanus_JX486030.gb)
############################################################################
my @inlist;
my($com);
open (my $INF, "$ctlfile") or die "Could not open file $ctlfile for input.\n";
@inlist = <$INF>; # Read the tab-delimited file of mitogenomes
close($INF) or die "Could not close file $ctlfile\n";
my($inlistnum) = $#inlist + 1;

print "\n";
print "########################################\n";
print "Will analyze $inlistnum datasets:\n";
for ($iter=0; $iter<$inlistnum; $iter++) {
	chomp($inlist[$iter]);
	(@temparray) = split(/\s+/, $inlist[$iter]);
	print "  -- $temparray[0] - $temparray[3]\n"
}
print "########################################\n";
print "\n";
print "\n";

############################################################################
# Read the inputfile (a tab-delimited file with R matrix data)
############################################################################

for ($iter=0; $iter<$inlistnum; $iter++) {
	chomp($inlist[$iter]);
	(@temparray) = split(/\s+/, $inlist[$iter]);
	
	if ( uc($temparray[1]) eq "S" ) { my($assembler) = "--megahit"; }
	$tempvar = localtime();
	print "\n";
	print "****************************************\n";
	print " Assembling data for:\n";
	print " 	$temparray[0]\n";
	print " Using read file(s):\n";
	print " 	$temparray[3]\n";
	if ( uc($temparray[1]) eq "S" ) { print " 	-- single-end reads\n"; }
	else { print " 	-- paired-end reads\n"; }  # Default is paired ends
	if ( uc($temparray[2]) eq "S" ) { print " 	-- downloaded from SRA\n"; }
	else { print " 	-- local file(s)\n"; }  # Default is local files
	print " Map to reference:\n";
	print " 	$temparray[4]\n";
	print " Assembler:\n";
	print " 	$assembler\n";
	print " Analysis start:\n";
	print " 	$tempvar\n";
	print "****************************************\n";
	print "\n";
	
	if ( uc($temparray[1]) eq "S" ) { # Single end reads
	
		if ( uc($temparray[2]) eq "S" ) { # download from SRA
			system("fasterq-dump $temparray[3]");
			system("gzip $temparray[3].fastq");
		}
		else {
			system("cp $temparray[2]/$temparray[3].fastq.gz .");
		}
	
		system("mitofinder -j $temparray[0] -s $temparray[3].fastq.gz -r $temparray[4] $settings $assembler");  

		# Clean up the read files (uncomment the if statement if you only want to clean up for SRA downloads)
#		if ( uc($temparray[2]) eq "S" ) { 
			system("rm $temparray[3].fastq.gz");
#		}

	}
	else { # Paired-end reads (default)
	
		if ( uc($temparray[2]) eq "S" ) { # download from SRA
			system("fasterq-dump --split-files $temparray[3]");
			system("gzip $temparray[3]_1.fastq");
			system("gzip $temparray[3]_2.fastq");
		}
		else {
			system("cp $temparray[2]/$temparray[3]_1.fastq.gz .");
			system("cp $temparray[2]/$temparray[3]_2.fastq.gz .");
		}
			
		system("mitofinder -j $temparray[0] -1 $temparray[3]_1.fastq.gz -2 $temparray[3]_2.fastq.gz -r $temparray[4] $settings $assembler");  

		# Clean up the read files (uncomment the if statement if you only want to clean up for SRA downloads)
#		if ( uc($temparray[2]) eq "S" ) { 
			system("rm $temparray[3]_1.fastq.gz");
			system("rm $temparray[3]_2.fastq.gz");
#		}
	}
	
	# Reset the assembler to $asm if it was changed due to use of single end reads
	$assembler = $asm;
	
	# Extract the info on size of contigs
	$com = "grep \"^LOCUS\" $temparray[0]/$temparray[0]" . "_Final_Results/$temparray[0]" . "_mtDNA_contig_*.gb > $temparray[0].contig_size.txt";
	system("$com");
	$com = "grep \"has been found more than once\" $temparray[0]" . "_MitoFinder.log >> $temparray[0].contig_size.txt";
	system("$com");
	
	$tempvar = localtime();
	print "\n";
	print " Assembly complete at time:\n";
	print " 	$tempvar\n";
	print "****************************************\n";
	print "\n";

}
