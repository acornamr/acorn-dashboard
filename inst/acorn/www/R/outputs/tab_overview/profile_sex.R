# TODO: remove if confirmed not displayed in app

output$profile_sex <- renderHighchart({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  df <- redcap_f01f05_dta_filter() %>%
    count(sex) %>%
    arrange(n) %>%
    mutate(freq = round(100*n / sum(n)), color = NA)
  
  df$color[df$sex == "Male"] <- "#1f78b4"
  df$color[df$sex == "Female"] <- "#33a02c"
  df$color[df$sex == "Unknown sex"] <- "#969696"
  df$color[df$sex == "Other"] <- "#969696"
  
  df %>%
    hchart(type = "column", hcaes(x = sex, y = n, color = color)) %>%
    hc_yAxis(title = "") %>%
    hc_xAxis(title = "") %>%
    hc_tooltip(headerFormat = "", pointFormat = "{point.n} patients ({point.freq} %)") %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})