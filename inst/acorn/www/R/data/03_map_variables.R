message("03_map_variables.R")

amr <- dta %>%
  mutate_all(as.character) %>%
  rename_with(use_acorn_name,
              acorn_names = data_dictionary$variables$acorn.code,
              local_names = data_dictionary$variables$local.code) %>%
  select(! starts_with("NOT_ACORN_COLUMN_"))

# Deal with rows with missing specimen IDs
# This is non-ideal and should be addressed at site-level, but is a pragmatic solution where this is difficult:
# Makes an assumption that a specimen is a single row of data (which is true in the vast majority of cases, and most importantly for blood cultures)
# Replaces NA with a running number (based on row.names(amr)) plus the prefix "SPEC"
amr <- amr |> 
  mutate(
    specid = na_if(specid, ""),
    specid = if_else(!is.na(specid), specid, paste0("SPEC", seq_along(row.names(amr)))),
    specid.lc = tolower(specid)
  )

# Add new columns of NAs required for aggregate variables (e.g. aggregate carbapenem) computations
col_sup <- setdiff(data_dictionary$variables$acorn.code, names(amr))
new <- rep(NA_character_, length(col_sup))
names(new) <- col_sup
amr <- amr %>% mutate(!!!new)

# Make a new orgnum (do not rely on any orgnum imported as part of the dataset)
specid <- subset(amr, select = c(specid.lc), subset = (!duplicated(specid.lc)))
specid$specid.acorn <- seq_along(specid$specid.lc)

amr <- left_join(amr, specid,
                 by = "specid.lc") %>%
  group_by(specid.lc) %>%
  mutate(orgnum.acorn = 1:n()) %>%
  ungroup() %>%
  as.data.frame() %>%
  select(-specid.lc)

# Make an isolate id variable (isolateid)
amr$isolateid <- paste(amr$specid.acorn, amr$orgnum.acorn, sep = "-")

# Map local beta-lactamase, inducible clindamycin resistance (ICR), ESBL, carbapenemase, MRSA, VRE test result codes to standard codes
test.res <- data_dictionary$test.res %>%
  select(acorn.test.code, local.result.code) %>%
  spread(acorn.test.code, local.result.code) # Make a wide data.frame of the positive / negative local test results

amr$blac[amr$blac == test.res$blac.neg] <- "NEGATIVE"
amr$blac[amr$blac == test.res$blac.pos] <- "POSITIVE"

amr$cpm[amr$cpm == test.res$cpm.neg] <- "NEGATIVE"
amr$cpm[amr$cpm == test.res$cpm.pos] <- "POSITIVE"

amr$esbl[amr$esbl == test.res$esbl.neg] <- "NEGATIVE"
amr$esbl[amr$esbl == test.res$esbl.pos] <- "POSITIVE"

amr$ind.cli[amr$ind.cli == test.res$ind.cli.neg] <- "NEGATIVE"
amr$ind.cli[amr$ind.cli == test.res$ind.cli.pos] <- "POSITIVE"

amr$mrsa[amr$mrsa == test.res$mrsa.neg] <- "NEGATIVE"
amr$mrsa[amr$mrsa == test.res$mrsa.pos] <- "POSITIVE"

amr$vre[amr$vre == test.res$vre.neg] <- "NEGATIVE"
amr$vre[amr$vre == test.res$vre.pos] <- "POSITIVE"
