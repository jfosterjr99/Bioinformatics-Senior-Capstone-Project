# MSI_Gene__psql_RShiny_template
## RShiny app that sorts/selects/limits/graphs FSP neoantigens from a postgres database

Installation notes:

clone repo to a designated directory on your computer (i.e. in a terminal cd to where you want it)
<p>
  download .zip file into your project directory


The data directory contains raw FSP neoantigen data and sql scripts to configure table and insert data
<p>Files contained in data directory:<p>
   1. Project_Script.ipynb<p>
   2. Alignment_Score.ipynb<p>
   3. Translation.R<p>
   4. SRR14676227format.txt<p>
   5. SRR14676234format.txt<p>
   6. SRR14676209format.txt<p>
   7. SRR14676235format.txt<p>
   8. SRR14676235format.txt<p>
   9. SRR14676248format.txt<p>
   10. msi_alignment_scores.txt<p>
   11. msi_gene.txt<p>
   12. psql_create_msi_alignment_scores.sql<p>
   13. psql_create_msi_gene.sql<p>

## cd to the data dir:
Make sure the postgres.app is running on your machine
## In a terminal/shell window type
'psql' to start the postgres.app

## from psql prompt type
CREATE DATABASE myadvproject;

## Connect to the myadvproject database
\c myadvproject

## To create the msi_alignment_scores table, enter
\i psql_create_msi_alignment_scores.sql

## To create the msi_gene table, enter
\i psql_create_msi_gene.sql

## To generate data manually (~16 hour runtime)
run Project_Script.ipynb
run Alignment_Score.ipynb
run Translation.R
\COPY psql_create_msi_alignment_scores FROM 'msi_alignment_scores.txt' with DELIMITER E'\t';
\COPY psql_create_msi_gene FROM 'msi_gene.txt' with DELIMITER E'\t';

Remove all records from table
DELETE from msi_alignment_scores;
DELETE from msi_gene;
## populate table directly from text file
\COPY psql_create_msi_alignment_scores FROM 'msi_alignment_scores.txt' with DELIMITER E'\t';
\COPY psql_create_msi_gene FROM 'msi_gene.txt' with DELIMITER E'\t';
###E escapes the following character (ie tab delimited format)

add Primary key to table for AlchemySQL<p>
ALTER TABLE msi_alignment_scores ADD COLUMN id SERIAL PRIMARY KEY;
ALTER TABLE msi_gene ADD COLUMN id SERIAL PRIMARY KEY;

\q to quit

## In the myadvproject_psql directory  (cd to main app directory)
## Edit the dbConnect line in server.R to reflect your local address to the database

*****************************************
 Connect to your local postgres database
*****************************************

conn <- dbConnect(RPostgres::Postgres(), dbname = myadvproject, host = localhost, port = your_port, user = postgres, password = your_password)
##Install any required packages for this app
install.packages("package_name")
##Open the app.R and Server.R files in RStudio
Use the keyboard shortcut: Command+Shift+Enter to start the app
## in your browser
## go to the localhost address to access database
http://127.0.0.1:6309

Close browser window to quit
