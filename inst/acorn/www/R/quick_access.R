output$quick_access <- renderUI({
  dropdownButton(
    inputId = "quick_access_btn",
    circle = FALSE,
    icon = icon("rocket"),
    status = "danger",
    width = "40%",
    div(
      fluidRow(
        column(6,
               strong(i18n$t("Overview")),
               tags$ul(
                 tags$li(actionLink("anchor_link_101", i18n$t("Date of Enrolment"))), 
                 tags$li(actionLink("anchor_link_102", i18n$t("Distribution of Enrolments"))),
                 tags$li(actionLink("anchor_link_103", i18n$t("Enrolments with Blood Culture"))),
                 tags$li(actionLink("anchor_link_104", i18n$t("Enrolments by (type of) Ward"))),
                 tags$li(actionLink("anchor_link_105", i18n$t("Patient Age Distribution"))),
                 tags$li(actionLink("anchor_link_106", i18n$t("Diagnosis at Enrolment"))),
                 tags$li(actionLink("anchor_link_107", i18n$t("Empiric Antibiotics Prescribed"))),
                 tags$li(actionLink("anchor_link_108", i18n$t("Updated Charlson Comorbidity Index (uCCI)"))),
                 tags$li(actionLink("anchor_link_109", i18n$t("Patient Comorbidities"))),
                 tags$li(actionLink("anchor_link_110", i18n$t("Patients Transferred"))),
                 tags$li(actionLink("anchor_link_111", i18n$t("Enrolments with Blood Culture"))),
                 tags$li(actionLink("anchor_link_112", i18n$t("Blood culture collected within 24 hours of admission (CAI) / symptom onset (HAI)")))
               ),
               strong(i18n$t("Follow-up")),
               tags$ul(
                 tags$li(actionLink("anchor_link_201", i18n$t("Clinical Outcome"))),
                 tags$li(actionLink("anchor_link_202", i18n$t("Day 28"))),
                 tags$li(actionLink("anchor_link_203", i18n$t("Bloodstream Infection (BSI)"))),
                 tags$li(actionLink("anchor_link_204", i18n$t("Initial & Final Surveillance Diagnosis")))
               ),
               strong("HAI"),
               tags$ul(
                 tags$li(actionLink("anchor_link_301", i18n$t("Ward Occupancy Rates"))),
                 tags$li(actionLink("anchor_link_302", i18n$t("HAI Prevalence")))
               )
        ),
        column(6,
               strong(i18n$t("Microbiology")),
               tags$ul(
                 tags$li(actionLink("anchor_link_401", i18n$t("Blood Culture Contaminants"))),
                 tags$li(actionLink("anchor_link_402", i18n$t("Growth / No Growth"))),
                 tags$li(actionLink("anchor_link_403", i18n$t("Specimen Types"))),
                 tags$li(actionLink("anchor_link_404", i18n$t("Isolates")))
               ),
               strong(i18n$t("AMR")),
               tags$ul(
                 tags$li(actionLink("anchor_amr_aci", HTML("<em>Acinetobacter</em> species"))),
                 tags$li(actionLink("anchor_amr_esc", HTML("<em>Escherichia coli</em>"))),
                 tags$li(actionLink("anchor_amr_hae", HTML("<em>Haemophilus influenzae</em>"))),
                 tags$li(actionLink("anchor_amr_kle", HTML("<em>Klebsiella pneumoniae</em>"))),
                 tags$li(actionLink("anchor_amr_nei", HTML("<em>Neisseria meningitidis</em>"))),
                 tags$li(actionLink("anchor_amr_pse", HTML("<em>Pseudomonas aeruginosa</em>"))),
                 tags$li(actionLink("anchor_amr_sal", HTML("<em>Salmonella</em> species"))),
                 tags$li(actionLink("anchor_amr_sta", HTML("<em>Staphylococcus aureus</em>"))),
                 tags$li(actionLink("anchor_amr_str", HTML("<em>Streptococcus pneumoniae</em>"))),
                 tags$li(actionLink("anchor_amr_all", i18n$t("All Other Organisms")))
               )
        )
      )
    )
  )
})

# Overview Tab.
observeEvent(input$anchor_link_101, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_101').scrollIntoView();"))
})

observeEvent(input$anchor_link_102, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_102').scrollIntoView();"))
})

observeEvent(input$anchor_link_103, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_103').scrollIntoView();"))
})

observeEvent(input$anchor_link_104, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_104').scrollIntoView();"))
})

observeEvent(input$anchor_link_105, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_105').scrollIntoView();"))
})

observeEvent(input$anchor_link_106, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_106').scrollIntoView();"))
})

observeEvent(input$anchor_link_107, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_107').scrollIntoView();"))
})

observeEvent(input$anchor_link_108, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_108').scrollIntoView();"))
})

observeEvent(input$anchor_link_109, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_109').scrollIntoView();"))
})

