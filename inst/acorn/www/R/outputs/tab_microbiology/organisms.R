output$isolates_growth_gauge <- renderGauge({
    req(acorn_dta_filter())
    req(nrow(acorn_dta_filter()) > 0)
  
  n <- acorn_dta_filter() %>%
    fun_filter_growth_only() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    pull(specid) %>% 
    n_distinct()
  
  total <- acorn_dta_filter() %>%
    fun_filter_cultured_only() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    pull(specid) %>% 
    n_distinct()
  
  gauge(n, min = 0, max = total, abbreviate = FALSE, gaugeSectors(colors = "#2c3e50"))
})

output$isolates_growth_pct <- renderText({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  n <- acorn_dta_filter() %>%
    fun_filter_growth_only() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    pull(specid) %>% 
    n_distinct()
  
  total <- acorn_dta_filter() %>%
    fun_filter_cultured_only() %>%
    fun_deduplication(method = input$deduplication_method) %>%
    pull(specid) %>% 
    n_distinct()
  
  paste(br(), br(), h4(paste0(round(100*n/total, 1), "%")), span("of cultures have growth."))
})



output$isolates_organism <- renderHighchart({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)
  
  df <- acorn_dta_filter() %>%
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
    hc_xAxis(categories = as.list(df$orgname)) %>%
    hc_add_series(data = df, type = "bar", hcaes(x = orgname, y = y),
                  showInLegend = FALSE, tooltip = list(headerFormat = "", 
                                                       pointFormat = "{point.y} isolates with {point.orgname} ({point.freq} %).")) %>%
    hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
})

output$isolates_organism_table <- renderDT({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)

  df <- acorn_dta_filter() %>%
    fun_filter_growth_only() %>%
    fun_filter_signifgrowth_only() %>%
    filter(orgname != "Mixed growth", orgname != "Not cultured") %>%
    fun_deduplication(method = input$deduplication_method) %>%
    
    group_by(orgname) %>%
    summarise(N = n(), .groups = "drop") %>%
    mutate(Frequency = N / sum(N)) %>%
    rename(Organism = orgname) %>%
    arrange(desc(N))

  datatable(df,
            rownames = FALSE,
            filter = "top",
            style = "bootstrap",
            options = list(scrollX = TRUE, scrollY = 300, paging = FALSE, dom = "lrtip")) %>%
    formatStyle('N', background = styleColorBar(c(0, df$N), "#969696"), backgroundSize = '100%', 
                backgroundRepeat = 'no-repeat', backgroundPosition = 'center') %>%
    formatPercentage('Frequency', digits = 1)
})
