library(glue)
library(openssl)
library(readxl)
library(tidyverse)
rm(list = ls())

all_cred <- readxl::read_excel("/Users/olivier/Documents/Projets/ACORN/Data/ACORN2_cred.xlsx", sheet = "cred") %>%
  filter(!is.na(site))
  

for (i in 1:nrow(all_cred)) {
  user <- all_cred[i, ]
  
  cred <- serialize(
    object = list(site = user$site,
                  user = user$user,
                  # REDCap
                  redcap_uri = user$redcap_uri,
                  redcap_f01f05_api = user$redcap_f01f05_api,
                  redcap_hai_api = user$redcap_hai_api,
                  # AWS S3
                  acorn_s3 = user$acorn_s3,
                  acorn_s3_bucket = user$acorn_s3_bucket,
                  acorn_s3_region = user$acorn_s3_region,
                  acorn_s3_key = user$acorn_s3_key,
                  acorn_s3_secret = user$acorn_s3_secret),
    connection = NULL)
  
  encrypted_cred <- aes_cbc_encrypt(cred, key = openssl::sha256(charToRaw(user$pwd)))
  saveRDS(encrypted_cred, glue("/Users/olivier/Desktop/encrypted_cred_{user$site}_{user$user}.rds"))
}

# "shared-acornamr" bucket:
saveRDS("HIDDEN", file = "/Users/olivier/Desktop/shared_acornamr_key.rds")
saveRDS("HIDDEN", file = "/Users/olivier/Desktop/shared_acornamr_sec.rds")


rm(list = ls())
