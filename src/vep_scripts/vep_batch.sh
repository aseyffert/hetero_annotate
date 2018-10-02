#!/usr/bin/env bash
# Description: This script is an interface for vep_single.sh which runs the VEP script
# for each .vcf input file in a given directory. It generates output in a second given directory
# Usage: bash vep_batch.sh path_to_input_directory path_to_output_directory force_overwrite

inputDir=$1                 # Path to the directory containing the .vcf.gz input files
                            # (no trailing '/')
outputDir=$2                # Path to the directory where the annotated .vcf output files
                            # should be generated (no trailing '/')
force_overwrite_flag=$3     # Flag to force overwriting of files (used by VEP)
                            # (pass 1 to overwrite, and 0 to preserve)

# ---- Run VEP of each .vcf.gz file in inputDir ----
# Note: This procedure is safest with ~/ and absolute paths. Relative paths might break it...
for inputFilePath in ${inputDir}/*.vcf.gz
do
    echo "Processing $inputFilePath [VEP]..."
    outputFilename=${inputFilePath%.*}            # removes .gz from the filename
    outputFilename=${outputFilename##*/}          # removes path (extracts only filename)
    bash vep_single.sh $inputFilePath ${outputDir}/$outputFilename ${force_overwrite_flag}
done
