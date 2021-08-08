output$checklist_qc_clinical <- renderText({
  text_checklist(checklist_status, vec = c("redcap_not_empty",
                                           "redcap_columns",
                                           "redcap_acornid",
                                           "redcap_F04F01",
                                           "redcap_F03F02",
                                           "redcap_F02F01",
                                           "redcap_F03F01",
                                           "redcap_consistent_outcomes",
                                           "redcap_age_category",
                                           "redcap_hai_dates",
                                           "redcap_f01f05_dta"))
})

output$checklist_qc_lab <- renderText({
  text_checklist(checklist_status, vec = c(paste0("lab_data_qc_", 1:8),
                                           "lab_dta"))
})

output$checklist_generate <- renderText(
  text_checklist(checklist_status, vec = c("linkage_caseB", 
                                           "linkage_caseC",
                                           "linkage_result"))
)

output$checklist_save <- renderText(
  text_checklist(checklist_status, vec = c("acorn_dta_saved_local",
                                           "acorn_dta_saved_server"))
)