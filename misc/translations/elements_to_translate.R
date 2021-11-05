# Find all strings that are arguments of i18n$t("").
library(readr)
library(stringr)
library(purrr)


files <- list.files(path = "./inst/acorn/www/", pattern = "\\.R$", recursive = TRUE)

files <- c("./inst/acorn/app.R", paste0("./inst/acorn/www/", files))
           


script <- map(files, read_lines, n_max = -1L) |> unlist()

script <- read_lines("./inst/acorn/app.R", skip = 0, n_max = -1L)

vec <- str_extract_all(script, '(?<=n\\$t\\(")(.*?)(?=\")') |> unlist() |> unique() |> sort()


# should also include the elements in i18n_r() - have to do it manually
# translate - [ ] dropdown duplication of isolate / 
#           - [ ] dropdown heuristic

en_fr <- readxl::read_excel(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_fr.xlsx")

setdiff(en_fr$en, vec)
setdiff(vec, en_fr$en)
