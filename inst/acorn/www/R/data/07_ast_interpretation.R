message("07_ast_interpretation.R")
tictoc::tic("07_ast_interpretation.R: Part 1.1")
# Combine into a single data.frame
ast.codes <- rbind(lab_code$ast.aci, lab_code$ast.col, lab_code$ast.ent, lab_code$ast.hin, lab_code$ast.ngo, lab_code$ast.nmen, lab_code$ast.pae, lab_code$ast.sal, lab_code$ast.sau, lab_code$ast.shi, lab_code$ast.spn)
tictoc::toc()
tictoc::tic("07_ast_interpretation.R: Part 1.2")
# Add Etest rows into ast.codes (not included in ast.codes since breakpoints are same as for other MIC, but they have unique codes in WHONET)
ast.codes.e <- subset(ast.codes, subset = (ast.codes$TESTMETHOD == "MIC"))
ast.codes.e$WHON5_TEST <- gsub("_NM", "_NE", ast.codes.e$WHON5_TEST)
ast.codes.e$WHON5_TEST <- gsub("_EM", "_EE", ast.codes.e$WHON5_TEST)
ast.codes <- rbind(ast.codes, ast.codes.e)
tictoc::toc()
tictoc::tic("07_ast_interpretation.R: Part 1.3")
# Make a link variable (link, to link AST breakpoints to amr data)
ast.codes$link <- paste(ast.codes$ACORN_AST_ORGGROUP, ast.codes$WHON5_TEST, sep = ".")

# Reshape amr data.frame to long and then make the same link variable (link)
# Only ast variable names include "_"
amr.l <- amr |> 
  tidyr::pivot_longer(
    contains("_"),
    names_to = "WHON5_TEST",
    values_to = "result"
  )
tictoc::toc()
tictoc::tic("07_ast_interpretation.R: Part 1.4")
amr.l <- subset(amr.l, subset = (!is.na(result) & !is.na(ast.group))) # Keep only isolateids with valid AST results

if(nrow(amr.l) == 0) {
  showNotification(i18n$t("There are no isolate with valid AST results. Please contact ACORN support."),
                   duration = 15, type = "error", closeButton = FALSE, session = session)
  Sys.sleep(15)
}
tictoc::toc()
tictoc::tic("07_ast_interpretation.R: Part 2")
amr.l$link <- paste(amr.l$ast.group, amr.l$WHON5_TEST, sep = ".")
amr.l <- subset(amr.l, select = c(isolateid, result, link))

# Merge amr.l and ast.codes by the link variable
amr.l.int <- left_join(amr.l, ast.codes, by = "link")
amr.l.int$ast.cat <- NA # Make an ast category variable (ast.cat)

