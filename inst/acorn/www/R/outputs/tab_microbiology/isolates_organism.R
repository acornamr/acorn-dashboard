output$isolates_organism_nc <- renderHighchart({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter() %>% filter(contaminant == "No")) > 0)
  
  dta <- acorn_dta_filter() %>% filter(contaminant == "No")
  
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
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind))) |> 
    hc_add_theme(hc_acorn_theme)
})

output$isolates_organism_contaminant <- renderHighchart({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter() %>% filter(contaminant == "Yes")) > 0)
  req(!input$filter_rm_contaminant)
  
  dta <- acorn_dta_filter() %>% filter(contaminant == "Yes")
  
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
    hc_colors("#e74c3c") %>%
    hc_xAxis(categories = as.list(dta$orgname)) %>%
    hc_add_series(data = dta, type = "bar", hcaes(x = orgname, y = y),
                  showInLegend = FALSE, tooltip = list(headerFormat = "", 
                                                       pointFormat = "{point.y} isolates with {point.orgname} ({point.freq} %).")) %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind))) |> 
    hc_add_theme(hc_acorn_theme)
})