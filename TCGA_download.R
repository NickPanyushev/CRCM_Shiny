#This script is intended for collecting data from TCGA and storing it in the temporary files

packages <- c("data.table", "devtools", "DT")
install.packages(setdiff(packages, rownames(installed.packages())))


#Checking if TCGAbiolinks is not installed and installing if necessary
if ("TCGAbiolinks" %in% rownames(installed.packages())) {
  if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
  BiocManager::install("TCGAbiolinks")
}

#loading libraries 
library(TCGAbiolinks)
library(data.table)
library(DT)

#Here I will perform some experiments with the retrieving data from TCGA
project_name <- "TCGA-PAAD"


#This will download only clinical data from TCGA portal
clinical_data <- GDCquery_clinic(project_name)

s
#This block downloads the project altogether (~700 mb)
query.my <- GDCquery(
  project = project_name,
  access = "open",
  data.category = "Transcriptome Profiling",
  data.type = "Gene Expression Quantification",
  experimental.strategy = "RNA-Seq",
  workflow.type = "STAR - Counts")

# download files
GDCdownload(query.my)

#Prepare the table
all_TCGA_data <- GDCprepare(query = query.my)