# Interpret the raw AST data (have to do as categories first, then convert to numeric to summarise per antibiotic, then back to categories)
# Disks - CLSI (categorised by >= for S and <= for R (with I in between))
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "CLSI" & amr.l.int$TESTMETHOD == "DISK" & amr.l.int$result >= amr.l.int$S] <- "S"
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "CLSI" & amr.l.int$TESTMETHOD == "DISK" & amr.l.int$result > amr.l.int$R & amr.l.int$result < amr.l.int$S] <- "I"
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "CLSI" & amr.l.int$TESTMETHOD == "DISK" & amr.l.int$result <= amr.l.int$R] <- "R"
# Disks - EUCAST (categorised by >= for S and < for R (with I in between))
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "EUCAST" & amr.l.int$TESTMETHOD == "DISK" & amr.l.int$result >= amr.l.int$S] <- "S"
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "EUCAST" & amr.l.int$TESTMETHOD == "DISK" & amr.l.int$result >= amr.l.int$R & amr.l.int$result < amr.l.int$S] <- "I"
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "EUCAST" & amr.l.int$TESTMETHOD == "DISK" & amr.l.int$result < amr.l.int$R] <- "R"
# MIC / ETESTS - CLSI (categorised by <= for S and >= for R (with I in between))
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "CLSI" & amr.l.int$TESTMETHOD == "MIC" & amr.l.int$result <= amr.l.int$S] <- "S"
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "CLSI" & amr.l.int$TESTMETHOD == "MIC" & amr.l.int$result > amr.l.int$S & amr.l.int$result < amr.l.int$R] <- "I"
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "CLSI" & amr.l.int$TESTMETHOD == "MIC" & amr.l.int$result >= amr.l.int$R] <- "R"
# MIC / ETESTS - EUCAST (categorised by <= for S and > for R (with I in between))
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "EUCAST" & amr.l.int$TESTMETHOD == "MIC" & amr.l.int$result <= amr.l.int$S] <- "S"
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "EUCAST" & amr.l.int$TESTMETHOD == "MIC" & amr.l.int$result > amr.l.int$S & amr.l.int$result <= amr.l.int$R] <- "I"
amr.l.int$ast.cat[amr.l.int$GUIDELINES == "EUCAST" & amr.l.int$TESTMETHOD == "MIC" & amr.l.int$result > amr.l.int$R] <- "R"
# Do the raw S / I / R results [Updated in ACORN v2.5.1 - was previously done before the numeric disk/MIC data, result in categorical data all being recoded incorrectly]
amr.l.int$ast.cat[amr.l.int$result == 110011] <- "S"
amr.l.int$ast.cat[amr.l.int$result == 220022] <- "I"
amr.l.int$ast.cat[amr.l.int$result == 330033] <- "R"
tictoc::toc()
tictoc::tic("07_ast_interpretation.R: Part 3")
# Summarise the Disk, MIC, Etest results for each antibiotic (use WHONET formula of Etest > MIC > Disk if >1 method): one row per isolate
# Add in amr.var$abxname.cat (E, M, D) to amr.l.int
amr.l.int <- left_join(amr.l.int, 
                       amr.var %>% transmute(WHON5_TEST = varname.ast, abxname.cat), 
                       by = "WHON5_TEST")

# For each antibiotic-category (abxname.cat) make a S / I / R category for each unique isolateid
# Add abxname.cat to make a unique isolateid-abxname.cat: this will make <= 3 categories per isolate, i.e. will start to merge CLSI and EUCAST results
amr.l.int$isolateid.abxname.cat <- paste(amr.l.int$isolateid, amr.l.int$abxname.cat, sep = "-")

# Convert R / I / S to numeric (R = 3; I = 2; S = 1; not done = 0) to use enable use of max() to compute abx.cat.result (i.e the final result for each antibiotic-category (E, M, D))
amr.l.int$ast.cat[amr.l.int$ast.cat == "R"] <- 3
amr.l.int$ast.cat[amr.l.int$ast.cat == "I"] <- 2
amr.l.int$ast.cat[amr.l.int$ast.cat == "S"] <- 1
amr.l.int$ast.cat[is.na(amr.l.int$ast.cat)] <- 0 # Important for the next part, otherwise NA > 3 and everything recoded as NA
amr.l.int$ast.cat <- as.numeric(amr.l.int$ast.cat)
tictoc::toc()
tictoc::tic("07_ast_interpretation.R: Part 4")
# Make a variable for the result of each test cat (abx.cat.result, if both CLSI and EUCAST for disk/mic/etst then the most resistant result will be taken)
tmp.ast <- amr.l.int %>%
  group_by(isolateid.abxname.cat) %>%
  summarise(abx.cat.result = max(ast.cat)) %>%
  ungroup()

# Re-define the key antibiotic / test category / isolate ID - antibiotic variables
tmp.ast$abxname.cat <- str_sub(tmp.ast$isolateid.abxname.cat, -5)
tmp.ast$abxname <- substr(tmp.ast$abxname.cat, 1, 3)
tmp.ast$cat.short <- str_sub(tmp.ast$abxname.cat, -1)
tmp.ast$isolateid.abxname <- substr(tmp.ast$isolateid.abxname.cat, 1, nchar(tmp.ast$isolateid.abxname.cat)-2)

# Make numeric codes for the test categories (E, M, D)
tmp.ast$cat.shortnum <- 1 # Default value = 1 (D)
tmp.ast$cat.shortnum[tmp.ast$cat.short == "E" & tmp.ast$abx.cat.result != 0] <- 3 # Only include E ( == 3) if a result is given (i.e. abx.cat.result ! = 0)
tmp.ast$cat.shortnum[tmp.ast$cat.short == "M" & tmp.ast$abx.cat.result != 0] <- 2 # Only include M ( == 2) if a result is given (i.e. abx.cat.result ! = 0)

