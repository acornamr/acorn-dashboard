text_checklist <- function(checklist_status, vec) {
  checklist <- reactiveValuesToList(checklist_status)
  checklist <- checklist[vec]
  
  text <- NULL
  
  # Status can be: hidden / info / okay / warning / ko
  for(index in 1:length(checklist)) {
    if(checklist[[index]]$status == "okay")  text[index] <-  paste0("<span class='cl-success'><i class='fa fa-check'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "ko")  text[index] <-  paste0("<span class='cl-fail'><i class='fa fa-times-circle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "warning")  text[index] <-  paste0("<span class='cl-warning'><i class='fa fa-exclamation-triangle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "info")  text[index] <-  paste0("<span class='cl-info'><i class='fa fa-info-circle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
  }
  
  text <- text[!is.na(text)]
  
  paste(text, collapse = "</br>")
}
