#This script is running the application and sets up the server and the UI

packages <- c("shiny", "data.table", "devtools", "DT")
install.packages(setdiff(packages, rownames(installed.packages()))) 

if (!("dqshiny" %in% installed.packages())){
    remotes::install_github("daqana/dqshiny")
}

library(shiny)
library(dqshiny)
library(data.table)
library(DT)
library(here)

#TODO
#Introduce error message, if file couldn't be loaded
load(here("temp", "preprocessed_files", "clinical_data.Rds"))


#Making the autocomplete list from tissue_of_organ_of_origin
opts <- c(clinical_data$tissue_or_organ_of_origin)


#Launching the application
suppressWarnings(rm(ui, server))

ui <-  fluidPage(
    titlePanel(h3("CRCM Shiny app prototype")),
    fluidRow(),
    fluidRow(),
    fluidRow(
        column(6, offset = 3, 
               autocomplete_input("origin_input", NULL, max_options = 100,
                                  #contains = TRUE,
                                  create = TRUE, 
                                  placeholder = "Start typing tissue or organ of origin",
                                  opts
               ))),
    
    fluidRow(column(12, DTOutput('tbl')))
) 

server <-  function(input, output) {
    
    data <- reactive({
        clinical_data[grep(input$origin_input, clinical_data$tissue_or_organ_of_origin)]
    })
    output$tbl <-  renderDT(data(),
                            options = list(lengthChange = TRUE,
                                           escape = FALSE,
                                           pageLength = 25,
                                           sDom  = '<"top">lrt<"bottom">ip'))
    
}


shinyApp(ui, server)

