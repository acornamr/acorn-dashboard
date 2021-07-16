output$culture_specgroup <- renderHighchart({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)
  
  ifelse(input$filter_rm_contaminant, {
    dta <- acorn_dta_filter() %>% 
      replace_na(list(contaminant = "No")) %>% filter(contaminant == "No")
  }, 
  {
    dta <- acorn_dta_filter() 
  })
  
  # Specimens with at least one element that has grown
  spec_grown <- dta %>%
    fun_filter_growth_only() %>%
    pull(specid)
  
  dta2 <- dta %>%
    fun_deduplication(method = input$deduplication_method) %>%
    mutate(growth = case_when(specid %in% spec_grown ~ "Growth", TRUE ~ "No Growth")) %>%
    mutate(culture_result = case_when(orgname == "Not cultured" ~ "Not cultured", TRUE ~ growth)) %>%
    group_by(specgroup, culture_result) %>%
    summarise(n = n_distinct(specid), .groups = "drop") %>%
    complete(specgroup, culture_result, fill = list(n = 0))
  
  dta2 <- left_join(dta2,
                    dta2 %>%
                     group_by(specgroup) %>%
                     summarise(total = sum(n), .groups = "drop"),
                   by = "specgroup") %>%
    mutate(freq = 100*round(n/total, 2)) %>%
    arrange(desc(total))
  
  dta2 %>%
    hchart(type = "bar", hcaes(x = "specgroup", y = "n", group = "culture_result")) %>%
    hc_xAxis(title = "") %>% hc_yAxis(title = "") %>%
    hc_colors(c("#8e44ad", "#7f8c8d", "#d35400")) %>%
    hc_plotOptions(bar = list(stacking = "normal")) %>%
    hc_tooltip(pointFormat = "{point.culture_result}: {point.y} specimens collected ({point.freq} %).") %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})
