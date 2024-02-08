#This script is running the application and sets up the server and the UI

packages <- c("shiny",
              "data.table",
              "survminer",
              "survival",
              "DT")
install.packages(setdiff(packages, rownames(installed.packages()))) 

if (!("dqshiny" %in% installed.packages())){
    install.packages("devtools")
    remotes::install_github("daqana/dqshiny")
}

library(shiny)
library(dqshiny)
library(data.table)
library(DT)
library(here)
library(survival)
library(survminer)

#TODO
#Introduce error message, if file couldn't be loaded
load(here("temp", "preprocessed_files", "clinical_data.Rds"))


#Making the autocomplete list from tissue_of_organ_of_origin
opts <- c(clinical_data$tissue_or_organ_of_origin)

#Launching the application
suppressWarnings(rm(ui, server))

ui <-  fluidPage(
    titlePanel(h3("CRCM Shiny app prototype")),
      tabsetPanel(
        tabPanel("Data overview",
          fluidRow(),
          fluidRow(),
          fluidRow(
            column(6, offset = 3, 
               autocomplete_input("origin_input", NULL, max_options = 100,
                                    #contains = TRUE,
                                    create = TRUE, 
                                    placeholder = "Start typing tissue or organ of origin",
                                    opts))),
          fluidRow(column(12, DTOutput('tbl')))),
        tabPanel("KM plots",
          fluidRow(),
          fluidRow(),
          fluidRow(),
          checkboxInput("show_all", "Show overall survival?", value = TRUE),
          
          selectInput("split_vars", "Select variables to compare cohorts",
                     choices = c(names(clinical_data)[sapply(clinical_data, is.factor)],
                                 names(clinical_data)[sapply(clinical_data, is.logical)]),
          #            multiple = TRUE, needs to elaborate logic, do not uncomment
          ),
          fluidRow(),
          fluidRow(
            column(6, offset = 3,
                   plotOutput("KM_plot"))
            )),
        tabPanel("Heatmaps"))
)


server <-  function(input, output) {
    
  #rendering the table
    data <- reactive({
        clinical_data[grep(input$origin_input, clinical_data$tissue_or_organ_of_origin)]
    })
    output$tbl <-  renderDT(data(),
                            options = list(lengthChange = TRUE,
                                           escape = FALSE,
                                           pageLength = 25,
                                           sDom  = '<"top">lrt<"bottom">ip'))
  
    KM_all <- survfit(Surv(days_to_death, vital_status) ~ 1, data = clinical_data)
    
    KM_split <- reactive({
      #survfit(Surv(days_to_death, vital_status) ~ input$split_vars, data = clinical_data) #it's not working, replaced with a placeholder
      survfit(Surv(days_to_death, vital_status) ~ prior_malignancy, data = clinical_data) #it's a placeholder
    })
    
    output$KM_plot <- renderPlot({
      if (input$show_all) {
        ggsurvplot_combine(list(KM_all, KM_split()), data = clinical_data)
      } else {
        ggsurvplot_combine(list(KM_split()), data = clinical_data)
      }
    })
    
}

shinyApp(ui, server)

