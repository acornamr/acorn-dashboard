showNotification("Trying to retrive REDCap data (HAI Ward form). It might take a minute.", duration = NULL, id = "try_redcap_hai")

dl_hai_dta <- try(
  withCallingHandlers({
    shinyjs::html(id = "text_redcap_log", "<strong>REDCap data retrieval log:</strong>")
    redcap_read(
      redcap_uri = "https://m-redcap-test.tropmedres.ac/redcap_test/api/", 
      token = acorn_cred()$redcap_hai_api,
      col_types = cols(.default = col_character())
    )$data
  },
  message = function(m) {
    shinyjs::html(id = "text_redcap_log", html = m$message, add = TRUE)
  }
  )
)

removeNotification(id = "try_redcap_hai")

if(inherits(dl_hai_dta, "try-error"))  {
  showNotification("REDCap data (HAI Ward form) wasn't retrived. Please try again.", type = "error")
  return()
}

showNotification("REDCap data (HAI Ward form) successfully retrived.")
shinyjs::html(id = "text_redcap_log", "<br/>", add = TRUE)