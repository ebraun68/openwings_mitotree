# openwings_mitotree
Code for the OpenWings mitogenomic tree project

Description of multimitofinder.pl

Simple perl script to run MitoFinder in a consistent manner. It requires MitoFinder (Alio
et al. (2020) abd one of the assemblers that MitoFinder uses (MEGAHIT, MetaSPAdes, or 
IDBA-UD) to be installed, along with the other MitoFinder dependencies (see the MitoFinder
github for details)

Allio, R., Schomaker-Bastos, A., Romiguier, J., Prosdocimi, F., Nabholz, B., & Delsuc, F. 
(2020) Mol Ecol Resour. 20, 892-905. doi: 10.1111/1755-0998.13160
Mitofinder: https://github.com/RemiAllio/MitoFinder

The program is straightforward to use; it will provide instructions when called without
command line options:

```
Usage:
  $ ./multimitofinder.pl <ctlfile> <assembler>
  ctlfile   = tab delimited list of mitogenomes to assemble
              (read the comments in this code for format details)
  assembler = program used to assemble reads
              (megahit, metaspades, idba)
exiting...
```
This program reads a control file, which is simply a tab-delimted file with the following
format:

Outfile_name Read_type  Source  Reads/SRR#  Reference
one file per line

# 	0. Outfile name (e.g., Atlapetes_gutturalis_UWMB93636)
# 	1. Read type - S = Single end; P = Paired end
# 	2. Source - S = SRA; otherwise the path to the file
# 	3. Read file or SRR number
# 	4. Reference mitogenome (e.g., Passer_montanus_JX486030.gb)

If you wish to use with data in NCBI SRA you must install SRA tools
SRA tools: https://github.com/ncbi/sra-tools

