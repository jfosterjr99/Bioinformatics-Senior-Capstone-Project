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
db <- "myadvproject"
db_host <- "localhost"
db_port <- "5432"
db_user <- "postgres"
db_pass <- "123"

conn <- dbConnect(
  RPostgres::Postgres(),
  dbname = db,
  host = db_host,
  port = db_port,
  user = db_user,
  password = db_pass
)

shinyServer(function(input, output, session) {
  hideTab(inputId = "msitabs", target = "Analyze Data Figures")
  observeEvent(input$homesearch, {
    updateTabsetPanel(session, "msitabs", selected = "Gene Search")
  })
  observeEvent(input$Genesearch, {
    qry <- paste("SELECT gene_name, msi_val, upperalignment, loweralignment, sample, mononucseq FROM msi_alignment_scores WHERE gene_name LIKE", paste0("'", tolower(input$name),"%'"), "LIMIT", paste0(input$var2, ";"))
    df <- dbGetQuery(conn, qry)
    output$table <- DT::renderDataTable({
      DT::datatable(df)
    })
  })
  observeEvent(input$Analyzedata, {
    hideTab(inputId = "msitabs", target = "Home")
    hideTab(inputId = "msitabs", target = "About")
    hideTab(inputId = "msitabs", target = "Gene Search")
    hideTab(inputId = "msitabs", target = "Analyze Data")
    hideTab(inputId = "msitabs", target = "References")
    hideTab(inputId = "msitabs", target = "Help")
    showTab(inputId = "msitabs", target = "Analyze Data Figures")
    updateTabsetPanel(session, "msitabs", selected = "Analyze Data Figures")
    qry1 <- paste("SELECT * FROM msi_alignment_scores WHERE gene_name LIKE", paste0("'", tolower(input$dataname),"%';"))
    df1 <- dbGetQuery(conn, qry1)
    print(df1)
    output$myhist <- renderPlot({
      hist(df1[,2], breaks=20, col="blue", main="Histogram of FSP Dataset", xlab=names(df1[2]))
    })
    output$myhist2 <- renderPlot({
      hist(df1[,2], breaks=10, col="blue", main="Histogram of FSP Dataset 2", xlab=names(df1[2]))
    })
    output$myhist3 <- renderPlot({
      hist(df1[,2], breaks=5, col="blue", main="Histogram of FSP Dataset 3", xlab=names(df1[2]))
    })
    qry4 <- paste("SELECT sample, count(sample) FROM msi_alignment_scores WHERE gene_name =", paste0("'", tolower(input$dataname),"' GROUP BY sample;"))
    print(qry4)
    df4 <- dbGetQuery(conn, qry4)
    print(df4)
    output$mypi <- renderPlot({
      pie(df4[,2], labels = df4[,1])
    })
    output$output1 <- renderUI({
      h3(HTML(paste('Data Analysis for', input$var, 'Oncogene', input$dataname, 'List', '<b>(Scroll Down for Figures)</b>')))
    })
    output$output2 <- renderUI({
      h5(paste('This data analysis displays selected FSP MSI values from selected oncogenes with', input$var, 'categorization'))
    })
    output$output3 <- renderUI({
      h5(paste('The data is analyzed by control and variable tumor samples for novel neoantigen identification'))
    })
    output$output4 <- renderUI({
      h5(paste('Data incorperated with RShiny'))
    })
    output$output5 <- renderUI({
      h5(paste('This Pi Chart displays selected MSI samples containing selected FSPs with', input$var, 'categorization'))
    })
    output$output6 <- renderUI({
      h5(paste('The data is analyzed by control and variable tumor samples for novel neoantigen identification'))
    })
    output$output7 <- renderUI({
      h5(paste('Data incorperated with RShiny'))
    })
  })
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
  qry2 <- "SELECT gene_name, msi_val FROM msi_gene WHERE gene_name LIKE 'Xirp1%' OR gene_name LIKE 'Nacad%';"
  df2 <- dbGetQuery(conn, qry2)
  output$table2 <- renderTable(df2)
}
)