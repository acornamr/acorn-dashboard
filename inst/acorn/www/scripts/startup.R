app_version <- "prototype.001"  # IMPORTANT ensure that the version is identical in DESCRIPTION and README.md

cols_sir <- c("#2c3e50", "#f39c12", "#e74c3c")  # resp. S, I, R
# cols_sir <- c("#2166ac", "#fddbc7", "#b2182b")  # resp. S, I, R
hc_export_kind <- c("downloadJPEG", "downloadCSV")

source("./www/scripts/load_packages.R", local = TRUE)

session_start_time <- format(Sys.time(), "%Y-%m-%d_%HH%M")
session_id <- glue("{glue_collapse(sample(LETTERS, 5, TRUE))}_{session_start_time}")

# Read data dictionnary
message("Read data dictionary")

path_data_dictionary_file <- "www/data/ACORN2_lab_data_dictionary_2021-05-02.xlsx"
data_dictionary <- list()
data_dictionary$variables <- read_excel(path_data_dictionary_file, sheet = "variables")
data_dictionary$test.res <- read_excel(path_data_dictionary_file, sheet = "test.results")
data_dictionary$local.spec <- read_excel(path_data_dictionary_file, sheet = "spec.types")
data_dictionary$local.orgs <- read_excel(path_data_dictionary_file, sheet = "organisms")
data_dictionary$notes <- read_excel(path_data_dictionary_file, sheet = "notes",
                                    col_types = "text", skip = 1, col_names = c("_", "Valeur"))

# Read lab codes and AST breakpoint data
message("Read lab codes and AST breakpoint data")

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
bucket_cred_k <- readRDS("./www/cred/bucket_cred_k.Rds")
bucket_cred_s <- readRDS("./www/cred/bucket_cred_s.Rds")

# contains all require i18n elements
source('./www/scripts/indicate_translation.R', local = TRUE)
for(file in list.files('./www/functions/'))  source(paste0('./www/functions/', file), local = TRUE)  # define all functions

acorn_theme <- bs_theme(bootswatch = "flatly", version = 4, "border-width" = "2px")
acorn_theme_la <- bs_theme(bootswatch = "flatly", version = 4, "border-width" = "2px", base_font = "Phetsarath OT")

h4_title <- function(...)  div(class = "h4_title", ...)

tab <- function(...) {
  shiny::tabPanel(..., class = "p-3 border border-top-0 rounded-bottom")
}