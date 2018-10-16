#!/usr/bin/env bash
# Description: This script is an interface for vep_single.sh which runs the VEP script
# for each .vcf input file in a given directory. It generates output in a second given directory
# Usage: bash vep_batch.sh path_to_input_directory path_to_output_directory force_overwrite

in_dir=$1                 # Path to the directory containing the .vcf.gz input files
                            # (no trailing '/')
out_dir=$2                # Path to the directory where the annotated .vcf output files
                            # should be generated (no trailing '/')
force_overwrite_flag=$3     # Flag to force overwriting of files (used by VEP)
                            # (pass 1 to overwrite, and 0 to preserve)

# ---- Run VEP of each .vcf.gz file in in_dir ----
# Note: This procedure is safest with ~/ and absolute paths. Relative paths might break it...
for in_file_path in ${in_dir}/*.vcf.gz
do
    echo "Processing $in_file_path [VEP]..."
    out_file_name=${in_file_path%.*}            # removes .gz from the filename
    out_file_name=${out_file_name##*/}          # removes path (extracts only filename)
    bash vep_single.sh $in_file_path ${out_dir}/$out_file_name ${force_overwrite_flag}
done
