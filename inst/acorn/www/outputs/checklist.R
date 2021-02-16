# Status can be: hidden / question / okay / warning / ko

output$checklist_status <- renderText({
  # elements <- c("app_init", "asp_upload", "asp_format", "internet_con", "s3_cred", "s3_con",
  #               "acorn_file_loaded", "acorn_file_saved", "acorn_data_filtered")
  
  # checklist <- reactiveValuesToList(checklist_status)[elements]
  
  checklist <- reactiveValuesToList(checklist_status)
  
  text <- NULL

  for(index in 1:length(checklist)) {
    if(checklist[[index]]$status == "okay")  text[index] <-  paste0("<span class='cl-success'><i class='fa fa-check'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "ko")  text[index] <-  paste0("<span class='cl-fail'><i class='fa fa-stop-circle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "warning")  text[index] <-  paste0("<span class='cl-warning'><i class='fa fa-stop-circle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "question" | checklist[[index]]$status == "hidden")  text[index] <-  paste0("<span class='cl-question'><i class='fa fa-question'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
  }

  
  text <- paste(text, collapse = "</br>")
  return(paste("(To close click outside)</br></br>", text))
})