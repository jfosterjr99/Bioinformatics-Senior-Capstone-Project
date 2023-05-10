DROP TABLE IF EXISTS msi_alignment_scores;
CREATE TABLE msi_alignment_scores
(
  gene_name VARCHAR(20) NOT NULL,
  msi_val REAL NOT NULL,
  upperalignment VARCHAR(100) NOT NULL,
  loweralignment VARCHAR(100) NOT NULL,
  sample VARCHAR(100) NOT NULL,
  position VARCHAR(100) NOT NULL,
  mononucseq VARCHAR(100) NOT NULL
);