# Define the highest level of AST done per antibiotic (Etest > MIC > Disk)
tmp.ast1 <- tmp.ast %>%
  group_by(isolateid.abxname) %>%
  summarise(max(cat.shortnum)) %>%
  ungroup()
tmp.ast1 <- as.data.frame(tmp.ast1)
names(tmp.ast1) <- c("isolateid.abxname", "cat.shortnum.max")
tmp.ast2 <- left_join(tmp.ast, tmp.ast1, by = "isolateid.abxname")
tictoc::toc()
tictoc::tic("07_ast_interpretation.R: Part 5")
# Change numeric values back to characters for AST test categories (E == 3, M == 2, D == 1)
tmp.ast2$cat.shortnum[tmp.ast2$cat.shortnum == 1] <- "D"
tmp.ast2$cat.shortnum[tmp.ast2$cat.shortnum == 2] <- "M"
tmp.ast2$cat.shortnum[tmp.ast2$cat.shortnum == 3] <- "E"
tmp.ast2$cat.shortnum.max[tmp.ast2$cat.shortnum.max == 1] <- "D"
tmp.ast2$cat.shortnum.max[tmp.ast2$cat.shortnum.max == 2] <- "M"
tmp.ast2$cat.shortnum.max[tmp.ast2$cat.shortnum.max == 3] <- "E"

# Reduce down to a single row per isolate-antibiotic (based on the highest level of AST done per antibiotic (Etest > MIC > Disk)
tmp.ast3 <- subset(tmp.ast2, subset = (cat.short == cat.shortnum & cat.shortnum == cat.shortnum.max))
rm(tmp.ast2) # Remove as no longer required
tmp.ast3$isolateid <- substr(tmp.ast3$isolateid.abxname, 1, nchar(tmp.ast3$isolateid.abxname)-4)
tmp.ast3 <- subset(tmp.ast3, select = c("isolateid", "abxname", "abx.cat.result")) # Restrict to key variables only

# Convert S / I / R result back from numeric to character
tmp.ast3$abx.cat.result[tmp.ast3$abx.cat.result == 3] <- "R"
tmp.ast3$abx.cat.result[tmp.ast3$abx.cat.result == 2] <- "I"
tmp.ast3$abx.cat.result[tmp.ast3$abx.cat.result == 1] <- "S"
tmp.ast3$abx.cat.result[tmp.ast3$abx.cat.result == 0] <- NA
tictoc::toc()
tictoc::tic("07_ast_interpretation.R: Part 6")
# Convert AST data.frame from long back to wide format
# Make individual variables for each antibiotic (WHONET codes)
ast.final <- tmp.ast3 |> 
  pivot_wider(
    names_from = "abxname", 
    values_from = "abx.cat.result"
  )

# Merge categorised AST data back into amr.raw data.frame (defined in 05_make_ast_group.R)
amr <- left_join(amr.raw, ast.final, by = "isolateid")

# Make a final data.frame with columns for all antibiotics in ACORN dataset 
# (depending on sites, not all antibiotics will be tested / present in ast.final)
ast.varnames <- unique(amr.var$abxname) # Create the variable names for summarised antibiotics
amr.finalvariables <- names(subset(amr, select = c(patid:ast.group))) # Create the variable names for the rest of the dataset

tmp.amr <- data.frame(matrix(vector(), nrow = 0, ncol = length(amr.finalvariables))) # Make an empty data.frame for the specimen / organism and raw AST data
names(tmp.amr) <- amr.finalvariables
tmp.amr1 <- data.frame(matrix(vector(), nrow = 0, ncol = length(ast.varnames))) # Make an empty data.frame for the summarised AST data
names(tmp.amr1) <- ast.varnames
tmp.amr2 <- cbind(tmp.amr, tmp.amr1) # Combine both data.frames

amr <- bind_rows(tmp.amr2 %>% mutate_all(as.character), 
                 amr %>% mutate_all(as.character)) %>%
  mutate(specdate = parse_date_time(specdate, c("dmY", "Ymd", "dbY", "Ymd HMS", "dmY HM")),
         spectype.whonet = as.numeric(spectype.whonet),
         specid.acorn = as.numeric(specid.acorn ),
         orgnum.acorn = as.numeric(orgnum.acorn))
tictoc::toc()