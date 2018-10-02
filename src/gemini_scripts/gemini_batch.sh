#!/usr/bin/env bash
# Description: This script is an interface for gemini_single.sh which runs the GEMINI script
# for each .vcf input file in a given directory. It generates output in a second given directory.
# Usage: bash geminiWholeFolder.sh path_to_input_directory path_to_output_directory force_overwrite

inputDir=$1                 # Path to the directory containing the .vcf.gz input files
                            # (no trailing '/')
outputDir=$2                # Path to the directory where the annotated .vcf.gz output files
                            # should be generated (no trailing '/')

bcLength=2                  # Barcode length. This should be handled differently...

# ---- Run GEMINI for each annotated .vcf file in inputDir ----
# Note: This procedure is safest with ~/ and absolute paths. Relative paths might break it...
for inputFile in ${inputDir}/*.vcf
do
    echo "Processing $inputFile [GEMINI]..."

    # ---- Decypher barcode into patient number ----
    # Extract barcode from inputFile filename
    barcode=${inputFile%.*}
    barcode=${barcode:${#barcode} - ${bcLength}}

    # ---- Resolve outputFile prefix ----
    if [ -e ${inputDir}/barcodeCypher.csv ]; then
        echo "... using patient number from ${inputDir}/barcodeCypher.csv..."
        prefix="$(grep $barcode ${inputDir}/barcodeCypher.csv | cut -d ',' -f 2)"
        prefix="P"${prefix}
    else
        echo "... using raw barcode. Add ${inputDir}/barcodeCypher.csv for patient number..."
        prefix="B"${barcode}
    fi

    # ---- Create output subdirectory (each file gets its own) ----
    outputFolder=${outputDir}/${prefix}
    echo "... creating outputFolder for ${prefix}: ${outputFolder}"
    mkdir ${outputFolder}

    # ---- Run GEMINI ----
    bash gemini_single.sh ${inputFile} ${outputFolder}
done
