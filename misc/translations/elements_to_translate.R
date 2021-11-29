# Find all strings that are arguments of i18n$t("").
library(readr)
library(stringr)
library(purrr)


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

# Existing translated elemets in the app
en_kh <- readxl::read_excel(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_kh.xlsx")


# Possibly required to update the font in Excel:
full_join(all_elements, en_kh, by = "en") |> 
  mutate(status = case_when(
    en %in% setdiff(en_kh$en, vec) ~ "deleted",  # elements in en_kh$en that are not in vec
    en %in% setdiff(vec, en_kh$en) ~ "new",  # elements in vec that are not in en_kh$en
    TRUE ~ ""
  )) |> 
  write_xlsx("/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_kh_elements_to_update.xlsx")
