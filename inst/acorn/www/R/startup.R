message("Start ACORN shiny app.")

app_version <- "prototype.001"  # IMPORTANT ensure that the version is identical in DESCRIPTION and README.md

cols_sir <- c("#2c3e50", "#f39c12", "#e74c3c")  # resp. S, I, R
# cols_sir <- c("#2166ac", "#fddbc7", "#b2182b")  # resp. S, I, R
hc_export_kind <- c("downloadJPEG", "downloadCSV")

# IMPORTANT: packages listed here should be synced with run_app.R and DESCRIPTION
library(aws.s3)
library(bslib)  # bs_theme()
library(curl)
library(DBI)  # to read lab data
library(DT)
library(flexdashboard)  # gaugeOutput()
library(glue)
library(highcharter)
library(lubridate)
library(openssl)
library(readr)  # to read lab data
library(readxl)  # to read lab data
library(REDCapR)  # to read clinical data
library(RSQLite)  # to read lab data
library(rmarkdown)  # pandoc_available()
library(shiny)
library(shinyanimate)
library(shiny.i18n)  # i18n$t()
library(shinyjs)
library(shinyWidgets)  # chooseSliderSkin()
library(tidyverse)
library(writexl)

session_start_time <- format(Sys.time(), "%Y-%m-%d_%HH%M")
session_id <- glue("{glue_collapse(sample(LETTERS, 5, TRUE))}_{session_start_time}")

# Read data dictionnary, one unique file for all sites
message("List data dictionaries files.")
files_data_dictionary <- list.files('./www/data/data_dictionary/')

# Read lab codes and AST breakpoint data
message("Read lab codes and AST breakpoint data.")

path_lab_code_file <- "www/data/ACORN2_lab_codes_2021-05-02.xlsx"
read_lab_code <- function(sheet) read_excel(path_lab_code_file, sheet = sheet, 
                                            col_types = c("text", "text", "text", "text", "text", "numeric", "numeric", "text", "text"), na = "NA")

lab_code <- list(
  whonet.spec = read_excel(path_lab_code_file, sheet = "spectypes.whonet"),
  orgs.antibio = read_excel(path_lab_code_file, sheet = "orgs.antibio"),
  whonet.orgs = read_excel(path_lab_code_file, sheet = "orgs.whonet"),
  acorn.bccontaminants = read_excel(path_lab_code_file, sheet = "acorn.bccontaminants"), # [UPDATED ACORN2]
  acorn.ast.groups = read_excel(path_lab_code_file, sheet = "acorn.ast.groups"),
  ast.aci = read_lab_code(sheet = "aci"),  # Gram negatives - Acinetobacter
  ast.col = read_lab_code(sheet = "col"),   # Enterobacteriaceae (all)
  ast.hin = read_lab_code(sheet = "hin"),  # Haemophilus influenzae
  ast.ngo = read_lab_code(sheet = "ngo"),  # Neisseria gonorrhoeae
  ast.nmen = read_lab_code(sheet = "nmen"),  # Neisseria meningitidis
  ast.pae = read_lab_code(sheet = "pae"),  # Pseudomonas aeruginosa
  ast.sal = read_lab_code(sheet = "sal"),  # Salmonella sp (all)
  ast.shi = read_lab_code(sheet = "shi"),  # Shigella sp
  ast.ent = read_lab_code(sheet = "ent"),  # Gram positives - Enterococcus sp (all)
  ast.sau = read_lab_code(sheet = "sau"),  # Staphylococcus aureus
  ast.spn = read_lab_code(sheet = "spn"),  # Streptococcus pneumoniae
  notes = read_excel(path_lab_code_file, sheet = "notes", skip = 1, col_names = paste("Notes", 1:3), col_types = "text")
)

# It's safe to expose those since the acornamr-cred bucket content can only be listed + read 
# and contains only encrypted files
bucket_cred_key <- readRDS("./www/cred/bucket_cred/bucket_cred_key.Rds")
bucket_cred_sec <- readRDS("./www/cred/bucket_cred/bucket_cred_sec.Rds")

# contains all require i18n elements
i18n <- Translator$new(translation_csvs_path = './www/translations/')
i18n$set_translation_language('en')

for(file in list.files('./www/R/functions/'))  source(paste0('./www/R/functions/', file), local = TRUE)  # define all functions

acorn_theme <- bs_theme(bootswatch = "flatly", version = 4, "border-width" = "2px")
acorn_theme_la <- bs_theme(bootswatch = "flatly", version = 4, "border-width" = "2px", base_font = "Phetsarath OT")

h4_title <- function(...)  div(class = "h4_title", ...)

tab <- function(...) {
  shiny::tabPanel(..., class = "p-3 border border-top-0 rounded-bottom")
}