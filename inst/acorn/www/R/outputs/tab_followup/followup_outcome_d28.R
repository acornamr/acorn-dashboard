output$d28_outcome_gauge <- renderGauge({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  n <- redcap_f01f05_dta_filter() %>%
    filter(has_d28_outcome) %>%
    pull(redcap_id) %>%
    n_distinct()
  
  total <- redcap_f01f05_dta_filter() %>% 
    pull(redcap_id) %>%
    n_distinct()
  
  gauge(n, min = 0, max = total, abbreviate = FALSE, gaugeSectors(colors = "#2c3e50"))
})

output$d28_outcome_pct <- renderText({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  n <- redcap_f01f05_dta_filter() %>%
    filter(has_d28_outcome) %>%
    pull(redcap_id) %>%
    n_distinct()
  
  total <- redcap_f01f05_dta_filter() %>%
    pull(redcap_id) %>%
    n_distinct()
  
  paste(h3(paste0(round(100*n/total, 1), "%")), span("of patient enrolments have a recorded D28 outcome."))
})



output$d28_outcome_status <- renderHighchart({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  df <- redcap_f01f05_dta_filter() %>%
    filter(has_d28_outcome) %>%
    count(d28_status) %>%
    mutate(d28_status = replace_na(d28_status, "Unknown")) %>%
    rename(y = n, name = d28_status) %>%
    mutate(freq = round(100*y / sum(y)), color = NA)
  
  df$color[df$name == "Dead"] <- "#000000"
  df$color[df$name == "Alive - completely recovered"] <- "#a6cee3"
  df$color[df$name == "Alive - not back to normal activities"] <- "#a6cee3"
  df$color[df$name == "Unable to contact"] <- "#999DA0"
  df$color[df$name == "Unknown"] <- "#999DA0"
  
  
  highchart() %>%
    hc_chart(type = "bar") %>% 
    hc_xAxis(categories = df$name) %>% 
    hc_add_series(df, name = "D28 Status", showInLegend = FALSE) %>%
    hc_tooltip(headerFormat = "", pointFormat = "{point.y} patients ({point.freq} %)") %>%
    hc_plotOptions(pie = list(dataLabels = list(enabled = TRUE, 
                                                format = '{point.name}: {point.y}',
                                                style = list(fontSize = 12)))) %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})
