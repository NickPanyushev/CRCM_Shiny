packages <- c("shiny", "data.table", "devtools", "DT")
install.packages(setdiff(packages, rownames(installed.packages()))) 

if (!("dqshiny" %in% installed.packages())){
    remotes::install_github("daqana/dqshiny")
}

library(shiny)
library(dqshiny)
library(data.table)
library(DT)

input_table <- fread("https://bio-test-data.s3.amazonaws.com/Demo/RShiny/Homo+sapiens.csv")

# Prettiyng the input table, removing empty columns
input_table[input_table == ""] <- NA
tmp <- colSums(!is.na(input_table)) > 0
tmp <- names(tmp[tmp])
input_table <- input_table[, ..tmp]
rm(tmp)

#Making the autocomplete list from GO and genenames
input_table$go_term_label <- gsub("\"\"", "", input_table$go_term_label)
input_table$go_term_id <- gsub("GO:", "", input_table$go_term_id)
input_table$hgnc_description <- gsub("\"\"", "", input_table$hgnc_description, )
input_table$hgnc_id <- gsub("HGNC:", "", input_table$hgnc_id)
input_table <- unique(input_table)

input_table[, sum_GO_terms := paste(go_term_label, sep = ","), by = gene_symbol]
input_table$sum_GO_terms <- sapply(input_table$sum_GO_terms, function(x) unique(x))


input_table[, sum_GO_ids := paste(go_term_id, sep = ","), by = gene_symbol]
input_table$sum_GO_ids <- sapply(input_table$sum_GO_ids, function(x) unique(x))

input_table[input_table == "NA"] <- NA

input_table$go_term_label <- NULL
input_table$go_term_id <- NULL

setnames(input_table, c("sum_GO_ids", "sum_GO_terms"), c("go_term_id", "go_term_label"))


tmp <- unlist(strsplit(input_table$go_term_label, ",", fixed = T))
tmp <- unique(tmp)
tmp <- tmp[!is.na(tmp)]
opts <- c(input_table$gene_symbol, tmp)
rm(tmp)

rm(ui, server)

ui <-  fluidPage(
    titlePanel(h3("Test task for GeneStack")),
    fluidRow(),
    fluidRow(),
    fluidRow(
        column(6, offset = 3, 
               autocomplete_input("geneinput", NULL, max_options = 100,
                                  #contains = TRUE,
                                  create = TRUE, 
                                  placeholder = "Start typing gene name or GO term",
                                  opts
               ))),
    
    fluidRow(column(12, DTOutput('tbl')))
) 

server <-  function(input, output) {
    
    data <- reactive({
        rbind(input_table[grep(input$geneinput, input_table$go_term_label), .(gene_symbol, gene_synonyms, go_term_label)],
        input_table[grep(input$geneinput, input_table$gene_symbol), .(gene_symbol, gene_synonyms, go_term_label)])
    })
    output$tbl <-  renderDT(data(),
                            options = list(lengthChange = TRUE,
                                           escape = FALSE,
                                           pageLength = 25,
                                           sDom  = '<"top">lrt<"bottom">ip'))
    
}


shinyApp(ui, server)

