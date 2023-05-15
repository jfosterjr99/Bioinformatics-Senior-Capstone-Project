#Listing libraries for loading packages
library(DBI)
library(RODBC)
library(odbc)
library(dplyr)
library(dbplyr)
library(RPostgreSQL)
library(shiny)
library(shinythemes)
library(markdown)
library(DT)
library(tidyverse)

#Listing db, db_host, db_port, db_user, db_pass parameters for connection to
#PostgreSQL database
db <- "myadvproject"
db_host <- "localhost"
db_port <- "5432"
db_user <- "postgres"
db_pass <- "123"

#Establishing connection to database with preset parameters
conn <- dbConnect(
  RPostgres::Postgres(),
  dbname = db,
  host = db_host,
  port = db_port,
  user = db_user,
  password = db_pass
)

#Defining the server-side logic of the Shiny application
shinyServer(function(input, output, session) {
  #Hiding the results page for the Analyze Data search
  hideTab(inputId = "msitabs", target = "Analyze Data Figures")
  #Creating a link button to the gene search page from the home page
  observeEvent(input$homesearch, {
    updateTabsetPanel(session, "msitabs", selected = "Gene Search")
  })
  #Setting events to take place when a search is executed on the gene search page
  observeEvent(input$Genesearch, {
    qry5 <- paste("SELECT syfpeithi_score FROM msi_gene WHERE gene_name LIKE", paste0("'", tolower(input$name), "';"))
    df5 <- dbGetQuery(conn, qry5)
    qry6 <- paste("SELECT percentage_rank FROM msi_gene WHERE gene_name LIKE", paste0("'", tolower(input$name), "';"))
    df6 <- dbGetQuery(conn, qry6)
    syfpeithi_score <- strtoi(df5[[1]])
    percentage_rank <- as.double(df6[[1]])
    #Setting criteria for MSI-high neoantigens
    if(input$var1 == "MSI-high") {
      if(percentage_rank <= 1) {
        qry <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE", paste0("'", tolower(input$name),"%' AND ", syfpeithi_score, " < msi_val"), "LIMIT", paste0(input$var2, ";"))
        df <- dbGetQuery(conn, qry)
        output$table <- DT::renderDataTable({
          DT::datatable(df)
        })
      }
      else{
        qry <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE 'NULL';")
        df <- dbGetQuery(conn, qry)
        output$table <- DT::renderDataTable({
          DT::datatable(df)
        })
      }
    }
    #Setting criteria for MSI-low neoantigens
    else if(input$var1 == "MSI-low") {
      if(percentage_rank > 1) {
        qry <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE", paste0("'", tolower(input$name),"%' AND ", syfpeithi_score, " >= msi_val"), "LIMIT", paste0(input$var2, ";"))
        df <- dbGetQuery(conn, qry)
        output$table <- DT::renderDataTable({
          DT::datatable(df)
        })
      }
      else{
        qry <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE 'NULL';")
        df <- dbGetQuery(conn, qry)
        output$table <- DT::renderDataTable({
          DT::datatable(df)
        })
      }
    }
    #Setting criteria for MSI-ambiguous/intermediate neoantigens
    else if(input$var1 == "MSI-ambiguous"){
      if(percentage_rank <= 1) {
        qry <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE", paste0("'", tolower(input$name),"%' AND ", syfpeithi_score, " >= msi_val"), "LIMIT", paste0(input$var2, ";"))
        df <- dbGetQuery(conn, qry)
        output$table <- DT::renderDataTable({
          DT::datatable(df)
        })
      }
      else if(percentage_rank > 1) {
        qry <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE", paste0("'", tolower(input$name),"%' AND ", syfpeithi_score, " < msi_val"), "LIMIT", paste0(input$var2, ";"))
        df <- dbGetQuery(conn, qry)
        output$table <- DT::renderDataTable({
          DT::datatable(df)
        })
      }
      else{
        qry <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE 'NULL';")
        df <- dbGetQuery(conn, qry)
        output$table <- DT::renderDataTable({
          DT::datatable(df)
        })
      }
    }
  })
  #Setting events to take place when a search is executed on the analyze data page
  observeEvent(input$Analyzedata, {
    #Showing the results page for the Analyze Data search; hiding all other pages
    hideTab(inputId = "msitabs", target = "Home")
    hideTab(inputId = "msitabs", target = "About")
    hideTab(inputId = "msitabs", target = "Gene Search")
    hideTab(inputId = "msitabs", target = "Analyze Data")
    hideTab(inputId = "msitabs", target = "References")
    hideTab(inputId = "msitabs", target = "Help")
    showTab(inputId = "msitabs", target = "Analyze Data Figures")
    updateTabsetPanel(session, "msitabs", selected = "Analyze Data Figures")
    qry5 <- paste("SELECT syfpeithi_score FROM msi_gene WHERE gene_name LIKE", paste0("'", tolower(input$dataname), "';"))
    df5 <- dbGetQuery(conn, qry5)
    qry6 <- paste("SELECT percentage_rank FROM msi_gene WHERE gene_name LIKE", paste0("'", tolower(input$dataname), "';"))
    df6 <- dbGetQuery(conn, qry6)
    syfpeithi_score <- strtoi(df5[[1]])
    percentage_rank <- as.double(df6[[1]])
    #Setting criteria for MSI-high neoantigens
    if(input$var == "MSI-high") {
      if(percentage_rank <= 1) {
        qry1 <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE", paste0("'", tolower(input$dataname),"%' AND ", syfpeithi_score, " < msi_val;"))
        df1 <- dbGetQuery(conn, qry1)
        output$myhist <- renderPlot({
          hist(df1[,2], breaks=20, col="blue", main="Histogram of FSP Dataset", xlab=names(df1[2]))
        })
        output$output2 <- renderUI({
          h5(paste('This data analysis displays selected FSP MSI values from selected', input$dataname, 'oncogenes with', input$var, 'categorization'))
        })
        output$output3 <- renderUI({
          h5(paste('The data is analyzed by control and variable tumor samples for novel neoantigen identification'))
        })
        output$output4 <- renderUI({
          h5(paste('Data incorperated with RShiny'))
        })
        qry4 <- paste("SELECT sample, count(sample) FROM msi_alignment_scores WHERE gene_name =", paste0("'", tolower(input$dataname),"' AND ", syfpeithi_score ," < msi_val GROUP BY sample;"))
        df4 <- dbGetQuery(conn, qry4)
        output$mypi <- renderPlot({
          pie(df4[,2], labels = df4[,1], main = "Pie Chart of Samples Containing FSP Neoantigens")
        })
        output$output5 <- renderUI({
          h5(paste('This Pie Chart displays selected MSI samples containing selected', input$dataname, 'FSPs with', input$var, 'categorization'))
        })
        output$output6 <- renderUI({
          h5(paste('The data is analyzed by control and variable tumor samples for novel neoantigen identification'))
        })
        output$output7 <- renderUI({
          h5(paste('Data incorperated with RShiny'))
        })
      }
      else{
        output$myhist <- renderPlot({
          plot(1, type = "n", bty = "n", main="Histogram of FSP Dataset", xlab = "msi_val", ylab = "Frequency", xlim = c(0, 10), ylim = c(0, 10))
        })
        output$output2 <- renderUI({
          h5(paste('No data available in table for FSP MSI values from selected', input$dataname, 'oncogenes with', input$var, 'categorization'))
        })
        output$output3 <- renderUI({
          h5('')
        })
        output$output4 <- renderUI({
          h5('')
        })
        output$mypi <- renderPlot({
          pie(1, labels = "", main = "Pie Chart of Samples Containing FSP Neoantigens", density = 5, init.angle = 45)
        })
        output$output5 <- renderUI({
          h5(paste('No data available in table for Pie Chart displaying selected MSI samples containing selected', input$dataname, 'FSPs with', input$var, 'categorization'))
        })
        output$output6 <- renderUI({
          h5('')
        })
        output$output7 <- renderUI({
          h5('')
        })
      }
    }
    #Setting criteria for MSI-low neoantigens
    else if(input$var == "MSI-low") {
      if(percentage_rank > 1) {
        qry1 <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE", paste0("'", tolower(input$dataname),"%' AND ", syfpeithi_score, " >= msi_val;"))
        df1 <- dbGetQuery(conn, qry1)
        output$myhist <- renderPlot({
          hist(df1[,2], breaks=20, col="blue", main="Histogram of FSP Dataset", xlab=names(df1[2]))
        })
        output$output2 <- renderUI({
          h5(paste('This data analysis displays selected FSP MSI values from selected', input$dataname, 'oncogenes with', input$var, 'categorization'))
        })
        output$output3 <- renderUI({
          h5(paste('The data is analyzed by control and variable tumor samples for novel neoantigen identification'))
        })
        output$output4 <- renderUI({
          h5(paste('Data incorperated with RShiny'))
        })
        qry4 <- paste("SELECT sample, count(sample) FROM msi_alignment_scores WHERE gene_name =", paste0("'", tolower(input$dataname),"' AND ", syfpeithi_score ," >= msi_val GROUP BY sample;"))
        df4 <- dbGetQuery(conn, qry4)
        output$mypi <- renderPlot({
          pie(df4[,2], labels = df4[,1], main = "Pie Chart of Samples Containing FSP Neoantigens")
        })
        output$output5 <- renderUI({
          h5(paste('This Pie Chart displays selected MSI samples containing selected', input$dataname, 'FSPs with', input$var, 'categorization'))
        })
        output$output6 <- renderUI({
          h5(paste('The data is analyzed by control and variable tumor samples for novel neoantigen identification'))
        })
        output$output7 <- renderUI({
          h5(paste('Data incorperated with RShiny'))
        })
      }
      else{
        output$myhist <- renderPlot({
          plot(1, type = "n", bty = "n", main="Histogram of FSP Dataset", xlab = "msi_val", ylab = "Frequency", xlim = c(0, 10), ylim = c(0, 10))
        })
        output$output2 <- renderUI({
          h5(paste('No data available in table for FSP MSI values from selected', input$dataname, 'oncogenes with', input$var, 'categorization'))
        })
        output$output3 <- renderUI({
          h5('')
        })
        output$output4 <- renderUI({
          h5('')
        })
        output$mypi <- renderPlot({
          pie(1, labels = "", main = "Pie Chart of Samples Containing FSP Neoantigens", density = 5, init.angle = 45)
        })
        output$output5 <- renderUI({
          h5(paste('No data available in table for Pie Chart displaying selected MSI samples containing selected', input$dataname, 'FSPs with', input$var, 'categorization'))
        })
        output$output6 <- renderUI({
          h5('')
        })
        output$output7 <- renderUI({
          h5('')
        })
      }
    }
    #Setting criteria for MSI-ambiguous/intermediate neoantigens
    else if(input$var == "MSI-ambiguous") {
      if(percentage_rank <= 1) {
        qry1 <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE", paste0("'", tolower(input$dataname),"%' AND ", syfpeithi_score, " >= msi_val;"))
        df1 <- dbGetQuery(conn, qry1)
        output$myhist <- renderPlot({
          hist(df1[,2], breaks=20, col="blue", main="Histogram of FSP Dataset", xlab=names(df1[2]))
        })
        output$output2 <- renderUI({
          h5(paste('This data analysis displays selected FSP MSI values from selected', input$dataname, 'oncogenes with', input$var, 'categorization'))
        })
        output$output3 <- renderUI({
          h5(paste('The data is analyzed by control and variable tumor samples for novel neoantigen identification'))
        })
        output$output4 <- renderUI({
          h5(paste('Data incorperated with RShiny'))
        })
        qry4 <- paste("SELECT sample, count(sample) FROM msi_alignment_scores WHERE gene_name =", paste0("'", tolower(input$dataname),"' AND ", syfpeithi_score ," >= msi_val GROUP BY sample;"))
        df4 <- dbGetQuery(conn, qry4)
        output$mypi <- renderPlot({
          pie(df4[,2], labels = df4[,1], main = "Pie Chart of Samples Containing FSP Neoantigens")
        })
        output$output5 <- renderUI({
          h5(paste('This Pie Chart displays selected MSI samples containing selected', input$dataname, 'FSPs with', input$var, 'categorization'))
        })
        output$output6 <- renderUI({
          h5(paste('The data is analyzed by control and variable tumor samples for novel neoantigen identification'))
        })
        output$output7 <- renderUI({
          h5(paste('Data incorperated with RShiny'))
        })
      }
      else if(percentage_rank > 1) {
        qry1 <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE", paste0("'", tolower(input$dataname),"%' AND ", syfpeithi_score, " < msi_val;"))
        df1 <- dbGetQuery(conn, qry1)
        output$myhist <- renderPlot({
          hist(df1[,2], breaks=20, col="blue", main="Histogram of FSP Dataset", xlab=names(df1[2]))
        })
        output$output2 <- renderUI({
          h5(paste('This data analysis displays selected FSP MSI values from selected', input$dataname, 'oncogenes with', input$var, 'categorization'))
        })
        output$output3 <- renderUI({
          h5(paste('The data is analyzed by control and variable tumor samples for novel neoantigen identification'))
        })
        output$output4 <- renderUI({
          h5(paste('Data incorperated with RShiny'))
        })
        qry4 <- paste("SELECT sample, count(sample) FROM msi_alignment_scores WHERE gene_name =", paste0("'", tolower(input$dataname),"' AND ", syfpeithi_score ," < msi_val GROUP BY sample;"))
        df4 <- dbGetQuery(conn, qry4)
        output$mypi <- renderPlot({
          pie(df4[,2], labels = df4[,1], main = "Pie Chart of Samples Containing FSP Neoantigens")
        })
        output$output5 <- renderUI({
          h5(paste('This Pie Chart displays selected MSI samples containing selected', input$dataname, 'FSPs with', input$var, 'categorization'))
        })
        output$output6 <- renderUI({
          h5(paste('The data is analyzed by control and variable tumor samples for novel neoantigen identification'))
        })
        output$output7 <- renderUI({
          h5(paste('Data incorperated with RShiny'))
        })
      }
      else{
        output$myhist <- renderPlot({
          plot(1, type = "n", bty = "n", main="Histogram of FSP Dataset", xlab = "msi_val", ylab = "Frequency", xlim = c(0, 10), ylim = c(0, 10))
        })
        output$output2 <- renderUI({
          h5(paste('No data available in table for FSP MSI values from selected', input$dataname, 'oncogenes with', input$var, 'categorization'))
        })
        output$output3 <- renderUI({
          h5('')
        })
        output$output4 <- renderUI({
          h5('')
        })
        output$mypi <- renderPlot({
          pie(1, labels = "", main = "Pie Chart of Samples Containing FSP Neoantigens", density = 5, init.angle = 45)
        })
        output$output5 <- renderUI({
          h5(paste('No data available in table for Pie Chart displaying selected MSI samples containing selected', input$dataname, 'FSPs with', input$var, 'categorization'))
        })
        output$output6 <- renderUI({
          h5('')
        })
        output$output7 <- renderUI({
          h5('')
        })
      }
    }
    output$output1 <- renderUI({
      h3(HTML(paste('Data Analysis for', input$var, 'Oncogene', input$dataname, 'List', '<b>(Scroll Down for Figures)</b>')))
    })
  })
  #Setting events to occur after clicking to exit analyze data results page
  observeEvent(input$backsearch, {
    showTab(inputId = "msitabs", target = "Home")
    showTab(inputId = "msitabs", target = "About")
    showTab(inputId = "msitabs", target = "Gene Search")
    showTab(inputId = "msitabs", target = "Analyze Data")
    showTab(inputId = "msitabs", target = "References")
    showTab(inputId = "msitabs", target = "Help")
    hideTab(inputId = "msitabs", target = "Analyze Data Figures")
    updateTabsetPanel(session, "msitabs", selected = "Analyze Data")
  })
  #Selecting MSI gene names, gene expression values, fsp bait sequences, 
  #SYFPEITHI Score, and percentage rank from database to appear in the help 
  #section of the webapp
  qry2 <- "SELECT gene_name, msi_val AS gene_expression, fsp_bait_sequence, SYFPEITHI_Score, percentage_rank FROM msi_gene 
  WHERE gene_name LIKE 'nacad' OR gene_name LIKE 'xirp1' OR gene_name LIKE '5730596b20rik'
  OR gene_name LIKE 'rif1' OR gene_name LIKE 'maz' OR gene_name LIKE 'hic1'
  OR gene_name LIKE 'sdccag1' OR gene_name LIKE 'tmem107' OR gene_name LIKE 'srcin1'
  OR gene_name LIKE 'marcks' OR gene_name LIKE 'senp6' OR gene_name LIKE 'phactr4'
  OR gene_name LIKE 'chrnb2';"
  df2 <- dbGetQuery(conn, qry2)
  output$table2 <- renderTable(df2)
}
)