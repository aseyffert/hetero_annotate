#!/usr/bin/env bash
# This script takes an Ion Torrent VCF file and annotates it using Ensembl VEP
# Example: bash vep_sinle.sh /path/to/vcf/input.vcf.gz /path/to/vcf/input.vcf

# NOTE: Filenames starting with "tmp_" indicate temporary files that are deleted

# ==== Preparation ====
# Directory where VEP is installed. [This may differ for your installation]
vep_dir="${HOME}/scripts/ensembl-vep"

# ---- VCF annotation fields ----
# Specify the .vcf annotation fields. They can be added in groups as below.
vep_fields="Consequence,Codons,Amino_acids,Gene,SYMBOL,Feature,EXON"
vep_fields="${vep_fields},PolyPhen,SIFT,check_alleles"

# ---- VEP arguments ----
# Specify the arguments to pass to VEP. They can be added in groups as below.
# NOTE: There is a space after "${vep_args}" in each additional group.
vep_args="--cache --offline --format vcf --vcf --buffer_size 25000"
vep_args="${vep_args} --sift b --polyphen b --symbol --numbers"
vep_args="${vep_args} --af_1kg --pubmed"
vep_args="${vep_args} --fields ${vep_fields}"

# ---- Handle arguments ----
in_file=$1				# Path to input .vcf.gz file
out_file=$2				# Path to output .vcf file

# ==== Run VEP ====
cp ${in_file} ${vep_dir}/tmp_input.vcf.gz
cd ${vep_dir}

echo "... running Ensembl VEP..."
./vep -i tmp_input.vcf.gz -o tmp_output.vcf ${vep_args}

# ---- Cleanup ----
rm tmp_input.vcf.gz
cd -
mv ${vep_dir}/tmp_output.vcf ${out_file}
mv ${vep_dir}/tmp_output.vcf_summary.html ${out_file}_summary.html
