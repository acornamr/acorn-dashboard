message("06_make_ast_group.R")

# Make an ast.group variable
# - GLASS orgs, enterococci (WHO priority), Pseudomonas aeruginosa (WHO priority), 
# - Haemophilus influenzae (VPD), Neisseria meningitis (VPD),
# - Other coliforms (emerging important sepsis group)
amr$acorn.genus <- sub(" .*", "", amr$orgname)
acorn.ast.groups <- lab_code$acorn.ast.groups

amr <- left_join(amr, acorn.ast.groups %>% select(acorn.ast.group, acorn.orgname),
                 by = c('acorn.genus' = 'acorn.orgname')) # Match on genus (for groups with >1 genus and or species, e.g. coliforms or Salmonella)
names(amr)[names(amr) == "acorn.ast.group"] <- "ast.group1"

amr <- left_join(amr, acorn.ast.groups %>% select(acorn.ast.group, acorn.orgname),
                 by = c('orgname' = 'acorn.orgname')) # Match on species (if species defines the group, e.g. Streptococcus pneumoniae)
names(amr)[names(amr) == "acorn.ast.group"] <- "ast.group2"

amr$ast.group <- amr$ast.group2
amr$ast.group[is.na(amr$ast.group2)] <- amr$ast.group1[is.na(amr$ast.group2)] # Consolidate into a single ast.group variable

amr$acorn.genus <- NULL # Remove as no longer required
amr$ast.group1 <- NULL # Remove as no longer required
amr$ast.group2 <- NULL # Remove as no longer required

# Make a variable data.frame to identify key AST variables
# Mark the MIC / Etest variables
amr.var <- names(amr)
amr.var <- as.data.frame(amr.var)
names(amr.var) <- "varname.ast"
amr.var$varname.ast <- as.character(amr.var$varname.ast)
amr.var$cat <- NA # Make a Disk / MIC variable (cat, MIC and Etest both categorised as MIC)
amr.var$cat[grep("_ND", amr.var$varname.ast)] <- "DISK"
amr.var$cat[grep("_NE", amr.var$varname.ast)] <- "MIC"
amr.var$cat[grep("_NM", amr.var$varname.ast)] <- "MIC"
amr.var$cat[grep("_ED", amr.var$varname.ast)] <- "DISK"
amr.var$cat[grep("_EE", amr.var$varname.ast)] <- "MIC"
amr.var$cat[grep("_EM", amr.var$varname.ast)] <- "MIC"

amr.var$cat.short <- NA # Make a Disk / MIC / Etest category variable (cat.short, short form)
amr.var$cat.short[grep("_ND", amr.var$varname.ast)] <- "D"
amr.var$cat.short[grep("_NE", amr.var$varname.ast)] <- "E"
amr.var$cat.short[grep("_NM", amr.var$varname.ast)] <- "M"
amr.var$cat.short[grep("_ED", amr.var$varname.ast)] <- "D"
amr.var$cat.short[grep("_EE", amr.var$varname.ast)] <- "E"
amr.var$cat.short[grep("_EM", amr.var$varname.ast)] <- "M"

amr.var <- subset(amr.var, subset = (!is.na(amr.var$cat))) # Subset to remove non-amr variables from original amr data.frame) 
amr.var$abxname <- substr(amr.var$varname.ast, 1, 3) # Extract the antibiotic code from the Disk / MIC / Etest code (WHONET format)
amr.var$guideline <- NA # Make a CLSI / EUCAST variable (guideline)
amr.var$guideline[grep("_N", amr.var$varname.ast)] <- "CLSI"
amr.var$guideline[grep("_E", amr.var$varname.ast)] <- "EUCAST"
amr.var$abxname.cat <- paste(amr.var$abxname, amr.var$cat.short, sep = ".") # Make name-category variable for each antibiotic and test category (abxname.cat, used later for summarising multiple AST per antibiotic)

# Save the raw data frame for merging with interpreted AST data at the end
amr.raw <- amr

# Sort out formatting of AST data (assuming English language for the S / I / R possibilities and standard notation with / without spaces for the MICs)
for(i in amr.var$varname.ast) { # Select the variables containing raw AST data
  amr[,i] <- gsub("NULL", "", amr[,i]) # Removes “NULL” text
  amr[,i] <- gsub(" ", "", amr[,i]) # Removes spaces
  amr[,i] <- gsub("<=", "", amr[,i]) # Replaces <= with blank
  amr[,i] <- gsub(">=", "", amr[,i]) # Replaces >= with blank
  amr[,i] <- gsub("\u2264", "", amr[,i]) # Replaces unicode-2264 (unicode <= with blank) [UPDATED ACORN2]
  amr[,i] <- gsub("\u2265", "", amr[,i]) # Replaces unicode-2265 (unicode >= with blank) [UPDATED ACORN2]
  amr[,i] <- gsub("\u00b5g/ml", "", amr[,i]) # Replaces unicode-00b5 g/ml (unicode ug/ml with blank) [UPDATED ACORN2]
  amr[,i] <- gsub("\u03bcg/ml", "", amr[,i]) # Replaces unicode-03bc g/ml (unicode ug/ml with blank) [UPDATED ACORN2]
  amr[,i] <- gsub("/.*", "", amr[,i]) # Anything with a slash MIC (e.g. co-amoxiclav 8/4), remove the "/" and the second MIC which should be the b-lac inhibitor or sulfa, for co-trimoxazole [UPDATED ACORN2]
  amr[,i] <- gsub("<[0-9]{1,3}", "0", amr[,i]) # Anything with < followed by a number (upto 3 digits) is replaced by "0" (i.e. low MIC = S)
  amr[,i] <- gsub(">[0-9]{1,3}", "512", amr[,i]) # Anything with > followed by a number (upto 3 digits) is replaced by "512" (i.e. high MIC = R)
  amr[,i] <- gsub("^[sS]$", "110011", amr[,i]) # Raw "S" - high non-random number
  amr[,i] <- gsub("^(?i)SUSCEPTIBLE(?-i)$", "110011", amr[,i])
  amr[,i] <- gsub("^(?i)SENSITIVE(?-i)$", "110011", amr[,i])
  amr[,i] <- gsub("^[iI]$", "220022", amr[,i]) # Raw "I" - high non-random number
  amr[,i] <- gsub("^(?i)INTERMEDIATE(?-i)$", "220022", amr[,i])
  amr[,i] <- gsub("^[rR]$", "330033", amr[,i]) # Raw "R" - high non-random number
  amr[,i] <- gsub("^(?i)RESISTANT(?-i)$", "330033", amr[,i])
}

