output$profile_age <- renderHighchart({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  hchart(redcap_f01f05_dta_filter()$age) %>%
    hc_colors("#969696") %>%
    hc_legend() %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})