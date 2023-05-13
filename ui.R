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
shinyUI(fluidPage(theme = shinytheme("yeti"),
    #Sidebar panel
  tabsetPanel(id = "msitabs",
    tabPanel("Home",
      sidebarLayout(
        sidebarPanel(width = 6,
          h4("Welcome to the MSI Gene Database"), 
          h5("Web Development in Advanced Bioinformatics"),
          actionButton("homesearch", "Go To Search")),
        mainPanel(width = 6
        )
      )
    ),
    tabPanel("About",
      sidebarLayout(
        sidebarPanel(width = 6,
          h4("About MSI Gene Database"), 
          h5("This Database will display and graph selected FSP neoantigens from target MSI genes"),
          h5("The data is searchable by gene name and MSI-categorization with the ability to limit search results"),
          h5("RShiny is Functional")
        ),
        mainPanel(width = 6
        )
      )
    ),
    tabPanel("Gene Search", 
      sidebarLayout(
        sidebarPanel(width = 6,       
          h3("Gene Search:"), h3("MSI Gene Database Search Form"), 
          h5("MSI Categorization"), selectInput("var1", "", choices = c("MSI-high", "MSI-low", "MSI-ambiguous")), 
          h5("Enter MSI Gene Name"), textInput("name", "", ""),
          h5("Limit Search Results By"), selectInput("var2", "", choices = c("1", "5", "10", "50", "100")), 
          actionButton("Genesearch", "Submit")),
        mainPanel(width = 6,
          h3("MSI Gene Database Search Results"),
          h4("List of MSI Genes"),
          DT::dataTableOutput("table")
        )
      )
    ),
    tabPanel("Analyze Data",
      sidebarLayout(
        sidebarPanel(width = 12,
          h3("Graphic Analysis:"), 
          h3("MSI Gene Graphic Analysis Form"), h5("MSI Categorization"), 
          selectInput("var", "", choices = c("MSI-high", "MSI-low", "MSI-ambiguous")),
          h5("Enter MSI Gene Name"), textInput("dataname", "", ""),
          actionButton("Analyzedata", "Analyze Data")),
        mainPanel(width = 0)
      )
    ),
    tabPanel("Analyze Data Figures",
      sidebarLayout(
        sidebarPanel(width = 0),
        mainPanel(width = 12,
          uiOutput('output1'),
          plotOutput("myhist"),
          uiOutput('output2'),
          uiOutput('output3'),
          uiOutput('output4'),
          br(),
          plotOutput("mypi"),
          uiOutput('output5'),
          uiOutput('output6'),
          uiOutput('output7'),
          br(),
          fluidRow(
            column(6, align="center", offset=3,
              actionButton("backsearch", "Back To Search")),
          ),
          br()
        )
      )
    ),
    tabPanel("References",
      sidebarLayout(
        sidebarPanel(width = 6,
          h4("References for MSI Gene Database"), 
          h5("Research Articles"),
          h5(HTML("Ballhausen, Alexej, et al. “The Shared Frameshift Mutation Landscape of Microsatellite-<p> 
          &emsp;Unstable Cancers Suggests Immunoediting during Tumor Evolution.” Nature<p> 
          &emsp;Communications, U.S. National Library of Medicine, 21 Sept. 2020,<p>")),
          tags$a(href="https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7506541/", target = "_blank", HTML("&emsp;https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7506541/.")),
          h5(HTML("Gebert J;Gelincik O;Oezcan-Wahlbrink M;Marshall JD;Hernandez-Sanchez A;Urban K;Long<p> 
          &emsp;M;Cortes E;Tosti E;Katzenmaier EM;Song Y;Elsaadi A;Deng N;Vilar E;Fuchs V;Nelius<p> 
          &emsp;N;Yuan YP;Ahadova A;Sei S;Shoemaker RH;Umar A;Wei L;Liu S;Bork P;Edelmann<p>
          &emsp;W;von Knebel Doe. “Recurrent Frameshift Neoantigen Vaccine Elicits Protective<p>
          &emsp;Immunity with Reduced Tumor Burden and Improved Overall Survival in a Lynch<p>
          &emsp;Syndrome Mouse Model.” Gastroenterology, U.S. National Library of Medicine,<p>")),
          tags$a(href="https://pubmed.ncbi.nlm.nih.gov/34224739/", target = "_blank", HTML("&emsp;https://pubmed.ncbi.nlm.nih.gov/34224739/.")),
          h5("Data Sources"),
          h5("Software libraries"),
          h5("Programming tools/languages etc.")
        ),
        mainPanel(width = 6
        )
      )
    ),
    tabPanel("Help",
      sidebarLayout(
        sidebarPanel(width = 6,
          h4("Help for MSI Gene Database"),
          h5("This page contains help for executing searches and analyzing results"),
          h5("The data is searchable by MSI categorization and gene name with the ability to limit search results"),
          tableOutput("table2"),
          h6(HTML("<b>Genes affected by cMNR FS mutations and derived FSPs. 
             Predicted immunoscores for neoantigens aligned with a 7-10 
             amino acid wild-type (WT) bait sequence for genes on C57BL/6 alleles 
             H2-Db and H2-Kb (with assosciated SYFPEITHI scoring). The numbers of MSI-high, MSI-low, and MSI-ambiguous are calculated from low numbers of percentage rank (<1), as well as MSI values > SYFPEITHI scores, predict Msi-high neoantigens.</b>"))
        ),
        mainPanel(width = 6
        )
      )
    )
  )
)
)