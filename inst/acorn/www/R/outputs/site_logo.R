output$site_logo <- renderUI({
  if(is.null(acorn_cred()$site))  return()
  
  
  return(img(src = glue("./images/logo_{acorn_cred()$site}.png"), alt = "Institution Logo", id = "logo-img"))
  
  # tags$a(href = dta_asp_site()$value[dta_asp_site()$var == "Logo link"], 
  #        tags$img(src = glue("logo_{dta_asp_site()$value[dta_asp_site()$var == 'Site Code']}.png"), id = 'logo'))
  # TODO: open the link in a new tab (what happens if it's in a standalone app?!)
})