output$culture_specimen_type <- renderHighchart({
  req(acorn_dta_filter())
  req(nrow(acorn_dta_filter()) > 0)
  
  
  if(input$filter_rm_contaminant)  {
    dta <- acorn_dta_filter()
    dta <- dta %>% replace_na(list(contaminant = "No")) %>% filter(contaminant == "No")
    
    dta <- dta %>%
      fun_deduplication(method = input$deduplication_method) %>%
      group_by(specid) %>%
      slice(1) %>%
      ungroup() %>%
      group_by(specgroup, contaminant) %>%
      summarise(y = n(), .groups = "drop") %>%
      mutate(color = 
               case_when(
                 specgroup == "Blood" ~ "#e31a1c",
                 TRUE ~ "#969696"),
             freq = round(100*y / sum(y))) %>%
      arrange(desc(y))
    
    return(
      highchart() %>% 
        hc_yAxis(title = "") %>%
        hc_xAxis(categories = as.list(dta$specgroup)) %>%
        hc_add_series(data = dta, type = "bar", hcaes(x = specgroup, y = y, color = color, group = contaminant),
                      showInLegend = FALSE, tooltip = list(pointFormat = "{point.y} specimens collected ({point.freq} %).")) %>%
        hc_plotOptions(bar = list(stacking = "normal")) %>%
        hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
    )
  }
  
  if(! input$filter_rm_contaminant) {
    dta <- acorn_dta_filter()
    
    dta <- dta %>%
      fun_deduplication(method = input$deduplication_method) %>%
      group_by(specid) %>%
      slice(1) %>%
      ungroup() %>%
      group_by(specgroup, contaminant) %>%
      summarise(y = n(), .groups = "drop") %>%
      mutate(freq = round(100*y / sum(y))) %>%
      arrange(desc(y)) %>%
      mutate(contaminant_recoded = case_when(
        contaminant == "Yes" ~ "Contaminant",
        contaminant == "No" ~ "Not a Contaminant",
        TRUE ~ "Not applicable"
      ))
    
    return(
      dta %>%
        hchart(type = "bar", hcaes(x = "specgroup", y = "y", group = "contaminant_recoded")) %>%
        hc_xAxis(title = "") %>% hc_yAxis(title = "") %>%
        hc_colors(c("#000000", "#e31a1c", "#969696")) %>%
        hc_plotOptions(bar = list(stacking = "normal")) %>%
        hc_tooltip(pointFormat = "{point.specgroup} ({point.contaminant_recoded}): {point.y} specimens collected ({point.freq} %).") %>%
        hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
    )
  }
})