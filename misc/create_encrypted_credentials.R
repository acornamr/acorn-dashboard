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
                  redcap_access = user$redcap_access,
                  redcap_uri = user$redcap_uri,
                  redcap_f01f05_api = user$redcap_f01f05_api,
                  redcap_hai_api = user$redcap_hai_api,
                  # AWS S3
                  aws_access = user$aws_access,
                  acorn_s3 = user$aws_access,  # TODO: can be removed once everyone is using 2.2.5 or later
                  aws_bucket = user$aws_bucket,
                  acorn_s3_bucket = user$aws_bucket,  # TODO: can be removed once everyone is using 2.2.5 or later
                  aws_region = user$aws_region,  
                  acorn_s3_region = user$aws_region,  # TODO: can be removed once everyone is using 2.2.5 or later
                  aws_key = user$aws_key,
                  acorn_s3_key = user$aws_key,  # TODO: can be removed once everyone is using 2.2.5 or later
                  aws_secret = user$aws_secret,
                  acorn_s3_secret = user$aws_secret   # TODO: can be removed once everyone is using 2.2.5 or later
    ),
    connection = NULL)
  
  encrypted_cred <- aes_cbc_encrypt(cred, key = openssl::sha256(charToRaw(user$pwd)))
  saveRDS(encrypted_cred, glue("/Users/olivier/Documents/Projets/ACORN/Data/ACORN2_creds/encrypted_cred_{user$site}_{user$user}.rds"))
}

# "shared-acornamr" bucket:
saveRDS("HIDDEN", file = "/Users/olivier/Documents/Projets/ACORN/Data/ACORN2_creds/shared_acornamr_key.rds")
saveRDS("HIDDEN", file = "/Users/olivier/Documents/Projets/ACORN/Data/ACORN2_creds/shared_acornamr_sec.rds")


rm(list = ls())
