# INSTRUCTIONS:
# - use the R commands below to generate one .rds file per line in ACORN2_cred.xlsx
# - add encrypted_cred_XXX_YYY.rds to the S3 "shared-acornamr" folder
# - rename encrypted_cred_demo.rds into encrypted_cred_demo_demo.rds
# - add encrypted_cred_demo.rds to the app "www/cred" folder

dir <- "/Users/olivier/Documents/Consultances/ACORN/Data"

creds <- readxl::read_excel(
  path = glue::glue("{dir}/ACORN2_cred.xlsx"),
  sheet = "cred") |>  
  dplyr::filter(
    !is.na(site)
  )


for (i in 1:nrow(creds)) {
  user <- creds[i, ]
  
  cred <- serialize(
    object = list(
      site = user$site,
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
  
  encrypted_cred <- openssl::aes_cbc_encrypt(cred, key = openssl::sha256(charToRaw(user$pwd)))
  saveRDS(encrypted_cred, glue::glue("{dir}/ACORN2_creds/encrypted_cred_{user$site}_{user$user}.rds"))
}

