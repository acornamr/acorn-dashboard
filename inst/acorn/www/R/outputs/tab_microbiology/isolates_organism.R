output$isolates_organism <- renderHighchart({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)
  
  ifelse(input$filter_rm_contaminant, {
    dta <- acorn_dta_filter() %>% 
      replace_na(list(contaminant = "No")) %>% filter(contaminant == "No")
  }, 
  {
    dta <- acorn_dta_filter() 
  })
  
  dta <- dta %>%
    fun_filter_growth_only() %>%
    fun_filter_signifgrowth_only() %>%
    filter(orgname != "Mixed growth", orgname != "Not cultured") %>%
    fun_deduplication(method = input$deduplication_method) %>%
    group_by(orgname) %>%
    summarise(y = n(), .groups = "drop") %>%
    arrange(desc(y)) %>% head(10) %>%
    mutate(freq = round(100*y / sum(y))) %>%
    arrange(desc(y))
  
  highchart() %>% 
    hc_yAxis(title = "") %>%
    hc_colors("#969696") %>%
    hc_xAxis(categories = as.list(dta$orgname)) %>%
    hc_add_series(data = dta, type = "bar", hcaes(x = orgname, y = y),
                  showInLegend = FALSE, tooltip = list(headerFormat = "", 
                                                       pointFormat = "{point.y} isolates with {point.orgname} ({point.freq} %).")) %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})