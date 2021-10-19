dl_redcap_f01f05_dta <- tryCatch(
  { 
    withCallingHandlers({
      shinyjs::html(id = "text_redcap_f01f05_log", "</br><strong>REDCap F01 to F05 data retrieval log: </strong></br>")
      REDCapR::redcap_read(
        batch_size = 500,
        redcap_uri = acorn_cred()$redcap_uri, 
        token = acorn_cred()$redcap_f01f05_api,
        col_types = cols(.default = col_character())
      )$data
    },
    message = function(m) {
      shinyjs::html(id = "text_redcap_f01f05_log", html = m$message, add = TRUE)
    })
  },
  error = function(cond)  {
    fail_read_redcap <<- TRUE
    continue <<- FALSE
  }
)