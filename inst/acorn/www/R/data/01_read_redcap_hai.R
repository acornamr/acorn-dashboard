dl_hai_dta <- try(
  withCallingHandlers({
    shinyjs::html(id = "text_redcap_hai_log", "<strong>REDCap HAI data retrieval log: </strong>")
    redcap_read(
      batch_size = 500,
      redcap_uri = acorn_cred()$redcap_uri,
      token = acorn_cred()$redcap_hai_api,
      col_types = cols(.default = col_character())
    )$data
  },
  message = function(m) {
    shinyjs::html(id = "text_redcap_hai_log", html = m$message, add = TRUE)
  }
  )
)

if(inherits(dl_hai_dta, "try-error"))  {
  showNotification(i18n$t("REDCap data could not be downloaded. Please try again."), type = "error")
  return()
}

shinyjs::html(id = "text_redcap_hai_log", "<br/>", add = TRUE)