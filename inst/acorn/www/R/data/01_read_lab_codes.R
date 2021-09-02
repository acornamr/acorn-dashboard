file_lab_code <- try(save_object(object = "ACORN2_lab_codes.xlsx",
                                 bucket = "shared-acornamr", 
                                 key    = shared_acornamr_key,
                                 secret = shared_acornamr_sec,
                                 region = "eu-west-3",
                                 file = tempfile()), silent = TRUE)

if (inherits(file_lab_code, 'try-error')) {
  showNotification(i18n$t("We couldn't download the lab codes file. Please contact ACORN support."), type = "error", duration = NULL)
  return()
}

read_lab_code <- function(sheet) read_excel(file_lab_code, sheet = sheet, 
                                            col_types = c("text", "text", "text", "text", "text", "numeric", "numeric", "text", "text"), 
                                            na = "NA")

lab_code <- list(
  whonet.spec = read_excel(file_lab_code, sheet = "spectypes.whonet"),
  orgs.antibio = read_excel(file_lab_code, sheet = "orgs.antibio"),
  whonet.orgs = read_excel(file_lab_code, sheet = "orgs.whonet"),
  acorn.bccontaminants = read_excel(file_lab_code, sheet = "acorn.bccontaminants"), # [UPDATED ACORN2]
  acorn.ast.groups = read_excel(file_lab_code, sheet = "acorn.ast.groups"),
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
  notes = read_excel(file_lab_code, sheet = "notes", skip = 1, col_names = paste("Notes", 1:3), col_types = "text")
)
