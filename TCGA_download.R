#This script is intended for collecting data from TCGA, 
# preprocessing it
# and storing it in temporary files

packages <- c("data.table", "here")
install.packages(setdiff(packages, rownames(installed.packages())))


#Checking if TCGAbiolinks is not installed and installing if necessary
if (!requireNamespace("TCGAbiolinks", quietly = TRUE)) {
  if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
  BiocManager::install("TCGAbiolinks")
}

#loading libraries 
library(TCGAbiolinks)
library(data.table)
library(here) #this library allows to make portable file structures
here::i_am("TCGA_download.R") #let it locate the root directory by finding Rproj file

#Here I will perform some experiments with the retrieving data from TCGA
project_name <- "TCGA-PAAD"


#This will download only clinical data from TCGA portal
#TODO
#Add check if the file exists
clinical_data <- GDCquery_clinic(project_name)
clinical_data <- as.data.table(clinical_data)

#Let's make 2 variables as factors to select on
#prior_malignancy and primary_diagnosis

clinical_data$prior_malignancy <- ifelse(clinical_data$prior_malignancy == "yes", TRUE, FALSE)
clinical_data$primary_diagnosis <- as.factor(clinical_data$primary_diagnosis)

#Preparing data to build KM_plot
clinical_data$days_to_death <- as.numeric(clinical_data$days_to_death)
clinical_data[vital_status == "Alive", vital_status := 0]
clinical_data[vital_status == "Dead", vital_status := 1]
clinical_data$vital_status <- as.numeric(clinical_data$vital_status)


#Saving clinical_data file to the filesystem
dir.create(here("temp", "preprocessed_files"), recursive = TRUE)
clin_data_file <- here("temp", "preprocessed_files", "clinical_data.Rds")

save(clinical_data, file = clin_data_file)


#Commented out as it is not necessary RN - it's transcriptome data thing
#This block downloads the project altogether (~700 mb)
# query.my <- GDCquery(
#   project = project_name,
#   access = "open",
#   data.category = "Transcriptome Profiling",
#   data.type = "Gene Expression Quantification",
#   experimental.strategy = "RNA-Seq",
#   workflow.type = "STAR - Counts")
# 
# # download files
# GDCdownload(query.my)
# 
# #Prepare the table
# all_TCGA_data <- GDCprepare(query = query.my)

#Clinical data cleanup to coerce data.types and remove the empty columns
