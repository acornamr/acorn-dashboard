message("10_generate_lab_log.R")

# Comparison of organisms ----
if (input$format_lab_data %in% c("WHONET .dBase", "WHONET .SQLite")) {
  lab_log$organism_name_compare <- bind_rows(
    amr |> filter(org.local != orgname) |> 
      group_by(org.local, org.whonet, orgname) |> summarise(n = n(), .groups = "drop") |> 
      mutate(Change = "changed"),
    amr |> filter(org.local == orgname) |> 
      group_by(org.local, org.whonet, orgname) |> summarise(n = n(), .groups = "drop") |> 
      mutate(Change = "identical")
  ) |>
    arrange(Change, orgname) |> 
    rename(`Initial Organism` = org.local, `Initial organism (WHONET code)` = org.whonet, `Final Organism` = orgname, `Number Organisms` = n)
}

if (input$format_lab_data == "Tabular") {
  lab_log$organism_name_compare <- bind_rows(
    amr |> filter(org.local != orgname) |> 
      group_by(org.local, orgname) |> summarise(n = n(), .groups = "drop") |> 
      mutate(Change = "changed"),
    amr |> filter(org.local == orgname) |> 
      group_by(org.local, orgname) |> summarise(n = n(), .groups = "drop") |> 
      mutate(Change = "identical")
  ) |>
    arrange(Change, orgname) |> 
    rename(`Initial Organism` = org.local, `Final Organism` = orgname, `Number Organisms` = n)
}

# Comparison of specimen types ----
if (input$format_lab_data %in% c("WHONET .dBase", "WHONET .SQLite")) {
  lab_log$specimen_type_compare <- amr |> 
    group_by(spectype.whonet, specgroup) |> 
    summarise(n = n(), .groups = "drop") |> 
    arrange(desc(n)) |> 
    rename(`Original Specimen Type` = spectype.whonet, `Recoded Specimen Type` = specgroup, `Number Organisms` = n)
}

if (input$format_lab_data == "Tabular") {
  lab_log$specimen_type_compare <- amr |> 
    group_by(spectype.local, specgroup) |> 
    summarise(n = n(), .groups = "drop") |> 
    arrange(desc(n)) |> 
    rename(`Original Specimen Type` = spectype.local, `Recoded Specimen Type` = specgroup, `Number Organisms` = n)
}

# Missing AST for key bug-drug combos ----
lab_log$missing_ast <- tibble("IN DEVELOPMENT" = "EXPECTED IN ACORN v2.3")

# Key intrinsic resistance ----
lab_log$intrinsic_resistance <- tibble("IN DEVELOPMENT" = "EXPECTED IN ACORN v2.3")

# Unusual AST results ----
lab_log$unusual_ast <- tibble("IN DEVELOPMENT" = "EXPECTED IN ACORN v2.3")
