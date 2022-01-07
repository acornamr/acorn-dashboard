# Find all strings that are arguments of i18n$t("").
library(readr)
library(stringr)
library(purrr)
library(tidyverse)
library(writexl)


# All elements to translate:
files <- list.files(path = "./inst/acorn/www/", pattern = "\\.R$", recursive = TRUE)
files <- c("./inst/acorn/app.R", paste0("./inst/acorn/www/", files))
script <- map(files, read_lines, n_max = -1L) |> unlist()
vec_double <- str_extract_all(script, '(?<=n\\$t\\(")(.*?)(?=\")') |> unlist() |> unique() |> sort()
vec_single <- str_extract_all(script, "(?<=n\\$t\\(')(.*?)(?=\')") |> unlist() |> unique() |> sort()
all_elements <- c(vec_double, vec_single) |> as_tibble() |> dplyr::rename(en = value)

# Nice to translate at some point:
# - [ ] dropdown duplication of isolate / 
# - [ ] dropdown heuristic

# Existing translated elements in the app
update_translation <- function(fichier_original, fichier_maj, fichier_to_update) {
  original <- readxl::read_excel(path = fichier_original)
  
  update <- full_join(all_elements, original, by = "en") |> 
    mutate(status = case_when(
      en %in% setdiff(as.vector(original$en), all_elements$en) ~ "deleted",  # elements in original$en that are not in all_elements
      en %in% setdiff(all_elements$en, as.vector(original$en)) ~ "new",  # elements in all_elements that are not in original$en
      TRUE ~ ""
    )) 
  
  update[which(is.na(update[, 2])), 2] <- "TBT"
  update |> filter(status != "deleted") |> select(-status) |> mutate() |> write_xlsx(fichier_maj)
  update |> write_xlsx(fichier_to_update)
}

update_translation(
  fichier_original  = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_kh.xlsx",
  fichier_maj       = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_kh_maj.xlsx",
  fichier_to_update = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_kh_elements_to_update.xlsx"
)

update_translation(
  fichier_original  = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_fr.xlsx",
  fichier_maj       = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_fr_maj.xlsx",
  fichier_to_update = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_fr_elements_to_update.xlsx"
)

update_translation(
  fichier_original  = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_la.xlsx",
  fichier_maj       = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_la_maj.xlsx",
  fichier_to_update = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_la_elements_to_update.xlsx"
)

update_translation(
  fichier_original  = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_vn.xlsx",
  fichier_maj       = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_vn_maj.xlsx",
  fichier_to_update = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_vn_elements_to_update.xlsx"
)

update_translation(
  fichier_original  = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_ba.xlsx",
  fichier_maj       = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_ba_maj.xlsx",
  fichier_to_update = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_ba_elements_to_update.xlsx"
)
