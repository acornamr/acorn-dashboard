# ACORN shiny app main script
source('./www/R/startup.R', local = TRUE)

# TODO: check that all .md are displayed in the app# TODO: check that all .md are displayed in the app
# TODO: consider using https://github.com/datastorm-open/shinymanager, https://rinterface.github.io/bs4Dash/index.html

# Definition of UI ----
ui <- fluidPage(
  title = 'ACORN | A Clinically Oriented antimicrobial Resistance Network',
  theme = acorn_theme,
  includeCSS("www/styles.css"),
  withAnim(),  # to add animation to UI elements using shinyanimate
  usei18n(i18n),  # for translation
  useShinyjs(),
  
  div(id = 'float',
      dropMenu(
        actionButton("checklist_show", label = "About", class = "btn-success"),
        theme = "light-border",
        class = "checklist",
        placement = "bottom-end",
        htmlOutput("about")
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
                 div(id = "filter_more",
                     dropMenu(
                       class = "filter_box_small",
                       actionButton("filterito", "Filters", icon = icon("sliders-h"), class = "btn-success"),
                       actionLink("shortcut_filter_1", label = span(icon("filter"), " Patients with Pneumonia, BC only")),
                       br(),
                       actionLink("shortcut_filter_2", label = span(icon("filter"), " Below 5 y.o. HAI")),
                     )
                 ),
                 fluidRow(
                   column(9,
                          div(id = "filter_box", class = "well",
                              fluidRow(
                                column(8,
                                       div(class = "smallcaps", class = "centerara", span(icon("hospital-user"), "Enrolments")),
                                       p("TODO: reset filter when a filter is desactivated."),
                                       fluidRow(
                                         column(5,
                                                checkboxGroupButtons("filter_enrolments",
                                                                     choices = c("Surveillance Category", "Type of Ward", "Date of Enrolment", "Age Category", 
                                                                                 "Initial Diagnosis", "Final Diagnosis", "Severity Score", "Clinical/D28 Outcome"),
                                                                     status = "light", direction = "vertical", size = "sm", 
                                                                     checkIcon = list(yes = icon("filter"))
                                                )
                                         ),
                                         column(7,
                                                conditionalPanel("input.filter_enrolments.includes('Surveillance Category')",
                                                                 prettyCheckboxGroup("filter_surveillance_cat", NULL, shape = "curve", status = "primary",
                                                                                     choiceNames = c("Community Acquired Infection", "Hospital Acquired Infection"), 
                                                                                     choiceValues = c("CAI", "HAI"), 
                                                                                     selected = c("CAI", "HAI"), inline = TRUE)
                                                ),
                                                conditionalPanel("input.filter_enrolments.includes('Type of Ward')",
                                                                 pickerInput("filter_ward_type", NULL, choices = NULL, selected = NULL, options = list(`actions-box` = TRUE), multiple = TRUE)
                                                ),
                                                conditionalPanel("input.filter_enrolments.includes('Date of Enrolment')",
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
                                                conditionalPanel("input.filter_enrolments.includes('Severity Score')",
                                                                 sliderInput("filter_severity", NULL, min = 0, max = 7, value = c(0, 7))
                                                ),
                                                conditionalPanel("input.filter_enrolments.includes('Clinical/D28 Outcome')",
                                                                 prettySwitch("filter_outcome_clinical", label = "Only with Clinical Outcome", status = "primary", value = FALSE, slim = TRUE),
                                                                 prettySwitch("filter_outcome_d28", label = "Only with Day-28 Outcome", status = "primary", value = FALSE, slim = TRUE)
                                                                 
                                                )
                                         )
                                       )
                                ),
                                column(4,
                                       div(class = "smallcaps", class = "centerara", span(icon("vial"), " Specimens, Isolates")),
                                       
                                       prettyCheckboxGroup(inputId = "filter_method_collection", label = NULL,  shape = "curve", status = "primary", inline = TRUE,
                                                           choices = c("Blood Culture" = "blood", "Other (not BC):" = "other_not_blood"), 
                                                           selected = c("blood", "other_not_blood")),
                                       conditionalPanel("input.filter_method_collection.includes('other_not_blood')",
                                                        pickerInput("filter_method_other", NULL, multiple = TRUE,
                                                                    choices = "", selected = NULL,
                                                                    options = list(style = "btn-primary",
                                                                                   `actions-box` = TRUE, `deselect-all-text` = "None...",
                                                                                   `select-all-text` = "Select All", `none-selected-text` = "None Selected"))
                                       ),
                                       br(),
                                       pickerInput("deduplication_method", label = NULL, 
                                                   choices = c("No deduplication of isolates", "Deduplication by patient-episode", "Deduplication by patient ID"))
                                )
                              )
                          )
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
                 ),
                 fluidRow(column(12, actionLink("filter_summary", label = "No filters")))
               )
             ),
             
             # Tab Welcome ----
             tabPanel(i18n$t('Welcome'), value = 'welcome',
                      fluidRow(
                        column(3,
                               uiOutput('site_logo'),
                               br(),
                               selectInput(
                                 'selected_language', label = span(icon('language'), i18n$t('Language')),
                                 choices = i18n$get_languages(), selected = i18n$get_key_translation(), width = "150px"
                               ),
                               br(),
                               div(id = "login-basic", 
                                   div(
                                     class = "well",
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
                                         # TODO: add an option to log out
                                         # actionButton("cred_logout", label = "Log out", class = "btn-primary")
                                     )
                                   ),
                                   br(),
                                   span("or ", actionLink("direct_upload_acorn", "upload a local acorn file."))
                               )
                        ),
                        column(9,
                               h4('Welcome!'),
                               includeMarkdown("./www/markdown/lorem_ipsum.md"),
                               span(img(src = "./images/Map-ACORN-Sites-Global.png", id = "map_sites"))
                        )
                      )
             ),
             # Tab Data Management ----
             tabPanel(div(id = "menu_data_management", span(icon("database"), 'Data Management')), value = "data_management",
                      # tabsetPanel(id = "data_management_tabs", type = "tabs",
                      radioGroupButtons("choice_datamanagement", "What do you want to do?",
                                        choices = c("Generate .acorn from clinical and lab data", "Load existing .acorn from cloud", "Load existing .acorn from local file"),
                                        selected = NULL,
                                        individual = TRUE,
                                        checkIcon = list(yes = icon("ok", lib = "glyphicon"))
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
                                                                   fileInput("file_lab_dba", NULL,  buttonLabel = "Browse for dBase file", accept = c(".ahc", ".dbf"))
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
                                         column(12,
                                                div(
                                                  pickerInput('acorn_files_server', choices = NULL, label = NULL,
                                                              options = pickerOptions(actionsBox = TRUE, noneSelectedText = "No file selected", liveSearch = FALSE,
                                                                                      showTick = TRUE, header = "10 most recent files:")),
                                                  
                                                  conditionalPanel(condition = "input.acorn_files_server",
                                                                   actionButton('load_acorn_server', span(icon('cloud-download-alt'), HTML('Load <em>.acorn</em>')))
                                                  )
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
             tabPanel("Clinical Overview", value = "overview", 
                      br(), br(),
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
                                   p("TODO: check numerator/denominator - issue when filters applied"),
                                   highchartOutput("enrolment_blood_culture"),
                                   em("TODO: automatically switch to per quarter/year when more than 12 bars.")
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
                                     column(6, htmlOutput("clinical_outcome_pct", width = "100%", height = "100px"))
                                   )
                               ),
                               div(class = 'box_outputs',
                                   h4_title("Clinical Outcome Status"),
                                   highchartOutput("clinical_outcome_status", height = "250px")
                               )
                               
                        ),
                        column(6,
                               div(class = 'box_outputs',
                                   h4_title("Day 28"),
                                   fluidRow(
                                     column(6, gaugeOutput("d28_outcome_gauge", width = "100%", height = "100px")),
                                     column(6, htmlOutput("d28_outcome_pct", width = "100%", height = "100px"))
                                   )
                               ),
                               div(class = 'box_outputs',
                                   h4_title("Day 28 Status"),
                                   highchartOutput("d28_outcome_status", height = "200px")
                               )
                        )
                      ),
                      fluidRow(
                        column(12, 
                               div(class = 'box_outputs',
                                   h4_title("Initial & Final Surveillance Diagnosis"),
                                   p("The 10 most common initial*final diagnosis:"),
                                   highchartOutput("profile_outcome_diagnosis", height = "500px")
                               )
                        )
                      )
             ),
             # Tab HAI ----
             tabPanel("HAI", value = "hai", 
                      div(class = 'box_outputs',
                          h4_title("Wards Occupancy Rates"),
                          plotOutput("bed_occupancy_ward", width = "80%")
                      ),
                      plotOutput("hai_rate_ward", width = "80%")
             ),
             # Tab Microbiology ----
             tabPanel("Microbiology", value = "microbiology", 
                      fluidRow(
                        column(5,
                               div(class = 'box_outputs',
                                   h4_title("Growth / No Growth"),
                                   fluidRow(
                                     column(6, gaugeOutput("isolates_growth_gauge", width = "100%", height = "100px")),
                                     column(6, htmlOutput("isolates_growth_pct", width = "100%", height = "100px"))
                                   )
                               ),
                               div(class = 'box_outputs',
                                   h4_title("Specimen Types"),
                                   p("Number of specimens per specimen type"),
                                   highchartOutput("culture_specgroup", height = "350px"),
                                   p("Culture results per specimen type"),
                                   highchartOutput("culture_specimen_type", height = "400px")
                               )
                        ),
                        column(6, offset = 1,
                               div(class = 'box_outputs',
                                   h4_title("Isolates"),
                                   p("Most frequent 10 organisms in the plot and complete listing in the table."),
                                   highchartOutput("isolates_organism", height = "400px"),
                                   br(), br(),
                                   DTOutput("isolates_organism_table", width = "95%"),
                                   br(), br()
                               )
                        )
                      )
             ),
             # Tab AMR ----
             tabPanel(span(icon("bug"), "AMR"), value = "amr", 
                      prettySwitch("combine_SI", label = "Combine Susceptible + Intermediate", status = "primary"),
                      tabsetPanel(
                        tabPanel(
                          "A. baumannii", 
                          fluidRow(
                            column(2,
                                   br(), 
                                   htmlOutput("nb_isolates_abaumannii"), br(),
                                   em("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")
                            ),
                            column(10,
                                   conditionalPanel(condition = "output.test_abaumannii_sir",
                                                    highchartOutput("abaumannii_sir", height = "500px"),
                                                    h4_title("Resistance to Carbapenems Over Time"),
                                                    highchartOutput("abaumannii_sir_evolution", height = "300px")
                                   ),
                                   conditionalPanel(condition = "! output.test_abaumannii_sir", span(h4("There is no data to display for this organism.")))
                            )
                          )
                        ),
                        tabPanel(
                          "E. coli",
                          htmlOutput("nb_isolates_ecoli"),
                          conditionalPanel(condition = "output.test_ecoli_sir",
                                           highchartOutput("ecoli_sir", height = "600px"), br(), br(),
                                           h4("Resistance to Carbapenems Over Time"),
                                           highchartOutput("ecoli_sir_evolution", height = "300px"),
                                           h4("Resistance to 3rd gen. cephalosporins Over Time"),
                                           highchartOutput("ecoli_sir_evolution_ceph", height = "300px"),
                                           em("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")
                          ),
                          conditionalPanel(condition = "! output.test_ecoli_sir", span(h4("There is no data to display for this organism.")))
                        ),
                        tabPanel(
                          "K. pneumoniae",
                          htmlOutput("nb_isolates_kpneumoniae"),
                          conditionalPanel(condition = "output.test_kpneumoniae_sir",
                                           highchartOutput("kpneumoniae_sir", height = "600px"), br(), br(),
                                           h4("Resistance to Carbapenems Over Time"),
                                           highchartOutput("kpneumoniae_sir_evolution", height = "300px"),
                                           h4("Resistance to 3rd gen. cephalosporins Over Time"),
                                           highchartOutput("kpneumoniae_sir_evolution_ceph", height = "300px"),
                                           em("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")
                          ),
                          conditionalPanel(condition = "! output.test_kpneumoniae_sir", span(h4("There is no data to display for this organism.")))
                        ),
                        tabPanel(
                          "S. aureus",
                          htmlOutput("nb_isolates_saureus"),
                          conditionalPanel(condition = "output.test_saureus_sir",
                                           highchartOutput("saureus_sir", height = "500px"),
                                           h4("Resistance to Oxacillin Over Time"),
                                           highchartOutput("saureus_sir_evolution", height = "300px"),
                                           em("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")
                          ),
                          conditionalPanel(condition = "! output.test_saureus_sir", span(h4("There is no data to display for this organism.")))
                        ),
                        tabPanel(
                          "S. pneumoniae",
                          htmlOutput("nb_isolates_spneumoniae"),
                          conditionalPanel(condition = "output.test_spneumoniae_sir",
                                           highchartOutput("spneumoniae_sir", height = "500px"),
                                           h4("Resistance to Penicillin Over Time"),
                                           highchartOutput("spneumoniae_sir_evolution", height = "300px"),
                                           em("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")
                          ),
                          conditionalPanel(condition = "! output.test_spneumoniae_sir", span(h4("There is no data to display for this organism.")))
                        ),
                        tabPanel(
                          "Salmonella species",
                          htmlOutput("nb_isolates_salmonella"),
                          prettyRadioButtons("select_salmonella", label = NULL,  shape = "curve",
                                             choices = c("Salmonella typhi", "Salmonella paratyphi", "Salmonella sp (not S. typhi or S. paratyphi)"), 
                                             selected = "Salmonella typhi", inline = TRUE),
                          conditionalPanel(condition = "output.test_salmonella_sir",
                                           highchartOutput("salmonella_sir", height = "500px"),
                                           h4("Resistance to 3rd gen. cephalosporins Over Time"),
                                           highchartOutput("salmonella_sir_evolution_ceph", height = "300px"),
                                           h4("Resistance to Fluoroquinolones Over Time"),
                                           highchartOutput("salmonella_sir_evolution_fluo", height = "300px"),
                                           em("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")
                          ),
                          conditionalPanel(condition = "! output.test_salmonella_sir", span(h4("There is no data to display for this organism.")))
                        ),
                        tabPanel(
                          "Other Organisms",
                          htmlOutput("nb_isolates_other"),
                          selectInput("other_organism", label = NULL, multiple = FALSE,
                                      choices = NULL, selected = NULL),
                          conditionalPanel(condition = "output.test_other_sir",
                                           highchartOutput("other_organism_sir", height = "700px"),
                                           em("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")
                          ),
                          conditionalPanel(condition = "! output.test_other_sir", span(h4("There is no data to display.")))
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
  
  # Management of help links
  observeEvent(input$show_faq,
               showModal(modalDialog(
                 includeMarkdown("./www/markdown/faq.md"),
                 title = "FAQ", size = "l", easyClose = TRUE))
  )
  
  # Management of CSS ----
  observe({
    session$setCurrentTheme(
      if (isTRUE(input$selected_language == "la")) acorn_theme_la else acorn_theme
    )
  })
  
  # Management of filters ----
  # change color based on if filtered or not
  observe({
    req(input$Id094, input$filter_sex)
    toggleClass(id = "filter-1", class = "filter_on", condition = length(input$Id094) != 5)
    toggleClass(id = "filter-2", class = "filter_on", condition = length(input$filter_sex) != 2)
  })
  
  observe({
    if(is.null(input$filter_enrolments))  {
      updateActionLink(session = session, "filter_summary", label = "No Filters", icon = NULL)
    }
    
    if(!is.null(input$filter_enrolments))  {
      label <- paste("Filters:", " Enrolments : ", paste(input$filter_enrolments, collapse = ", "))
      updateActionLink(session = session, "filter_summary", label = label, icon = icon("eye"))
    }
  })
  
  observeEvent(input$filter_summary, {
    if( input$filter_summary == 0 )  shinyjs::show(id = "filter_box")
    
    if( input$filter_summary %% 2 == 0 ) {
      shinyjs::show(id = "filter_box")
    } else {
      shinyjs::hide(id = "filter_box")
    }
  })
  
  # To have it hidden on start of the app
  # observe(
  #   if( input$additional_filter_1 == 0 )  shinyjs::hide(id = "box_additional_filter_1")
  # )
  # 
  # observeEvent(input$additional_filter_1, {
  #   if( input$additional_filter_1 %% 2 == 1 ) {
  #     shinyjs::show(id = "box_additional_filter_1")
  #     updateActionButton(session = session, "additional_filter_1", icon = icon("minus"))
  #   } else {
  #     shinyjs::hide(id = "box_additional_filter_1")
  #     updateActionButton(session = session, "additional_filter_1", icon = icon("plus"))
  #   }
  # })
  
  # (TODO) Management of filters shortcuts
  observeEvent(input$shortcut_filter_1, {
    # Patients with Pneumonia, BC only
    updatePrettyCheckboxGroup(session, "filter_diagnosis", selected = c("Pneumonia"))
  })
  
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
                            selected = NULL,
                            checkIcon = list(yes = icon("ok", lib = "glyphicon")))
    
  })
  
  # Definition of reactive elements for data ----
  acorn_cred <- reactiveVal()
  
  # Primary datatsets
  meta <- reactiveVal()
  redcap_f01f05_dta <- reactiveVal()
  redcap_hai_dta <- reactiveVal()
  lab_dta <- reactiveVal()
  acorn_dta <- reactiveVal()
  corresp_org_antibio <- reactiveVal()
  
  # Secondary datasets (derived from primary datasets)
  redcap_f01f05_dta_filter <- reactive(redcap_f01f05_dta() %>% fun_filter_enrolment(input = input))
  redcap_hai_dta_filter <- reactive(redcap_hai_dta() %>% fun_filter_survey(input = input))
  acorn_dta_filter <- reactive(acorn_dta() %>% fun_filter_enrolment(input = input) %>% fun_filter_isolate(input = input))
  
  # Enrolment log
  enrolment_log <- reactive({
    req(redcap_f01f05_dta())
    
    redcap_f01f05_dta() %>%
      transmute("Category" = surveillance_category,
                "Patient ID" = patient_id, 
                "ACORN ID" = acorn_id,
                "Date of admission" = date_admission, 
                "Infection Episode" = infection_episode_nb,
                "Date of episode enrolment" = date_episode_enrolment, 
                "Discharge date" = ho_discharge_date, 
                "Discharge status" = ho_discharge_status,
                "Expected Day-28 date" =  date_episode_enrolment + 28,
                "Actual Day-28 date" = d28_date)
  })
  
  output$enrolment_log_table <- renderUI({
    # TODO: hide if .acorn has been loaded and not generated
    req(enrolment_log())
    tagList(
      p("Log of all enrolments retrived from REDCap:"),
      DTOutput("table_enrolment_log")
    )
  })
  
  output$enrolment_log_dl <- renderUI({
    # TODO: hide if .acorn has been loaded and not generated
    req(enrolment_log())
    tagList(
      br(), br(),
      downloadButton("download_enrolment_log", "Download Enrolment Log (.xlsx)")
    )
  })
  
  # Definition of checklist_status ----
  # status can be: hidden/question/okay/warning/ko
  checklist_status <- reactiveValues(
    lab_data_qc_1 = list(status = "hidden", msg = ""),
    lab_data_qc_2 = list(status = "hidden", msg = ""),
    lab_data_qc_3 = list(status = "hidden", msg = ""),
    lab_data_qc_4 = list(status = "hidden", msg = ""),
    lab_data_qc_5 = list(status = "hidden", msg = ""),
    lab_data_qc_6 = list(status = "hidden", msg = ""),
    lab_data_qc_7 = list(status = "hidden", msg = ""),
    lab_data_qc_8 = list(status = "hidden", msg = ""),
    
    redcap_not_empty       = list(status = "hidden", msg = ""),
    redcap_columns         = list(status = "hidden", msg = ""),
    redcap_acornid         = list(status = "hidden", msg = ""),
    redcap_F04F01          = list(status = "hidden", msg = ""),
    redcap_F03F02          = list(status = "hidden", msg = ""),
    redcap_F02F01          = list(status = "hidden", msg = ""),
    redcap_F03F01          = list(status = "hidden", msg = ""),
    redcap_confirmed_match = list(status = "hidden", msg = ""),
    redcap_age_category    = list(status = "hidden", msg = ""),
    redcap_hai_dates       = list(status = "hidden", msg = ""),
    
    linkage_caseB  = list(status = "hidden", msg = ""),
    linkage_caseC  = list(status = "hidden", msg = ""),
    linkage_result = list(status = "info", msg = "No .acorn has been generated"),
    
    redcap_f01f05_dta = list(status = "info", msg = "Clinical data not provided"),
    lab_dta           = list(status = "info", msg = "Lab data not provided"),
    
    acorn_dta_saved_local = list(status = "hidden", msg = ""),
    acorn_dta_saved_server = list(status = "info", msg = "No .acorn has been saved")
  )
  
  # On login ----
  observeEvent(input$cred_login, {
    id <- notify("Attempting to connect")
    on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
    # showNotification("Attempting to connect", id = "notif_connection")
    
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
      # TODO: hide Generete .acorn tab
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
        removeNotification(id = "notif_connection")
        showNotification("Couldn't connect to server credentials. Please check internet access/firewall.", type = "error")
        return()
      }
      
      # Test if credentials for this user name exist
      if (! file_cred %in% as.vector(connect[names(connect) == "Contents.Key"])) {
        removeNotification(id = "notif_connection")
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
        removeNotification(id = "notif_connection")
        showNotification("Wrong password.", type = "error")
        return()
      }
      
      # set back to default, blank values
      Sys.setenv("AWS_ACCESS_KEY_ID" = "", "AWS_SECRET_ACCESS_KEY" = "", "AWS_DEFAULT_REGION" = "")
      # TODO: use Sys.unsetenv()
      
      acorn_cred(cred)
    }
    notify(glue("Successfully logged in as {cred$user} ({input$cred_site})"), id = id)
    
    # removeNotification(id = "notif_connection")
    # showNotification("Successfully logged in!")
    showTab("tabs", target = "data_management")
    updateTabsetPanel(session = session, "tabs", selected = "data_management")
    
    updateRadioGroupButtons(session = session, "choice_datamanagement", "What do you want to do?",
                            choices = c("Generate .acorn from clinical and lab data", "Load existing .acorn from cloud", "Load existing .acorn from local file"),
                            selected = NULL,
                            checkIcon = list(yes = icon("ok", lib = "glyphicon")))
    
    # startAnim(session, "menu_data_management", type = "tada")
    
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
    
    showNotification("Trying to load data (TODO: improve message)")
    
    acorn_file <- get_object(object = input$acorn_files_server, 
                             bucket = acorn_cred()$acorn_s3_bucket,
                             key =  acorn_cred()$acorn_s3_key,
                             secret = acorn_cred()$acorn_s3_secret,
                             region = acorn_cred()$acorn_s3_region)
    load(rawConnection(acorn_file))
    
    meta(meta)
    redcap_f01f05_dta(redcap_f01f05_dta)
    redcap_hai_dta(redcap_hai_dta)
    acorn_dta(acorn_dta)
    corresp_org_antibio(corresp_org_antibio)
    
    source('./www/R/update_input_widgets.R', local = TRUE)
    showNotification(glue("Successfully loaded data. Data generated on the {meta()$time_generation}; by {meta$user}. {meta$comment}"))
    focus_analysis()
  })
  
  # On "Load .acorn" file from local ----
  observeEvent(input$load_acorn_local, {
    load(input$load_acorn_local$datapath)
    
    meta(meta)
    redcap_f01f05_dta(redcap_f01f05_dta)
    redcap_hai_dta(redcap_hai_dta)
    acorn_dta(acorn_dta)
    corresp_org_antibio(corresp_org_antibio)
    
    source('./www/R/update_input_widgets.R', local = TRUE)
    showNotification(glue("Successfully loaded data. Data generated on the {meta()$time_generation}; by {meta$user}. {meta$comment}"))
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
    
    # TODO: check that for a given enrollement, all infection episodes are on different dates
    if(any(c(checklist_status$redcap_not_empty$status,
             checklist_status$redcap_columns$status,
             checklist_status$redcap_acornid$status,
             checklist_status$redcap_F04F01$status,
             checklist_status$redcap_F03F02$status,
             checklist_status$redcap_F02F01$status,
             checklist_status$redcap_F03F01$status,
             checklist_status$redcap_confirmed_match$status,
             checklist_status$redcap_age_category$status) == "ko")) {
      checklist_status$redcap_f01f05_dta <- list(status = "ko", msg = "")
      
      showNotification("There is a critical issue with clinical data. The issue should be fixed in REDCap.", type = "error", duration = NULL)
    } else {
      checklist_status$redcap_f01f05_dta <- list(status = "okay", 
                                                 msg = glue("👏😀 Clinical data (F01-F05) provided with {length(unique(infection$redcap_id))} patient enrolments and {nrow(infection)} infection episodes"))
      # showNotification("Clinical data successfully provided.", type = "message", duration = 5)
      # TODO: modify this to ensure that HAI data is okay before announcing that clinical data is provided
    }
    redcap_f01f05_dta(infection)
    redcap_hai_dta(dl_hai_dta)
  })
  
  # On "Download Enrolment Log" ----
  output$download_enrolment_log <- downloadHandler(
    filename = glue("enrolment_log_{format(Sys.time(), '%Y-%m-%d_%H%M')}.xlsx"),
    content = function(file)  writexl::write_xlsx(enrolment_log(), path = file)
  )
  
  
  # On "Provide Lab data" ----
  # input$file_lab_dba | input$file_lab_sql | 
  observeEvent(c(input$file_lab_tab, input$file_lab_dba, input$file_lab_sql), 
               {
                 id <- notify("Reading lab data")
                 on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
                 source("./www/R/data/01_read_lab_data.R", local = TRUE)
                 
                 notify("Reading lab codes and AST breakpoint data", id = id)
                 source("./www/R/data/01_read_lab_codes.R", local = TRUE)
                 corresp_org_antibio(lab_code$orgs.antibio)
                 source("./www/R/data/01_read_data_dic.R", local = TRUE)
                 
                 notify("Processing Lab data: mapping", id = id)
                 source("./www/R/data/03_map_variables.R", local = TRUE)
                 source("./www/R/data/04_map_specimens.R", local = TRUE)
                 source("./www/R/data/05_map_organisms.R", local = TRUE)
                 
                 notify("Processing Lab data: AST interpretation.", id = id)
                 source("./www/R/data/06_make_ast_group.R", local = TRUE)
                 source("./www/R/data/07_ast_interpretation.R", local = TRUE)
                 source("./www/R/data/08_ast_interpretation_nonstandard.R", local = TRUE)
                 
                 notify("Processing Lab data: quality checks.", id = id)
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
    
    ## Anonymised data ----
    redcap_f01f05_dta <- redcap_f01f05_dta() %>% mutate(patient_id = md5(patient_id))
    redcap_hai_dta <- redcap_hai_dta()
    acorn_dta <- acorn_dta() %>% mutate(patient_id = md5(patient_id))
    corresp_org_antibio <- corresp_org_antibio()
    
    name_file <- glue("{input$name_file}.acorn")
    file <- file.path(tempdir(), name_file)
    
    save(meta, redcap_f01f05_dta, redcap_hai_dta, acorn_dta, corresp_org_antibio,
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
    
    name_file_non_anonymised <- glue("{input$name_file}.acorn_non_anonymised")
    file_non_anonymised <- file.path(tempdir(), name_file_non_anonymised)
    
    save(meta, redcap_f01f05_dta, redcap_hai_dta, lab_dta, acorn_dta, corresp_org_antibio,
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
    
    checklist_status$acorn_dta_saved_server <- list(status = "okay", msg = "👏😀 .acorn file saved on server")
    notify("👏😀 Successfully saved .acorn file in the cloud. You can now explore acorn data.", id = id)
    
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
      
      # Anonymised
      redcap_f01f05_dta <- redcap_f01f05_dta() %>% mutate(patient_id = md5(patient_id))
      redcap_hai_dta <- redcap_hai_dta()
      acorn_dta <- acorn_dta() %>% mutate(patient_id = md5(patient_id))
      corresp_org_antibio <- corresp_org_antibio()
      
      save(meta, redcap_f01f05_dta, redcap_hai_dta, acorn_dta, corresp_org_antibio, 
           file = file)
      checklist_status$acorn_dta_saved_local <- list(status = "okay", msg = "Successfully saved .acorn file locally")
      showNotification("👏😀 Successfully saved .acorn file locally. You can now explore acorn data.", duration = 5)
      
      if(checklist_status$acorn_dta_saved_server$status != "okay")  {
        checklist_status$acorn_dta_saved_server <- list(status = "warning", msg = "Consider saving .acorn file on the cloud for additional security.")
      }
      
      focus_analysis()
    })
}

shinyApp(ui = ui, server = server)  # port 3872
