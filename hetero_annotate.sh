#!/usr/bin/env bash
# This script uses the vep_single.sh and gemini_single.sh scripts (via their
#   batch wrappers) to build a batch-capable variant annotation and filtering
#   pipeline. The underlying tools are the offline Ensembl VEP runner and GEMINI
# This script should ideally be used on patient folders in a batch fashion.
# Example: bash hetero_annotate.sh /path/to/input/dir/ /path/to/output/dir/
# NOTE: Absolute paths are safest since they're unambiguous

# ---- Handle arguments ----
in_dir=$1                 # Path to input directory
out_dir=$2                # Path to output directory

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
