output$contaminants_pct <- renderText({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  ifelse(input$filter_rm_contaminant, {
    dta <- acorn_dta_filter() %>% 
      replace_na(list(contaminant = "No")) %>% filter(contaminant == "No")
  }, 
  {
    dta <- acorn_dta_filter() 
  })
  
  n <- dta %>%
    fun_deduplication(method = input$deduplication_method) %>%
    group_by(specid) %>%
    slice(1) %>%
    ungroup() %>%
    filter(specgroup == "Blood", contaminant == "No") %>%
    nrow()
  
  total <- dta %>%
    fun_deduplication(method = input$deduplication_method) %>%
    group_by(specid) %>%
    slice(1) %>%
    ungroup() %>%
    filter(specgroup == "Blood") %>%
    nrow()
  
  paste(br(), br(), h4(paste0(round(100 * n / total, 1), "%")), span("of blood cultures aren't contaminants."))
})