# ACORN shiny app main script
source('./www/R/startup.R', local = TRUE)

# Definition of UI ----
ui <- fluidPage(
  title = 'ACORN | A Clinically Oriented antimicrobial Resistance Network',
  theme = acorn_theme,
  includeCSS("www/styles.css"),
  withAnim(),  # to add animation to UI elements using shinyanimate
  usei18n(i18n),  # for translation
  useShinyjs(),
  
  div(id = "float_about",
      dropMenu(
        actionButton("checklist_show", icon = icon("caret-down"), label = "About", class = "btn btn-success"),
        theme = "light-border",
        class = "checklist",
        placement = "bottom-end",
        htmlOutput("about")
      )
  ),
  div(id = "float_faq",
      dropMenu(
        actionButton("show_faq", icon = icon("caret-down"), label = "FAQ", class = "btn btn-success"),
        theme = "light-border",
        class = "faq",
        placement = "bottom-end",
        fluidRow(
          column(3,
                 h3("Content:"),
                 includeMarkdown("./www/markdown/faq_content.md")
          ),
          column(9,
                 includeMarkdown("./www/markdown/faq.md")
          )
        )
      )
  ),
  
  navbarPage(id = 'tabs',
             title = a(img(src = "logo_acorn.png", style = "height: 40px; position: relative;")),
             collapsible = TRUE, inverse = FALSE, 
             position = "static-top",
             
             header = conditionalPanel(
               id = "header-filter",
               condition = "input.tabs != 'welcome' & input.tabs != 'data_management'",
               div(
                 a(id = "anchor_header", style = "visibility: hidden", ""),
                 fluidRow(
                   column(9,
                          div(id = "filter_box", class = "well",
                              fluidRow(
                                column(8,
                                       div(class = "smallcaps", class = "center", span(icon("hospital-user"), "Enrolments")),
                                       fluidRow(
                                         column(12,
                                                checkboxGroupButtons("filter_enrolments",
                                                                     choices = c("Surveillance Category", "Type of Ward", "Date of Enrolment/Survey", "Age Category", 
                                                                                 "Initial Diagnosis", "Final Diagnosis", "Clinical Severity", "Clinical/D28 Outcome"),
                                                                     status = "light", direction = "horizontal", size = "sm", individual = TRUE,
                                                                     checkIcon = list(yes = icon("filter"))),
                                                conditionalPanel("input.filter_enrolments.includes('Surveillance Category')",
                                                                 prettyCheckboxGroup("filter_surveillance_cat", NULL, shape = "curve", status = "primary",
                                                                                     choiceNames = c("Community Acquired Infection", "Hospital Acquired Infection"), 
                                                                                     choiceValues = c("CAI", "HAI"), 
                                                                                     selected = c("CAI", "HAI"), inline = TRUE)
                                                ),
                                                conditionalPanel("input.filter_enrolments.includes('Type of Ward')",
                                                                 pickerInput("filter_ward_type", NULL, choices = NULL, selected = NULL, options = list(`actions-box` = TRUE), multiple = TRUE)
                                                ),
                                                conditionalPanel("input.filter_enrolments.includes('Date of Enrolment/Survey')",
                                                                 dateRangeInput("filter_date_enrolment", NULL, startview = "year")
                                                ),
                                                conditionalPanel("input.filter_enrolments.includes('Age Category')",
                                                                 prettyCheckboxGroup("filter_age_cat", NULL, shape = "curve", status = "primary",
                                                                                     choices = c("Adult", "Child", "Neonate"), selected = c("Adult", "Child", "Neonate"), inline = TRUE)
                                                ),
                                                conditionalPanel("input.filter_enrolments.includes('Initial Diagnosis')",
                                                                 pickerInput("filter_diagnosis_initial", NULL, choices = NULL, 
                                                                             selected = NULL, options = list(`actions-box` = TRUE), multiple = TRUE)
                                                ),
                                                conditionalPanel("input.filter_enrolments.includes('Final Diagnosis')",
                                                                 pickerInput("filter_diagnosis_final", NULL, choices = NULL, 
                                                                             selected = NULL, options = list(`actions-box` = TRUE), multiple = TRUE)
                                                ),
                                                conditionalPanel("input.filter_enrolments.includes('Clinical Severity')",
                                                                 sliderInput("filter_severity_adult", "Adult qSOFA score", min = 0, max = 3, value = c(0, 3)),
                                                                 prettySwitch("filter_severity_child_0", label = "Include Child/Neonate with 0 severity criteria", status = "primary", value = TRUE, slim = TRUE),
                                                                 prettySwitch("filter_severity_child_1", label = "Include Child/Neonate with ≥ 1 severity criteria", status = "primary", value = TRUE, slim = TRUE)
                                                ),
                                                conditionalPanel("input.filter_enrolments.includes('Clinical/D28 Outcome')",
                                                                 prettySwitch("filter_outcome_clinical", label = "Only with Clinical Outcome", status = "primary", value = FALSE, slim = TRUE),
                                                                 prettySwitch("filter_outcome_d28", label = "Only with Day-28 Outcome", status = "primary", value = FALSE, slim = TRUE)
                                                )
                                         )
                                       )
                                ),
                                column(4,
                                       div(class = "smallcaps", class = "center", span(icon("vial"), " Specimens, Isolates")),
                                       prettyCheckboxGroup(inputId = "filter_method_collection", label = NULL,  shape = "curve", status = "primary", inline = TRUE,
                                                           choices = c("Blood Culture" = "blood", "Other (not BC):" = "other_not_blood"), 
                                                           selected = c("blood", "other_not_blood")),
                                       conditionalPanel("input.filter_method_collection.includes('other_not_blood')",
                                                        pickerInput("filter_method_other", NULL, multiple = TRUE,
                                                                    choices = "", selected = NULL,
                                                                    options = list(`actions-box` = TRUE, `deselect-all-text` = "None...",
                                                                                   `select-all-text` = "Select All", `none-selected-text` = "None Selected"))
                                       ),
                                       pickerInput("deduplication_method", label = NULL, 
                                                   choices = c("No deduplication of isolates", "Deduplication by patient-episode", "Deduplication by patient ID"))
                                )
                              )
                          ),
                          # TODO v2.1: reactivate this section
                          # dropMenu(
                          #   class = "filter_box_small",
                          #   actionLink("quick_filters", "Quick Filters", icon = icon("sliders-h")),
                          #   actionLink("shortcut_filter_1", label = span(icon("filter"), " Patients with Pneumonia, BC only")),
                          #   br(),
                          #   actionLink("shortcut_filter_2", label = span(icon("filter"), " Below 5 y.o. HAI")),
                          #   br(),
                          #   br(),
                          #   actionLink("shortcut_reset_filters", label = span(icon("ban"), " Reset All Filters")),
                          # )
                   ),
                   column(3,
                          htmlOutput("nb_enrolments"),
                          htmlOutput("nb_patients_microbiology"),
                          br(),
                          htmlOutput("nb_specimens"),
                          br(),
                          htmlOutput("nb_isolates_growth"),
                          htmlOutput("nb_isolates_target")
                   )
                 )
               )
             ),
             
             # Tab Welcome ----
             tabPanel(i18n$t('Welcome'), value = 'welcome',
                      fluidRow(
                        column(3,
                               uiOutput('site_logo'),
                               selectInput(
                                 'selected_language', label = span(icon('language'), i18n$t('Language')),
                                 choices = i18n$get_languages(), selected = i18n$get_key_translation(), width = "150px"
                               ),
                               div(id = "login-basic", 
                                   div(class = "well",
                                       h5(class = "text-center", "Please log in"),
                                       selectInput("cred_site", tagList(icon("hospital"), "Site"),
                                                   choices = code_sites),
                                       conditionalPanel("input.cred_site != 'demo'", div(
                                         textInput("cred_user", tagList(icon("user"), "User"),
                                                   placeholder = "Enter user"),
                                         passwordInput("cred_password", tagList(icon("unlock-alt"), "Password"), 
                                                       placeholder = "Enter password")
                                       )
                                       ), 
                                       div(class = "text-center",
                                           actionButton("cred_login", label = "Log in", class = "btn-primary"),
                                           div(em("To log out, close or reload the app."))
                                       )
                                   ),
                                   span("or ", actionLink("direct_upload_acorn", "upload a local acorn file."))
                               )
                        ),
                        column(9,
                               fluidRow(
                                 column(6,
                                        h4('Welcome!'),
                                        h5("What is ACORN?"),
                                        includeMarkdown("./www/markdown/what_is_acorn.md"),
                                        h5("Why is ACORN needed?"),
                                        includeMarkdown("./www/markdown/why_acorn_needed.md")
                                 ),
                                 column(6,
                                        h5("ACORN Participating Countries"),
                                        span(img(src = "./images/Map-ACORN-Sites-Global.png", id = "map_sites")),
                                        h5("Target Pathogens"),
                                        includeMarkdown("./www/markdown/target_pathogens.md")
                                 )
                               )
                        )
                      )
             ),
             # Tab Data Management ----
             tabPanel(span(icon("database"), "Data Management"), value = "data_management",
                      p("What do you want to do?"),
                      div(class = "center",
                          radioGroupButtons("choice_datamanagement", NULL,
                                            choices = c("Generate .acorn from clinical and lab data", "Load existing .acorn from cloud", "Load existing .acorn from local file"),
                                            selected = NULL, individual = TRUE,
                                            checkIcon = list(yes = icon("hand-point-right")))
                      ),
                      hr(),
                      ## Choice Generate ----
                      conditionalPanel("input.choice_datamanagement == 'Generate .acorn from clinical and lab data'",
                                       div(
                                         fluidRow(
                                           column(4,    
                                                  h5("(1/4) Download Clinical data"), p("and generate enrolment log."),
                                                  actionButton("get_redcap_data", "Get data from REDCap", icon = icon('cloud-download-alt'))
                                           ),
                                           column(8,
                                                  htmlOutput("checklist_qc_clinical")
                                           )
                                         ),
                                         br(), br(),
                                         fluidRow(
                                           column(4,    
                                                  uiOutput("enrolment_log_dl")
                                           ),
                                           column(8,
                                                  uiOutput("enrolment_log_table")
                                           )
                                         ),
                                         hr(),
                                         fluidRow(
                                           column(4,
                                                  h5("(2/4) Provide Lab data"),
                                                  pickerInput("format_lab_data", 
                                                              options = list(title = "Select lab data format"),
                                                              choices = c("WHONET .dBase", "WHONET .SQLite", "Tabular"), 
                                                              multiple = FALSE,
                                                              selected = NULL),
                                                  
                                                  conditionalPanel("input.format_lab_data == 'WHONET .dBase'",
                                                                   fileInput("file_lab_dba", NULL,  buttonLabel = "Browse for dBase file")
                                                  ),
                                                  conditionalPanel("input.format_lab_data == 'WHONET .SQLite'",
                                                                   fileInput("file_lab_sql", NULL,  buttonLabel = "Browse for sqlite file", accept = c(".sqlite3", ".sqlite", ".db"))
                                                  ),
                                                  conditionalPanel("input.format_lab_data == 'Tabular'",
                                                                   fileInput("file_lab_tab", NULL,  buttonLabel = "Browse for file", accept = c(".csv", ".txt", ".xls", ".xlsx"))
                                                  )
                                           ),
                                           column(8,
                                                  htmlOutput("checklist_qc_lab")
                                           )
                                         ),
                                         hr(),
                                         fluidRow(
                                           column(4, 
                                                  h5("(3/4) Combine Clinical and Lab data"),
                                                  actionButton("generate_acorn_data", span("Generate ", em(".acorn"), "file"))
                                           ),
                                           column(8,
                                                  htmlOutput("checklist_generate")
                                           )
                                         ),
                                         hr(),
                                         fluidRow(
                                           column(4, 
                                                  h5("(4/4) Save .acorn file"),
                                                  tags$div(
                                                    materialSwitch("save_switch", label = "Local", 
                                                                   inline = TRUE, status = "primary", value = TRUE),
                                                    tags$span(icon("cloud"), "Server"),
                                                    conditionalPanel("! input.save_switch",
                                                                     actionButton('save_acorn_local', HTML('Save <em>.acorn</em> file'))
                                                    ),
                                                    conditionalPanel("input.save_switch",
                                                                     actionButton('save_acorn_server', span(icon('cloud-upload-alt'), HTML('Save <em>.acorn</em> file')))
                                                    )
                                                  )
                                           ),
                                           column(8,
                                                  htmlOutput("checklist_save")
                                           )
                                         )
                                       )
                      ),
                      ## Choice Load cloud ----
                      conditionalPanel("input.choice_datamanagement == 'Load existing .acorn from cloud'",
                                       fluidRow(
                                         column(3,
                                                pickerInput('acorn_files_server', choices = NULL, label = NULL,
                                                            options = pickerOptions(actionsBox = TRUE, noneSelectedText = "No file selected", liveSearch = FALSE,
                                                                                    showTick = TRUE, header = "10 most recent files:"))
                                         ),
                                         column(9,
                                                conditionalPanel(condition = "input.acorn_files_server",
                                                                 actionButton('load_acorn_server', span(icon('cloud-download-alt'), HTML('Load selected <em>.acorn</em>')))
                                                )
                                         )
                                       )
                      ),
                      ## Choice Load local ----
                      conditionalPanel("input.choice_datamanagement == 'Load existing .acorn from local file'",
                                       fileInput("load_acorn_local", label = NULL, buttonLabel =  HTML("Load <em>.acorn</em>"), accept = '.acorn')
                      )
             ),
             # Tab Overview ----
             tabPanel("Overview", value = "overview", 
                      fluidRow(
                        column(6,
                               div(class = 'box_outputs', h4_title(icon("calendar-check"), "Date of Enrolment"),
                                   prettySwitch("show_date_week", label = "See by Week", status = "primary"),
                                   highchartOutput("profile_date_enrolment")
                               )
                        ),
                        column(6,
                               div(class = "box_outputs",
                                   h4_title("Distribution of Enrolments"),
                                   fluidRow(
                                     column(3, "Variables in Table:"),
                                     column(9,
                                            checkboxGroupButtons("variables_table", label = NULL, 
                                                                 size = "sm", status = "primary", checkIcon = list(yes = icon("check-square"), no = icon("square-o")), individual = TRUE,
                                                                 choices = c("Place of Infection" = "surveillance_category", "Type of Ward" = "ward_type", "Ward" = "ward", "Clinical Outcome" = "clinical_outcome", "Day-28 Outcome" = "d28_outcome"), 
                                                                 selected = c("surveillance_category", "ward_type", "ward", "clinical_outcome", "d28_outcome"))
                                     )
                                   ),
                                   DTOutput("table_patients", width = "95%")
                               )
                        )
                      ),
                      fluidRow(
                        column(12,
                               div(class = 'box_outputs',
                                   h4_title(icon("tint"), "Enrolments with Blood Culture"),
                                   fluidRow(
                                     column(6, gaugeOutput("profile_blood_culture_gauge", width = "100%", height = "100px")),
                                     column(6, htmlOutput("profile_blood_culture_pct", width = "100%", height = "100px"))
                                   )
                               )
                        ),
                      ),
                      
                      fluidRow(
                        column(6, 
                               div(class = 'box_outputs',
                                   h4_title("Enrolments by (type of) Ward"),
                                   prettySwitch("show_ward_breakdown", label = "See Breakdown by Ward", status = "primary"),
                                   highchartOutput("profile_type_ward")
                               )
                        ),
                        column(6, 
                               div(class = 'box_outputs', h4_title("Patient Age Distribution"),
                                   highchartOutput("profile_age")
                               )
                        )
                      ),
                      fluidRow(
                        column(6, 
                               div(class = 'box_outputs',
                                   h4_title("Diagnosis at Enrolment"),
                                   highchartOutput("profile_diagnosis")
                               )
                        ),
                        column(6, 
                               div(class = 'box_outputs',
                                   h4_title("Empiric Antibiotics Prescribed"),
                                   highchartOutput("profile_antibiotics")
                               )
                        )
                      ),
                      fluidRow(
                        column(6, 
                               div(class = 'box_outputs',
                                   h4_title(icon("arrows-alt-h"), "Patients Transferred"),
                                   highchartOutput("profile_transfer_hospital")
                               )
                        ),
                        column(6, 
                               div(class = 'box_outputs',
                                   h4_title("Patient Comorbidities"),
                                   prettySwitch("comorbidities_combinations", label = "Show comorbidities combinations", status = "primary", value = FALSE, slim = TRUE),
                                   highchartOutput("profile_comorbidities")
                               )
                        )
                      ),
                      fluidRow(
                        column(6, 
                               div(class = "box_outputs",
                                   h4_title("Enrolments with Blood Culture"),
                                   pickerInput("display_unit_ebc", label = NULL, 
                                               choices = c("Use heuristic for time unit", "Display by month", "Display by year")),
                                   highchartOutput("enrolment_blood_culture"),
                               )
                               
                        ),
                        column(6, 
                               div(class = 'box_outputs', h4_title("Blood culture collected within 24 hours of admission (CAI) / symptom onset (HAI)"),
                                   highchartOutput("profile_blood")
                               )
                        )
                      )
             ),
             # Tab Follow-up ----
             tabPanel("Follow-up", value = "follow_up",
                      fluidRow(
                        column(6,
                               div(class = 'box_outputs',
                                   h4_title("Clinical Outcome"),
                                   fluidRow(
                                     column(6, gaugeOutput("clinical_outcome_gauge", width = "100%", height = "100px")),
                                     column(6, htmlOutput("clinical_outcome_pct", width = "100%", height = "70px"))
                                   ),
                                   h5("Clinical Outcome Status:"),
                                   highchartOutput("clinical_outcome_status", height = "250px")
                               ),
                        ),
                        column(6,
                               div(class = 'box_outputs',
                                   h4_title("Day 28"),
                                   fluidRow(
                                     column(6, gaugeOutput("d28_outcome_gauge", width = "100%", height = "100px")),
                                     column(6, htmlOutput("d28_outcome_pct", width = "100%", height = "70px"))
                                   ),
                                   h5("Day 28 Status:"),
                                   highchartOutput("d28_outcome_status", height = "250px")
                               ),
                        )
                      ),
                      fluidRow(
                        column(4,
                               div(class = 'box_outputs',
                                   h4_title("Bloodstream Infection (BSI)"),
                                   htmlOutput("bsi_summary")
                               )
                        ),
                        column(8, 
                               div(class = 'box_outputs',
                                   h4_title("Initial & Final Surveillance Diagnosis"),
                                   p("The 10 most common initial-final diagnosis combinations:"),
                                   highchartOutput("profile_outcome_diagnosis", height = "500px")
                               )
                        )
                      )
             ),
             # Tab HAI ----
             tabPanel("HAI", value = "hai", 
                      div(class = 'box_outputs',
                          h4_title("Ward Occupancy Rates"),
                          plotOutput("bed_occupancy_ward", width = "80%")
                      ),
                      div(class = 'box_outputs',
                          h4_title("HAI Prevalence"),
                          plotOutput("hai_rate_ward", width = "80%")
                      )
             ),
             # Tab Microbiology ----
             tabPanel("Microbiology", value = "microbiology", 
                      prettySwitch("filter_rm_contaminant", label = "Remove BC Contaminants in following visualisations", status = "primary", value = FALSE, slim = TRUE),
                      fluidRow(
                        column(6,
                               div(class = 'box_outputs',
                                   h4_title("Blood Culture Contaminants"),
                                   fluidRow(
                                     column(6, gaugeOutput("contaminants_gauge", width = "100%", height = "100px")),
                                     column(6, htmlOutput("contaminants_pct", width = "100%", height = "100px"))
                                   )
                               ),
                               div(class = 'box_outputs',
                                   h4_title("Specimen Types"),
                                   
                                   p("Number of specimens per specimen type"),
                                   highchartOutput("culture_specimen_type", height = "400px"),
                                   
                                   p("Culture results per specimen type"),
                                   highchartOutput("culture_specgroup", height = "350px")
                               )
                        ),
                        column(6,
                               div(class = 'box_outputs',
                                   h4_title("Growth / No Growth"),
                                   fluidRow(
                                     column(6, gaugeOutput("isolates_growth_gauge", width = "100%", height = "100px")),
                                     column(6, htmlOutput("isolates_growth_pct", width = "100%", height = "100px"))
                                   )
                               ),
                               div(class = 'box_outputs',
                                   h4_title("Isolates"),
                                   p("Most frequent 10 organisms in the plot and complete listing in the table. Contaminants are in red."),
                                   highchartOutput("isolates_organism_nc"),
                                   highchartOutput("isolates_organism_contaminant"),
                                   br(), br(),
                                   DTOutput("isolates_organism_table", width = "95%"),
                                   br(), br()
                               )
                        )
                      )
             ),
             # Tab AMR ----
             tabPanel(span(icon("bug"), "AMR"), value = "amr", 
                      fluidRow(
                        column(3,
                               prettySwitch("combine_SI", label = "Combine Susceptible + Intermediate", status = "primary")
                        ),
                        column(8, offset = 1,
                               em("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")
                        )
                      ),
                      tabsetPanel(
                        tabPanel(
                          span(em("Acinetobacter"), " species"), 
                          fluidRow(
                            column(2,
                                   br(), 
                                   htmlOutput("nb_isolates_acinetobacter")
                            ),
                            column(10,
                                   conditionalPanel(condition = "output.test_acinetobacter_sir",
                                                    highchartOutput("acinetobacter_sir", height = "500px"),
                                   ),
                                   conditionalPanel(condition = "! output.test_acinetobacter_sir", span(h4("There is no data to display for this organism.")))
                            )
                          )
                        ),
                        tabPanel(
                          span(em("Enterococcus"), " species"), 
                          fluidRow(
                            column(2,
                                   br(), 
                                   htmlOutput("nb_isolates_enterococcus")
                            ),
                            column(10,
                                   conditionalPanel(condition = "output.test_enterococcus_sir",
                                                    highchartOutput("enterococcus_sir", height = "500px"),
                                   ),
                                   conditionalPanel(condition = "! output.test_enterococcus_sir", span(h4("There is no data to display for this organism.")))
                            )
                          )
                        ),
                        # TODO: remove the following lines and matching code in amr_sir.R after confirmation by Paul
                        # tabPanel(
                        #   "A. baumannii", 
                        #   fluidRow(
                        #     column(2,
                        #            br(), 
                        #            htmlOutput("nb_isolates_abaumannii")
                        #     ),
                        #     column(10,
                        #            conditionalPanel(condition = "output.test_abaumannii_sir",
                        #                             highchartOutput("abaumannii_sir", height = "500px"),
                        #                             h4_title("Resistance to Carbapenems Over Time"),
                        #                             highchartOutput("abaumannii_sir_evolution", height = "400px")
                        #            ),
                        #            conditionalPanel(condition = "! output.test_abaumannii_sir", span(h4("There is no data to display for this organism.")))
                        #     )
                        #   )
                        # ),
                        tabPanel(
                          em("E. coli"),
                          fluidRow(
                            column(2,
                                   br(), 
                                   htmlOutput("nb_isolates_ecoli")
                            ),
                            column(10,
                                   conditionalPanel(condition = "output.test_ecoli_sir",
                                                    highchartOutput("ecoli_sir", height = "600px"), br(), br(),
                                                    h4("Resistance to Carbapenems Over Time"),
                                                    highchartOutput("ecoli_sir_evolution", height = "400px"),
                                                    h4("Resistance to 3rd gen. cephalosporins Over Time"),
                                                    highchartOutput("ecoli_sir_evolution_ceph", height = "400px")
                                   ),
                                   conditionalPanel(condition = "! output.test_ecoli_sir", span(h4("There is no data to display for this organism.")))
                            )
                          )
                        ),
                        tabPanel(
                          em("Haemophilus influenzae"), 
                          fluidRow(
                            column(2,
                                   br(), 
                                   htmlOutput("nb_isolates_haemophilus_influenzae")
                            ),
                            column(10,
                                   conditionalPanel(condition = "output.test_haemophilus_influenzae_sir",
                                                    highchartOutput("haemophilus_influenzae_sir", height = "500px"),
                                   ),
                                   conditionalPanel(condition = "! output.test_haemophilus_influenzae_sir", span(h4("There is no data to display for this organism.")))
                            )
                          )
                        ),
                        tabPanel(
                          em("K. pneumoniae"),
                          fluidRow(
                            column(2,
                                   br(), 
                                   htmlOutput("nb_isolates_kpneumoniae")
                            ),
                            column(10,
                                   conditionalPanel(condition = "output.test_kpneumoniae_sir",
                                                    highchartOutput("kpneumoniae_sir", height = "600px"), br(), br(),
                                                    h4("Resistance to Carbapenems Over Time"),
                                                    highchartOutput("kpneumoniae_sir_evolution", height = "400px"),
                                                    h4("Resistance to 3rd gen. cephalosporins Over Time"),
                                                    highchartOutput("kpneumoniae_sir_evolution_ceph", height = "400px")
                                   ),
                                   conditionalPanel(condition = "! output.test_kpneumoniae_sir", span(h4("There is no data to display for this organism.")))
                            )
                          )
                        ),
                        tabPanel(
                          em("Neisseria Meningitidis"), 
                          fluidRow(
                            column(2,
                                   br(), 
                                   htmlOutput("nb_isolates_neisseria_meningitidis")
                            ),
                            column(10,
                                   conditionalPanel(condition = "output.test_neisseria_meningitidis_sir",
                                                    highchartOutput("neisseria_meningitidis_sir", height = "500px"),
                                   ),
                                   conditionalPanel(condition = "! output.test_neisseria_meningitidis_sir", span(h4("There is no data to display for this organism.")))
                            )
                          )
                        ),
                        tabPanel(
                          em("Pseudomonas aeruginosa"), 
                          fluidRow(
                            column(2,
                                   br(), 
                                   htmlOutput("nb_isolates_pseudomonas_aeruginosa")
                            ),
                            column(10,
                                   conditionalPanel(condition = "output.test_pseudomonas_aeruginosa_sir",
                                                    highchartOutput("pseudomonas_aeruginosa_sir", height = "500px"),
                                   ),
                                   conditionalPanel(condition = "! output.test_pseudomonas_aeruginosa_sir", span(h4("There is no data to display for this organism.")))
                            )
                          )
                        ),
                        tabPanel(
                          span(em("Salmonella"), "species"),
                          fluidRow(
                            column(2,
                                   br(), 
                                   htmlOutput("nb_isolates_salmonella")
                            ),
                            column(10,
                                   br(),
                                   prettyRadioButtons("select_salmonella", label = NULL,  shape = "curve",
                                                      choices = c("Salmonella Typhi", "Salmonella Paratyphi", "Salmonella sp (not S. Typhi or S. Paratyphi)"), 
                                                      selected = "Salmonella Typhi", inline = TRUE),
                                   conditionalPanel(condition = "output.test_salmonella_sir",
                                                    highchartOutput("salmonella_sir", height = "500px"),
                                                    h4("Resistance to 3rd gen. cephalosporins Over Time"),
                                                    highchartOutput("salmonella_sir_evolution_ceph", height = "400px"),
                                                    h4("Resistance to Fluoroquinolones Over Time"),
                                                    highchartOutput("salmonella_sir_evolution_fluo", height = "400px")
                                   ),
                                   conditionalPanel(condition = "! output.test_salmonella_sir", span(h4("There is no data to display for this organism.")))
                            )
                          )
                        ),
                        tabPanel(
                          em("S. aureus"),
                          fluidRow(
                            column(2,
                                   br(), 
                                   htmlOutput("nb_isolates_saureus")
                            ),
                            column(10,
                                   conditionalPanel(condition = "output.test_saureus_sir",
                                                    highchartOutput("saureus_sir", height = "500px"),
                                                    h4("Resistance to Oxacillin Over Time"),
                                                    highchartOutput("saureus_sir_evolution", height = "400px")
                                   ),
                                   conditionalPanel(condition = "! output.test_saureus_sir", span(h4("There is no data to display for this organism.")))
                            )
                          )
                        ),
                        tabPanel(
                          em("S. pneumoniae"),
                          fluidRow(
                            column(2,
                                   br(),
                                   htmlOutput("nb_isolates_spneumoniae")
                            ),
                            column(10,
                                   conditionalPanel(condition = "output.test_spneumoniae_sir",
                                                    highchartOutput("spneumoniae_sir", height = "500px"),
                                                    h4("Resistance to Penicillin Over Time"),
                                                    highchartOutput("spneumoniae_sir_evolution", height = "400px")
                                   ),
                                   conditionalPanel(condition = "! output.test_spneumoniae_sir", span(h4("There is no data to display for this organism.")))
                            )
                          )
                        ),
                        tabPanel(
                          "All Other Organisms",
                          fluidRow(
                            column(2,
                                   br(),
                                   htmlOutput("nb_isolates_other")
                            ),
                            column(10,
                                   br(),
                                   selectInput("other_organism", label = NULL, multiple = FALSE,
                                               choices = NULL, selected = NULL),
                                   conditionalPanel(condition = "output.test_other_sir",
                                                    highchartOutput("other_organism_sir", height = "400px")
                                   ),
                                   conditionalPanel(condition = "! output.test_other_sir", span(h4("There is no data to display.")))
                            )
                          )
                        )
                      )
             )
  )
)

