message("04_map_specimens.R")

amr <- left_join(amr %>%
                   mutate(spectype.whonet = as.numeric(spectype.whonet)), 
                 lab_code$whonet.spec %>% select(NUMERIC, acorn.spec.code), 
                 by = c('spectype.whonet' = 'NUMERIC')) %>%
  rename(spec.code1 = acorn.spec.code)

local.spec <- data_dictionary$local.spec %>%
  select(acorn.spec.code, local.spec.code1:ncol(data_dictionary$local.spec)) %>%  # This code allows for columns to be added to the spreadsheet (for further spectypes)
  pivot_longer(names_to = "local.spec.code", values_to = "spectype.local", -acorn.spec.code) %>%
  filter(!is.na(spectype.local))
  
amr <- left_join(amr %>% mutate(spectype.local = tolower(spectype.local)), 
                 local.spec %>% transmute(spectype.local = tolower(spectype.local), acorn.spec.code), # Convert dictionary values to lower case to maximise matching, 
                 by = "spectype.local") %>%
  rename(spec.code2 = acorn.spec.code)

amr$specgroup <- amr$spec.code1 # Consolidate the two spec.codes into a specgroup variable
amr$specgroup[is.na(amr$spec.code1)] <- amr$spec.code2[is.na(amr$spec.code1)]
amr$specgroup[is.na(amr$specgroup)] <- "other" # Any non-coded specimens = "other"

amr$specgroup = recode(amr$specgroup,
                       blood = "Blood", csf = "CSF", sterile.fluid = "Sterile fluids", lower.resp = "Lower respiratory tract specimen",
                       pleural.fluid = "Pleural fluid", throat = "Throat swab", urine = "Urine", gu = "Genito-urinary swab", stool = "Stool",
                       other = "Other specimens")

amr <- amr %>% 
  select(-spec.code1, -spec.code2)
