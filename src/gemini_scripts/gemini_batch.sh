#!/usr/bin/env bash
# This script is a wrapper for gemini_single.sh which calls it for each .vcf
#   file in the input directory. See that script for output details.
# Example: bash gemini_batch.sh /path/to/input/dir/ path/to/output/dir/
# NOTE: Absolute paths are safest since they're unambiguous

in_dir=$1                 # Path to input directory
out_dir=$2                # Path to output directory

# ---- Run GEMINI for batch ----
for in_file in ${in_dir}/*.vcf
do
    echo "Processing ${in_file} [GEMINI]..."

    out_subdir="$(basename ${in_file} .vcf)"

    # Create output subdirectory (each file gets its own)
    out_dir_full=${out_dir}/${out_subdir}
    mkdir ${out_dir_full}

    bash gemini_single.sh ${in_file} ${out_dir_full}
done
