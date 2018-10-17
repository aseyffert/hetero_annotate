#!/usr/bin/env bash
# Description: This scripts aims to take some set of unannotated .vcf.gz files and feed them
# through the Ensembl VEP runner and GEMINI.
# It should ideally work on patient folders in a batch fashion.
# Note: This script assumes it's on the same level in the directory tree as the scripts it calls
# to make relative paths work.
# Usage: bash master_script.sh <path_to_VCF_directory> <path_to_output_directory> 1/0

in_dir=$1                 # Path to the directory containing the .vcf.gz input files
                            # (no trailing '/')
out_dir=$2                # Path to the directory where the annotated .vcf output files
                            # should be generated (no trailing '/')

# Check whether out_dir exists (1) and is empty (2)
if ! [ -d ${out_dir} ]; then
    echo "Create main output directory first..."
    exit 1
else
    if ! [ -z "$(ls -A ${out_dir})" ]; then
        echo "Empty main output directory first..."
        exit 1
    fi
fi

# ---- Prepare out_dir ----
mkdir ${out_dir}/vep_out

# ---- Run VEP ----
cd src/vep_scripts
bash vep_batch.sh ${in_dir} ${out_dir}/vep_out/

# ---- Run GEMINI ----
cd ../gemini_scripts
bash gemini_batch.sh ${out_dir}/vep_out/ ${out_dir}

cd ../../
