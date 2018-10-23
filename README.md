# Introduction

This is a set of BASH scripts that do batch variant annotation and filtering using the offline Ensembl VEP runner, and GEMINI genome mining scripts.

## VEP installation

To install VEP, follow the instructions on their installation page: https://www.ensembl.org/info/docs/tools/vep/script/vep_download.html

NOTE: To install only the relevant files for the human genome, pass `--SPECIES` to VEP's `INSTALL.pl` installer. To use VEP offline effectively, you'll need to install (at least) the human cache file. This can most likely best be done by also passing `--AUTO ac`. To additionally install the human reference sequence (for HGVS names), pass `--AUTO acf` instead. Plugins can also be installed (e.g., the CADD score plugin); check VEP's documentation for details on adding this to your installation.