# Definition of server ----
server <- function(input, output, session) {
  
  # Hide tabs on app launch ----
  hideTab("tabs", target = "data_management")
  hideTab("tabs", target = "overview")
  hideTab("tabs", target = "follow_up")
  hideTab("tabs", target = "hai")
  hideTab("tabs", target = "microbiology")
  hideTab("tabs", target = "amr")
  
  # Management of CSS ----
  observe({
    session$setCurrentTheme(
      if (isTRUE(input$selected_language == "la")) acorn_theme_la else acorn_theme
    )
  })
  
  # (TODO v2.1) Management of filters shortcuts ----
  observeEvent(input$shortcut_filter_1, {})
  observeEvent(input$shortcut_filter_2, {})
  observeEvent(input$shortcut_reset_filters, {})
  
  # Misc stuff ----
  # source files with code to generate outputs
  file_list <- list.files(path = "./www/R/outputs", pattern = "*.R", recursive = TRUE)
  for (file in file_list) source(paste0("./www/R/outputs/", file), local = TRUE)$value
  
  # allow debug on click
  observeEvent(input$debug, browser())
  
  # update language based on dropdown choice
  observeEvent(input$selected_language, {
    update_lang(session, input$selected_language)
  })
  
  # allow to upload acorn file and not being logged
  observeEvent(input$direct_upload_acorn, {
    showTab("tabs", target = "data_management")
    updateTabsetPanel(session = session, "tabs", selected = "data_management")
    
    updateRadioGroupButtons(session = session, "choice_datamanagement", "What do you want to do?",
                            choices = "Load existing .acorn from local file",
                            selected = NULL, status = "success",
                            checkIcon = list(yes = icon("hand-point-right")))
  })
  
  # Definition of reactive elements for data ----
  acorn_cred <- reactiveVal()
  acorn_origin <- reactiveVal()
  
  # Primary datatsets
  meta <- reactiveVal()
  redcap_f01f05_dta <- reactiveVal()
  redcap_hai_dta <- reactiveVal()
  lab_dta <- reactiveVal()
  acorn_dta <- reactiveVal()
  corresp_org_antibio <- reactiveVal()
  lab_code <- reactiveVal()
  data_dictionary <- reactiveVal()
  
  # checklist_status' status can be: hidden/question/okay/warning/ko
  checklist_status <- reactiveValues(
    log_errors = tibble(issue = character(), redcap_id = character(), acorn_id = character()),
    
    lab_data_qc_1 = list(status = "hidden", msg = ""),
    lab_data_qc_2 = list(status = "hidden", msg = ""),
    lab_data_qc_3 = list(status = "hidden", msg = ""),
    lab_data_qc_4 = list(status = "hidden", msg = ""),
    lab_data_qc_5 = list(status = "hidden", msg = ""),
    lab_data_qc_6 = list(status = "hidden", msg = ""),
    lab_data_qc_7 = list(status = "hidden", msg = ""),
    lab_data_qc_8 = list(status = "hidden", msg = ""),
    
    redcap_not_empty           = list(status = "hidden", msg = ""),
    redcap_columns             = list(status = "hidden", msg = ""),
    redcap_acornid             = list(status = "hidden", msg = ""),
    redcap_F04F01              = list(status = "hidden", msg = ""),
    redcap_F03F02              = list(status = "hidden", msg = ""),
    redcap_F02F01              = list(status = "hidden", msg = ""),
    redcap_F03F01              = list(status = "hidden", msg = ""),
    redcap_consistent_outcomes = list(status = "hidden", msg = ""),
    redcap_age_category        = list(status = "hidden", msg = ""),
    redcap_hai_dates           = list(status = "hidden", msg = ""),
    
    linkage_caseB  = list(status = "hidden", msg = ""),
    linkage_caseC  = list(status = "hidden", msg = ""),
    linkage_result = list(status = "info", msg = "No .acorn has been generated"),
    
    redcap_f01f05_dta = list(status = "info", msg = "Clinical data not provided"),
    lab_dta           = list(status = "info", msg = "Lab data not provided"),
    
    acorn_dta_saved_local = list(status = "hidden", msg = ""),
    acorn_dta_saved_server = list(status = "info", msg = "No .acorn has been saved")
  )
  
  # Secondary datasets (derived from primary datasets)
  redcap_f01f05_dta_filter <- reactive(redcap_f01f05_dta() %>% 
                                         fun_filter_enrolment(input = input))
  redcap_hai_dta_filter <- reactive(redcap_hai_dta() %>% 
                                      fun_filter_survey(input = input))
  acorn_dta_filter <- reactive(acorn_dta() %>% 
                                 fun_filter_enrolment(input = input) %>% 
                                 fun_filter_specimen(input = input) %>%
                                 fun_filter_isolate(input = input))
  
  # Enrolment log
  enrolment_log <- reactive({
    req(redcap_f01f05_dta())
    
    # calculate the expected Day-28 date: one acorn_id/redcap_id per enrolment but some acorn_id are missing so we prefer to group by redcap_id
    left_join(redcap_f01f05_dta(),
              redcap_f01f05_dta() %>% 
                group_by(redcap_id) %>%
                summarise(expected_d28_date = max(date_episode_enrolment) + 28, .groups = "drop"),
              by = "redcap_id") %>%
      transmute("Category" = surveillance_category,
                "Patient ID" = patient_id, 
                "ACORN ID" = acorn_id,
                "Date of admission" = date_admission, 
                "Infection Episode" = infection_episode_nb,
                "Date of episode enrolment" = date_episode_enrolment, 
                "Discharge date" = ho_discharge_date, 
                "Discharge status" = ho_discharge_status,
                "Expected Day-28 date" =  expected_d28_date,
                "Actual Day-28 date" = d28_date)
  })
  
  output$enrolment_log_table <- renderUI({
    req(enrolment_log())
    req(acorn_origin() == "generated")
    DTOutput("table_enrolment_log")
  })
  
  output$enrolment_log_dl <- renderUI({
    req(enrolment_log())
    req(acorn_origin() == "generated")
    tagList(
      br(), br(), br(),
      downloadButton("download_enrolment_log", "Download Enrolment Log (.xlsx)"),
      p("First sheet is the log of all enrolments retrived from REDCap (as per adjacent table). The second sheet is a listing of all flagged elements.")
    )
  })
  
  # On login ----
  observeEvent(input$cred_login, {
    id <- notify("Attempting to connect")
    on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
    
    if (input$cred_site == "demo") {
      # The demo should work offline
      cred <- readRDS("./www/cred/bucket_site/encrypted_cred_demo.rds")
      key_user <- sha256(charToRaw("demo"))
      cred <- unserialize(aes_cbc_decrypt(cred, key = key_user))
      
      if(cred$site != input$cred_site)  {
        removeNotification(id = "notif_connection")
        showNotification("The credential file is corrupted. Please contact ACORN Data Management.", type = "error")
        return()
      }
      
      acorn_cred(cred)
    }
    if (input$cred_site != "demo") {
      file_cred <- glue("encrypted_cred_{tolower(input$cred_site)}_{input$cred_user}.rds")
      # Stop if the connection can't be established
      connect <- try(get_bucket(bucket = "shared-acornamr", 
                                key    = shared_acornamr_key,
                                secret = shared_acornamr_sec,
                                region = "eu-west-3") %>% unlist(),
                     silent = TRUE)
      
      if (inherits(connect, 'try-error')) {
        showNotification("Couldn't connect to server credentials. Please check internet access/firewall.", type = "error")
        return()
      }
      
      # Test if credentials for this user name exist
      if (! file_cred %in% as.vector(connect[names(connect) == "Contents.Key"])) {
        showNotification("Couldn't find this user", type = "error")
        return()
      }
      
      # I can't find a way to pass those credentials directly in s3read_using()
      Sys.setenv("AWS_ACCESS_KEY_ID" = shared_acornamr_key,
                 "AWS_SECRET_ACCESS_KEY" = shared_acornamr_sec,
                 "AWS_DEFAULT_REGION" = "eu-west-3")
      
      cred <- try(s3read_using(FUN = read_encrypted_cred, 
                               pwd = input$cred_password,
                               object = file_cred,
                               bucket = "shared-acornamr"),
                  silent = TRUE)
      
      if (inherits(cred, 'try-error')) {
        showNotification("Wrong password.", type = "error")
        return()
      }
      
      # remove AWS environment variables
      Sys.unsetenv("AWS_ACCESS_KEY_ID")
      Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
      Sys.unsetenv("AWS_DEFAULT_REGION")
      
      acorn_cred(cred)
    }
    notify(glue("Successfully logged in as {cred$user} ({input$cred_site})"), id = id)
    
    showTab("tabs", target = "data_management")
    updateTabsetPanel(session = session, "tabs", selected = "data_management")
    
    updateRadioGroupButtons(session = session, "choice_datamanagement", "What do you want to do?",
                            choices = c("Generate .acorn from clinical and lab data", "Load existing .acorn from cloud", "Load existing .acorn from local file"),
                            selected = NULL, status = "success",
                            checkIcon = list(yes = icon("hand-point-right")))
    
    # reinitiate everything so that previousely loaded .acorn data isn't there anymore
    meta(NULL)
    redcap_f01f05_dta(NULL)
    redcap_hai_dta(NULL)
    lab_dta(NULL)
    acorn_dta(NULL)
    corresp_org_antibio(NULL)
    data_dictionary(NULL)
    lab_code(NULL)
    
    hideTab("tabs", target = "overview")
    hideTab("tabs", target = "follow_up")
    hideTab("tabs", target = "hai")
    hideTab("tabs", target = "microbiology")
    hideTab("tabs", target = "amr")
    
    # Connect to AWS S3 server ----
    if(acorn_cred()$acorn_s3) {
      
      connect_server_test <- bucket_exists(
        bucket = acorn_cred()$acorn_s3_bucket,
        key =  acorn_cred()$acorn_s3_key,
        secret = acorn_cred()$acorn_s3_secret,
        region = acorn_cred()$acorn_s3_region)[1]
      
      if(connect_server_test) {
        # Update select list with .acorn files on the server
        dta <- get_bucket(bucket = acorn_cred()$acorn_s3_bucket,
                          key =  acorn_cred()$acorn_s3_key,
                          secret = acorn_cred()$acorn_s3_secret,
                          region = acorn_cred()$acorn_s3_region) %>%
          unlist()
        acorn_dates <- as.vector(dta[names(dta) == 'Contents.LastModified'])
        ord_acorn_dates <- order(as.POSIXct(acorn_dates))
        acorn_files <- rev(tail(as.vector(dta[names(dta) == 'Contents.Key'])[ord_acorn_dates], 10))
        acorn_files <- acorn_files[endsWith(acorn_files, ".acorn")]
        
        updatePickerInput(session, 'acorn_files_server', choices = acorn_files, selected = acorn_files[1])
      }
    }
  })
  
  # On "Load .acorn" file from server ----
  observeEvent(input$load_acorn_server, {
    id <- notify("Loading data.")
    on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
    
    acorn_file <- get_object(object = input$acorn_files_server, 
                             bucket = acorn_cred()$acorn_s3_bucket,
                             key =  acorn_cred()$acorn_s3_key,
                             secret = acorn_cred()$acorn_s3_secret,
                             region = acorn_cred()$acorn_s3_region)
    load(rawConnection(acorn_file))
    acorn_origin("loaded")
    
    meta(meta)
    redcap_f01f05_dta(redcap_f01f05_dta)
    redcap_hai_dta(redcap_hai_dta)
    acorn_dta(acorn_dta)
    corresp_org_antibio(corresp_org_antibio)
    
    source('./www/R/update_input_widgets.R', local = TRUE)
    notify("Successfully loaded data.", id = id)
    startAnim(session, "float_about", type = "swing")
    focus_analysis()
  })
  
  # On "Load .acorn" file from local ----
  observeEvent(input$load_acorn_local, {
    load(input$load_acorn_local$datapath)
    acorn_origin("loaded")
    
    meta(meta)
    redcap_f01f05_dta(redcap_f01f05_dta)
    redcap_hai_dta(redcap_hai_dta)
    acorn_dta(acorn_dta)
    corresp_org_antibio(corresp_org_antibio)
    
    source('./www/R/update_input_widgets.R', local = TRUE)
    showNotification("Successfully loaded data.")
    startAnim(session, "float_about", type = "swing")
    focus_analysis()
  })
  
  # On "Get Clinical Data from REDCap server" ----
  observeEvent(input$get_redcap_data, {
    if(is.null(acorn_cred()$redcap_f01f05_api)) {
      showNotification("REDCap server credentials not provided", type = "error")
      return()
    }
    
    if(! has_internet()) {
      showNotification("Not connected to internet", type = "error")
      return()
    }
    
    showModal(modalDialog(
      title = "Retriving data from REDCap server.", footer = NULL, size = "l",
      div(
        p("It might take a couple of minutes. This window will close on completion."),
        textOutput("text_redcap_f01f05_log"),
        textOutput("text_redcap_hai_log")))
    )
    
    source("./www/R/data/01_read_redcap_f01f05.R", local = TRUE)
    source("./www/R/data/02_process_redcap_f01f05.R", local = TRUE)
    
    source("./www/R/data/01_read_redcap_hai.R", local = TRUE)
    source("./www/R/data/02_process_redcap_hai.R", local = TRUE)
    removeModal()
    
    if(any(c(checklist_status$redcap_not_empty$status,
             checklist_status$redcap_columns$status,
             checklist_status$redcap_acornid$status,
             checklist_status$redcap_F04F01$status,
             checklist_status$redcap_F03F02$status,
             checklist_status$redcap_F02F01$status,
             checklist_status$redcap_F03F01$status,
             checklist_status$redcap_consistent_outcomes$status,
             checklist_status$redcap_age_category$status) == "ko")) {
      checklist_status$redcap_f01f05_dta <- list(status = "ko", msg = "Critical errors with clinical data.")
      
      showNotification("There is a critical issue with clinical data. The issue should be fixed in REDCap.", type = "error", duration = NULL)
    } else {
      checklist_status$redcap_f01f05_dta <- list(status = "okay", 
                                                 msg = glue("Clinical data provided with {length(unique(infection$redcap_id))} patient enrolments and {nrow(infection)} infection episodes."))
    }
    redcap_f01f05_dta(infection)
    redcap_hai_dta(dl_hai_dta)
  })
  
  # On "Download Enrolment Log" ----
  output$download_enrolment_log <- downloadHandler(
    filename = glue("enrolment_log_{format(Sys.time(), '%Y-%m-%d_%H%M')}.xlsx"),
    content = function(file)  writexl::write_xlsx(
      list(
        enrolment_log(),
        checklist_status$log_errors
      ), path = file)
  )
  
  
  # On "Provide Lab data" ----
  # input$file_lab_dba | input$file_lab_sql | 
  observeEvent(c(input$file_lab_tab, input$file_lab_dba, input$file_lab_sql), 
               {
                 id <- notify("Reading lab data")
                 on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
                 source("./www/R/data/01_read_lab_data.R", local = TRUE)
                 
                 source("./www/R/data/01_read_lab_codes.R", local = TRUE)
                 corresp_org_antibio(lab_code$orgs.antibio)
                 lab_code(
                   list(whonet.spec = lab_code$whonet.spec,
                        orgs.antibio = lab_code$orgs.antibio,
                        whonet.orgs = lab_code$orgs.whonet,
                        acorn.bccontaminants = lab_code$acorn.bccontaminants,
                        acorn.ast.groups = lab_code$acorn.ast.groups,
                        ast.aci =lab_code$ast.aci,
                        ast.col =lab_code$ast.col,
                        ast.hin = lab_code$ast.hin,
                        ast.ngo = lab_code$ast.ngo,
                        ast.nmen = lab_code$ast.nmen,
                        ast.pae = lab_code$ast.pae,
                        ast.sal = lab_code$ast.sal,
                        ast.shi = lab_code$ast.shi,
                        ast.ent = lab_code$ast.ent,
                        ast.sau = lab_code$ast.sau,
                        ast.spn = lab_code$ast.spn,
                        notes = lab_code$notes)
                 )
                 
                 source("./www/R/data/01_read_data_dic.R", local = TRUE)
                 data_dictionary(
                   list(variables = data_dictionary$variables,
                        test.res = data_dictionary$test.res,
                        local.spec = data_dictionary$local.spec,
                        local.orgs = data_dictionary$local.orgs,
                        notes = data_dictionary$notes)
                 )
                 
                 notify("Processing Lab data.", id = id)
                 source("./www/R/data/03_map_variables.R", local = TRUE)
                 source("./www/R/data/04_map_specimens.R", local = TRUE)
                 source("./www/R/data/05_map_organisms.R", local = TRUE)
                 source("./www/R/data/06_make_ast_group.R", local = TRUE)
                 source("./www/R/data/07_ast_interpretation.R", local = TRUE)
                 source("./www/R/data/08_ast_interpretation_nonstandard.R", local = TRUE)
                 source("./www/R/data/09_checklist_lab.R", local = TRUE)
                 
                 lab_dta(amr)
                 notify("Lab data successfully processsed!", id = id)
               })
  
  # On "Generate ACORN" ----
  observeEvent(input$generate_acorn_data, {
    id <- notify("Generating .acorn")
    on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
    
    if(checklist_status$redcap_f01f05_dta$status != "okay")  showNotification("Aborted: clinical data not provided.", type = "warning", duration = NULL)
    if(checklist_status$lab_dta$status != "okay")     showNotification("Aborted: lab data not provided.", type = "warning", duration = NULL)
    
    if(checklist_status$lab_dta$status == "okay" & checklist_status$redcap_f01f05_dta$status == "okay") {
      source("./www/R/data/10_link_clinical_assembly.R", local = TRUE)
      
      acorn_dta(acorn_dta)
      acorn_origin("generated")
      source('./www/R/update_input_widgets.R', local = TRUE)
      
      notify(".acorn data successfully generated!", id = id)
      checklist_status$acorn_dta_saved = list(status = "warning", msg = ".acorn not saved")
    }
  })
  
  # On "Save ACORN" on server ----
  observeEvent(input$save_acorn_server, { 
    if(checklist_status$linkage_result$status != "okay") {
      showNotification("No .acorn data loaded.", type = "error", duration = 10)
      return()
    }
    
    if(! has_internet()) {
      showNotification("Not connected to internet", type = "error")
      return()
    }
    
    showModal(modalDialog(
      title = "Save acorn data", footer = modalButton("Cancel"), size = "m", easyClose = FALSE, fade = TRUE,
      div(
        textInput("name_file", value = glue("{input$cred_site}_{session_start_time}"), label = "File name:"),
        textAreaInput("meta_acorn_comment", label = "(Optional) Comments:"),
        br(), br(),
        actionButton("save_acorn_server_confirm", label = "Save on Server")
      )
    ))
  })
  
  # On "Save ACORN" as a local file ----
  observeEvent(input$save_acorn_local, { 
    if(checklist_status$linkage_result$status != "okay") {
      showNotification("No .acorn data loaded.", type = "error", duration = 10)
      return()
    }
    
    showModal(modalDialog(
      title = "Save acorn data", footer = modalButton("Cancel"), size = "m", easyClose = FALSE, fade = TRUE,
      div(
        textInput("name_file_dup", value = glue("{input$cred_site}_{session_start_time}"), label = "File name:"),
        textAreaInput("meta_acorn_comment_dup", label = "(Optional) Comments:"),
        br(), br(),
        downloadButton("save_acorn_local_confirm", label = "Save")
      )
    ))
  })
  
  # On confirmation that the file is being saved on server ----
  observeEvent(input$save_acorn_server_confirm, { 
    removeModal()
    id <- notify("Trying to save .acorn file on server")
    on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
    
    meta <- list(time_generation = session_start_time,
                 app_version = app_version,
                 site = input$cred_site,
                 user = input$cred_user,
                 comment = input$meta_acorn_comment)
    meta(meta)
    
    ## Anonymised data ----
    redcap_f01f05_dta <- redcap_f01f05_dta() %>% mutate(patient_id = md5(patient_id))
    redcap_hai_dta <- redcap_hai_dta()
    acorn_dta <- acorn_dta() %>% mutate(patient_id = md5(patient_id))
    corresp_org_antibio <- corresp_org_antibio()
    lab_code <- lab_code()
    data_dictionary <- data_dictionary()
    
    name_file <- glue("{input$name_file}.acorn")
    file <- file.path(tempdir(), name_file)
    
    save(meta, redcap_f01f05_dta, redcap_hai_dta, acorn_dta, corresp_org_antibio, lab_code, data_dictionary,
         file = file)
    
    put_object(file = file,
               object = name_file,
               bucket = acorn_cred()$acorn_s3_bucket,
               key =  acorn_cred()$acorn_s3_key,
               secret = acorn_cred()$acorn_s3_secret,
               region = acorn_cred()$acorn_s3_region)
    
    ## Non anonymised data ----
    redcap_f01f05_dta <- redcap_f01f05_dta()
    redcap_hai_dta <- redcap_hai_dta()
    lab_dta <- lab_dta()
    acorn_dta <- acorn_dta()
    corresp_org_antibio <- corresp_org_antibio()
    lab_code <- lab_code()
    data_dictionary <- data_dictionary()
    
    name_file_non_anonymised <- glue("{input$name_file}.acorn_non_anonymised")
    file_non_anonymised <- file.path(tempdir(), name_file_non_anonymised)
    
    save(meta, redcap_f01f05_dta, redcap_hai_dta, lab_dta, acorn_dta, corresp_org_antibio, lab_code, data_dictionary,
         file = file_non_anonymised)
    
    put_object(file = file_non_anonymised,
               object = name_file_non_anonymised,
               bucket = acorn_cred()$acorn_s3_bucket,
               key =  acorn_cred()$acorn_s3_key,
               secret = acorn_cred()$acorn_s3_secret,
               region = acorn_cred()$acorn_s3_region)
    
    # update list of files to load
    dta <- get_bucket(bucket = acorn_cred()$acorn_s3_bucket,
                      key =  acorn_cred()$acorn_s3_key,
                      secret = acorn_cred()$acorn_s3_secret,
                      region = acorn_cred()$acorn_s3_region)
    dta <- unlist(dta)
    acorn_dates <- as.vector(dta[names(dta) == 'Contents.LastModified'])
    ord_acorn_dates <- order(as.POSIXct(acorn_dates))
    acorn_files <- rev(tail(as.vector(dta[names(dta) == 'Contents.Key'])[ord_acorn_dates], 10))
    acorn_files <- acorn_files[endsWith(acorn_files, ".acorn")]
    
    updatePickerInput(session, 'acorn_files_server', choices = acorn_files, selected = acorn_files[1])
    
    checklist_status$acorn_dta_saved_server <- list(status = "okay", msg = ".acorn file saved on server")
    notify("Successfully saved .acorn file in the cloud. You can now explore acorn data.", id = id)
    startAnim(session, "float_about", type = "swing")
    focus_analysis()
  })
  
  
  # On confirmation that the file is being saved locally ----
  output$save_acorn_local_confirm <- downloadHandler(
    filename = glue("{input$name_file_dup}.acorn"),
    content = function(file) {
      removeModal()
      meta <- list(time_generation = session_start_time,
                   app_version = app_version,
                   site = input$cred_site,
                   user = input$cred_user,
                   comment = input$meta_acorn_comment_dup)
      meta(meta)
      
      # Anonymised
      redcap_f01f05_dta <- redcap_f01f05_dta() %>% mutate(patient_id = md5(patient_id))
      redcap_hai_dta <- redcap_hai_dta()
      acorn_dta <- acorn_dta() %>% mutate(patient_id = md5(patient_id))
      corresp_org_antibio <- corresp_org_antibio()
      lab_code <- lab_code()
      data_dictionary <- data_dictionary()
      
      save(meta, redcap_f01f05_dta, redcap_hai_dta, acorn_dta, corresp_org_antibio, lab_code, data_dictionary,
           file = file)
      checklist_status$acorn_dta_saved_local <- list(status = "okay", msg = "Successfully saved .acorn file locally")
      showNotification("Successfully saved .acorn file locally. You can now explore acorn data.", duration = 5)
      startAnim(session, "float_about", type = "swing")
      focus_analysis()
      
      if(checklist_status$acorn_dta_saved_server$status != "okay")  {
        checklist_status$acorn_dta_saved_server <- list(status = "warning", msg = "Consider saving .acorn file on the cloud for additional security.")
      }
    })
}

shinyApp(ui = ui, server = server)  # port 3872
