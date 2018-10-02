#!/usr/bin/env bash
# NOTE: Filenames starting with "tmp_" indicate temporary files that are deleted

inputFile=$1				# Path to input .vcf.gz file
outputFile=$2				# Path to output .vcf file
force_overwrite_flag=$3			# Flag to force overwriting of files (used by VEP)
 					# pass 1 to overwrite, and 0 to preserve

# Directory where VEP is installed.
# This directory should contain variant_effect_predictor.pl
# This WILL differ for your installation
vepDir="ETv81/scripts/variant_effect_predictor"

# Specify the .vcf annotation fields. They can be added in groups as below.
fields="Consequence,Codons,Amino_acids,Gene,SYMBOL,Feature,EXON"
fields="${fields},PolyPhen,SIFT,check_alleles"

# Set --force_overwrite if specified
if [ "${force_overwrite_flag}" -eq 1 ]; then
	force="--force_overwrite"
else
	force=""
fi

# ---- Run VEP ----
cp ${inputFile} ../${vepDir}/tmp_input.vcf.gz
cd ../${vepDir}
echo "... running variant_effect_predictor.pl..."
# What follows is a single command spread over multiple lines for readability.
# The "\" character indicates that the command continues on the next line.
# To run this command in the command line delete the "\" characters and newlines
perl variant_effect_predictor.pl -i tmp_input.vcf.gz -o tmp_output.vcf \
	--cache \
	--offline \
	--format vcf \
	--vcf \
	--buffer_size 25000 \
	--sift b \
	--polyphen b \
	--symbol \
	--numbers \
	--maf_1kg \
	--pubmed \
	--fields ${fields} \
	$force

# ---- Cleanup ----
rm tmp_input.vcf.gz
cd -
mv ../${vepDir}/tmp_output.vcf ${outputFile}
mv ../${vepDir}/tmp_output.vcf_summary.html ${outputFile}_summary.html
