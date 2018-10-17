#!/usr/bin/env bash
# Description: This script is an interface for gemini_single.sh which runs the GEMINI script
# for each .vcf input file in a given directory. It generates output in a second given directory.
# Usage: bash gemini_batch.sh path_to_input_directory path_to_output_directory force_overwrite

in_dir=$1                 # Path to the directory containing the .vcf.gz input files
                            # (no trailing '/')
out_dir=$2                # Path to the directory where the annotated .vcf.gz output files
                            # should be generated (no trailing '/')

# ---- Run GEMINI for each annotated .vcf file in in_dir ----
# Note: This procedure is safest with ~/ and absolute paths. Relative paths might break it...
for in_file in ${in_dir}/*.vcf
do
    echo "Processing ${in_file} [GEMINI]..."

    out_subdir="$(basename ${in_file} .vcf)"

    # ---- Create output subdirectory (each file gets its own) ----
    out_dir_full=${out_dir}/${out_subdir}
    mkdir ${out_dir_full}

    # ---- Run GEMINI ----
    bash gemini_single.sh ${in_file} ${out_dir_full}
done
