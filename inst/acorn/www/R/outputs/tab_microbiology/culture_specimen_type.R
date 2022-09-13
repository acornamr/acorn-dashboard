output$culture_specimen_type <- renderHighchart({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)
  
  
  ifelse(input$filter_rm_contaminant, {
    dta <- acorn_dta_filter() %>% filter(contaminant == "No")
  }, 
  {
    dta <- acorn_dta_filter() 
  })
  
  dta <- dta %>%
    fun_deduplication(method = input$deduplication_method) %>%
    group_by(specid) %>%
    slice(1) %>%
    ungroup() %>%
    group_by(specgroup) %>%
    summarise(y = n(), .groups = "drop") %>%
    mutate(freq = round(100*y / sum(y))) %>%
    arrange(desc(y))
  
  highchart() %>% 
    hc_yAxis(title = "") %>%
    hc_xAxis(categories = as.list(dta$specgroup)) %>%
    hc_colors("#969696") %>%
    hc_add_series(data = dta, type = "bar", hcaes(x = specgroup, y = y),
                  showInLegend = FALSE, tooltip = list(pointFormat = "{point.y} specimens collected ({point.freq} %).")) %>%
    hc_plotOptions(bar = list(stacking = "normal")) %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind))) |> 
    hc_add_theme(hc_acorn_theme)
})