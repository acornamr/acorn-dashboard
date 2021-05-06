print("Source 11_prepare_data.R")


# Make a final microbiology data.frame [UPDATED ACORN2]
microbio <- amr %>%
  transmute(
    patient_id = as.character(md5(patid)),
    specimen_id = as.character(md5(specid)),
    episode_id = as.character(md5(ACORN.EPID)),
    date_specimen = as.Date(specdate),
    specimen_type = recode(specgroup,
                           blood = "Blood", csf = "CSF", sterile.fluid = "Sterile fluids", lower.resp = "Lower respiratory tract specimen",
                           pleural.fluid = "Pleural fluid", throat = "Throat swab", urine = "Urine", gu = "Genito-urinary swab", stool = "Stool",
                           other = "Other specimens"),
    isolate_id = as.character(md5(paste0(specid, orgnum.acorn))),
    orgnum = orgnum.acorn,
    organism = orgname,
    organism_local = org.local,
    organism_whonet = org.whonet,
    blac,
    cpm,
    esbl, 
    ind.cli,
    mrsa, vre, AMK_ND30, AMK_NE, AMK_NM, AMC_ND20, AMC_NE, AMC_NM, AMP_ND10, AMP_NE, AMP_NM,
    SAM_ND10, SAM_NE, SAM_NM, AZM_ND15, AZM_NE, AZM_NM, ATM_ND30, ATM_NE, ATM_NM, FEP_ND30, FEP_NE, FEP_NM,
    CTX_ND30, CTX_NE, CTX_NM, FOX_ND30, FOX_NE, FOX_NM, CAZ_ND30, CAZ_NE, CAZ_NM, CRO_ND30, CRO_NE, CRO_NM,
    CHL_ND30, CHL_NE, CHL_NM, CIP_ND5, CIP_NE, CIP_NM, CLI_ND2, CLI_NE, CLI_NM, COL_NM, DOR_ND10, DOR_NE, DOR_NM,
    ETP_ND10, ETP_NE, ETP_NM, ERY_ND15, ERY_NE, ERY_NM, GEN_ND10, GEN_NE, GEN_NM, IPM_ND10, IPM_NE, IPM_NM,
    LVX_ND5, LVX_NE, LVX_NM, MEM_ND10, MEM_NE, MEM_NM, MFX_ND5, MFX_NE, MFX_NM, NIT_ND300, NIT_NE, NIT_NM,
    OFX_ND5, OFX_NE, OFX_NM, OXA_ND1, OXA_NE, OXA_NM, PEN_ND10, PEN_NE, PEN_NM, PEF_ND5, TZP_ND100, TZP_NE, TZP_NM,
    SPT_ND100, SPT_NE, SPT_NM, TCY_ND30, TCY_NE, TCY_NM, SXT_ND1_2, SXT_NE, SXT_NM, VAN_ND30, VAN_NE, VAN_NM,
    AMK_ED30, AMK_EE, AMK_EM, AMC_ED2, AMC_ED20, AMC_EE, AMC_EM, AMP_ED2, AMP_ED10, AMP_EE, AMP_EM, SAM_EE, SAM_EM,
    AZM_EE, AZM_EM, ATM_ED30, ATM_EE, ATM_EM, FEP_ED30, FEP_EE, FEP_EM, CTX_ED5, CTX_EE, CTX_EM, FOX_ED30, FOX_EE, FOX_EM,
    CAZ_ED10, CAZ_EE, CAZ_EM, CRO_ED30, CRO_EE, CRO_EM, CHL_ED30, CHL_EE, CHL_EM, CIP_ED5, CIP_EE, CIP_EM,
    CLI_ED2, CLI_EE, CLI_EM, COL_EM, DOR_ED10, DOR_EE, DOR_EM, ETP_ED10, ETP_EE, ETP_EM, ERY_ED15, ERY_EE, ERY_EM,
    GEN_ED10, GEN_EE, GEN_EM, IPM_ED10, IPM_EE, IPM_EM, LVX_ED5, LVX_EE, LVX_EM, MEM_ED10, MEM_EE, MEM_EM,
    MFX_ED5, MFX_EE, MFX_EM, NIT_ED100, NIT_EE, NIT_EM, OFX_ED5, OFX_EE, OFX_EM, OXA_ED1, OXA_EE, OXA_EM,
    PEN_ED1, PEN_EE, PEN_EM, PEF_ED5, TZP_ED30, TZP_EE, TZP_EM, SPT_ED, SPT_EE, SPT_EM, TCY_ED30, TCY_EE, TCY_EM,
    SXT_ED1_2, SXT_EE, SXT_EM, VAN_ED5, VAN_EE, VAN_EM,
    ast_group = ast.group,
    AMK, AMC, AMP, SAM, AZM, ATM,
    FEP, CTX, CTX_MEN, FOX, CAZ, CRO, CRO_MEN, CHL, CIP,
    CLI, COL, DOR, ETP, ERY, GEN, IPM,
    LVX, MEM, MFX, NIT, OFX, OXA, PEN,
    PEN_MEN, PEF, TZP, SPT, TCY, SXT, VAN, carbapenem, fluoroquinolone, thirdgenceph, contaminant) %>% 
  filter(patient_id %in% patient$patient_id)  # select only records from patient in patient_id.

# Filter the and anonymise the "amr.original" data.frame [UPDATED ACORN2]
microbio.original <- amr.original %>%
  mutate(
    patid = as.character(md5(patid)),
    specid = as.character(md5(specid))) %>%
  filter(specid %in% microbio$specimen_id)

corresp_org_antibio <- lab_code$orgs.antibio