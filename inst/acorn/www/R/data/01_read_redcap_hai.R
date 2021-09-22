dl_hai_dta <- tryCatch(
  { withCallingHandlers({
    shinyjs::html(id = "text_redcap_hai_log",  "<strong>REDCap HAI data retrieval log: </strong>")
    redcap_read(
      batch_size = 500,
      redcap_uri = acorn_cred()$redcap_uri,
      token = acorn_cred()$redcap_hai_api,
      col_types = cols(.default = col_character())
    )$data
  },
  message = function(m) {
    shinyjs::html(id = "text_redcap_hai_log", html = m$message, add = TRUE)
  }) },
  error = function(cond)  {
    fail_read_redcap <<- TRUE
    continue <<- FALSE
  }
)


