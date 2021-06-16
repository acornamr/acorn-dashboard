output$culture_specimen_type <- renderHighchart({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)
  
  dta <- acorn_dta_filter() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    group_by(specid) %>%
    slice(1) %>%
    ungroup() %>%
    group_by(specgroup) %>%
    summarise(y = n(), .groups = "drop") %>%
    mutate(color = 
             case_when(
               specgroup == "Blood" ~ "#e31a1c",
               TRUE ~ "#969696"),
           freq = round(100*y / sum(y))) %>%
    arrange(desc(y))
  
  highchart() %>% 
    hc_yAxis(title = "") %>%
    hc_xAxis(categories = as.list(dta$specgroup)) %>%
    hc_add_series(data = dta, type = "bar", hcaes(x = specgroup, y = y, color = color),
                  showInLegend = FALSE, tooltip = list(pointFormat = "{point.y} specimens collected ({point.freq} %).")) %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})

output$culture_specgroup <- renderHighchart({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)
  
  # Specimens with at least one element that has grown
  spec_grown <- acorn_dta_filter() %>%
    fun_filter_growth_only() %>%
    pull(specid)
  
  dta <- acorn_dta_filter() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    mutate(growth = case_when(specid %in% spec_grown ~ "Growth", TRUE ~ "No Growth")) %>%
    mutate(culture_result = case_when(orgname == "Not cultured" ~ "Not cultured", TRUE ~ growth)) %>%
    group_by(specgroup, culture_result) %>%
    summarise(n = n_distinct(specid), .groups = "drop") %>%
    complete(specgroup, culture_result, fill = list(n = 0))
  
  dta <- left_join(dta,
                   dta %>%
                     group_by(specgroup) %>%
                     summarise(total = sum(n), .groups = "drop"),
                   by = "specgroup") %>%
    mutate(freq = 100*round(n/total, 2)) %>%
    arrange(desc(total))
  
  dta %>%
    hchart(type = "bar", hcaes(x = "specgroup", y = "n", group = "culture_result")) %>%
    hc_xAxis(title = "") %>% hc_yAxis(title = "") %>%
    hc_colors(c("#8e44ad", "#7f8c8d", "#d35400")) %>%
    hc_plotOptions(bar = list(stacking = "normal")) %>%
    hc_tooltip(pointFormat = "{point.culture_result}: {point.y} specimens collected ({point.freq} %).") %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})
