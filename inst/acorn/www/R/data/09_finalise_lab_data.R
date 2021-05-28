message("09_finalise_lab_data.R")

browser()

# TODO: use md5() here?
amr <- amr %>%
  mutate(
    patient_id = patid, # as.character(md5(patid)),
    specimen_id = specid, # as.character(md5(specid)),
    # episode_id = as.character(md5(ACORN.EPID)),  # TODO: clarify with Paul what is being done here?
    date_specimen = as.Date(specdate),
    specimen_type = recode(specgroup,
                           blood = "Blood", csf = "CSF", sterile.fluid = "Sterile fluids", lower.resp = "Lower respiratory tract specimen",
                           pleural.fluid = "Pleural fluid", throat = "Throat swab", urine = "Urine", gu = "Genito-urinary swab", stool = "Stool",
                           other = "Other specimens"),
    isolate_id = paste0(specid, orgnum.acorn), # as.character(md5(paste0(specid, orgnum.acorn))),
    orgnum = orgnum.acorn,
    organism = orgname,
    organism_local = org.local,
    organism_whonet = org.whonet,
    ast_group = ast.group)

# # Filter the and anonymise the "amr.original" data.frame [UPDATED ACORN2]
# microbio.original <- amr.original %>%
#   mutate(
#     patid = as.character(md5(patid)),
#     specid = as.character(md5(specid))) %>%
#   filter(specid %in% microbio$specimen_id)
# 
# corresp_org_antibio <- lab_code$orgs.antibio