# Introduction

'hetero_annotate' is a set of BASH scripts that do batch variant annotation and filtering using the offline Ensembl VEP runner, and GEMINI genome mining scripts.

# Setting up `hetero_annotate`
The first step to setting up `hetero_annotate` is to ensure your system has `bash` installed. For users on Linux and OSX, this will most likely already be the case. For users on Microsoft Windows, there are a number of option available, most notably the `Windows Subsystem for Linux` offered by Windows 10.

DISCLAIMER: While all three tools `hetero_annotate` relies on (`bash`, VEP, and GEMINI) can be installed on Windows, their installation is more difficult. These scripts have also not been extensively tested in the Windows environment, so your results may vary.

The second step is to install VEP and GEMINI, the two tools `hetero_annotate` uses.

## VEP installation
To install VEP, follow the instructions on their installation page: https://www.ensembl.org/info/docs/tools/vep/script/vep_download.html

NOTE: As a prerequisite, VEP needs a number of `PERL` libraries to be installed. Details on which libraries are required, and how they might be installed, can be found in the above-linked installation documentation.

To install only the relevant files for the human genome, pass `--SPECIES homo_sapien` to VEP's `INSTALL.pl` installer. To use VEP offline effectively, you'll need to install (at least) the human cache file. This can most likely best be done by also passing `--AUTO ac`. To additionally install the human reference sequence (for HGVS names), pass `--AUTO acf` instead. Plugins can also be installed (e.g., the CADD score plugin); check VEP's documentation for details on adding this to your installation.

NOTE: GEMINI's documentation actually has a section devoted to the installation and use of the VEP script which you might find useful: https://gemini.readthedocs.io/en/latest/content/functional_annotation.html#stepwise-installation-and-usage-of-vep

Once VEP has been successfully installed, update the entry in `src/vep_scripts/vep_single.sh` containing the VEP installation directory (`vep_dir`) with the directory where you installed it. This can be done with any simple text editor (although not something like MS Word).

## GEMINI installation
To install GEMINI, follow the instructions from their documentation:
https://gemini.readthedocs.io/en/latest/

More detailed instructions can also be found at:
https://gemini.readthedocs.io/en/latest/content/installation.html

The former source seems to be more frequently updated, however, so we suggest that it override the latter source where appropriate (e.g., the 'New Installation' entry under 'Latest News').

NB: Make sure not to skip the step where your system's `PATH` environment variable is updated to include the GEMINI executable. If you're unsure whether you've done this, consult GEMINI's detailed installation instructions again (the second source listed above).

NOTE: GEMINI officially only supports loading of variants mapped to GRCh37 (therefore also only variants for `homo_sapiens`). While it is possible to process GRCh38 mapped variants (and variants for other species) such that GEMINI can be used to mine them (http://quinlanlab.org/blog/2016/05/02/gemini-2-progress.html), `hetero_annotate` will remain limited to GRCh37. This may change once GRCh38 support has been officially added to GEMINI.

## Testing the pipeline
The Ensembl VEP installation comes with a number of example VCF files, one of which is mapped using GRCh37. This file can be used to check whether or not `hetero_annotate` runs properly. To perform this test you can run:

`bash hetero_annotate.sh <path_to_vep_sample_file> tmp_testRun/`

You can then inspect the `tmp_testRun` directory to see whether output was generated or not. Remember to delete this directory when you're done.

# Using `hetero_annotate`
`hetero_annotate` is meant to operate in a batch fashion. Generally these batches are the results from a single sequencing run from, say, an Ion Torrent S5 sequencer, or something similar. Before files are fed into `hetero_annotate` the following steps should have already occured:
- Signal calling
- Base calling
- Sequence alignment
- Variant calling

These steps often form part of the on-board analysis modern NGS platforms perform, but we suggest making sure.

## Calling `hetero_annotate`
`hetero_annotate` takes 2 arguments: `in_dir` and `out_dir`. The former is the path to the directory containing the input `.vcf.qz` files (the files produced by the sequencer). The latter is the path to the directory inside which the GEMINI output should be written. As a precautionary measure, `hetero_annotate` won't do anything unless `out_dir` is empty. This ensures that no previous results can be accidentally overwritten. It means, however, that you need to create a seperate directory for each batch you analyse with `hetero_annotate`.

Example call: `bash hetero_annotate.sh ~/data/my_sample_set/ ~/results/my_sample_set/`

For each `.vcf.gz` file in `in_dir`, `hetero_annotate` will create a directory with the same name in `out_dir`. Inside this directory you'll find a `queries` directory, containing a `.txt` file for each query specified in the `queries_spec.txt` file.

## Adding and removing queries
Each line in `queries_spec.txt` corresponds to a single query to the SQLite database GEMINI loads the annotated `.vcf` files into. Each line has two parts, seperated by a comma: the query's name, and the query snippet to use when constructing the query. The former simply determines the filename of the queries corresponding `.txt` file (in `out_dir`), while the latter should be such that it can be added into a SQLite query as follows: `select <cols> from variants where <query_snippet>`. An example query snippet would be something like `is_coding = 1 and impact LIKE 'frame_shift'`, which would have GEMINI return all the frame shift variants that were found in coding regions. For a detailed introduction to what queries are possible, see GEMINI's documentation: https://gemini.readthedocs.io/en/latest/content/querying.html

The `queries_spec.txt` file included in this repository contains a set of example queries. You can add or remove queries to this file, and can even specify a different (similarly formatted) file in `src/gemini_scripts/gemini_single.sh` (by setting the `qfile` variable). Having different files available for different kinds of analyses might be convenient for you.

NOTE: Comments aren't parsed in these files, so commenting out a query won't have the desired effect. This feature might be added later.

## Specifying the columns returned by GEMINI
The information contained in the annotated VCF files is loaded into corresponding database columns by GEMINI. The `cols` variable in the `src/gemini_scripts/gemini_single.sh` script allows one to specify which of these columns GEMINI should include in its query results. A full list of the columns available can be found at: https://gemini.readthedocs.io/en/latest/content/database_schema.html#the-variants-table

Extra columns can be added to the list in groups (or individually) as demonstrated in the `src/gemini_scripts/gemini_single.sh` script. Since this specification is done in a bash script, lines can be commented out, and hence groups of columns can be exluded or included for different analysis runs. We suspect, however, that the columns include won't need to be changed often, and have therefore opted for this hardcoding style of specification over more flexible (but more opaque) solutions.

## Specifying VEP fields and arguments
The VEP runner allows fine control over which annotations are made and which fields are added to the VCF files it produces. To interface with these fine controls the `src/vep_scripts/vep_single.sh` script opts for a similar 'add-in-groups' solution to the one discussed for GEMINI's columns. Similar to GEMINI's columns, we suspect these won't change too often for your runs, and have implemented the same hardcoding solution for their modification.

A full list of the available command-line arguments is available at:
https://www.ensembl.org/info/docs/tools/vep/script/vep_options.html

For information on the available fields, see:
https://www.ensembl.org/info/docs/tools/vep/vep_formats.html#vcfout

## Specifying the number of cores
Both VEP and GEMINI are capable of parallel processing. For both, `hetero_annotate` assumes 4 cores to be the appropriate number. However, many desktop machines are now equipped with considerably more cores. Should you wish to increase (or decrease) the number of cores the pipeline assumes, modify the `num_forks` and `num_cores` variables in `src/vep_scripts/vep_single.sh` and `src/gemini_scripts/gemini_single.sh` respectively.
