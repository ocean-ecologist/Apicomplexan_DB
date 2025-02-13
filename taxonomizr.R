install.packages("taxonomizr") 

library(taxonomizr)
setwd("/path-to/working-taxonimizr")

prepareDatabase('accessionTaxa.sql')

#create txt file with column label - IDs $ save 18S_accIDs_final.txt > 18S_accIDs_finaltax.txt

acc <- read.table("18S_accIDs_finaltax.txt", sep = "\t", header = TRUE)

taxaId<-accessionToTaxa(acc$IDs,"accessionTaxa.sql")
taxaId

#prepare online resources
getNamesAndNodes(
  outDir = ".",
  url = sprintf("https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz"),
  fileNames = c("names.dmp", "nodes.dmp"),
  protocol = "ftp",
  resume = TRUE
)

#gunzip files - make them readable

read.nodes.sql("nodes.dmp", sqlFile = "namenode.sqlite", overwrite = FALSE)
read.names.sql("names.dmp", sqlFile = "namenode.sqlite", overwrite = TRUE)


#get taxonomy assignment & write file
taxa <- getTaxonomy(taxaId,'namenode.sqlite')

write.table(taxa, "taxa_table.txt")
