#!/usr/bin/env bash
# Description: This script is an interface for vep_single.sh which runs the VEP script
# for each .vcf input file in a given directory. It generates output in a second given directory
# Usage: bash vep_batch.sh path_to_input_directory path_to_output_directory force_overwrite

in_dir=$1                 # Path to the directory containing the .vcf.gz input files
                            # (no trailing '/')
out_dir=$2                # Path to the directory where the annotated .vcf output files
                            # should be generated (no trailing '/')

# ---- Run VEP of each .vcf.gz file in in_dir ----
# Note: This procedure is safest with ~/ and absolute paths. Relative paths might break it...
for in_file in ${in_dir}/*.vcf.gz
do
    echo "Processing ${in_file} [VEP]..."
    out_file_name="$(basename ${in_file} .gz)"
    bash vep_single.sh ${in_file} ${out_dir}/${out_file_name}
done
