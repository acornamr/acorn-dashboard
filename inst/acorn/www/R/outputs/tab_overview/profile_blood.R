output$profile_blood <- renderHighchart({
  req(acorn_dta_filter())
  req(acorn_dta_filter() |> nrow() > 0)
  
  df <- redcap_f01f05_dta_filter() %>%
    count(blood_collect) %>%
    arrange(n) %>%
    rename(y = n, name = blood_collect) %>%
    mutate(freq = round(100*y / sum(y)), color = NA)
  
  df$color[df$name == "Yes"] <- "#fb9a99"
  df$color[df$name == "No"] <- "#a6cee3"
  df$color[df$name == "Unknown"] <- "#969696"
  
  df %>%
    hchart(type = "column", hcaes(x = name, y = y, color = color)) %>%
    hc_yAxis(title = "") %>%
    hc_xAxis(title = "") %>%
    hc_tooltip(headerFormat = "", pointFormat = "{point.y} patients ({point.freq} %)") %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
  
})