observeEvent(input$anchor_link_110, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_110').scrollIntoView();"))
})

observeEvent(input$anchor_link_111, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_111').scrollIntoView();"))
})

observeEvent(input$anchor_link_112, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "overview")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_112').scrollIntoView();"))
})


# Follow-up Tab.
observeEvent(input$anchor_link_201, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "follow_up")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_201').scrollIntoView();"))
})

observeEvent(input$anchor_link_202, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "follow_up")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_202').scrollIntoView();"))
})

observeEvent(input$anchor_link_203, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "follow_up")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_203').scrollIntoView();"))
})

observeEvent(input$anchor_link_204, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "follow_up")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_204').scrollIntoView();"))
})

# HAI Tab.
observeEvent(input$anchor_link_301, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "hai")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_301').scrollIntoView();"))
})

observeEvent(input$anchor_link_302, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "hai")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_302').scrollIntoView();"))
})

# Microbiology Tab.
observeEvent(input$anchor_link_401, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "microbiology")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_401').scrollIntoView();"))
})

observeEvent(input$anchor_link_402, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "microbiology")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_402').scrollIntoView();"))
})

observeEvent(input$anchor_link_403, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "microbiology")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_403').scrollIntoView();"))
})

observeEvent(input$anchor_link_404, {
  toggleDropdownButton(inputId = "quick_access_btn")
  updateTabsetPanel(session, "tabs", "microbiology")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_404').scrollIntoView();"))
})

# AMR tab ----
observeEvent(input$anchor_amr_aci, {
  toggleDropdownButton(inputId = "quick_access_btn")
  shinyjs::runjs("$('a[data-value=\"amr\"]').tab('show');")
  shinyjs::runjs("$('a[data-value=\"amr_aci\"]').tab('show');")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_amr').scrollIntoView();"))
})

observeEvent(input$anchor_amr_esc, {
  toggleDropdownButton(inputId = "quick_access_btn")
  shinyjs::runjs("$('a[data-value=\"amr\"]').tab('show');")
  shinyjs::runjs("$('a[data-value=\"amr_esc\"]').tab('show');")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_amr').scrollIntoView();"))
})

observeEvent(input$anchor_amr_hae, {
  toggleDropdownButton(inputId = "quick_access_btn")
  shinyjs::runjs("$('a[data-value=\"amr\"]').tab('show');")
  shinyjs::runjs("$('a[data-value=\"amr_hae\"]').tab('show');")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_amr').scrollIntoView();"))
})

observeEvent(input$anchor_amr_kle, {
  toggleDropdownButton(inputId = "quick_access_btn")
  shinyjs::runjs("$('a[data-value=\"amr\"]').tab('show');")
  shinyjs::runjs("$('a[data-value=\"amr_kle\"]').tab('show');")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_amr').scrollIntoView();"))
})

observeEvent(input$anchor_amr_nei, {
  toggleDropdownButton(inputId = "quick_access_btn")
  shinyjs::runjs("$('a[data-value=\"amr\"]').tab('show');")
  shinyjs::runjs("$('a[data-value=\"amr_nei\"]').tab('show');")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_amr').scrollIntoView();"))
})

observeEvent(input$anchor_amr_pse, {
  toggleDropdownButton(inputId = "quick_access_btn")
  shinyjs::runjs("$('a[data-value=\"amr\"]').tab('show');")
  shinyjs::runjs("$('a[data-value=\"amr_pse\"]').tab('show');")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_amr').scrollIntoView();"))
})

observeEvent(input$anchor_amr_sal, {
  toggleDropdownButton(inputId = "quick_access_btn")
  shinyjs::runjs("$('a[data-value=\"amr\"]').tab('show');")
  shinyjs::runjs("$('a[data-value=\"amr_sal\"]').tab('show');")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_amr').scrollIntoView();"))
})

observeEvent(input$anchor_amr_sta, {
  toggleDropdownButton(inputId = "quick_access_btn")
  shinyjs::runjs("$('a[data-value=\"amr\"]').tab('show');")
  shinyjs::runjs("$('a[data-value=\"amr_sta\"]').tab('show');")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_amr').scrollIntoView();"))
})

observeEvent(input$anchor_amr_str, {
  toggleDropdownButton(inputId = "quick_access_btn")
  shinyjs::runjs("$('a[data-value=\"amr\"]').tab('show');")
  shinyjs::runjs("$('a[data-value=\"amr_str\"]').tab('show');")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_amr').scrollIntoView();"))
})

observeEvent(input$anchor_amr_all, {
  toggleDropdownButton(inputId = "quick_access_btn")
  shinyjs::runjs("$('a[data-value=\"amr\"]').tab('show');")
  shinyjs::runjs("$('a[data-value=\"amr_all\"]').tab('show');")
  shinyjs::delay(500, shinyjs::runjs("document.getElementById('anchor_amr').scrollIntoView();"))
})