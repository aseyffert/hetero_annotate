#!/usr/bin/env bash
# Description: This scripts aims to take some set of unannotated .vcf.gz files and feed them
# through the Ensembl VEP runner and GEMINI.
# It should ideally work on patient folders in a batch fashion.
# Usage: bash hetero_annotate.sh <path_to_VCF_directory> <path_to_output_directory>

in_dir=$1                 # Path to the directory containing the .vcf.gz input files
                            # (no trailing '/')
out_dir=$2                # Path to the directory where the annotated .vcf output files
                            # should be generated (no trailing '/')

# ---- Prepare out_dir ----
# Check whether out_dir exists (1) and is empty (2)
if ! [ -d ${out_dir} ]; then
    echo "Creating main output directory: ${out_dir}..."
    mkdir ${out_dir}
else
    if ! [ -z "$(ls -A ${out_dir})" ]; then
        echo "Empty main output directory first..."
        exit 1
    fi
fi
mkdir ${out_dir}/vep_out

# ---- Run VEP ----
cd src/vep_scripts
bash vep_batch.sh ${in_dir} ${out_dir}/vep_out
cd -

# ---- Run GEMINI ----
cd src/gemini_scripts
bash gemini_batch.sh ${out_dir}/vep_out ${out_dir}
cd -
