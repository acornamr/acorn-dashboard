output$profile_transfer_hospital <- renderHighchart({
  req(redcap_f01f05_dta_filter())
  
  redcap_f01f05_dta_filter() %>%
    count(transfer_hospital) %>%
    arrange(n) %>%
    mutate(freq = round(100*n / sum(n)),
           color = case_when(transfer_hospital == "Yes" ~ "#1f78b4",
                             transfer_hospital == "No" ~ "#33a02c",
                             transfer_hospital == "Unknown" ~ "gray")) %>%
    hchart(type = "column", hcaes(x = transfer_hospital, y = n, color = color)) %>%
    hc_xAxis(title = "", stackLabels = list(enabled = TRUE)) %>% 
    hc_yAxis(title = "") %>%
    hc_tooltip(headerFormat = "", pointFormat = "{point.n} patients ({point.freq} %)") %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})