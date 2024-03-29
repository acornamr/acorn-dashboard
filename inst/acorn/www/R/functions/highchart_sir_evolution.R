highchart_sir_evolution <- function(
    data_input, 
    organism_input, 
    corresp, 
    combine_SI, 
    filter_antibio = "", 
    deduplication_method
) {
  
  hc_acorn_theme <- hc_theme_google() # mirror in startup.R, highchart_sir.R and highchart_sir_evolution.R
  
  # Column in the Organism-Antibiotic matrix
  matching_name_column <- "all_other_organisms"  # default
  
  if(organism_input == "Acinetobacter sp")            matching_name_column <- "acinetobacter_species"
  if(organism_input == "Escherichia coli")            matching_name_column <- "e_coli"
  if(organism_input == "Haemophilus influenzae")      matching_name_column <- "haemophilus_influenzae"
  if(organism_input == "Klebsiella pneumoniae")       matching_name_column <- "k_pneumoniae"
  if(organism_input == "Neisseria meningitidis")      matching_name_column <- "neisseria_meningitidis"
  if(organism_input == "Pseudomonas aeruginosa")      matching_name_column <- "pseudomonas_aeruginosa"
  if(str_detect(organism_input, "Salmonella"))        matching_name_column <- "salmonella_species"
  if(organism_input == "Staphylococcus aureus")       matching_name_column <- "s_aureus"
  if(organism_input == "Streptococcus pneumoniae")    matching_name_column <- "s_pneumoniae"
  
  
  # Treatment of species
  organism_filter <- organism_input
  
  if(organism_input == "Acinetobacter sp") {
    vec <- unique(data_input$orgname)
    organism_filter <- vec[str_detect(vec, "Acinetobacter")]
  }
  
  if(organism_input == "Salmonella sp (not S. Typhi or S. Paratyphi)") {
    vec <- unique(data_input$orgname)
    organism_filter <- vec[str_detect(vec, "Salmonella") & vec != "Salmonella Typhi" & !str_detect(vec, "Salmonella Paratyphi")]
  }
  
  if(combine_SI) {
    sir_results <- data_input %>% 
      filter(orgname %in% organism_filter) %>% 
      fun_deduplication(method = deduplication_method) %>%
      select(c("specid", "specdate", any_of(corresp$antibio_code))) %>%
      pivot_longer(-c(specid:specdate)) %>%
      filter(value %in% c("S", "I", "R")) %>%
      mutate(
        specimen_month = round_date(specdate, "month"),
        value = factor(value, levels = c("S", "I", "R"), labels = c("Susceptible", "Susceptible", "Resistant"))
      ) %>%
      group_by(specimen_month, name) %>%
      count(value) %>%
      ungroup()
  }
  
  if(! combine_SI) {
    sir_results <- data_input %>% 
      filter(orgname %in% organism_filter) %>% 
      fun_deduplication(method = deduplication_method) %>%
      select(c("specid", "specdate", any_of(corresp$antibio_code))) %>%
      pivot_longer(-c(specid:specdate)) %>%
      filter(value %in% c("S", "I", "R")) %>%
      mutate(
        specimen_month = round_date(specdate, "month"),
        value = factor(value, levels = c("S", "I", "R"), labels = c("Susceptible", "Intermediate", "Resistant"))
      ) %>%
      group_by(specimen_month, name) %>%
      count(value) %>%
      ungroup()
  }
  
  
  sir_results <- left_join(sir_results, 
                           corresp, 
                           by = c('name' = 'antibio_code')) %>%
    filter(UQ(as.symbol(matching_name_column)) %in% c("show", "show_sir_only")) %>%
    filter(filter_antibio == antibio_name)
  
  
  sir_results <- sir_results %>% 
    group_by(specimen_month, value) %>%
    summarise(n = sum(n), .groups = "drop") %>%
    filter(!is.na(specimen_month)) %>%
    complete(value, specimen_month, fill = list(n = 0))
  
  # Add total
  total_tested <- sir_results %>%
    group_by(specimen_month) %>%
    summarise(total_org = sum(n), .groups = "drop") %>%
    ungroup()
  
  sir_results <- left_join(sir_results, total_tested, by = "specimen_month") %>%
    mutate(percent = round(100*n / total_org, 0),
           specimen_month = format(specimen_month, "%b-%y"))
  
  if(combine_SI) {
    return(
      sir_results %>%
        hchart(type = "column", hcaes(x = "specimen_month", y = "n", group = "value")) %>%
        hc_yAxis(title = list(text = "%"), max = 115, endOnTick = FALSE, stackLabels = list(enabled = TRUE)) %>%
        hc_xAxis(title = "") %>%
        hc_colors(cols_sir[c(1, 3)]) %>%
        hc_tooltip(headerFormat = "",
                   pointFormat = "{point.value}: {point.percent}% <br>({point.n} of {point.total_org} tested.)") %>%
        hc_plotOptions(series = list(stacking = 'percent')) %>%
        hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind))) |> 
        hc_add_theme(hc_acorn_theme)
    )
  }
  
  if(! combine_SI) {
    return(
      sir_results %>%
        hchart(type = "column", hcaes(x = "specimen_month", y = "n", group = "value")) %>%
        hc_yAxis(title = list(text = "%"), max = 115, endOnTick = FALSE, stackLabels = list(enabled = TRUE)) %>%
        hc_xAxis(title = "") %>%
        hc_colors(cols_sir) %>%
        hc_tooltip(headerFormat = "",
                   pointFormat = "{point.value}: {point.percent}% <br>({point.n} of {point.total_org} tested.)") %>%
        hc_plotOptions(series = list(stacking = 'percent')) %>%
        hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind))) |> 
        hc_add_theme(hc_acorn_theme)
    )
  }
}