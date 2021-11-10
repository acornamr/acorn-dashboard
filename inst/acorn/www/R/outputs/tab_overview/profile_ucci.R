output$profile_ucci <- renderHighchart({
  req(acorn_dta_filter())
  
  acorn_dta_filter() %>% 
    mutate(cci = case_when(
      age_category != "Adult" ~ "uCCI Not Applicable (Non Adults)",
      TRUE ~ as.character(cci)
    )) %>%
    count(cci) %>% 
    arrange(desc(n)) %>%
    hchart(type = "bar", hcaes(x = "cci", y = "n")) %>%
    hc_yAxis(title = "", stackLabels = list(enabled = TRUE)) %>% 
    hc_xAxis(title = "") %>%
    hc_colors("#969696") %>%
    hc_tooltip(headerFormat = "",
               pointFormat = "{point.n} patients.") %>%
    hc_plotOptions(series = list(stacking = 'normal')) %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})
