#This script is intended for collecting data from TCGA and storing it in the temporary files

packages <- c("data.table", "devtools", "DT")
install.packages(setdiff(packages, rownames(installed.packages())))

#TODO
#Checking if TCGAbiolinks is not installed



if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("TCGAbiolinks")
library(TCGAbiolinks)

#Here I will perform some experiments with the retrieving data from TCGA
project_name <- "TCGA-PAAD"


#This will download only clinical data from TCGA portal
clinical_data <- GDCquery_clinic(project_name)


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
data <- GDCprepare(query = query.my)
