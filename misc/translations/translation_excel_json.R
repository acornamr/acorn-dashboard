library(RJSONIO)
library(tidyverse)
library(plyr)  # important to load after tidyverse/dplyr
library(readxl)
library(writexl)

# JSON to Excel files ----
# json_file = RJSONIO::fromJSON("./misc/translations/translation_excel.json")
# 
# trans <- json_file$translation
# trans_df <- plyr::ldply(trans)
# 
# trans_df |> 
#   select(en, fr) |> 
#   writexl::write_xlsx(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_fr.xlsx")
# 
# trans_df |> 
#   select(en, la) |> 
#   writexl::write_xlsx(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_la.xlsx")
# 
# trans_df |> 
#   select(en, kh) |> 
#   writexl::write_xlsx(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_kh.xlsx")
# 
# trans_df |> 
#   select(en, vn) |> 
#   writexl::write_xlsx(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_vn.xlsx")
# 
# trans_df |> 
#   select(en, ba) |> 
#   writexl::write_xlsx(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_ba.xlsx")



# Excel files to JSON ----
en_fr <- read_excel(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_fr.xlsx")
en_la <- read_excel(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_la.xlsx")
en_kh <- read_excel(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_kh.xlsx")
en_vn <- read_excel(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_vn.xlsx")
en_ba <- read_excel(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/translations/en_ba.xlsx")

if(any(en_fr$en != en_la$en) | any(en_la$en != en_kh$en) | any(en_kh$en != en_vn$en) | any(en_vn$en != en_ba$en))  warning("Excel file en columns do not match!")

# ===============================================================================
# IMPORTANT: once updated, replace translation.json in the www/translations folder
# ===============================================================================

list(languages = c("en", "fr", "la", "kh", "vn", "ba"),
     translation = bind_cols(en_fr, 
                             en_la %>% select(la),
                             en_kh %>% select(kh),
                             en_vn %>% select(vn),
                             en_ba %>% select(ba)) |> 
       purrr::transpose()) |> 
  RJSONIO::toJSON(pretty = TRUE) |> 
  write(file = "./misc/translations/translation.json")
