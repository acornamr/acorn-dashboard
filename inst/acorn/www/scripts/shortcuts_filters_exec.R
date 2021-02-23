observeEvent(input$shortcut_filter_1, {
  # Patients with Pneumonia, BC only
  updatePrettyCheckboxGroup(session, "filter_diagnosis", selected = c("Pneumonia"))
})

observeEvent(input$shortcut_filter_2, {
  
})

observeEvent(input$shortcut_reset_filters, {
  
})