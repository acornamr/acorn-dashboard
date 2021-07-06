output$profile_outcome_diagnosis <- renderHighchart({
  
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  df <- redcap_f01f05_dta_filter() %>%
    filter(has_clinical_outcome) %>%
    group_by(surveillance_diag, ho_final_diag) %>% count() %>% ungroup() %>%
    rename(from = surveillance_diag, to = ho_final_diag, weight = n) %>% 
    mutate(id = paste0(from, " - ", to, ": ", weight)) %>%
    slice_max(weight, n = 10)
  
  highchart() %>%
    hc_chart(type = 'sankey') %>%
    hc_add_series(data = df,
                  tooltip = list(headerFormat = "", pointFormat = "{point.weight} patients | initial: {point.from}, final: {point.to}")) %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})
  