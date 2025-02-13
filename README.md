# Building a Custom Apicomplexan Database

### Project description
This repository contains scripts, workflows, and datasets related to the molecular surveillance of Apicomplexa parasites in seabirds, specifically the endangered Cape cormorant, Cape gannet, and African Penguin populations. Our goal is to develop and optimize bioinformatics tools for detecting and characterizing these pathogens using molecular techniques.


_________________________________________________________________________________________
			
		
## STEP 01-04: DOWNLOAD & PREPARE FILES 
(Adapted from Lucas Huggins - https://figshare.unimelb.edu.au/articles/dataset/ApicomplexanDB/22153529?file=39387155)

### 01 Download relevant sequences from NCBI 
https://www.ncbi.nlm.nih.gov/nuccore/

All Apicomplexa:
  ```
  ((((((18S ribosomal RNA[Title]) OR 18S rRNA[Title]) OR ribosomal RNA[Title]) OR SSU rRNA[Title]) OR SSU ribosomal RNA[Title]) AND txid5794[Organism]) AND 200:2000[Sequence Length]
```
  
The specific fasta sequences were chosen and downloaded as a fasta file from NCBI.
> Send to: Complete Record, file (FASTA format) > Create file

Rename file: 18S_Apicomplexan.fasta


### 02 Format/edit Fasta file & extract accession numbers
```
awk '{print $1}' 18S_Apicomplexan_v1.fasta > 18S_Apicomplexan_v2.fasta  ## removes text in header after accession number
```

Extract accession numbers from the fasta headers and produce a single column text file.
```
grep -e ">" 18S_Apicomplexan.fasta > 18S_accIDs.txt
```
  
Fix file by removing unwanted characters from accession IDs
```
sed 's/>//g' 18S_accIDs.txt > 18S_accIDs_fix1.txt
sed 's/\.1//g' 18S_accIDs_fix1.txt > 18S_accIDs_fix2.txt
```
 

### 03 Download the large NCBI accession2taxid database - a text file:
https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz


### 04 Created a mapping file
Creating a table of each accession to its taxa id using nucl_gb.accession2taxid 

```
awk -F"\t" 'BEGIN{while(getline<"18S_accIDs_fix.txt") hash[$1]=1} {if ($2 in hash) print $2,$3}' nucl_gb.accession2taxid > ApicomplexanDB_map.txt
```

_________________________________________________________________________________________
			
		
## STEP 05-06: GET TAXONOMY & FIX FILES  

### 05 Get all taxonomy for taxa IDs - using R studio

taxonomizr.R (https://github.com/ocean-ecologist/Apicomplexan_DB/blob/651e918c3af2da567dfb39de2360604ab1715f5f/taxonomizr.R)

### 06 - Fix files

Fix headers if needed:

```
sed 's/\.1//g' 18S_Apicomplexan.fasta > 18S_Apicomplexan_tmp.fasta
sed 's/\.2//g' 18S_Apicomplexan_tmp.fasta > 18S_Apicomplexan_final.fasta
```

```
sed 's/\.1//g' ApicomplexanDB_map.txt > ApicomplexanDB_map_tmp.txt
sed 's/\.2//g' ApicomplexanDB_map_tmp.txt > ApicomplexanDB_map_final.txt
```


Fix all files to tsv (eg. ApicomplexanDB_map_final.txt > ApicomplexanDB_map_final.tsv), add taxaID to taxa_table.txt (produced in R)

__________________________________________________________________________________________

## STEP 07-08: BUILD DATABASE & RUN IN EMU
(Adapted from Kristen Curry, Treagen Lab - https://gitlab.com/treangenlab/emu/-/tree/master?ref_type=heads)

### 07 - Build Custom Database for EMU

An emu database consists of 2 files:

1. taxonomy.tsv (tab separated datasheet of database taxonomy lineages containing at columns: 'tax_id' and any taxonomic ranks (i.e. species, genus, etc))

2. species_taxid.fasta (database sequences where each sequence header starts with the respective species-level tax id (or lowest level above species-level if missing) preceeding a colon [<species_taxid>:<remainder of header>])



The following files are required to build a custom database:

1. Nucleotide sequences in fasta format

2. Mapping file in .tsv format - a headerless two column tab-separated values, where each row contains (1) sequence header in database.fasta and (2) corresponding tax id

3. Taxonomy file: 

- Either a directory containing both names.dmp and nodes.dmp files in NCBI taxonomy format and named accordingly

	OR

- A .tsv file containing complete taxonomic lineages. The first column MUST be the taxonomy ids. Remaining columns can be in any format, then Emu abundance output will match this format

USAGE:

```
emu build-database ApiDB --sequences /path-to/18S_Apicomplexan_final.fasta --seq2tax /path-to/ApicomplexanDB_map_final.tsv --taxonomy-list /path-to/taxa_table.tsv
```
OR
```
emu build-database ApiDB --sequences /path-to/18S_Apicomplexan_final.fasta --seq2tax /path-to/ApicomplexanDB_map_final.tsv --ncbi-taxonomy /path-to/folder-with-names&nodes.dmp
```

### 08 - Run with EMU

```
for i in *
	do
	emu /path-to/reads/$i --type map-ont --db /path-to/ApiDB --threads 8 --keep-counts --output-dir /path-to/emu-output
done
```
