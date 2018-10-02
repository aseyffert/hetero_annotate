#!/usr/bin/env bash
# This script contains the list of queries to be made to the GEMINI database
# created by gemini_single.sh.
# There are two ways of querying: simple 1 line queries, and compound for-loop queries.
# To add a simple query, copy an existing one and modify
# 1) the query inside the quotation marks, and
# 2) the part of the filename (end of the line) before the ".txt"
# To add a compound query, copy the compound query template (bottom of file) and modify
# 1) the queries after "select ${cols} from variants", and
# 2) the query name on the line above the relevant query (no spaces; this will go before
#    the ".txt" in the filename)
# The basic structure of a query is:
# gemini query -q "<query>" tmp_gS.db > <path_to_file>/<filename>_<queryName>.txt
# The output filename convention followed here matters for the <filename>_metaInfo.txt file
# generation step.

barcode=$1
cols=$2

tmpDir="tmp_geminiOutputs"

# ==== Simple queries
# ---- LoF = 1 ----
echo "Querying for all Lof variants..."
gemini query -q "select ${cols} from variants where is_lof = 1" tmp_gS.db \
> ${tmpDir}/bar${barcode}_LoF.txt
echo "...done."

# ---- Rare variants ----
echo "Querying for all rare variants..."
gemini query -q \
"select ${cols} from variants where is_lof = 1 \
and (in_dbsnp = 0 or aaf <= 0.01)" tmp_gS.db \
> ${tmpDir}/bar${barcode}_RareNovelLoF.txt
echo "...done."

# ---- Pathogenic ----
echo "Querying for all pathogenic variants..."
gemini query -q \
"select ${cols} from variants where in_omim = 1 \
or clinvar_disease_name is not NULL" tmp_gS.db \
> ${tmpDir}/bar${barcode}_omimClinivar.txt

gemini query -q "select ${cols} from variants where sift_pred = 'deleterious' \
or polyphen_pred = 'probably_damaging'" tmp_gS.db \
> ${tmpDir}/bar${barcode}_siftPolyphen.txt
echo "...done."

# ==== Compound queries ====
# ---- Coding vs Non coding ----
echo "Querying for coding and non-coding variants..."
for queryName_query in \
    "allVariants,\
    select ${cols} from variants" \
    "coding,\
    select ${cols} from variants where is_coding = 1" \
    "nonCoding,\
    select ${cols} from variants where is_coding = 0"; do
        queryName="$(echo ${queryName_query} | cut -d "," -f 1)"
        query="$(echo ${queryName_query} | cut -d "," -f 2)"
        gemini query -q ${query} tmp_gS.db > ${tmpDir}/bar${barcode}_${queryName}.txt
done
echo "...done."

# ---- Coding = 1 ----
echo "Querying for coding impacts"
for queryName_query in \
    "codingSynonymous,\
    select ${cols} from variants where is_coding = 1 and impact LIKE 'synonymous_coding'" \
    "codingNonSynonymous,\
    select ${cols} from variants where is_coding = 1 and impact LIKE 'non_syn_coding'" \
    "codingStopgain,\
    select ${cols} from variants where is_coding = 1 and impact LIKE 'stop_gain'" \
    "codingStoploss,\
    select ${cols} from variants where is_coding = 1 and impact LIKE 'stop_loss'" \
    "codingFrameshift,\
    select ${cols} from variants where is_coding = 1 and impact LIKE 'frame_shift'"; do
        queryName="$(echo ${queryName_query} | cut -d "," -f 1)"
        query="$(echo ${queryName_query} | cut -d "," -f 2)"
        gemini query -q ${query} tmp_gS.db > ${tmpDir}/bar${barcode}_${queryName}.txt
done
echo "...done"

# ---- Reported ----
echo "Querying for all reported variants..."
for queryName_query in \
    "reported,\
    select ${cols} from variants where in_dbsnp = 1" \
    "reportedLoF,\
    select ${cols} from variants where is_lof = 1 and in_dbsnp = 1" \
    "reportedNonLoF,\
    select ${cols} from variants where is_lof = 0 and in_dbsnp = 1" \
    "reportedCoding,\
    select ${cols} from variants where in_dbsnp = 1 and is_coding = 1" \
    "reportedCodingLoF,\
    select ${cols} from variants where is_lof = 1 and in_dbsnp = 1 and is_coding = 1" \
    "reportedCodingNonLoF,\
    select ${cols} from variants where is_lof = 0 and in_dbsnp = 1 and is_coding = 1"; do
        queryName="$(echo ${queryName_query} | cut -d "," -f 1)"
        query="$(echo ${queryName_query} | cut -d "," -f 2)"
        gemini query -q ${query} tmp_gS.db > ${tmpDir}/bar${barcode}_${queryName}.txt
done
echo "...done."

# ---- Novel ----
echo "Querying for all novel variants..."
for queryName_query in \
    "novel,\
    select ${cols} from variants where in_dbsnp = 0" \
    "novelLoF,\
    select ${cols} from variants where is_lof = 1 and in_dbsnp = 0" \
    "novelNonLoF,\
    select ${cols} from variants where is_lof = 0 and in_dbsnp = 0" \
    "novelCoding,\
    select ${cols} from variants where in_dbsnp = 0 and is_coding = 1" \
    "novelCodingLoF,\
    select ${cols} from variants where is_lof = 1 and in_dbsnp = 0 and is_coding = 1" \
    "novelCodingNonLoF,\
    select ${cols} from variants where is_lof = 0 and in_dbsnp = 0 and is_coding = 1"; do
        queryName="$(echo ${queryName_query} | cut -d "," -f 1)"
        query="$(echo ${queryName_query} | cut -d "," -f 2)"
        gemini query -q ${query} tmp_gS.db > ${tmpDir}/bar${barcode}_${queryName}.txt
done
echo "...done."

# ---- ----

echo "Queries made successfully."

# ---- Compound query template ----
# NOTE: This template has space for 3 queries. Add more by copying the middel lines...

#for queryName_query in \
#    ",\
#    select ${cols} from variants" \
#    ",\
#    select ${cols} from variants" \
#    ",\
#    select ${cols} from variants"; do
#        queryName="$(echo ${queryName_query} | cut -d "," -f 1)"
#        query="$(echo ${queryName_query} | cut -d "," -f 2)"
#        gemini query -q ${query} tmp_gS.db > ${tmpDir}/bar${barcode}_${queryName}.txt
#done
