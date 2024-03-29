highchart_sir <- function(
    data_input, 
    organism_input, 
    corresp, 
    combine_SI, 
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
    
    data <- data_input %>% 
      filter(orgname %in% organism_filter) %>%
      fun_deduplication(method = deduplication_method) %>%
      select(c("specid", any_of(corresp$antibio_code))) %>%
      pivot_longer(-specid) %>%
      filter(value != "Not Tested") %>%
      mutate(value = recode(value, I = "S")) %>%
      group_by(name) %>%
      count(value) |> 
      ungroup()
    
    total_tested <- data %>% 
      group_by(name) %>%
      summarise(total_org = sum(n), .groups = "drop")
    
    sir_results <- data %>% 
      left_join(total_tested, by = "name") %>%
      mutate(percent = round(100*n / total_org, 1),
             resistance = case_when(
               value == "S" ~ "Susceptible",
               value == "R" ~ "Resistant")) %>%
      mutate(resistance = factor(resistance, levels = c("Susceptible", "Resistant"))) %>%
      complete(resistance, nesting(name))
    
    
    sir_results <- left_join(sir_results, corresp, by = c("name" = "antibio_code")) %>%
      filter(UQ(as.symbol(matching_name_column)) == "show") %>%
      ungroup() %>%
      mutate(antibio_group = str_replace(antibio_group, "Other", "zzzOther")) %>%
      mutate(antibio_name = str_replace(antibio_name, "Aggregate", "zzzAggregate")) %>%
      arrange(antibio_group, antibio_name) %>%
      mutate(antibio_group = str_replace(antibio_group, "zzzOther", "Other")) %>%
      mutate(antibio_name = str_replace(antibio_name, "zzzAggregate", "Aggregate"))
    
    categories_grouped <- sir_results %>%
      select(antibio_group, antibio_name) %>%
      distinct() %>%
      group_by(name = antibio_group) %>%
      do(categories = .$antibio_name) %>%
      ungroup() %>%
      mutate(name = str_replace(name, "Other", "zzzOther")) %>%
      arrange(name) %>%
      mutate(name = str_replace(name, "zzzOther", "Other")) %>%
      list_parse() %>%
      map(function(x){
        if(length(x[["categories"]]) == 1)
          x[["categories"]] <- list(x[["categories"]])
        x
      })
    
    return(
      sir_results %>%
        hchart(type = "bar", hcaes(x = "antibio_name", y = "n", group = "resistance")) %>%
        hc_yAxis(title = list(text = "%"), max = 115, endOnTick = FALSE, stackLabels = list(enabled = TRUE)) %>%
        hc_xAxis(title = "", categories = categories_grouped) %>%
        hc_xAxis(title = "") %>%
        hc_colors(cols_sir[c(1, 3)]) %>%
        hc_tooltip(headerFormat = "",
                   pointFormat = "<b>{point.antibiotic_name}</b><br> {point.resistance}: {point.percent}% <br>({point.n} of {point.total_org} tested.)") %>%
        hc_plotOptions(series = list(stacking = 'percent')) %>%
        hc_add_dependency("plugins/grouped-categories.js") %>%
        hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind))) |> 
        hc_add_theme(hc_acorn_theme)
    )
  }
  
  if(!combine_SI) {
    
    data <- data_input %>% 
      filter(orgname %in% organism_filter) %>% 
      fun_deduplication(method = deduplication_method) %>%
      select(c("specid", any_of(corresp$antibio_code))) %>%
      pivot_longer(-specid) %>%
      filter(value != "Not Tested") %>%
      group_by(name) %>%
      count(value) |> 
      ungroup()
    
    total_tested <- data %>% 
      group_by(name) %>%
      summarise(total_org = sum(n), .groups = "drop")
    
    sir_results <- data %>% 
      left_join(total_tested, by = "name") %>%
      mutate(percent = round(100*n / total_org, 1),
             resistance = case_when(
               value == "S" ~ "Susceptible",
               value == "I" ~ "Intermediate",
               value == "R" ~ "Resistant")) %>%
      mutate(resistance = factor(resistance, levels = c("Susceptible", "Intermediate", "Resistant"))) %>%
      complete(resistance, nesting(name))
    
    sir_results <- left_join(sir_results, corresp, by = c('name' = 'antibio_code')) %>%
      filter(UQ(as.symbol(matching_name_column)) %in% c("show", "show_sir_only")) %>%
      ungroup() %>%
      mutate(antibio_group = str_replace(antibio_group, "Other", "zzzOther")) %>%
      mutate(antibio_name = str_replace(antibio_name, "Aggregate", "zzzAggregate")) %>%
      arrange(antibio_group, antibio_name) %>%
      mutate(antibio_group = str_replace(antibio_group, "zzzOther", "Other")) %>%
      mutate(antibio_name = str_replace(antibio_name, "zzzAggregate", "Aggregate"))
    
    categories_grouped <- sir_results %>%
      select(antibio_group, antibio_name) %>%
      distinct() %>%
      group_by(name = antibio_group) %>%
      do(categories = .$antibio_name) %>%
      ungroup() %>%
      mutate(name = str_replace(name, "Other", "zzzOther")) %>%
      arrange(name) %>%
      mutate(name = str_replace(name, "zzzOther", "Other")) %>%
      list_parse() %>%
      map(function(x){
        if(length(x[["categories"]]) == 1)
          x[["categories"]] <- list(x[["categories"]])
        x
      })
    
    return(
      sir_results %>%
        hchart(type = "bar", hcaes(x = "antibio_name", y = "n", group = "resistance")) %>%
        hc_yAxis(title = list(text = "%"), max = 115, endOnTick = FALSE, stackLabels = list(enabled = TRUE)) %>%
        hc_xAxis(title = "", categories = categories_grouped) %>%
        hc_xAxis(title = "") %>%
        hc_colors(cols_sir) %>%
        hc_tooltip(headerFormat = "",
                   pointFormat = "<b>{point.antibiotic_name}</b><br> {point.resistance}: {point.percent}% <br>({point.n} of {point.total_org} tested.)") %>%
        hc_plotOptions(series = list(stacking = 'percent')) %>%
        hc_add_dependency("plugins/grouped-categories.js") %>%
        hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind))) |> 
        hc_add_theme(hc_acorn_theme)
    )
  }
}
