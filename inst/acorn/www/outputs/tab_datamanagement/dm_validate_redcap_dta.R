output$validate_rules_REDCap <- renderPlot({
  req(redcap_dta())
  
  out <- confront(redcap_dta(), validate_rules_REDCap, raise = "all")
  plot(out)
})