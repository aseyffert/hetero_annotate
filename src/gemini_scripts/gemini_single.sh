#!/usr/bin/env bash
# This script takes a VEP-annotated VCF file and loads it into a SQLite
#   database for querying. It produces a set of variant lists, as well as a
#   meta_info.txt file in the output directory.
# Example: bash gemini_single.sh /path/to/vcf/input.vcf /path/to/output/dir/

# ==== Preparation ====
# Specify the number of CPU cores GEMINI can use, and the queries_spec file
num_cores=4
qfile="../../queries_spec.txt"

# ---- GEMINI query columns ----
# Define columns of interest. They can be added in groups as below.
cols="chrom, start, end, gene, exon, ref, alt, qual, type, cyto_band"
cols="${cols}, is_coding, codon_change, aa_change"
cols="${cols}, num_hom_ref, num_hom_alt, num_het"
cols="${cols}, impact, impact_severity, is_lof, is_conserved"
cols="${cols}, depth, qual_depth, rs_ids, in_omim, pfam_domain"
cols="${cols}, clinvar_sig, clinvar_origin, clinvar_disease_name"
cols="${cols}, polyphen_pred, polyphen_score, sift_pred, sift_score"
cols="${cols}, in_hm3, in_esp, in_1kg, aaf_1kg_all, aaf_1kg_eur, aaf_1kg_afr"

# ---- GEMINI load arguments ----
gemini_args="--skip-gerp-bp"

# ---- Handle arguments ----
in_file=$1                        # Annotated .vcf input file
out_dir=$2                        # Output directory for query results files

# ==== Run GEMINI ====
# ---- Load into SQLite database ----
cp ${in_file} tmp_vcf.vcf
mkdir tmp_out_dir

gemini load -v tmp_vcf.vcf -t VEP --cores ${num_cores} ${gemini_args} tmp_gS.db

# ---- Query database ----
echo "Querying..."
while read line
do
		qname=$(echo ${line} | cut -d "," -f 1)
		qsnip=$(echo ${line} | cut -d "," -f 2)
	  query="select ${cols} from variants where ${qsnip}"

		printf "... ${qname}...\n"
		echo gemini query -q "${query}" tmp_gS.db > tmp_out_dir/${qname}.txt
		printf "done\n"
done < ${qfile}

# ---- Generate meta_info.txt ----
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
