# Create demo acorn for v2.1
rm(list = ls())
load("/Users/olivier/Desktop/ACORN_v2.0_demo.acorn.acorn")

acorn <- list(meta = meta, 
              redcap_f01f05_dta = redcap_f01f05_dta, 
              redcap_hai_dta = redcap_hai_dta, 
              lab_dta = tibble(), 
              acorn_dta = acorn_dta, 
              corresp_org_antibio = corresp_org_antibio, 
              lab_code = lab_code, 
              data_dictionary = data_dictionary)

save(acorn, file = "/Users/olivier/Desktop/ACORN_v2.1_demo.acorn")