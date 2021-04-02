output$table_redcap_dta <- renderDT({
  req(redcap_dta())
  
  dta <- redcap_dta() %>% 
    select(recordid, redcap_repeat_instrument,
           brthdtc, d28_date)
  
  
  datatable(dta, 
            escape = FALSE, selection = "single", rownames = FALSE, 
            options = list(pageLength = 5)
  )
})