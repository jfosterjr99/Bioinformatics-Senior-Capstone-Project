library("seqinr")
library(Biostrings)

`Sequence 1` <- DNAString("AAATTTGGGCCC")
`Sequence 2` <- DNAString("TTTGGGCCCAAA")

seq_1 <- translate(`Sequence 1`, no.init.codon=TRUE)
seq_1

mySRRList <- list("SRR14676234", "SRR14676248", "SRR14676209", "SRR14676235", "SRR14676227")
for(i in 1:5) {
  setwd(paste("/Users/jfosterjr99/Desktop/mysrrfilescopy/", mySRRList[i], sep = "", collapse = ""))
  dnaseq1 <- read.fasta(file = paste(mySRRList[i], "format1.txt", sep = "", collapse = ""), seqtype = "DNA", forceDNAtolower = TRUE)
  df1 <- data.frame()
  mylength <- length(readLines(paste(mySRRList[i], "format1.txt", sep = "", collapse = "")))/2
  print(mylength)
  for(j in 1:mylength) {
    df2 <- data.frame(id = paste(translate(RNAString(complement(DNAString(paste(dnaseq1[[j]][1:21], collapse = ""))))), collapse = ""))
    df1 <- rbind(df1,df2)
  }
  write.table(df1, paste("/Users/jfosterjr99/Desktop/mysrrfilescopy/", mySRRList[i], "/", mySRRList[i], "format3.txt", sep = "", collapse = ""), row.names=FALSE, col.names = FALSE)
}

length(dnaseq1)