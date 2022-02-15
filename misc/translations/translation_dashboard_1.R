# Find all strings that are arguments of i18n$t("").
library(readr)
library(stringr)
library(purrr)
library(tidyverse)
library(writexl)

# (Informational) Nb of lines of code.
vec <- sapply(files, R.utils::countLines)
glue("Total lines of R code: {sum(vec)}")

# All elements to translate:
files <- list.files(path = "./inst/acorn/www/", pattern = "\\.R$", recursive = TRUE)
files <- c("./inst/acorn/app.R", paste0("./inst/acorn/www/", files))
script <- map(files, read_lines, n_max = -1L) |> unlist()
vec_double <- str_extract_all(script, '(?<=n\\$t\\(")(.*?)(?=\")') |> unlist() |> unique() |> sort()
vec_single <- str_extract_all(script, "(?<=n\\$t\\(')(.*?)(?=\')") |> unlist() |> unique() |> sort()
all_elements <- c(vec_double, vec_single) |> as_tibble() |> dplyr::rename(en = value)

# Existing translated elements in the app
update_translation <- function(file_provided, file_updated, file_to_share) {
  original <- readxl::read_excel(path = file_provided)
  
  update <- full_join(all_elements, original, by = "en") |> 
    mutate(status = case_when(
      en %in% setdiff(as.vector(original$en), all_elements$en) ~ "deleted",  # elements in original$en that are not in all_elements
      en %in% setdiff(all_elements$en, as.vector(original$en)) ~ "new",  # elements in all_elements that are not in original$en
      TRUE ~ ""
    )) 
  
  update[which(is.na(update[, 2])), 2] <- "TBT"
  update |> filter(status != "deleted") |> select(-status) |> mutate() |> write_xlsx(file_updated)
  update |> write_xlsx(file_to_share)
}

update_translation(
  file_provided  = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_kh.xlsx",
  file_updated       = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_kh_maj.xlsx",
  file_to_share = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_kh_elements_to_update.xlsx"
)

update_translation(
  file_provided  = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_fr.xlsx",
  file_updated       = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_fr_maj.xlsx",
  file_to_share = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_fr_elements_to_update.xlsx"
)

update_translation(
  file_provided  = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_la.xlsx",
  file_updated       = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_la_maj.xlsx",
  file_to_share = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_la_elements_to_update.xlsx"
)

update_translation(
  file_provided  = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_vn.xlsx",
  file_updated       = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_vn_maj.xlsx",
  file_to_share = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_vn_elements_to_update.xlsx"
)

update_translation(
  file_provided  = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_ba.xlsx",
  file_updated       = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_ba_maj.xlsx",
  file_to_share = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_ba_elements_to_update.xlsx"
)
