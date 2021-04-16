output$checklist_status_load_server <- renderText(  
  text_checklist(checklist_status, vec = c("internet_connection", "app_login", "acorn_server_test"))
) 

output$checklist_qc_clinical <- renderText({
  text_checklist(checklist_status, vec = paste0("redcap_qc_", 1:6))
})

output$checklist_status_clinical <- renderText(
  text_checklist(checklist_status, vec = c("internet_connection", "app_login", "redcap_server_cred"))
)

output$checklist_status_lab <- renderText(
  text_checklist(checklist_status, vec = c("lab_dta"))
)

output$checklist_generate <- renderText(
  text_checklist(checklist_status, vec = c("lab_dta", "redcap_dta"))
)

output$checklist_save_local <- renderText(
  text_checklist(checklist_status, vec = c("acorn_dta_saved"))
)

output$checklist_save_server <- renderText(
  text_checklist(checklist_status, vec = c("internet_connection", "app_login", "acorn_server_test",
                                           "acorn_server_write", "acorn_dta_saved"))
)