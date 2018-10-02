#!/usr/bin/env bash
# Description: This scripts aims to take some set of unannotated .vcf.gz files and feed them
# through the Ensembl VEP runner and GEMINI.
# It should ideally work on patient folders in a batch fashion.
# Note: This script assumes it's on the same level in the directory tree as the scripts it calls
# to make relative paths work.
# Usage: bash master_script.sh <path_to_VCF_directory> <path_to_output_directory> 1/0

inputDir=$1                 # Path to the directory containing the .vcf.gz input files
                            # (no trailing '/')
outputDir=$2                # Path to the directory where the annotated .vcf output files
                            # should be generated (no trailing '/')
force_overwrite_flag=$3     # Flag to force overwriting of files (used by VEP)
                            # (pass 1 to overwrite, and 0 to preserve)

# Check whether outputDir exists (1) and is empty (2)
if ! [ -d ${outputDir} ]; then
    echo "Create main output directory first..."
    exit 1
else
    if ! [ -z "$(ls -A ${outputDir})" ]; then
        echo "Empty main output directory first..."
        exit 1
    fi
fi

# ---- Prepare outputDir ----
mkdir ${outputDir}/vepOutput
cp ${inputDir}/barcodeCypher.csv ${outputDir}/vepOutput

#  ---- Run VEP ----
cd ../vep_scripts
bash vep_batch.sh ${inputDir} ${outputDir}/vepOutput/ ${force_overwrite_flag}

#  ---- Run gemini ----
cd ../gemini_scripts
bash gemini_batch.sh ${outputDir}/vepOutput/ ${outputDir}

cd ../master_script
