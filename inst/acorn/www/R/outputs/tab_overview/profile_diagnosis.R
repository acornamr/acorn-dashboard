output$profile_diagnosis <- renderHighchart({
  req(redcap_f01f05_dta_filter(), nrow(redcap_f01f05_dta_filter()) > 0)
  
  df <- redcap_f01f05_dta_filter() %>%
    group_by(surveillance_diag) %>%
    summarise(y = n(), .groups = "drop") %>%
    mutate(freq = round(100*y / sum(y)))
  
  
  highchart() %>% 
    hc_yAxis(title = "") %>%
    hc_xAxis(categories = as.list(df$surveillance_diag)) %>%
    hc_add_series(data = df, type = "bar", hcaes(x = surveillance_diag, y = y),
                  showInLegend = FALSE, tooltip = list(headerFormat = "", 
                                                       pointFormat = "Patients with {point.surveillance_diag}: {point.y} ({point.freq} %)")) %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})