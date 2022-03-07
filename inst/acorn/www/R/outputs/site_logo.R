output$site_logo <- renderUI({
  if(is_empty(acorn_cred()$site))  return()
  if(acorn_cred()$site == "demo")  return()
  if(!file.exists(glue("./www/images/logo_{acorn_cred()$site}.png")))  return()
  
  return(img(src = glue("./images/logo_{acorn_cred()$site}.png"), alt = "Institution Logo", id = "logo-img"))
})