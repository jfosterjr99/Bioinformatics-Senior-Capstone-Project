#Listing libraries for loading packages
library("seqinr")
library(Biostrings)

#Establishing list of SRR files to be read for generating amino acid peptide
#sequences
mySRRList <- list("SRR14676234", "SRR14676248", "SRR14676209", "SRR14676235", "SRR14676227")
for(i in 1:5) {
  #Set working directory to specific SRR folder
  setwd(paste("/Users/jfosterjr99/Desktop/mysrrfilescopy/", mySRRList[i], sep = "", collapse = ""))
  #Read the SRR genome into a variable named dnaseq1
  dnaseq1 <- read.fasta(file = paste(mySRRList[i], "format1.txt", sep = "", collapse = ""), seqtype = "DNA", forceDNAtolower = TRUE)
  #Establish an empty data frame for storing amino acid peptide sequences
  df1 <- data.frame()
  #Generate and store row length of SRR file to be translated
  mylength <- length(readLines(paste(mySRRList[i], "format1.txt", sep = "", collapse = "")))/2
  print(mylength)
  for(j in 1:mylength) {
    #Transcribe, translate DNA string to 7 amino acid long peptide sequence
    df2 <- data.frame(id = paste(translate(RNAString(complement(DNAString(paste(dnaseq1[[j]][1:21], collapse = ""))))), collapse = ""))
    df1 <- rbind(df1,df2)
  }
  #Write newly generated 7 amino acid long peptide sequences to file
  write.table(df1, paste("/Users/jfosterjr99/Desktop/mysrrfilescopy/", mySRRList[i], "/", mySRRList[i], "format3.txt", sep = "", collapse = ""), row.names=FALSE, col.names = FALSE)
}