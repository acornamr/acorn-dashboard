output$site_logo <- renderUI({
  if(is.null(acorn_cred()$site))  return()
  
  return(img(src = glue("./images/logo_{acorn_cred()$site}.png"), alt = "Institution Logo", id = "logo-img"))
})