output$checklist_status_load <- renderText({
  checklist <- reactiveValuesToList(checklist_status)
  
  # re-order
  checklist <- checklist[c("acorn_dta")]
  
  text <- NULL
  
  # Status can be: hidden / question / okay / warning / ko
  for(index in 1:length(checklist)) {
    if(checklist[[index]]$status == "okay")  text[index] <-  paste0("<span class='cl-success'><i class='fa fa-check'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "ko")  text[index] <-  paste0("<span class='cl-fail'><i class='fa fa-times-circle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "warning")  text[index] <-  paste0("<span class='cl-warning'><i class='fa fa-exclamation-triangle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "question")  text[index] <-  paste0("<span class='cl-question'><i class='fa fa-question'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
  }
  
  text <- text[!is.na(text)]
  
  paste(text, collapse = "</br>")
})

output$checklist_status_load_server <- renderText({
  checklist <- reactiveValuesToList(checklist_status)
  
  # re-order
  checklist <- checklist[c("internet_connection", "app_login", "acorn_server_test")]
  
  text <- NULL
  
  # Status can be: hidden / question / okay / warning / ko
  for(index in 1:length(checklist)) {
    if(checklist[[index]]$status == "okay")  text[index] <-  paste0("<span class='cl-success'><i class='fa fa-check'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "ko")  text[index] <-  paste0("<span class='cl-fail'><i class='fa fa-times-circle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "warning")  text[index] <-  paste0("<span class='cl-warning'><i class='fa fa-exclamation-triangle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "question")  text[index] <-  paste0("<span class='cl-question'><i class='fa fa-question'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
  }
  
  text <- text[!is.na(text)]
  
   paste(text, collapse = "</br>")
})


output$checklist_status_clinical <- renderText({
  checklist <- reactiveValuesToList(checklist_status)
  
  # re-order
  checklist <- checklist[c("internet_connection", "app_login", "redcap_server_cred")]
  
  text <- NULL
  
  # Status can be: hidden / question / okay / warning / ko
  for(index in 1:length(checklist)) {
    if(checklist[[index]]$status == "okay")  text[index] <-  paste0("<span class='cl-success'><i class='fa fa-check'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "ko")  text[index] <-  paste0("<span class='cl-fail'><i class='fa fa-times-circle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "warning")  text[index] <-  paste0("<span class='cl-warning'><i class='fa fa-exclamation-triangle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "question")  text[index] <-  paste0("<span class='cl-question'><i class='fa fa-question'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
  }
  
  text <- text[!is.na(text)]
  
  paste(text, collapse = "</br>")
})

output$checklist_status_lab <- renderText({
  checklist <- reactiveValuesToList(checklist_status)
  
  # re-order
  checklist <- checklist[c("lab_dta")]
  
  text <- NULL
  
  # Status can be: hidden / question / okay / warning / ko
  for(index in 1:length(checklist)) {
    if(checklist[[index]]$status == "okay")  text[index] <-  paste0("<span class='cl-success'><i class='fa fa-check'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "ko")  text[index] <-  paste0("<span class='cl-fail'><i class='fa fa-times-circle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "warning")  text[index] <-  paste0("<span class='cl-warning'><i class='fa fa-exclamation-triangle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "question")  text[index] <-  paste0("<span class='cl-question'><i class='fa fa-question'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
  }
  
  text <- text[!is.na(text)]
  
  paste(text, collapse = "</br>")
})

output$checklist_generate <- renderText({
  checklist <- reactiveValuesToList(checklist_status)
  
  # re-order
  checklist <- checklist[c("redcap_dta", "lab_dta")]
  
  text <- NULL
  
  # Status can be: hidden / question / okay / warning / ko
  for(index in 1:length(checklist)) {
    if(checklist[[index]]$status == "okay")  text[index] <-  paste0("<span class='cl-success'><i class='fa fa-check'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "ko")  text[index] <-  paste0("<span class='cl-fail'><i class='fa fa-times-circle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "warning")  text[index] <-  paste0("<span class='cl-warning'><i class='fa fa-exclamation-triangle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "question")  text[index] <-  paste0("<span class='cl-question'><i class='fa fa-question'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
  }
  
  text <- text[!is.na(text)]
  
  paste(text, collapse = "</br>")
})


output$checklist_save <- renderText({
  checklist <- reactiveValuesToList(checklist_status)
  
  # re-order
  checklist <- checklist[c("acorn_dta_saved")]
  
  text <- NULL
  
  # Status can be: hidden / question / okay / warning / ko
  for(index in 1:length(checklist)) {
    if(checklist[[index]]$status == "okay")  text[index] <-  paste0("<span class='cl-success'><i class='fa fa-check'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "ko")  text[index] <-  paste0("<span class='cl-fail'><i class='fa fa-times-circle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "warning")  text[index] <-  paste0("<span class='cl-warning'><i class='fa fa-exclamation-triangle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "question")  text[index] <-  paste0("<span class='cl-question'><i class='fa fa-question'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
  }
  
  text <- text[!is.na(text)]
  
  paste(text, collapse = "</br>")
})

output$checklist_save_server <- renderText({
  checklist <- reactiveValuesToList(checklist_status)
  
  # re-order
  checklist <- checklist[c("acorn_dta_saved")]
  
  text <- NULL
  
  # Status can be: hidden / question / okay / warning / ko
  for(index in 1:length(checklist)) {
    if(checklist[[index]]$status == "okay")  text[index] <-  paste0("<span class='cl-success'><i class='fa fa-check'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "ko")  text[index] <-  paste0("<span class='cl-fail'><i class='fa fa-times-circle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "warning")  text[index] <-  paste0("<span class='cl-warning'><i class='fa fa-exclamation-triangle'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
    if(checklist[[index]]$status == "question")  text[index] <-  paste0("<span class='cl-question'><i class='fa fa-question'></i> ", i18n$t(checklist[[index]]$msg), "</span>")
  }
  
  text <- text[!is.na(text)]
  
  paste(text, collapse = "</br>")
})