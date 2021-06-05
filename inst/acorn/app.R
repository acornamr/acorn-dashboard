# ACORN shiny app main script
source('./www/R/startup.R', local = TRUE)

# TODO: check that all .md are displayed in the app

# Definition of UI ----
ui <- fluidPage(
  title = 'ACORN | A Clinically Oriented antimicrobial Resistance Network',
  theme = acorn_theme,
  includeCSS("www/styles.css"),
  withAnim(),  # for shinyanimate
  usei18n(i18n),  # for translation
  useShinyjs(),
  
  
  div(id = 'float',
      dropMenu(
        actionButton("checklist_show", icon = icon("plus"), label = NULL, class = "btn-success"),
        theme = "light-border",
        class = "checklist",
        placement = "bottom-end",
        htmlOutput("report_generation")
      )
  ),
  
  navbarPage(id = 'tabs',
             title = a(img(src = "logo_acorn.png", style = "height: 40px; position: relative;")),
             collapsible = TRUE, inverse = FALSE, 
             position = "static-top",
             ## Header ----
             header = conditionalPanel(
               id = "header-filter",
               condition = "input.tabs != 'welcome' & input.tabs != 'data_management' & input.tabs != 'about'",
               div(
                 fluidRow(
                   column(12,
                          div(id = "filter_box", class = "well",
                              div(id = "filter_more", 
                                  dropMenu(
                                    class = "filter_box_small",
                                    actionButton("filterito", "Filters", icon = icon("sliders-h"), class = "btn-success"),
                                    actionLink(inputId = "shortcut_filter_1", label = span(icon("filter"), " Patients with Pneumonia, BC only")),
                                    br(),
                                    actionLink(inputId = "shortcut_filter_2", label = span(icon("filter"), " Below 5 y.o. HAI")),
                                    br(), br(),
                                    actionLink(inputId = "shortcut_reset_filters", label = span(icon("times"), " Reset All Filters"))
                                  )
                              ),
                              fluidRow(
                                column(6,
                                       div(class = "smallcaps", class = "centerara", span(icon("hospital-user"), " Patient Enrollments")),
                                       fluidRow(
                                         column(6,
                                                prettyRadioButtons(
                                                  inputId = "filter_origin_infection",
                                                  label = "Origin of Infection:", 
                                                  choices = c("All Origins", "CAI", "HAI"),
                                                  inline = TRUE, 
                                                  status = "primary",
                                                  fill = FALSE
                                                )
                                         ),
                                         column(5,
                                                prettyCheckboxGroup(inputId = "filter_type_ward", label = "Type of Ward:", shape = "curve", status = "primary", inline = TRUE, 
                                                                    choices = c("Paediatric ward", "PICU"), selected = c("Paediatric ward", "PICU"))
                                         ),
                                         column(1,
                                                br(),
                                                div(id = "additional_filter_btn", class = "right",
                                                    actionButton("additional_filter_1", icon = icon("plus"), label = "", class = "btn-success")
                                                )
                                         )
                                       ),
                                       div(id = "box_additional_filter_1",
                                           fluidRow(
                                             column(6,
                                                    dateRangeInput("filter_date_enrollment", label = "Date of Enrollment:", startview = "year"),
                                                    span("Patient Ages:"),
                                                    fluidRow(
                                                      column(4, numericInput("filter_age_min", label = "", min = 0, value = 0)),
                                                      column(4, numericInput("filter_age_max", label = "", min = 0, value = 99),),
                                                      column(4, selectInput("filter_age_unit", label = "", choices = c("days", "months", "years"), selected = "years"))
                                                    ),
                                                    prettySwitch(inputId = "filter_age_na", label = "Include Unknown Ages", status = "primary", value = TRUE, slim = TRUE)
                                             ),
                                             column(6,
                                                    prettyCheckboxGroup(inputId = "filter_diagnosis", label = "Patient Diagnosis:", shape = "curve", status = "primary",
                                                                        choices = c("Meningitis", "Pneumonia", "Sepsis"), selected = c("Meningitis", "Pneumonia", "Sepsis"),
                                                                        inline = TRUE),
                                                    prettyRadioButtons(inputId = "confirmed_diagnosis", label = "Diagnosis confirmation (if clinical outcome):",
                                                                       choices = c("Diagnosis confirmed", "Diagnosis rejected", "No filter on diagnosis confirmation"),
                                                                       selected = "No filter on diagnosis confirmation"),
                                                    prettySwitch(inputId = "filter_outcome_clinical", label = "Only with Clinical Outcome", status = "primary", value = FALSE, slim = TRUE),
                                                    prettySwitch(inputId = "filter_outcome_d28", label = "Only with Day-28 Outcome", status = "primary", value = FALSE, slim = TRUE)
                                             )
                                           )
                                       )
                                ),
                                column(3, class = "vl",
                                       div(class = "smallcaps", class = "centerara", span(icon("vial"), " Specimens")),
                                       pickerInput(inputId = "filter_method_other", label = "Method of Collection:", multiple = TRUE,
                                                   choices = c("Blood Culture", "CSF", "Genito-urinary swab"), 
                                                   selected = c("Blood Culture", "CSF", "Genito-urinary swab"),
                                                   options = list(`actions-box` = TRUE, 
                                                                  `deselect-all-text` = "None...",
                                                                  `select-all-text` = "All Methods", 
                                                                  `none-selected-text` = "None Selected",
                                                                  `multiple-separator` = " + "),
                                                   choicesOpt = list(content = c("<span class = 'filter_blood'>Blood Culture</span>", "CSF", "Genito-urinary swab")),
                                       )
                                ),
                                column(3, class = "vl",
                                       div(class = "smallcaps", class = "centerara", span(icon("microscope"), " Isolates")),
                                       pickerInput(inputId = "deduplication_method", label = "Deduplication:", 
                                                   choices = c("No deduplication of isolates", "Deduplication by patient-episode", "Deduplication by patient ID"))
                                )
                              )
                          )
                   )
                 ),
                 fluidRow(
                   column(3, htmlOutput("nb_enrollments")),
                   column(3, htmlOutput("nb_patients_microbiology")),
                   column(3, htmlOutput("nb_specimens")),
                   column(3, htmlOutput("nb_isolates"))
                 )
               )
             ),
             
             # Tab Welcome ----
             tabPanel(i18n$t('Welcome'), value = 'welcome',
                      fluidRow(
                        column(3,
                               uiOutput('site_logo'),
                               br(),
                               div(id = "login-basic", 
                                   div(
                                     class = "well",
                                     h4(class = "text-center", "Please log in"),
                                     selectInput("cred_site", tagList(icon("hospital"), "Site"),
                                                 choices = c("demo", "KH001", "GH001", "GH002", "ID001", "ID002", 
                                                             "KE001", "KE002", "LA001", "LA002", "MW001", 
                                                             "NP001", "NG001", "NG002", "VN001", "VN002", 
                                                             "VN003")
                                     ),
                                     conditionalPanel("input.cred_site != 'demo'", div(
                                       textInput("cred_user", tagList(icon("user"), "User"),
                                                 placeholder = "Enter user"
                                       ),
                                       passwordInput("cred_password", tagList(icon("unlock-alt"), "Password"), 
                                                     placeholder = "Enter password"
                                       )
                                     )
                                     ), 
                                     div(class = "text-center",
                                         actionButton(inputId = "cred_login", label = "Log in", class = "btn-primary"),
                                         # TODO: add an option to log out
                                         # actionButton(inputId = "cred_logout", label = "Log out", class = "btn-primary")
                                     )
                                   )
                               )
                        ),
                        column(9,
                               div(id = 'language-box', class = "well",
                                   selectInput(
                                     inputId = 'selected_language', label = span(icon('language'), i18n$t('Language')),
                                     choices = i18n$get_languages(), selected = i18n$get_key_translation(), width = "150px"
                                   )
                               ),
                               h4('Welcome!'),
                               includeMarkdown("./www/markdown/lorem_ipsum.md"),
                               span(img(src = "./images/Map-ACORN-Sites-Global.png", id = "map_sites"))
                        )
                      )
             ),
             # Tab Data Management ----
             tabPanel(span(icon("database"), 'Data Management'), value = "data_management",
                      tabsetPanel(id = "data_management_tabs", type = "tabs",
                                  ## Tab Load ----
                                  tab(value = "load", span("Load existing ", em(".acorn")),
                                      fluidRow(
                                        column(3,
                                               tags$div(
                                                 materialSwitch(inputId = "load_switch", label = "Local", 
                                                                inline = TRUE, status = "primary", value = TRUE),
                                                 tags$span(icon("cloud"), "Server")
                                               )
                                        ),
                                        column(9,
                                               conditionalPanel("! input.load_switch",
                                                                div(
                                                                  p("You can upload a file from your PC"),
                                                                  fileInput("load_acorn_local", label = NULL, buttonLabel =  HTML("Load <em>.acorn</em>"), accept = '.acorn'),
                                                                )
                                               ),
                                               conditionalPanel("input.load_switch",
                                                                div(
                                                                  htmlOutput("checklist_status_load_server"),
                                                                  br(),
                                                                  
                                                                  pickerInput('acorn_files_server', choices = NULL, label = NULL,
                                                                              options = pickerOptions(actionsBox = TRUE, noneSelectedText = "No file selected", liveSearch = FALSE,
                                                                                                      showTick = TRUE, header = "10 most recent files:")),
                                                                  
                                                                  conditionalPanel(condition = "input.acorn_files_server",
                                                                                   actionButton('load_acorn_server', span(icon('cloud-download-alt'), HTML('Load <em>.acorn</em>')))
                                                                  )
                                                                )
                                               )
                                        )
                                      )
                                  ),
                                  ## Tab Generate ----
                                  tab(value = "generate", span("Generate ", em(".acorn")),
                                      fluidRow(
                                        column(3,    
                                               h5("(1/3) Get Clinical data"), p("and generate enrolment log.")
                                        ),
                                        column(9,
                                               fluidRow(
                                                 column(3,
                                                        htmlOutput("checklist_status_clinical"),
                                                        actionButton("get_redcap_data", "Get Clinical Data from REDCap", icon = icon('times-circle')),
                                                 ),
                                                 column(9,
                                                        textOutput("text_redcap_f01f05_log"),
                                                        textOutput("text_redcap_hai_log")
                                                 )
                                               ),
                                               br(),
                                               htmlOutput("message_redcap_dta"),
                                               htmlOutput("checklist_qc_clinical"),
                                               uiOutput("enrolment_log")
                                        )
                                      ),
                                      hr(),
                                      fluidRow(
                                        column(3,
                                               h5("(2/3) Provide Lab data")
                                        ),
                                        column(9,
                                               fluidRow(
                                                 column(3,
                                                        pickerInput("format_lab_data", "Select lab data format", 
                                                                    choices = c("_", "WHONET .dBase", "WHONET .SQLite", "Tabular"), 
                                                                    multiple = FALSE),
                                                        
                                                        conditionalPanel("input.format_lab_data == 'WHONET .dBase'",
                                                                         fileInput("file_lab_dba", NULL,  buttonLabel = "Browse for dBase file", accept = c(".ahc", ".dbf"))
                                                        ),
                                                        conditionalPanel("input.format_lab_data == 'WHONET .SQLite'",
                                                                         fileInput("file_lab_sql", NULL,  buttonLabel = "Browse for sqlite file", accept = c(".sqlite3", ".sqlite", ".db"))
                                                        ),
                                                        conditionalPanel("input.format_lab_data == 'Tabular'",
                                                                         fileInput("file_lab_tab", NULL,  buttonLabel = "Browse for tabular file", accept = c(".csv", ".txt", ".xls", ".xlsx"))
                                                        )
                                                 ),
                                                 column(9,
                                                        htmlOutput("message_lab_dta"),
                                                        htmlOutput("checklist_qc_lab")
                                                 )
                                               )
                                        )
                                      ),
                                      hr(),
                                      fluidRow(
                                        column(3, 
                                               h5("(3/3) Combine Clinical and Lab data")
                                        ),
                                        column(9,
                                               # htmlOutput("checklist_generate"),
                                               actionButton("generate_acorn_data", span("Generate ", em(".acorn")))
                                        )
                                      )
                                  ),
                                  ## Tab Save ----
                                  tab(value = "save", span("Save ", em(".acorn"), " file"),
                                      fluidRow(
                                        column(3,
                                               tags$div(
                                                 materialSwitch(inputId = "save_switch", label = "Local", 
                                                                inline = TRUE, status = "primary", value = TRUE),
                                                 tags$span(icon("cloud"), "Server")
                                               )
                                        ),
                                        column(9,
                                               conditionalPanel("! input.save_switch",
                                                                div(
                                                                  htmlOutput("checklist_save_local"),
                                                                  actionButton('save_acorn_local', HTML('Save <em>.acorn</em>'))
                                                                )
                                               ),
                                               conditionalPanel("input.save_switch",
                                                                div(
                                                                  htmlOutput("checklist_save_server"),
                                                                  actionButton('save_acorn_server', span(icon('cloud-upload-alt'), HTML('Save <em>.acorn</em>')))
                                                                )
                                               )
                                        )
                                      )
                                  )
                      )
             ),
             # Tab Overview ----
             tabPanel("Overview", value = "overview", 
                      br(), br(),
                      fluidRow(
                        column(5,
                               div(class = "box_outputs",
                                   h4_title("Proportions of Enrollments with Blood Culture"),
                                   highchartOutput("evolution_blood_culture")
                               )),
                        column(6, offset = 1,
                               div(class = "box_outputs",
                                   h4_title("Number of Patients"),
                                   pickerInput("variables_table", label = "Table Columns:", 
                                               multiple = TRUE, width = "600px",
                                               choices = c("Place of Infection" = "surveillance_cat", "Type of Ward" = "ward", "Ward" = "ward_text", "Clinical Outcome" = "clinical_outcome", "Day-28 Outcome" = "d28_outcome"), 
                                               selected = c("surveillance_cat", "ward", "ward_text")),
                                   
                                   DTOutput("table_patients", width = "95%")
                               )
                        )
                      ),
                      div(class = 'box_outputs',
                          h4_title(icon('stethoscope'), "Patients Diagnosis"),
                          fluidRow(
                            column(6, highchartOutput("profile_diagnosis")),
                            column(3, highchartOutput("profile_diagnosis_meningitis")),
                            column(3, highchartOutput("profile_diagnosis_pneumonia"))
                          )
                      ),
                      fluidRow(
                        column(6,
                               div(class = 'box_outputs',
                                   h4_title("Enrolled Cases by Ward / Type of Ward"),
                                   prettySwitch(inputId = "show_ward_breakdown", label = "See Breakdown by Ward", status = "primary"),
                                   highchartOutput("profile_type_ward")
                               )
                        ),
                        column(6,
                               div(class = 'box_outputs',
                                   h4_title(icon("tint"), "Patients with Blood Culture"),
                                   fluidRow(
                                     column(6, gaugeOutput("profile_blood_culture_gauge", width = "100%", height = "100px")),
                                     column(6, htmlOutput("profile_blood_culture_pct", width = "100%", height = "100px"))
                                   )
                               )
                        )
                      ),
                      fluidRow(
                        column(6,
                               div(class = 'box_outputs', h4_title("Patients Age Distribution"),
                                   highchartOutput("profile_age")
                               ),
                               div(class = 'box_outputs', h4_title("Patients Sex"),
                                   highchartOutput("profile_sex")
                               ),
                               div(class = 'box_outputs', h4_title("Blood culture collected within 24h"),
                                   highchartOutput("profile_blood")
                               )
                               
                        ),
                        column(6,
                               div(class = 'box_outputs', h4_title(icon("calendar-check"), "Date of Enrollment"),
                                   prettySwitch(inputId = "show_date_week", label = "See by Week", status = "primary"),
                                   highchartOutput("profile_date_enrollment")
                               ),
                               div(class = 'box_outputs',
                                   h4_title("Empiric Antibiotics Prescribed"),
                                   highchartOutput("profile_antibiotics")
                               ),
                               div(class = 'box_outputs',
                                   h4_title("Patients Comorbidities"),
                                   pickerInput(width = '100%',
                                               options = pickerOptions(style = "primary"),
                                               inputId = "comorbidities",
                                               choices = list(
                                                 Syndromes = c("Cancer", "Chronic renal failure", "Chronic lung disease", "Diabetes mellitus", "Malnutrition"),
                                                 Options = c("Display Comorbidities", "Show Patients with No Recorded Syndrom")
                                               ),
                                               selected = c("Cancer", "Chronic renal failure", "Chronic lung disease", "Diabetes mellitus", "Malnutrition"),
                                               multiple = TRUE),
                                   highchartOutput("profile_comorbidities")
                               ),
                               div(class = 'box_outputs',
                                   h4_title(icon("arrows-alt-h"), "Patients Transfered"),
                                   highchartOutput("profile_transfer")
                               ),
                               br(), br(), br(), br(), br()
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
                               ),
                               div(class = 'box_outputs',
                                   h4_title("Initial & Final Surveillance Diagnosis"),
                                   highchartOutput("profile_outcome_diagnosis", height = "500px")
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
                      )
             ),
             # Tab HAI ----
             tabPanel("HAI", value = "hai", 
                      div(class = 'box_outputs',
                          h4_title("Wards Occupancy Rates"),
                          htmlOutput("bed_occupancy_ward_title"),
                          plotOutput("bed_occupancy_ward", width = "80%")
                      ),
                      plotOutput("hai_rate_ward", width = "80%")
                      # )
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
                                   highchartOutput("specimens_specimens_type", height = "350px"),
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
                      prettySwitch(inputId = "combine_SI", label = "Combine Susceptible + Intermediate", status = "primary"),
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
                          prettyRadioButtons(inputId = "select_salmonella", label = NULL,  shape = "curve",
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
                          selectInput(inputId = "other_organism", label = NULL, multiple = FALSE,
                                      choices = NULL, selected = NULL),
                          conditionalPanel(condition = "output.test_other_sir",
                                           highchartOutput("other_organism_sir", height = "700px"),
                                           em("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")
                          ),
                          conditionalPanel(condition = "! output.test_other_sir", span(h4("There is no data to display.")))
                        )
                      )
             ),
             # Tab About
             tabPanel("About", value = "about",
                      includeMarkdown("./www/markdown/about_uCCI.md")
             )
  )
)

