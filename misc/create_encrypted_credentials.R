library(glue)
library(openssl)
library(readxl)
library(tidyverse)
rm(list = ls())

all_cred <- readxl::read_excel("/Users/olivier/Documents/Projets/ACORN/Data/ACORN2_cred.xlsx", sheet = "cred") |>  
  filter(!is.na(site)) |> 
  filter(user != "demo")


for (i in 1:nrow(all_cred)) {
  user <- all_cred[i, ]
  
  cred <- serialize(
    object = list(site = user$site,
                  user = user$user,
                  # REDCap
                  redcap_access = user$redcap_access,
                  redcap_uri = user$redcap_uri,
                  redcap_f01f05_api = user$redcap_f01f05_api,
                  redcap_hai_api = user$redcap_hai_api,
                  # AWS S3
                  aws_access = user$aws_access,
                  aws_bucket = user$aws_bucket,
                  aws_region = user$aws_region,  
                  aws_key = user$aws_key,
                  aws_secret = user$aws_secret
    ),
    connection = NULL)
  
  encrypted_cred <- aes_cbc_encrypt(cred, key = openssl::sha256(charToRaw(user$pwd)))
  saveRDS(encrypted_cred, glue("/Users/olivier/Documents/Projets/ACORN/Data/ACORN2_creds/encrypted_cred_{user$site}_{user$user}.rds"))
}

rm(list = ls())

# Instructions:
# encrypted_cred_XXX_YYY.rds files should be added to the "shared-acornamr" folder
# "encrypted_cred_demo.rds" should be added to the "www/cred" folder.
# "shared_acornamr_key.rds" and "share-acornamr_sec.rds" should be added to the "www/cred" folder. 
# They can be generated with the commands:
# saveRDS("COPY_KEY_HERE", file = "/Users/olivier/Documents/Projets/ACORN/Data/ACORN2_creds/shared_acornamr_key.rds")
# saveRDS("COPY_SECRET_HERE", file = "/Users/olivier/Documents/Projets/ACORN/Data/ACORN2_creds/shared_acornamr_sec.rds")
