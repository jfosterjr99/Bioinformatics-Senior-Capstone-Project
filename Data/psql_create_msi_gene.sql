DROP TABLE IF EXISTS msi_gene;
CREATE TABLE msi_gene
(
  gene_name VARCHAR(20) NOT NULL,
  msi_val REAL NOT NULL,
  fsp_bait_sequence VARCHAR(20) NULL,
  SYFPEITHI_Score VARCHAR(20) NULL,
  percentage_rank VARCHAR(20) NULL
);
