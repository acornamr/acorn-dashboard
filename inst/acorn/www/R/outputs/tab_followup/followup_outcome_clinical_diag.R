output$profile_outcome_diagnosis <- renderHighchart({
  
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  df <- redcap_f01f05_dta_filter() %>%
    filter(has_clinical_outcome) %>%
    mutate(ho_final_diag = replace_na(ho_final_diag, "Unknown Final")) %>%
    group_by(surveillance_diag, ho_final_diag) %>%
    count() %>%
    rename(from = surveillance_diag, to = ho_final_diag, weight = n) %>% 
    mutate(color = NA, id = paste0(from, " - ", to, ": ", weight))
  
  df$color[df$from == "Meningitis"] <- "#1f78b4"
  df$color[df$from == "Pneumonia"] <- "#33a02c"
  df$color[df$from == "Sepsis"] <- "#e31a1c"
  df$color[df$from == "Unknown Initial"] <- "#969696"
  
  highchart() %>%
    hc_chart(type = 'sankey') %>%
    hc_add_series(data = df,
                  # Meningitis, Confirmed, Rejected, Pneumonia, Sepsis, , Unknown Initial, Unknown Final
                  colors = c("#1f78b4", "#fd8d3c", "#000000", "#33a02c", "#e31a1c", "#969696", "#969696"),
                  tooltip = list(headerFormat = "", pointFormat = "{point.weight} patients with {point.from} - diagnostic {point.to}")) %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})
  