# Convert raw AST variables back to numeric for further manipulation
amr[,(names(amr)[(names(amr) %in% amr.var$varname.ast)])] <- sapply(amr[,(names(amr)[(names(amr) %in% amr.var$varname.ast)])], as.numeric)

# Sort out Etest raw results into defined MIC categories as per kit instructions (<0.03 = 0.03mg/L; >256 = 512mg/L; doubling dilutions from 0.03 - 512mg/L)
# Ensure the S / I / R number codes (110011, 220022, 330033) are retained
# No need to do this for MIC (non-Etest as should already be doubling dilutions), except for co-trimoxazole (SXT) if reported as a compound MIC rather than just trimethoprim (e.g. VITEK) - see below.
# Co-trimoxazole (TS) Etests report the trimethoprim MIC only so no modification required (source = biomerieux kit insert)
mic.breaks <- c(0, 0.04, 0.065, 0.126, 0.26, 0.6, 1.1, 2.1, 4.1, 8.1, 16.1, 32.1, 64.1, 128.1, 256.1, 110010, 220021, 330032, Inf) # Make MIC category cut-offs [updated v2.5.1, to ensure values of >=512 coded correctly]
mic.labels <- c(0.03, 0.06, 0.12, 0.25, 0.5, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 110011, 220022, 33033) # Make MIC values

for(i in amr.var$varname.ast[amr.var$cat.short == "E"]) {
  amr[,i] <- cut(amr[,i], breaks = mic.breaks, labels = mic.labels)
  amr[,i] <- as.numeric(as.character(amr[,i]))
}

# Sort out SXT-VITEK MIC results [UPDATED ACORN2]
# If results are recorded as trimethoprim + sulfamethoxazole (e.g. 40) rather than trimethoprim/sulfamethoxazole (e.g. 2/38)
if(!is.null(amr$SXT_NM)) {
  amr$SXT_NM[amr$SXT_NM == 10240] <- 512 # CLSI
  amr$SXT_NM[amr$SXT_NM == 5120] <- 256
  amr$SXT_NM[amr$SXT_NM == 2560] <- 128
  amr$SXT_NM[amr$SXT_NM == 1280] <- 64
  amr$SXT_NM[amr$SXT_NM == 640] <- 32
  amr$SXT_NM[amr$SXT_NM == 320] <- 16
  amr$SXT_NM[amr$SXT_NM == 160] <- 8
  amr$SXT_NM[amr$SXT_NM == 80] <- 4
  amr$SXT_NM[amr$SXT_NM == 40] <- 2
  amr$SXT_NM[amr$SXT_NM == 20] <- 1
  amr$SXT_NM[amr$SXT_NM == 10] <- 0.5
  amr$SXT_NM[amr$SXT_NM == 5] <- 0.25
  amr$SXT_NM[amr$SXT_NM == 2.4] <- 0.12
  amr$SXT_NM[amr$SXT_NM == 1.2] <- 0.06
  amr$SXT_NM[amr$SXT_NM == 0.6] <- 0.03
}

if(!is.null(amr$SXT_EM)) {
  amr$SXT_EM[amr$SXT_EM == 10240] <- 512 # EUCAST
  amr$SXT_EM[amr$SXT_EM == 5120] <- 256
  amr$SXT_EM[amr$SXT_EM == 2560] <- 128
  amr$SXT_EM[amr$SXT_EM == 1280] <- 64
  amr$SXT_EM[amr$SXT_EM == 640] <- 32
  amr$SXT_EM[amr$SXT_EM == 320] <- 16
  amr$SXT_EM[amr$SXT_EM == 160] <- 8
  amr$SXT_EM[amr$SXT_EM == 80] <- 4
  amr$SXT_EM[amr$SXT_EM == 40] <- 2
  amr$SXT_EM[amr$SXT_EM == 20] <- 1
  amr$SXT_EM[amr$SXT_EM == 10] <- 0.5
  amr$SXT_EM[amr$SXT_EM == 5] <- 0.25
  amr$SXT_EM[amr$SXT_EM == 2.4] <- 0.12
  amr$SXT_EM[amr$SXT_EM == 1.2] <- 0.06
  amr$SXT_EM[amr$SXT_EM == 0.6] <- 0.03
}