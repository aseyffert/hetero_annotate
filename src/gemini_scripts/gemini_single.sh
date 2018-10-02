#!/usr/bin/env bash
# Description: This script aims to take a Ensembl VEP annotated .vcf file and
# load it into GEMINI.
# It produces a set list of output files, grouping the variants logically according to
# certain criteria
# and combinations of criteria.
# This list may be expanded as needed.
# Usage: bash gemini_single.sh path_to_input_file path_to_output_directory
# Note: No directory check is performed. Also, barcode is assumed to be the 2 chars before .vcf

inputFile=$1                        # Annotated .vcf input file
outputDir=$2                        # Output directory for query results files

# Define columns of interest. For more options see GEMINI's documentation
cols="chrom, start, end, gene, exon, ref, alt, qual, type, cyto_band"
cols="${cols}, num_hom_ref, num_hom_alt, num_het, is_coding, codon_change, aa_change"
cols="${cols}, impact, impact_severity, is_lof, is_conserved, depth, qual_depth"
cols="${cols}, rs_ids, in_omim, clinvar_sig, clinvar_origin, clinvar_disease_name"
cols="${cols}, polyphen_pred, polyphen_score, sift_pred, sift_score, pfam_domain"
cols="${cols}, in_hm3, in_esp, in_1kg, aaf_1kg_all, aaf_1kg_eur, aaf_1kg_afr"

bcLength=2                          # barcode length

# ---- Load inputFIle into tmp_gS.db SQL database ----
cp ${inputFile} tmp_vcf.vcf
tmpDir="tmp_geminiOutputs"
mkdir ${tmpDir}

# The "time timeout -k 20 90" snippet is just for safety. If you're brave, you can remove it.
time timeout -k 20 90 gemini load -v tmp_vcf.vcf -t VEP --cores 4 --skip-gerp-bp tmp_gS.db
barcode=${inputFile%.*}             # These two steps extract the barcode
barcode=${barcode:${#barcode} - ${bcLength}}

# ---- Query database (inc. metaInfo) ----
bash queryDatabase.sh ${barcode} ${cols}

if [ -e ${tmpDir}/bar${barcode}_metaInfo.txt ]; then
    rm ${tmpDir}/bar${barcode}_metaInfo.txt
fi

for inFile in ${tmpDir}/bar${barcode}_*.txt; do
    wc -l ${inFile} >> ${tmpDir}/bar${barcode}_metaInfo.txt

# ---- Move files to outputDir ----
if [ -d ${outputDir}/queries ]; then
    echo "Clobbering contents of queries folder..."
    rm -r ${outputDir}/queries/*
else
    echo "Creating queries folder"
    mkdir ${outputDir}/queries
fi
mv ./tmp_geminiOutputs/bar${barcode}_metaInfo.txt ${outputDir}
mv ./tmp_geminiOutputs/bar${barcode}_* ${outputDir}/queries/

# ---- Cleanup ----
rm ./tmp_gS.db ./tmp_vcf.vcf
rmdir ${tmpDir}