# Definition of server ----
server <- function(input, output, session) {
  
  # Hide tabs on app launch ----
  hideTab(inputId = "tabs", target = "data_management")
  hideTab(inputId = "tabs", target = "overview")
  hideTab(inputId = "tabs", target = "follow_up")
  hideTab(inputId = "tabs", target = "hai")
  hideTab(inputId = "tabs", target = "microbiology")
  hideTab(inputId = "tabs", target = "amr")
  
  # Management of CSS ----
  observe({
    session$setCurrentTheme(
      if (isTRUE(input$selected_language == "la")) acorn_theme_la else acorn_theme
    )
  })
  
  # TODO: activate in production:
  # hideTab("tabs", "data_visualisation")
  # observe(
  #   if (checklist_status$acorn_file_loaded$status == "okay")  showTab("tabs", "data_visualisation")
  # )
  
  # Management of filters ----
  # change color based on if filtered or not
  observe({
    req(input$Id094, input$filter_sex)
    toggleClass(id = "filter-1", class = "filter_on", condition = length(input$Id094) != 5)
    toggleClass(id = "filter-2", class = "filter_on", condition = length(input$filter_sex) != 2)
  })
  
  # To have it hidden on start of the app
  observe(
    if( input$additional_filter_1 == 0 )  shinyjs::hide(id = "box_additional_filter_1")
  )
  
  observeEvent(input$additional_filter_1, {
    if( input$additional_filter_1 %% 2 == 1 ) {
      shinyjs::show(id = "box_additional_filter_1")
      updateActionButton(session = session, inputId = "additional_filter_1", icon = icon("minus"))
    } else {
      shinyjs::hide(id = "box_additional_filter_1")
      updateActionButton(session = session, inputId = "additional_filter_1", icon = icon("plus"))
    }
  })
  
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
  
  # Definition of reactive elements for data ----
  
  # Primary datatsets
  acorn_cred <- reactiveVal()
  redcap_dta <- reactiveVal()
  hai_dta <- reactiveVal()
  lab_dta <- reactiveVal()
  acorn_dta_file <- reactiveValues()
  meta <- reactiveVal()
  
  # Secondary datasets (created from primary datasets)
  enrolment_log <- reactive({
    req(redcap_dta())
    
    redcap_dta() %>%
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
  
  patient <- reactiveVal()
  microbio <- reactiveVal()
  hai_surveys <- reactiveVal()
  corresp_org_antibio <- reactiveVal()
  
  
  # Tertiary datasets
  # patient_filter <- reactive(patient() %>% fun_filter_patient(input = input))
  # microbio_filter <- reactive(microbio() %>% fun_filter_microbio(patient = patient_filter(), input = input))
  # microbio_filter_blood <- reactive(microbio_filter() %>% fun_filter_blood_only())
  # hai_surveys_filter <- reactive(hai_surveys() %>% fun_filter_hai(input = input))
  patient_filter <- reactive(patient() %>% fun_filter_patient(input = input))
  microbio_filter <- reactive(microbio())
  microbio_filter_blood <- reactive(microbio_filter())
  hai_surveys_filter <- reactive(hai_surveys())
  
  
  
  output$enrolment_log <- renderUI({
    req(enrolment_log())
    
    tagList(
      strong("Enrolment Log:"),
      DTOutput("table_enrolment_log"),
      downloadButton("download_enrolment_log", "Download Enrolment Log (.xlsx)")
    )
  })
  
  # Definition of checklist_status ----
  # Status can be: hidden/question/okay/warning/ko
  checklist_status <- reactiveValues(
    internet_connection = list(status = "ko", msg = "Not connected to internet"),
    app_login = list(status = "ko", msg = "Not logged in"),
    
    redcap_server_cred = list(status = "ko", msg = "No connection to REDCap server"),
    acorn_server_test = list(status = "ko", msg = "Not connected to .acorn server"),
    acorn_server_write = list(status = "ko", msg = "No rights to backup .acorn on the server"),
    
    lab_data_qc_1 = list(status = "hidden", msg = ""),
    lab_data_qc_2 = list(status = "hidden", msg = ""),
    lab_data_qc_3 = list(status = "hidden", msg = ""),
    lab_data_qc_4 = list(status = "hidden", msg = ""),
    lab_data_qc_5 = list(status = "hidden", msg = ""),
    lab_data_qc_6 = list(status = "hidden", msg = ""),
    lab_data_qc_7 = list(status = "hidden", msg = ""),
    lab_data_qc_8 = list(status = "hidden", msg = ""),
    
    redcap_not_empty = list(status = "hidden", msg = "REDCap dataset empty"),
    redcap_structure = list(status = "hidden", msg = "REDCap dataset columns number"),
    redcap_columns = list(status = "hidden", msg = "REDCap dataset columns names"),
    redcap_acornid = list(status = "hidden", msg = "All records have an ACORN id."),
    redcap_F04F01 = list(status = "hidden", msg = "Every D28 form (F04) matches exactly one patient enrolment (F01)"),
    redcap_F03F02 = list(status = "hidden", msg = "Every hospital outcome (F03) has a matching infection episode (F02)"),
    redcap_F02F01 = list(status = "hidden", msg = "Every infection episode (F02) has a matching patient enrolment (F01)"),
    redcap_F03F01 = list(status = "hidden", msg = "Every hospital outcome form (F03) matches exactly one patient enrolment (F01)"),
    redcap_confirmed_match = list(status = "hidden", msg = "All confirmed entries match the original entry"),
    redcap_age_category = list(status = "hidden", msg = "(HIDDEN)"),
    redcap_hai_dates = list(status = "hidden", msg = "(HIDDEN)"),
    # redcap_F05F01 = list(status = "hidden", msg = "Every BSI episode form (F05) matches exactly one patient enrolment (F01)"),
    
    redcap_dta = list(status = "warning", msg = "Clinical data not provided"),
    lab_dta = list(status = "warning", msg = "Lab data not provided"),
    lab_dic = list(status = "ko", msg = "Lab data dictionary not found"),
    
    acorn_dta = list(status = "ko", msg = ".acorn data not loaded"),
    acorn_dta_saved = list(status = "ko", msg = "There is no .acorn data loaded")
  )
  
  # allow access to info on some elements of checklist_status
  # output$state_redcap_cred <- reactive(checklist_status$redcap_server_cred$status == "okay")
  # outputOptions(output, 'state_redcap_cred', suspendWhenHidden = FALSE)
  
  # output$state_s3_connection <- reactive(checklist_status$acorn_server_test$status == "okay")
  # outputOptions(output, 'state_s3_connection', suspendWhenHidden = FALSE)
  
  # output$state_write_s3 <- reactive(checklist_status$acorn_server_write$status == "okay")
  # outputOptions(output, 'state_write_s3', suspendWhenHidden = FALSE)
  
  # output$state_dta_available <- reactive(checklist_status$acorn_dta$status == "okay")
  # outputOptions(output, 'state_dta_available', suspendWhenHidden = FALSE)
  
  observe({
    ifelse(has_internet(), 
           { checklist_status$internet_connection <- list(status = "hidden", msg = "Connected to internet") }, 
           { checklist_status$internet_connection <- list(status = "ko", msg = "Not connected to internet")}
    )
  })
  
  # On connection ----
  observeEvent(input$cred_login, {
    showNotification("Attempting to connect", id = "notif_connection")
    Sys.sleep(1)
    
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
      
      checklist_status$app_login <- list(status = "okay", msg = "Successfully logged in (demo)")
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
      
      cred <- try(s3read_using(FUN = readRDS_encrypted, 
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
      
      
      checklist_status$app_login <- list(status = "okay", msg = glue("Successfully logged in to {input$cred_site} (as {cred$user})"))
      acorn_cred(cred)
    }
    removeNotification(id = "notif_connection")
    showNotification("Successfully logged in!")
    showTab("tabs", target = "data_management")
    
    # Connect to AWS S3 server ----
    if(acorn_cred()$acorn_s3) {
      
      connect_server_test <- bucket_exists(
        bucket = acorn_cred()$acorn_s3_bucket,
        key =  acorn_cred()$acorn_s3_key,
        secret = acorn_cred()$acorn_s3_secret,
        region = acorn_cred()$acorn_s3_region)[1]
      
      if(connect_server_test) {
        checklist_status$acorn_server_test <- list(status = "okay", msg = "Connection to .acorn server established")
        updateActionButton(session = session, 'get_redcap_data', icon = icon("cloud-download-alt"), label = "Get Clinical Data from REDCap server")
        
        if(acorn_cred()$acorn_s3_write)  checklist_status$acorn_server_write <- list(status = "okay", msg = "Ability to write on server")
        if(! acorn_cred()$acorn_s3_write)  checklist_status$acorn_server_write <- list(status = "ko", msg = "Not allowed to write on server")
        
        # Update select list with .acorn files on the server
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
      }
    }
    
    # Connect to REDCap server ----
    if(acorn_cred()$redcap_server) {
      checklist_status$redcap_server_cred <- list(status = "okay", msg = "REDCap credentials provided")
    }
    
    # TODO: decide what to do with these startAnim()
    startAnim(session, 'float', 'bounce')
  })
  
  # On "Load .acorn" file from server ----
  observeEvent(input$load_acorn_server, {
    # load content
    acorn_s3 <- get_object(object = input$acorn_files_server, 
                           bucket = acorn_cred()$acorn_s3_bucket,
                           key =  acorn_cred()$acorn_s3_key,
                           secret = acorn_cred()$acorn_s3_secret,
                           region = acorn_cred()$acorn_s3_region)
    load(rawConnection(acorn_s3))
    
    patient(patient)
    microbio(microbio)
    hai_surveys(hai.surveys)
    corresp_org_antibio(corresp_org_antibio)
    meta(meta)
    
    # update status of the app
    checklist_status$acorn_dta <- list(status = "okay", msg = glue("Successfully loaded data<br>{icon('info-circle')} Data generated on the {meta()$time_generation}; 
                                                                   by <strong>{meta$user}</strong>. {meta$comment}"))
    
    checklist_status$acorn_dta_saved = list(status = "info", msg = ".acorn not saved (but nothing new here)")
    
    # TODO: provide more details in the notification on the file loaded - see info_acorn_file() for a start
    showNotification(".acorn file successfully loaded")
    
    showTab("tabs", target = "overview")
    showTab("tabs", target = "follow_up")
    showTab("tabs", target = "hai")
    showTab("tabs", target = "microbiology")
    showTab("tabs", target = "amr")
    
    updateTabsetPanel(inputId = "tabs", selected = "overview")
  })
  
  # On "Load .acorn" file from local ----
  observeEvent(input$load_acorn_local, {
    load(input$load_acorn_local$datapath)
    
    patient(patient)
    microbio(microbio)
    hai_surveys(hai.surveys)
    corresp_org_antibio(corresp_org_antibio)
    meta(meta)
    
    
    # update status of the app
    checklist_status$acorn_dta <- list(status = "okay", msg = glue("Successfully loaded data<br>{icon('info-circle')} Data generated on the {meta()$time_generation}; 
                                                                   by <strong>{meta$user}</strong>. {meta$comment}"))
    
    checklist_status$acorn_dta_saved = list(status = "info", msg = ".acorn not saved (but nothing new here)")
    
    # TODO: provide more details in the notification on the file loaded - see info_acorn_file() for a start
    showNotification(".acorn file successfully loaded")
    
    showTab("tabs", target = "overview")
    showTab("tabs", target = "follow_up")
    showTab("tabs", target = "hai")
    showTab("tabs", target = "microbiology")
    showTab("tabs", target = "amr")
    
    updateTabsetPanel("tabs", selected = "overview")
  })
  
  
  # On supply of Lab data file ----
  observeEvent(input$file_lab_dba, {
    source("./www/R/data/01_read_lab_data.R", local = TRUE)
  })
  
  observeEvent(input$file_lab_sql, {
    source("./www/R/data/01_read_lab_data.R", local = TRUE)
  })
  
  observeEvent(input$file_lab_tab, {
    
    id <- notify("Processing Lab data: reading")
    on.exit(removeNotification(id), add = TRUE)
    
    source("./www/R/data/01_read_lab_data.R", local = TRUE)
    
    notify("Read lab codes and AST breakpoint data.", id = id)
    source("./www/R/data/01_read_lab_codes.R", local = TRUE)
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
    showNotification("Lab data successfully processsed!", type = "message")
  })
  
  
  # On "Get REDCap data" ----
  observeEvent(input$get_redcap_data, {
    if(is.null(acorn_cred()$redcap_f01f05_api)) {
      showNotification("REDCap server credentials not provided", type = "error")
      return()
    }
    
    source("./www/R/data/01_read_redcap_f01f05.R", local = TRUE)
    source("./www/R/data/02_process_redcap_f01f05.R", local = TRUE)
    
    source("./www/R/data/01_read_redcap_hai.R", local = TRUE)
    source("./www/R/data/02_process_redcap_hai.R", local = TRUE)
    
    
    # TODO: check that for a given enrollement, all infection episodes are on different dates
    if(any(c(checklist_status$redcap_not_empty$status,
             checklist_status$redcap_structure$status,
             checklist_status$redcap_columns$status,
             checklist_status$redcap_acornid$status,
             checklist_status$redcap_F04F01$status,
             checklist_status$redcap_F03F02$status,
             checklist_status$redcap_F02F01$status,
             checklist_status$redcap_F03F01$status,
             checklist_status$redcap_confirmed_match$status,
             checklist_status$redcap_age_category$status) == "ko")) {
      checklist_status$redcap_dta <- list(status = "ko", msg = "")
      
      showNotification("There is a critical issue with clinical data.
                       The issue should be fixed in REDCap.", type = "error", duration = NULL)
    } else {
      checklist_status$redcap_dta <- list(status = "okay", 
                                          msg = glue("Clinical data (F01-F05) provided with {length(unique(infection$redcap_id))} patient enrolments and {nrow(infection)} infection episodes"))
      showNotification("Clinical data successfully provided.", type = "message", duration = 5)
      # TODO: modify this to ensure that HAI data is okay before announcing that clinical data is provided
    }
    redcap_dta(infection)
    hai_dta(dl_hai_dta)
  })
  
  # On "Download Enrolment Log"
  output$download_enrolment_log <- downloadHandler(
    filename = glue("enrolment_log_{format(Sys.time(), '%Y-%m-%d_%H%M')}.xlsx"),
    content = function(file)  writexl::write_xlsx(enrolment_log(), path = file)
  )
  
  # On "Generate ACORN" ----
  observeEvent(input$generate_acorn_data, {
    if(checklist_status$redcap_dta$status == "warning")  {
      showNotification("Aborted: clinical data not provided.", type = "warning", duration = NULL)
    }
    
    if(checklist_status$lab_dta$status == "warning")  {
      showNotification("Aborted: lab data not provided.", type = "warning", duration = NULL)
    }
    
    if(checklist_status$redcap_dta$status == "ko") {
      showNotification("Aborted: there are critical issues with provided clinical data.", type = "error", duration = NULL)
    }
    
    if(checklist_status$lab_dta$status == "ko") {
      showNotification("Aborted: there are critical issues with provided lab data.", type = "error", duration = NULL)
    }
    
    
    if(checklist_status$lab_dta$status == "okay" & checklist_status$redcap_dta$status == "okay") {
      source("./www/R/data/09_link_clinical_assembly.R", local = TRUE)
      showNotification("It's critical to save your acorn file", type = "warning", duration = NULL)
      acorn_dta_saved = list(status = "ko", msg = ".acorn not saved")
    }
  })
  
  # On "Save ACORN" on server ----
  observeEvent(input$save_acorn_server, { 
    if(checklist_status$acorn_dta$status != "okay") {
      showNotification("No .acorn data loaded.", type = "warning", duration = NULL)
      return()
    }
    
    showModal(modalDialog(
      fluidRow(
        column(6,
               textInput("name_file", value = glue("{input$cred_site}_{session_start_time}"), label = "Choose a name for the file or (recommended) use default name"),
               textInput("meta_acorn_user", label = "User:", value = Sys.info()["user"]),
               textAreaInput("meta_acorn_comment", label = "(Optional) Comment")
        ),
        column(6,
               actionButton("save_acorn_server_confirm", label = "Confirm Save on Server")
        )
      ),
      
      title = "Save acorn data",
      footer = modalButton("Cancel"),
      size = "l",
      easyClose = FALSE,
      fade = TRUE
    ))
    
  })
  
  # Require confirmation and metadata
  observeEvent(input$save_acorn_server_confirm, { 
    name_file <- glue("{input$name_file}.acorn")
    file <- file.path(tempdir(), name_file)
    
    patient <- patient()
    microbio <- microbio()
    hai.surveys <- hai_surveys()
    corresp_org_antibio <- corresp_org_antibio()
    
    # generate meta
    meta <- list()
    meta$time_generation <- session_start_time
    meta$app_version <- app_version
    meta$user <- input$meta_acorn_user
    meta$comment <- input$meta_acorn_comment
    
    save(patient, microbio, corresp_org_antibio, hai.surveys,
         meta,
         file = file)
    
    put_object(file = file,
               object = name_file,
               bucket = acorn_cred()$acorn_s3_bucket,
               key =  acorn_cred()$acorn_s3_key,
               secret = acorn_cred()$acorn_s3_secret,
               region = acorn_cred()$acorn_s3_region)
    
    dta <- get_bucket(bucket = acorn_cred()$acorn_s3_bucket,
                      key =  acorn_cred()$acorn_s3_key,
                      secret = acorn_cred()$acorn_s3_secret,
                      region = acorn_cred()$acorn_s3_region)
    dta <- unlist(dta)
    acorn_dates <- as.vector(dta[names(dta) == 'Contents.LastModified'])
    ord_acorn_dates <- order(as.POSIXct(acorn_dates))
    acorn_files <- rev(tail(as.vector(dta[names(dta) == 'Contents.Key'])[ord_acorn_dates], 10))
    
    checklist_status$acorn_dta_saved <- list(status = "okay", msg = "ACORN file saved")
    
    updatePickerInput(session, 'acorn_files_server', choices = acorn_files, selected = character(0))
    removeModal()
    show_toast(title = "File Saved on Server", type = "success", position = "top")
  })
  
  # On "Save ACORN" locally ----
  observeEvent(input$save_acorn_local, { 
    showModal(modalDialog(
      fluidRow(
        column(6,
               textInput("name_file_dup", value = session_start_time, label = "Choose a name for the file"),
               textInput("meta_acorn_user_dup", label = "User:", value = Sys.info()["user"]),
               textInput("meta_acorn_machine_dup", label = "Machine:", value = Sys.info()["nodename"]),
               textAreaInput("meta_acorn_comment_dup", label = "(Optional) Comment"),
               p(glue("The session id: {session_id} will be added to the file."))
        ),
        column(6,
               downloadButton("save_acorn_local_confirm", label = "Confirm Save File")
        )
      ),
      
      title = "Save acorn data",
      footer = modalButton("Cancel"),
      size = "l",
      easyClose = FALSE,
      fade = TRUE
    ))
  })
  
  # Require confirmation and metadata
  output$save_acorn_local_confirm <- downloadHandler(
    filename = glue("{input$name_file_dup}.acorn"),
    content = function(file) {
      checklist_status$acorn_dta_saved <- list(status = "okay", msg = "ACORN file saved")
      f01 <- acorn_dta_merged$f01
      f02 <- acorn_dta_merged$f02
      f03 <- acorn_dta_merged$f03
      f04 <- acorn_dta_merged$f04
      f05 <- acorn_dta_merged$f05
      f06 <- acorn_dta_merged$f06
      
      f01_edit <- acorn_dta_merged$f01_edit
      f02_edit <- acorn_dta_merged$f02_edit
      f03_edit <- acorn_dta_merged$f03_edit
      f04_edit <- acorn_dta_merged$f04_edit
      f05_edit <- acorn_dta_merged$f05_edit
      f06_edit <- acorn_dta_merged$f06_edit
      
      lab_dta <- acorn_dta_merged$lab_dta
      
      meta <- list(time_generation = session_start_time,
                   session_id = session_id,
                   app_version = app_version,
                   user = input$meta_acorn_user_dup,
                   machine = input$meta_acorn_machine_dup,
                   comment = input$meta_acorn_comment_dup)
      
      save(f01, f02, f03, f04, f05, f06,
           f01_edit, f02_edit, f03_edit, f04_edit, f05_edit, f06_edit,
           lab_dta, meta,
           file = file)
    })
  startAnim(session, 'float', 'bounce')
}

shinyApp(ui = ui, server = server)  # port 3872
