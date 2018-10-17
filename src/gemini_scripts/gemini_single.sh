#!/usr/bin/env bash
# Description: This script aims to take a Ensembl VEP annotated .vcf file and
# load it into GEMINI.
# It produces a set list of output files, grouping the variants logically according to
# certain criteria
# and combinations of criteria.
# This list may be expanded as needed.
# Usage: bash gemini_single.sh path_to_input_file path_to_output_directory
# Note: No directory check is performed. Also, barcode is assumed to be the 2 chars before .vcf

in_file=$1                        # Annotated .vcf input file
out_dir=$2                        # Output directory for query results files

# Define columns of interest. For more options see GEMINI's documentation
cols="chrom, start, end, gene, exon, ref, alt, qual, type, cyto_band"
cols="${cols}, num_hom_ref, num_hom_alt, num_het, is_coding, codon_change, aa_change"
cols="${cols}, impact, impact_severity, is_lof, is_conserved, depth, qual_depth"
cols="${cols}, rs_ids, in_omim, clinvar_sig, clinvar_origin, clinvar_disease_name"
cols="${cols}, polyphen_pred, polyphen_score, sift_pred, sift_score, pfam_domain"
cols="${cols}, in_hm3, in_esp, in_1kg, aaf_1kg_all, aaf_1kg_eur, aaf_1kg_afr"

# ---- Load in_file into tmp_gS.db SQL database ----
cp ${in_file} tmp_vcf.vcf
mkdir tmp_out_dir

gemini load -v tmp_vcf.vcf -t VEP --cores 4 --skip-gerp-bp tmp_gS.db

# ---- Query database (inc. metaInfo) ----
bash do_queries.sh ${cols}

if [ -e tmp_out_dir/meta_info.txt ]; then
    rm tmp_out_dir/meta_info.txt
fi

for in_file in tmp_out_dir/*.txt; do
    wc -l ${in_file} >> tmp_out_dir/meta_info.txt

# ---- Move files to out_dir ----
if [ -d ${out_dir}/queries ]; then
    echo "Clobbering contents of queries folder..."
    rm -r ${out_dir}/queries/*
else
    echo "Creating queries folder"
    mkdir ${out_dir}/queries
fi

# NOTE: This works because meta_info.txt gets moved _before_ the rest...
mv ./tmp_out_dir/meta_info.txt ${output_dir}
mv ./tmp_out_dir/* ${out_dir}/queries/

# ---- Cleanup ----
rm ./tmp_gS.db ./tmp_vcf.vcf
rmdir tmp_out_dir
