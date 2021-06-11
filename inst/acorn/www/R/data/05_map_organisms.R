message("Map local / WHO organism codes and names to ACORN organism names / groups.")

whonet.orgs <- lab_code$whonet.orgs
whonet.orgs$genus.sp <- paste(whonet.orgs$GENUS, " sp", sep = "") # Make a genus/species variable
whonet.orgs$genus.sp[whonet.orgs$genus.sp == "NA sp"] <- NA # Remove values from non-bacterial species (organism codes with no genus (e.g. viruses or "Acid fast bacilli"))
whonet.orgs$acorn.org.code[is.na(whonet.orgs$acorn.org.code)] <- whonet.orgs$genus.sp[is.na(whonet.orgs$acorn.org.code)] # Replace missing acorn.org.codes with genus/species values as acorn.org.codes only contains values for the ACORN surveillance organisms


# Local organism name matching
local.orgs <- data_dictionary$local.orgs
local.orgs <- local.orgs %>% gather(local.org.code1:ncol(local.orgs), key = local.orgs.code, value = org.local) # Make a long list of local.org.codes and acorn.org.codes
local.orgs <- subset(local.orgs, subset = (!is.na(org.local))) # Remove rows with missing values
local.orgs$org.local <- tolower(local.orgs$org.local) # Convert dictionary values to lower case to maximise matching
amr$org.local.lower <- tolower(amr$org.local) # Convert amr data.frame org.local values to lower case to maximise matching
amr <- left_join(amr, 
                 local.orgs %>% select(org.local, acorn.org.code), 
                 by = c('org.local.lower' = 'org.local'))
names(amr)[names(amr) == "acorn.org.code"] <- "org.code1"

# WHONET organism code matching
# Note that some of the WHONET org codes (ORG) are duplicated because of changes in nomenclature: so first create a subset just of the current code-name combos (STATUS == "C")
# (will give these codes the appropriate acorn.org.code - either ACORN key species or Genus sp, e.g. "Bordetella sp")
whonet.orgs.unique <- subset(whonet.orgs, subset = (whonet.orgs$STATUS == "C"))
amr <- left_join(amr, 
                 whonet.orgs.unique %>% select(ORG, acorn.org.code),
                 by = c('org.whonet' = 'ORG'))
names(amr)[names(amr) == "acorn.org.code"] <- "org.code2"

# WHONET organism name matching (matches WHONET organism name and returns the acorn.org.code)
whonet.orgs$ORG_CLEAN_LOWER <- tolower(whonet.orgs$ORG_CLEAN)
amr <- left_join(amr, 
                 whonet.orgs %>% select(acorn.org.code, ORG_CLEAN_LOWER), 
                 by = c('org.local.lower' = 'ORG_CLEAN_LOWER'))
names(amr)[names(amr) == "acorn.org.code"] <- "org.code3"

# Genus matching
# https://stackoverflow.com/questions/25477920/get-characters-before-first-space
amr$genus <- sub(" .*", "", amr$org.local.lower)

whonet.orgs.subset <- subset(whonet.orgs, select = c(GENUS, genus.sp))
whonet.orgs.subset <- unique(whonet.orgs.subset)

whonet.orgs.subset$GENUS <- tolower(whonet.orgs.subset$GENUS) # Try to map WHONET organism names 

amr <- left_join(amr, 
                 whonet.orgs.subset %>% select(GENUS, genus.sp), 
                 by = c('genus' = 'GENUS'))
names(amr)[names(amr) == "genus.sp"] <- "org.code4"

# Make a final organism code
amr$orgname <- NA
amr$orgname[!is.na(amr$org.code1)] <- amr$org.code1[!is.na(amr$org.code1)]
amr$orgname[is.na(amr$orgname) & !is.na(amr$org.code2)] <- amr$org.code2[is.na(amr$orgname) & !is.na(amr$org.code2)]
amr$orgname[is.na(amr$orgname) & !is.na(amr$org.code3)] <- amr$org.code3[is.na(amr$orgname) & !is.na(amr$org.code3)]
amr$orgname[is.na(amr$orgname) & !is.na(amr$org.code4)] <- amr$org.code4[is.na(amr$orgname) & !is.na(amr$org.code4)]
amr$orgname[is.na(amr$orgname)] <- amr$org.local[is.na(amr$orgname)] # If no orgname at this stage, use the org.local value

# Flag potential contaminants in blood cultures (CoNS, Micrococcus sp., GBP - diphtheroids / Bacillus sp.) [UPDATED ACORN2]
# Make a non-contaminant species list (i.e. exclusions from "contaminant" genera)
non.cont <- paste0(lab_code$acorn.bccontaminants$acorn.orgname, " ", lab_code$acorn.bccontaminants$species.exclusions)
non.cont <- non.cont[!grepl(" NA", non.cont)] # Remove those where there was no excluded species in a contaminant genus

# Identify contaminant genera
amr$genus.final <- sub(" .*", "", amr$orgname) # Updated genus variable (based on final acorn orgname)
amr$contaminant <- "No"
amr$contaminant[tolower(amr$genus.final) %in% tolower(lab_code$acorn.bccontaminants$acorn.orgname)] <- "Yes"
amr$contaminant[amr$orgname %in% non.cont] <- "No"

# Restrict contaminant call to blood cultures only
amr$contaminant[amr$specgroup != "Blood"] <- NA

# Remove columns that are no longer required [UPDATED ACORN2]
amr <- amr %>% 
  select(-org.local.lower, -genus, -genus.final, -org.code1, -org.code2, -org.code3, -org.code4)
