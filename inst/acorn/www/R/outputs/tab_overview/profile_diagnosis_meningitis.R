output$profile_diagnosis_meningitis <- renderHighchart({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter() %>% filter(surveillance_diag == "Meningitis")) > 0)
  
  csf_patient_id <- acorn_dta_filter() %>% filter(specgroup == "CSF") %>% pull(patient_id)
  
  redcap_f01f05_dta_filter() %>%
    filter(surveillance_diag == "Meningitis") %>%
    mutate(had_csf = as.character(patient_id %in% csf_patient_id)) %>%
    mutate(had_csf = recode(had_csf, "TRUE" = "Yes", "FALSE" = "No")) %>%
    group_by(had_csf) %>%
    summarise(y = n(), .groups = "drop") %>%
    mutate(total = sum(y), freq = round(100*y / sum(y))) %>%
    hchart(type = "column", hcaes(x = had_csf, y = y)) %>%
    hc_colors("#1f78b4") %>%
    hc_yAxis(title = "") %>%
    hc_xAxis(title = "") %>%
    hc_title(text = "Meningitis patients with a CSF", style = list(fontSize = "11px")) %>%
    hc_tooltip(headerFormat = "", pointFormat = "{point.y} of {point.total} ({point.freq} %)") %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})
