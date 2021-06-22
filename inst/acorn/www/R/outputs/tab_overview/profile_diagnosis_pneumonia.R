output$profile_diagnosis_pneumonia <- renderHighchart({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter() %>% filter(surveillance_diag == "Pneumonia")) > 0)
  
  pf_patient_id <- acorn_dta_filter() %>% filter(specgroup == "Lower respiratory tract specimen") %>% pull(patient_id)
  
  redcap_f01f05_dta_filter() %>%
    filter(surveillance_diag == "Pneumonia") %>%
    mutate(had_pf = as.character(patient_id %in% pf_patient_id)) %>%
    mutate(had_pf = recode(had_pf, "TRUE" = "Yes", "FALSE" = "No")) %>%
    group_by(had_pf) %>%
    summarise(y = n(), .groups = "drop") %>%
    mutate(total = sum(y), freq = round(100*y / sum(y))) %>%
    hchart(type = "column", hcaes(x = had_pf, y = y)) %>%
    hc_colors("#33a02c") %>%
    hc_yAxis(title = "") %>%
    hc_xAxis(title = "") %>%
    hc_title(text = "Pneumonia patients with a sputum", style = list(fontSize = "11px")) %>%
    hc_tooltip(headerFormat = "", pointFormat = "{point.y} of {point.total} ({point.freq} %)") %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})
