#!/usr/bin/env bash

# This file reads lines from <spec_file> and parses each into a gemini query.
# It takes the database file's path as an argument, as well as the cols to query.

qfile=$1
cols=$2
db=$3
outdir=$4

echo "Querying..."
while read line
do
	# TODO: Reduce the parse to a single line
	qname=$(echo ${line} | cut -d "," -f 1)
	query=$(echo ${line} | cut -d "," -f 2)

	printf "... ${qname}...\n"
	echo "gemini query -q ${query} ${db} > ${outdir}/${qname}.txt"
	printf "done\n"

done < ${qfile}
