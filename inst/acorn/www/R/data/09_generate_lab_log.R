message("09_generate_lab_log.R")

# Branch out if clinical data has or hasn't been provided
ifelse(is.null(redcap_f01f05_dta()), 
       {
         amr_acorn_relevant <- amr
         showNotification(i18n$t("The lab log is generated based on all specimens, including those not relevant to ACORN. 
                          To avoid this, download clinical data first."), duration = 8, type = "warning")
         
       },
       {
         amr_acorn_relevant <- amr |> filter(patid %in% redcap_f01f05_dta()$patient_id)
         showNotification(paste0(i18n$t("Generating the lab log only on specimens from patients relevant to ACORN ("), 
                                 amr_acorn_relevant |> nrow(), 
                                 " records out of ", amr |> nrow(),
                                 " total records)."), duration = 8)
       }
)


# Comparison of organisms -----------------------------------------------------

if (input$format_lab_data %in% c("WHONET .dBase", "WHONET .SQLite")) {
  lab_log$organism_name_compare <- bind_rows(
    amr_acorn_relevant |> filter(org.local != orgname) |> 
      group_by(org.local, org.whonet, orgname) |> summarise(n = n(), .groups = "drop") |> 
      mutate(Change = "changed"),
    amr_acorn_relevant |> filter(org.local == orgname) |> 
      group_by(org.local, org.whonet, orgname) |> summarise(n = n(), .groups = "drop") |> 
      mutate(Change = "identical")
  ) |>
    arrange(Change, orgname) |> 
    rename(`Initial Organism` = org.local, `Initial organism (WHONET code)` = org.whonet, `Final Organism` = orgname, `Number Organisms` = n)
}

if (input$format_lab_data == "Tabular") {
  lab_log$organism_name_compare <- bind_rows(
    amr_acorn_relevant |> filter(org.local != orgname) |> 
      group_by(org.local, orgname) |> summarise(n = n(), .groups = "drop") |> 
      mutate(Change = "changed"),
    amr_acorn_relevant |> filter(org.local == orgname) |> 
      group_by(org.local, orgname) |> summarise(n = n(), .groups = "drop") |> 
      mutate(Change = "identical")
  ) |>
    arrange(Change, orgname) |> 
    rename(`Initial Organism` = org.local, `Final Organism` = orgname, `Number Organisms` = n)
}

# Comparison of specimen types ------------------------------------------------

if (input$format_lab_data %in% c("WHONET .dBase", "WHONET .SQLite")) {
  lab_log$specimen_type_compare <- amr_acorn_relevant |> 
    group_by(spectype.whonet, specgroup) |> 
    summarise(n = n(), .groups = "drop") |> 
    arrange(desc(n)) |> 
    rename(`Original Specimen Type` = spectype.whonet, `Recoded Specimen Type` = specgroup, `Number Organisms` = n)
}

if (input$format_lab_data == "Tabular") {
  lab_log$specimen_type_compare <- amr_acorn_relevant |> 
    group_by(spectype.local, specgroup) |> 
    summarise(n = n(), .groups = "drop") |> 
    arrange(desc(n)) |> 
    rename(`Original Specimen Type` = spectype.local, `Recoded Specimen Type` = specgroup, `Number Organisms` = n)
}


# Missing AST for key bug-drug combos -----------------------------------------
dta_combo <- lab_code$key.bug.drug.combos |> 
  mutate(antibio_code = str_replace_all(antibio_code, pattern = " ", replacement = "")) |> 
  mutate(antibio_code_vec = str_split(antibio_code, ",")) |> 
  mutate(dta_combo_row = 1:n())

# iterate across dta_combo rows
result <- tibble()

for(dta_combo_row in dta_combo$dta_combo_row) {
  result <- bind_rows(result, 
                      amr_acorn_relevant |> 
                        filter(str_detect(orgname, dta_combo$orgname[dta_combo_row])) |> 
                        select(specid, specgroup, orgnum, orgname, 
                               dta_combo$antibio_code_vec[[dta_combo_row]]) |> 
                        rowwise() |> 
                        mutate(across(-c(1:4), ~ .x %in% c("S", "I", "R"))) |> 
                        mutate(flag = !any(c_across(-c(1:4)))) |> 
                        ungroup() |> 
                        mutate(dta_combo_row = dta_combo_row) |> 
                        select(specid, specgroup, orgnum, orgname,
                               flag, dta_combo_row))
}

lab_log$missing_ast <- left_join(result,
                                 dta_combo |> select(-orgname),
                                 by = "dta_combo_row") |>
  filter(flag == TRUE) |>
  select(`Specimen number` = specid, `Specimen type` = specgroup, `Organism number` = orgnum, `Organism name` = orgname,
         `Antibiotic group` = antibio_group, `Antibiotic names` = antibio_name) |> 
  mutate(Comment = "At least one of the named antibiotic should be tested")

# Key intrinsic resistance ----------------------------------------------------

dta_intrinsic <- lab_code$intrinsic.resistance |> 
  mutate(antibio_code = str_replace_all(antibio_code, pattern = " ", replacement = "")) |> 
  separate(antibio_code, paste("code", 1:10, sep = "_"), ",", fill = "right") |> 
  separate(antibio_name, paste("name", 1:10, sep = "_"), ",", fill = "right") |> 
  pivot_longer(-c(orgname, antibio_group, ast.result, comment, note), names_to = c(".value", "item"), names_sep = "_") |> 
  select(-item) |> 
  rename(antibio_code = code, antibio_name = name) |> 
  filter(!is.na(antibio_code)) |> 
  mutate(dta_intrinsic_row = 1:n())

# iterate across dta_intrinsic rows
result <- tibble()

for(dta_intrinsic_row in dta_intrinsic$dta_intrinsic_row) {
  result <- bind_rows(result, 
                      amr_acorn_relevant |> 
                        filter(str_detect(orgname, dta_intrinsic$orgname[dta_intrinsic_row])) |> 
                        select(specid, specgroup, orgnum, orgname, 
                               dta_intrinsic$antibio_code[[dta_intrinsic_row]]) |> 
                        rowwise() |> 
                        mutate(across(-c(1:4), ~ .x %in% unlist(strsplit(dta_intrinsic$ast.result[dta_intrinsic_row], ",")))) |> 
                        mutate(flag = !any(c_across(-c(1:4)))) |>
                        ungroup() |> 
                        mutate(dta_intrinsic_row = dta_intrinsic_row) |> 
                        select(specid, specgroup, orgnum, orgname,
                               flag, dta_intrinsic_row)
  )
}

lab_log$intrinsic_resistance <- left_join(result,
                                          dta_intrinsic |> select(-orgname),
                                          by = "dta_intrinsic_row") |>
  filter(flag == TRUE) |>
  select(`Specimen number` = specid, `Specimen type` = specgroup, `Organism number` = orgnum, `Organism name` = orgname,
         `Antibiotic group` = antibio_group, `Antibiotic name` = antibio_name, Comment = comment, Note = note)



# Unusual AST results ---------------------------------------------------------

# Modify amr_acorn_relevant to test if correctly flagged
# amr_acorn_relevant |> filter(orgname == "Salmonella Typhi") |> pull(MEM)  # S
# amr_acorn_relevant[amr_acorn_relevant$specid == "BC2021-2281" & amr_acorn_relevant$orgnum == 1, "MEM"] <- "R"

dta_unusual_ast <- lab_code$qc.checks |> 
  mutate(antibio_code = str_replace_all(antibio_code, pattern = " ", replacement = "")) |> 
  separate(antibio_code, paste("code", 1:10, sep = "_"), ",", fill = "right") |> 
  separate(antibio_name, paste("name", 1:10, sep = "_"), ",", fill = "right") |> 
  pivot_longer(-c(orgname, antibio_group, ast.result, comment), names_to = c(".value", "item"), names_sep = "_") |> 
  select(-item) |> 
  rename(antibio_code = code, antibio_name = name) |> 
  filter(!is.na(antibio_code)) |> 
  mutate(dta_unusual_ast_row = 1:n())

# iterate across dta_unusual_ast rows
result <- tibble()

for(dta_unusual_ast_row in dta_unusual_ast$dta_unusual_ast_row) {
  result <- bind_rows(result, 
                      amr_acorn_relevant |> 
                        filter(str_detect(orgname, dta_unusual_ast$orgname[dta_unusual_ast_row])) |> 
                        select(specid, specgroup, orgnum, orgname, 
                               dta_unusual_ast$antibio_code[[dta_unusual_ast_row]]) |> 
                        rowwise() |> 
                        mutate(across(-c(1:4), ~ .x %in% unlist(strsplit(dta_unusual_ast$ast.result[dta_unusual_ast_row], ",")))) |> 
                        mutate(flag = any(c_across(-c(1:4)))) |>
                        ungroup() |> 
                        mutate(dta_unusual_ast_row = dta_unusual_ast_row) |> 
                        select(specid, specgroup, orgnum, orgname,
                               flag, dta_unusual_ast_row)
  )
}

lab_log$unusual_ast <- left_join(result,
                                 dta_unusual_ast |> select(-orgname),
                                 by = "dta_unusual_ast_row") |>
  filter(flag == TRUE) |>
  select(`Specimen number` = specid, `Specimen type` = specgroup, `Organism number` = orgnum, `Organism name` = orgname,
         `Antibiotic group` = antibio_group, `Antibiotic name` = antibio_name, Comment = comment)


# All patient_id in REDCap should match one patid in the lab file.
lab_log$patient_redcap_not_lab <- tibble::tibble(
  patient_id = setdiff(
    redcap_f01f05_dta() |> pull(patient_id) |> unique(),
    lab_dta() |> pull(patid) |> unique()
  )
)


# Check the first cases flagged in KH001 data:
# Missing AST for key bug-drug combos:
# amr_acorn_relevant |> filter(specid == "BC2021-1952", orgnum == 2) |> select(TZP)  # NA
# Key intrinsic resistance:
# amr_acorn_relevant |> filter(specid == "BC2021-1952", orgnum == 3) |> select(CRO)  # I 
