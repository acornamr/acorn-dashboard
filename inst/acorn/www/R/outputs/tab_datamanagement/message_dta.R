output$message_redcap_dta <- renderText({
  req(redcap_dta())
  "Successfully retrieved clinical data."
})


output$message_lab_dta <- renderText({
  req(lab_dta())
  "Successfully provided lab data."
  
  # data_dictionary()$variables
})