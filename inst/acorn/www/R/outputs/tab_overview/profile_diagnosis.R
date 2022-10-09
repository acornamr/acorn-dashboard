output$profile_diagnosis <- renderHighchart({
  req(redcap_f01f05_dta_filter(), nrow(redcap_f01f05_dta_filter()) > 0)
  
  redcap_f01f05_dta_filter() %>%
    group_by(surveillance_diag) %>%
    summarise(n = n(), .groups = "drop") %>%
    arrange(desc(n)) %>%
    mutate(freq = round(100*n / sum(n))) %>%
    hchart(type = "bar", hcaes(x = "surveillance_diag", y = "n")) %>%
    hc_yAxis(title = "", stackLabels = list(enabled = TRUE)) %>%
    hc_xAxis(title = "") %>%
    hc_colors("#969696") %>%
    hc_tooltip(headerFormat = "",
               pointFormat = "Patients with {point.surveillance_diag}: {point.n} ({point.freq} %)") %>%
    hc_plotOptions(series = list(stacking = "normal")) %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind))) |> 
    hc_add_theme(hc_acorn_theme)
})