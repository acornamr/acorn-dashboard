output$table_patients <- DT::renderDT({
  req(redcap_f01f05_dta_filter())
  
  grouping_vars <- input$variables_table
  grouping_vars_sym <- rlang::syms(grouping_vars)
  
  dta <- redcap_f01f05_dta_filter() %>%
    mutate(
      d28_outcome = case_when(
        !is.na(d28_date) ~ "Day-28 Outcome",
        TRUE ~ "No Day-28 Outcome"),
      clinical_outcome = case_when(
        !is.na(ho_discharge_date) ~ "Clinical Outcome",
        TRUE ~ "No Clinical Outcome"),
      ward_type = replace_na(ward_type, "Unknown"),
      ward = replace_na(ward, "Unknown"),
      surveillance_category = replace_na(surveillance_category, "Unknown")
    ) %>%
    mutate(surveillance_category = as.factor(surveillance_category), ward_type = as.factor(ward_type), ward = as.factor(ward),
           clinical_outcome = as.factor(clinical_outcome), d28_outcome = as.factor(d28_outcome)) %>%
    select(!!! grouping_vars_sym) %>%
    group_by(across(grouping_vars)) %>% count() %>% ungroup() %>%
    mutate(Proportion = n / sum(n)) %>%
    arrange(desc(n)) %>%
    rename_all(recode, surveillance_category = "Place of Infection", clinical_outcome = "Clinical Outcome",
               d28_outcome = "Day 28 Outcome", ward_type = "Type of Ward", ward = "Ward", n = "Enrolments")
  
  datatable(dta,
            rownames = FALSE, filter = "top",
            options = list(scrollX = TRUE, scrollY = 300, paging = FALSE)) %>%
    formatPercentage('Proportion', digits = 1)
})