#!/usr/bin/env bash
# NOTE: Filenames starting with "tmp_" indicate temporary files that are deleted

in_file=$1				# Path to input .vcf.gz file
out_file=$2				# Path to output .vcf file

# Directory where VEP is installed.
# This directory should contain variant_effect_predictor.pl
# This WILL differ for your installation
# IDEA: Move this to the top, above some "no fiddling" line.
vep_dir="${HOME}/scripts/vep"

# Specify the .vcf annotation fields. They can be added in groups as below.
fields="Consequence,Codons,Amino_acids,Gene,SYMBOL,Feature,EXON"
fields="${fields},PolyPhen,SIFT,check_alleles"

# ---- Run VEP ----
cp ${in_file} ${vep_dir}/tmp_input.vcf.gz
cd ${vep_dir}
echo "... running Ensembl VEP..."
# What follows is a single command spread over multiple lines for readability.
# The "\" character indicates that the command continues on the next line.
# To run this command in the command line delete the "\" characters and newlines
./vep -i tmp_input.vcf.gz -o tmp_output.vcf \
	--cache \
	--offline \
	--format vcf \
	--vcf \
	--buffer_size 25000 \
	--sift b \
	--polyphen b \
	--symbol \
	--numbers \
	--af_1kg \
	--pubmed \
	--fields ${fields}

# ---- Cleanup ----
rm tmp_input.vcf.gz
cd -
mv ${vep_dir}/tmp_output.vcf ${out_file}
mv ${vep_dir}/tmp_output.vcf_summary.html ${out_file}_summary.html
