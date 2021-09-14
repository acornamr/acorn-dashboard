# IMPORTANT: once updated, replace translation.json in the www/translations folder

library(RJSONIO)
library(plyr)
library(tidyverse)
library(writexl)

# JSON to Excel files ----
json_file = RJSONIO::fromJSON("./misc/translation.json")

trans <- json_file$translation
trans_df <- plyr::ldply(trans)

trans_df |> 
  select(en, fr) |> 
  writexl::write_xlsx(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/en_fr.xlsx")

trans_df |> 
  select(en, la) |> 
  writexl::write_xlsx(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/en_la.xlsx")

trans_df |> 
  select(en, vn) |> 
  writexl::write_xlsx(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/en_vn.xlsx")

trans_df |> 
  select(en, ba) |> 
  writexl::write_xlsx(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/en_ba.xlsx")



# Excel files to JSON ----
en_fr <- read_excel(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/en_fr.xlsx")
en_la <- read_excel(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/en_la.xlsx")
en_vn <- read_excel(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/en_vn.xlsx")
en_ba <- read_excel(path = "/Users/olivier/Documents/Projets/ACORN/acorn-dashboard/misc/en_ba.xlsx")

if(any(en_fr$en != en_la$en) | any(en_la$en != en_vn$en) | any(en_vn$en != en_ba$en))  warning("Excel file en columns do not match!")

list(languages = c("en", "fr", "la", "vn", "ba"),
     translation = bind_cols(en_fr, 
                             en_la %>% select(la),
                             en_vn %>% select(vn),
                             en_ba %>% select(ba)) |> 
       purrr::transpose()) |> 
  RJSONIO::toJSON(pretty = TRUE) |> 
  write(file = "./misc/translation_excel.json")

# IMPORTANT: once updated, replace translation.json in the www/translations folder
