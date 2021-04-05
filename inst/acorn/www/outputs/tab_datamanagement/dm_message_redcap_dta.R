output$message_redcap_dta <- renderText({
  req(redcap_dta())
  
  glue("We have successfully retrived {redcap_dta() %>% nrow()} records from REDCap server")
})