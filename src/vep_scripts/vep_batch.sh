#!/usr/bin/env bash
# This script is a wrapper for vep_single.sh which calls it for each .vcf.gz
#   file in the input directory. It outputs a VEP-annotated VCF file for each
#   input file in the output directory.
# Example: bash vep_batch.sh /path/to/input/dir/ /path/to/output/dir/
# NOTE: Absolute paths are safest since they're unambiguous

# ---- Handle arguments ----
in_dir=$1                 # Path to input directory
out_dir=$2                # Path to output directory

# ---- Run VEP for batch ----
for in_file in ${in_dir}/*.vcf.gz
do
    echo "Processing ${in_file} [VEP]..."
    out_file_name="$(basename ${in_file} .gz)"
    bash vep_single.sh ${in_file} ${out_dir}/${out_file_name}
done
