# ACORN shiny app main script
# TODO: eliminate everything labelled 'ACORN1'

# Start ACORN1 ----
load("./www/mock_ACORN1_Data.RData")
patient$patient_id <- as.character(patient$patient_id)
patient$episode_id <- as.character(patient$episode_id)
cols_sir <- c("#2166ac", "#fddbc7", "#b2182b")  # resp. S, I, R
hc_export_kind <- c("downloadJPEG", "downloadCSV")
# End ACORN1 ----

source("./www/scripts/load_packages.R", local = TRUE)
app_version <- 'prototype.001'  # IMPORTANT ensure that the version is identical in DESCRIPTION and README.md
helper_developer <- "true" # JS condition
session_start_time <- format(Sys.time(), "%Y-%m-%d_%H:%M")
session_id <- glue("{glue_collapse(sample(LETTERS, 5, TRUE))}_{session_start_time}")

# It's safe to expose those since the acornamr-cred bucket content can only be listed + read 
# and contains only encrypted files
bucket_cred_k <- readRDS("./www/cred/bucket_cred_k.Rds")
bucket_cred_s <- readRDS("./www/cred/bucket_cred_s.Rds")

# contains all require i18n elements
source('./www/scripts/indicate_translation.R', local = TRUE)
for(file in list.files('./www/functions/'))  source(paste0('./www/functions/', file), local = TRUE)  # define all functions

# List of BS4 variables: https://github.com/rstudio/bslib/blob/master/inst/lib/bs/scss/_variables.scss
# Theme flatly: https://bootswatch.com/flatly/ ; https://bootswatch.com/4/flatly/bootstrap.css
acorn_theme <- bs_theme(bootswatch = "flatly", version = 4, 
                        "border-width" = "2px")
acorn_theme_la <- bs_theme(bootswatch = "flatly", version = 4, 
                           "border-width" = "2px", base_font = "Phetsarath OT", bg = "#202123", fg = "#B8BCC2")

tab <- function(...) {
  shiny::tabPanel(..., class = "p-3 border border-top-0 rounded-bottom")
}

ui <- fluidPage(
  title = 'ACORN | A Clinically Oriented antimicrobial Resistance Network',
  theme = acorn_theme,
  includeCSS("www/styles.css"),
  withAnim(),  # for shinyanimate
  usei18n(i18n),  # for translation
  useShinyjs(),
  
  
  div(id = 'float',
      dropMenu(
        actionButton("checklist_show", icon = icon("sliders-h"), label = NULL, class = "btn-success"),
        theme = "light-border",
        class = "checklist",
        placement = "bottom-end",
        htmlOutput("checklist_status")
      )
  ),
  
  # div(id = 'float-debug',
  #     conditionalPanel(helper_developer, actionLink("debug", label = "(Debug)"))
  # ),
  
  
  navbarPage(id = 'tabs',
             title = a(img(src = "logo_acorn.png", style = "height: 40px; position: relative;")),
             collapsible = TRUE, inverse = FALSE, 
             position = "static-top",
             # Header ----
             header = conditionalPanel(
               id = "header-filter",
               condition = "input.tabs != 'welcome' & input.tabs != 'data_management'",
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
                                       div(class = "smallcaps", class = "centerara", span(icon("hospital-user"), " Patients")),
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
                                                    prettySwitch(inputId = "filter_age_na", label = "Include Unknown Ages", status = "primary", value = TRUE, slim = TRUE),
                                                    hr()
                                             ),
                                             column(6,
                                                    prettyCheckboxGroup(inputId = "filter_diagnosis", label = "Patient Diagnosis:", shape = "curve", status = "primary",
                                                                        choices = c("Meningitis", "Pneumonia", "Sepsis"), selected = c("Meningitis", "Pneumonia", "Sepsis"),
                                                                        inline = TRUE),
                                                    prettyRadioButtons(inputId = "confirmed_diagnosis", label = "Diagnosis confirmation (if clinical outcome):",
                                                                       choices = c("Diagnosis confirmed", "Diagnosis rejected", "No filter on diagnosis confirmation"),
                                                                       selected = "No filter on diagnosis confirmation"),
                                                    prettySwitch(inputId = "filter_outcome_clinical", label = "Only Patients with Clinical Outcome", status = "primary", value = FALSE, slim = TRUE),
                                                    prettySwitch(inputId = "filter_outcome_d28", label = "Only Patients with Day-28 Outcome", status = "primary", value = FALSE, slim = TRUE)
                                             )
                                           )
                                       )
                                       # div(id = "box_additional_filter_1", 
                                       #     fluidRow(
                                       #       column(6,
                                       #              dateRangeInput("filter_date_enrollment", label = "Date of Enrollment:", startview = "year"),
                                       #              p("Patient Ages:"),
                                       #              fluidRow(
                                       #                column(4, numericInput("filter_age_min", label = "", min = 0, value = 0)),
                                       #                column(4, numericInput("filter_age_max", label = "", min = 0, value = 99),),
                                       #                column(4, selectInput("filter_age_unit", label = "", choices = c("days", "months", "years"), selected = "years"))
                                       #              ),
                                       #              prettySwitch(inputId = "filter_age_na", label = "Including Unknown Ages", status = "primary", value = TRUE, slim = TRUE),
                                       #              hr()
                                       #       ),
                                       #       column(4,
                                       #              prettyCheckboxGroup(inputId = "filter_diagnosis", label = "Patient Diagnosis:", shape = "curve", status = "primary",
                                       #                                  choices = c("Meningitis", "Pneumonia", "Sepsis"), selected = c("Meningitis", "Pneumonia", "Sepsis"), 
                                       #                                  inline = TRUE),
                                       #              prettyRadioButtons(inputId = "confirmed_diagnosis", label = "Diagnosis confirmation (if clinical outcome):", 
                                       #                                 choices = c("Diagnosis confirmed", "Diagnosis rejected", "No filter on diagnosis confirmation"),
                                       #                                 selected = "No filter on diagnosis confirmation")
                                       #       ),
                                       #       column(4,
                                       #              prettySwitch(inputId = "filter_outcome_clinical", label = "Select Only Patients with Clinical Outcome", status = "primary", value = FALSE),
                                       #              prettySwitch(inputId = "filter_outcome_d28", label = "Patients w/ Day-28 Outcome", status = "primary", value = FALSE)
                                       #       )
                                       #     )
                                       # ),
                                       # div(id = "additional_filter_btn",
                                       #     actionButton("additional_filter_1", icon = icon("plus"), label = "", class = "btn-success")
                                       # )
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
             
             # Footer ----
             footer = div(class = "f-85 footer", 
                          p(glue("App version {app_version}"), "| ", a("ACORN Project website", href = "https://acornamr.net/", class='js-external-link', target="_blank"))),
             
             # Tab Welcome ----
             tabPanel(i18n$t('Welcome'), value = 'welcome',
                      fluidRow(
                        column(3,
                               uiOutput('site_logo'),
                               br(),
                               div(id = "login-basic", 
                                   div(
                                     class = "well",
                                     h4(class = "text-center", "Please login"),
                                     p(class = "text-center", "Use demo/demo for a tour of the App or to visualise a specific .acorn file."
                                     ),
                                     textInput(
                                       inputId     = "cred_username", 
                                       label       = tagList(icon("user"), "User Name"),
                                       placeholder = "Enter user name"
                                     ),
                                     passwordInput(
                                       inputId     = "cred_password", 
                                       label       = tagList(icon("unlock-alt"), "Password"), 
                                       placeholder = "Enter password"
                                     ), 
                                     div(class = "text-center",
                                         actionButton(inputId = "cred_login", label = "Log in", class = "btn-primary")
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
                               includeMarkdown("./www/markdown/lorem_ipsum.md")
                        )
                      )
             ),
             # Tab Data Management ----
             tabPanel(span(icon("database"), 'Data Management'), value = "data_management",
                      tabsetPanel(id = "management", type = "tabs",
                                  tab(value = "clinical", "Review clinical data",
                                      p("Provided clinical data, you can track records and generate logs here."),
                                      conditionalPanel(condition = 'output.state_redcap_cred',
                                                       actionButton('get_redcap_data', span(icon('cloud-download-alt'), HTML('Get REDCap Data')))
                                      ),
                                      DTOutput("table_redcap_dta")
                                  ),
                                  tab(value = "generate", span("Generate ", em(".acorn"), " file"),
                                      p("Provided with clinical and lab data, we can generate a .acorn file."),
                                      fluidRow(
                                        column(6,
                                               div(class = "centerara", h5(icon("laptop"), "Local")), br()
                                        ),
                                        column(6,
                                               div(class = "centerara", class = "vl", h5(icon("cloud"), "Server")), br()
                                        )
                                      ),
                                      br()
                                  ),
                                  tab(value = "load", span("Load ", em(".acorn"), " file"),
                                      HTML("This section allows you to load an .acorn file. If you don't have one, you can <a id='link_to_generate' href='#' class='action-button'>generate one.</a>"),
                                      br(),
                                      fluidRow(
                                        column(6,
                                               div(class = "centerara", h5(icon("laptop"), "Local")),
                                               fileInput("load_acorn_local", label = NULL, buttonLabel =  HTML("Load <em>.acorn</em>"), accept = '.acorn'),
                                        ),
                                        column(6,
                                               div(class = "centerara", class = "vl", 
                                                   h5(icon("cloud"), "Server"),
                                                   conditionalPanel(condition = '! output.state_s3_connection',
                                                                    p("No connection to a server has been established."),
                                                   ),
                                                   conditionalPanel(condition = 'output.state_s3_connection',
                                                                    fluidRow(
                                                                      column(6,
                                                                             pickerInput('acorn_files_server', choices = NULL, label = NULL,
                                                                                         options = pickerOptions(actionsBox = TRUE, noneSelectedText = "No file selected", liveSearch = FALSE,
                                                                                                                 showTick = TRUE, header = "10 most recent files:"))
                                                                      ),
                                                                      column(6,
                                                                             conditionalPanel(condition = "input.acorn_files_server",
                                                                                              actionButton('load_acorn_server', span(icon('cloud-download-alt'), HTML('Load <em>.acorn</em>')))
                                                                             )
                                                                      )
                                                                    )
                                                   )
                                               )
                                        )
                                      ),
                                      br()
                                  ),
                                  tab(value = "save", span("Save ", em(".acorn"), " file"),
                                      conditionalPanel(condition = '! output.state_dta_available',
                                                       p("There is no data to be saved. Create data first.")
                                      ),
                                      conditionalPanel(condition = 'output.state_dta_available',
                                                       fluidRow(
                                                         column(6,
                                                                div(class = "centerara", h5(icon("laptop"), "Local")), br(),
                                                                actionButton('save_acorn_local', HTML('Save <em>.acorn</em>'))
                                                         ),
                                                         column(6,
                                                                div(class = "centerara", class = "vl", h5(icon("cloud"), "Server"), br(),
                                                                    conditionalPanel(condition = 'output.state_s3_connection & output.state_write_s3',
                                                                                     actionButton('save_acorn_server', span(icon('cloud-upload-alt'), HTML('Save <em>.acorn</em>')))
                                                                    ),
                                                                    conditionalPanel(condition = '! output.state_write_s3',
                                                                                     p(icon("times"), " No write access to server."),
                                                                                     actionButton('save_acorn_server', span(icon('cloud-upload-alt'), HTML('Save <em>.acorn</em>')), disabled = TRUE)
                                                                    ),
                                                                    conditionalPanel(condition = '! output.state_s3_connection',
                                                                                     p(icon("satellite-dish"), " No connection to server.")
                                                                    )
                                                                )
                                                         )
                                                       )
                                      )
                                  )
                      ), br(), br()
             ),
             # Tab Patients ----
             navbarMenu("Patient Enrollment",
                        # Tab Overview ----
                        tabPanel("Overview", value = "overview", 
                                 br(), br(), 
                                 
                                 # fluidRow(
                                 #   column(6,
                                 #          div(class = "box_outputs",
                                 #              h5("Proportions of Enrollments with Blood Culture"),
                                 #              highchartOutput("evolution_blood_culture", height = "350px")
                                 #          )
                                 #   ),
                                 #   column(6,
                                 #          div(class = "box_outputs",
                                 #              h5("Number of Patients"),
                                 #              # checkboxGroupButtons("variables_table", label = "Select Variables to Include in Table:", 
                                 #              #                      size = "sm", status = "primary", checkIcon = list(yes = icon("check")), individual = TRUE,
                                 #              #                      choices = c("Place of Infection" = "surveillance_cat", "Type of Ward" = "ward", "Ward" = "ward_text", "Clinical Outcome" = "clinical_outcome", "Day-28 Outcome" = "d28_outcome"), 
                                 #              #                      selected = c("surveillance_cat", "ward", "ward_text")),
                                 #              
                                 #              pickerInput("variables_table", label = "Table Columns:", 
                                 #                          # size = "sm", status = "primary", checkIcon = list(yes = icon("check")), 
                                 #                          multiple = TRUE, width = "100%",
                                 #                          choices = c("Place of Infection" = "surveillance_cat", "Type of Ward" = "ward", "Ward" = "ward_text", "Clinical Outcome" = "clinical_outcome", "Day-28 Outcome" = "d28_outcome"), 
                                 #                          selected = c("surveillance_cat", "ward", "ward_text")),
                                 #              
                                 #              DTOutput("table_patients", width = "95%")
                                 #          )
                                 #   )
                                 # ),
                                 fluidRow(
                                   column(5,
                                          htmlOutput("nb_patients_distinct"),
                                          div(class = "box_outputs",
                                              h5("Proportions of Enrollments with Blood Culture"),
                                              highchartOutput("evolution_blood_culture")
                                          )),
                                   column(7,
                                          div(class = "box_outputs",
                                              h5("Number of Patients"),
                                              pickerInput("variables_table", label = "Table Columns:", 
                                                          multiple = TRUE, width = "600px",
                                                          choices = c("Place of Infection" = "surveillance_cat", "Type of Ward" = "ward", "Ward" = "ward_text", "Clinical Outcome" = "clinical_outcome", "Day-28 Outcome" = "d28_outcome"), 
                                                          selected = c("surveillance_cat", "ward", "ward_text")),
                                              
                                              DTOutput("table_patients", width = "95%")
                                          )
                                   )
                                 ),
                                 br()
                        ),
                        "----",
                        tabPanel("Profile", value = "patients_profile", 
                                 br(), br(),
                                 div(class = 'box_outputs',
                                     h4(icon('stethoscope'), "Patients Diagnosis"),
                                     fluidRow(
                                       column(6, highchartOutput("profile_diagnosis")),
                                       column(3, highchartOutput("profile_diagnosis_meningitis")),
                                       column(3, highchartOutput("profile_diagnosis_pneumonia"))
                                     )
                                 ),
                                 fluidRow(
                                   column(6,
                                          div(class = 'box_outputs',
                                              h4("Enrolled Cases by Ward / Type of Ward"),
                                              prettySwitch(inputId = "show_ward_breakdown", label = "See Breakdown by Ward", status = "primary"),
                                              highchartOutput("profile_type_ward")
                                          )
                                   ),
                                   column(6,
                                          div(class = 'box_outputs',
                                              h4(icon("tint"), "Patients with Blood Culture"),
                                              fluidRow(
                                                column(6, gaugeOutput("profile_blood_culture_gauge", width = "100%", height = "100px")),
                                                column(6, htmlOutput("profile_blood_culture_pct", width = "100%", height = "100px"))
                                              )
                                          )
                                   )
                                 ),
                                 fluidRow(
                                   column(6,
                                          h4("Patients Age Distribution"),
                                          highchartOutput("profile_age"),
                                          h4("Patients Sex"),
                                          highchartOutput("profile_sex"),
                                          h4("Blood culture collected within 24h"),
                                          highchartOutput("profile_blood")
                                          
                                   ),
                                   column(6,
                                          h4(icon("calendar-check"), "Date of Enrollment"),
                                          prettySwitch(inputId = "show_date_week", label = "See by Week", status = "primary"),
                                          highchartOutput("profile_date_enrollment"),
                                          h4("Empiric Antibiotics Prescribed"),
                                          highchartOutput("profile_antibiotics"),
                                          h4("Patients Comorbidities"),
                                          pickerInput(width = '100%',
                                                      options = pickerOptions(style = "primary"),
                                                      inputId = "comorbidities",
                                                      choices = list(
                                                        Syndromes = c("Cancer", "Chronic renal failure", "Chronic lung disease", "Diabetes mellitus", "Malnutrition"),
                                                        Options = c("Display Comorbidities", "Show Patients with No Recorded Syndrom")
                                                      ),
                                                      selected = c("Cancer", "Chronic renal failure", "Chronic lung disease", "Diabetes mellitus", "Malnutrition"),
                                                      multiple = TRUE),
                                          highchartOutput("profile_comorbidities"),
                                          h4(icon("arrows-alt-h"), "Patients Transfered"),
                                          highchartOutput("profile_transfer"),
                                          br(), br(), br(), br(), br()
                                   )
                                 )
                        ),
                        # Tab Follow-up ----
                        tabPanel("Follow-up", value = "follow_up",
                                 fluidRow(
                                   column(6,
                                          div(class = 'box_outputs',
                                              h4("Clinical Outcome"),
                                              fluidRow(
                                                column(6, gaugeOutput("clinical_outcome_gauge", width = "100%", height = "100px")),
                                                column(6, htmlOutput("clinical_outcome_pct", width = "100%", height = "100px"))
                                              )
                                          ),
                                          div(class = 'box_outputs',
                                              h4("Clinical Outcome Status"),
                                              highchartOutput("clinical_outcome_status", height = "250px")
                                          ),
                                          div(class = 'box_outputs',
                                              h4("Initial & Final Surveillance Diagnosis"),
                                              highchartOutput("profile_outcome_diagnosis", height = "500px")
                                          )
                                   ),
                                   column(6,
                                          div(class = 'box_outputs',
                                              h4("Day 28"),
                                              fluidRow(
                                                column(6, gaugeOutput("d28_outcome_gauge", width = "100%", height = "100px")),
                                                column(6, htmlOutput("d28_outcome_pct", width = "100%", height = "100px"))
                                              )
                                          ),
                                          div(class = 'box_outputs',
                                              h4("Day 28 Status"),
                                              highchartOutput("d28_outcome_status", height = "200px")
                                          )
                                   )
                                 )
                        ),
                        # Tab HAI ----
                        tabPanel("HAI", value = "hai", 
                                 div(class = 'box_outputs',
                                     h4("Wards Occupancy Rates"),
                                     htmlOutput("bed_occupancy_ward_title"),
                                     plotOutput("bed_occupancy_ward", width = "80%")
                                 ),
                                 plotOutput("hai_rate_ward", width = "80%")
                        )
             ),
             # Tab Microbiology ----
             tabPanel("Microbiology", value = "microbiology", 
                      fluidRow(
                        column(3, htmlOutput("n_patient")),
                        column(3, offset = 1, htmlOutput("n_specimen")),
                        column(4, offset = 1, htmlOutput("n_isolate"))
                      ),
                      br(),
                      fluidRow(
                        column(5,
                               div(class = 'box_outputs',
                                   h4("Growth / No Growth"),
                                   fluidRow(
                                     column(6, gaugeOutput("isolates_growth_gauge", width = "100%", height = "100px")),
                                     column(6, htmlOutput("isolates_growth_pct", width = "100%", height = "100px"))
                                   )
                               ),
                               div(class = 'box_outputs',
                                   h4("Specimen Types"),
                                   p("Number of specimens per specimen type"),
                                   highchartOutput("specimens_specimens_type", height = "350px"),
                                   p("Culture results per specimen type"),
                                   highchartOutput("culture_specimen_type", height = "400px")
                               )
                        ),
                        column(6, offset = 1,
                               div(class = 'box_outputs',
                                   h4("Isolates"),
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
                          htmlOutput("nb_isolates_abaumannii"),
                          conditionalPanel(condition = "output.test_abaumannii_sir",
                                           highchartOutput("abaumannii_sir", height = "500px"),
                                           h4("Resistance to Carbapenems Over Time"),
                                           highchartOutput("abaumannii_sir_evolution", height = "300px"),
                                           em("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")
                          ),
                          conditionalPanel(condition = "! output.test_abaumannii_sir", span(h4("There is no data to display for this organism.")))
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
             )
  )
)

# define server ----

server <- function(input, output, session) {
  
  observeEvent(input$link_to_generate, {
    updateTabsetPanel(session, "management", "generate")
  })
  
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
  
  # Misc stuff ----
  # source files with code to generate outputs
  file_list <- list.files(path = "./www/outputs", pattern = "*.R")
  for (file in file_list) source(paste0("./www/outputs/", file), local = TRUE)$value
  source("./www/scripts/shortcuts_filters_exec.R", local = TRUE)$value
  
  # allow debug on click
  observeEvent(input$debug, browser())
  
  # update language based on dropdown choice
  observeEvent(input$selected_language, {
    update_lang(session, input$selected_language)
  })
  
  # Definition of reactive elements for data ----
  # The "ACORN Data Management SOP" document has relevant information
  redcap_dta <- reactiveVal()
  acorn_cred <- reactiveVal()
  acorn_dta_file <- reactiveValues()
  # In-App editing:
  # acorn_dta_session <- reactiveValues()
  acorn_dta_merged <- reactiveValues()  
  
  acorn_dta <- reactive({
    req(acorn_dta_merged$lab_dta, acorn_dta_merged$f01_cor)
    merge_clinical_lab(acorn_dta_merged)
  })
  
  acorn_dta_filter <- reactive({
    req(acorn_dta())
    acorn_dta() %>% filter_data(input = input)
  })
  
  
  # ACORN1 Start ----
  # Main datasets:
  patient <- reactiveVal(patient)
  microbio <- reactiveVal(microbio)
  hai_surveys <- reactiveVal(hai.surveys)
  corresp_org_antibio <- reactiveVal(corresp_org_antibio)
  
  # Secondary datasets:
  # patient_filter <- reactive(patient() %>% fun_filter_patient(input = input))
  # microbio_filter <- reactive(microbio() %>% fun_filter_microbio(patient = patient_filter(), input = input))
  # microbio_filter_blood <- reactive(microbio_filter() %>% fun_filter_blood_only())
  # hai_surveys_filter <- reactive(hai_surveys() %>% fun_filter_hai(input = input))
  patient_filter <- reactive(patient())
  microbio_filter <- reactive(microbio())
  microbio_filter_blood <- reactive(microbio_filter())
  hai_surveys_filter <- reactive(hai_surveys())
  # ACORN1 End ----
  
  # Checklists ----
  
  # Status can be: hidden / question / okay / warning / ko
  checklist_status <- reactiveValues(
    app_login = list(status = "hidden", msg = "Connection status"),
    s3_cred = list(status = "hidden", msg = "S3 ACORN server credential"),
    redcap_cred = list(status = "hidden", msg = "REDCap server credential"),
    internet_con = list(status = "hidden", msg = "Connection to internet"),
    s3_connection = list(status = "hidden", msg = "Connection to S3 ACORN server"),
    s3_write = list(status = "hidden", msg = "Authorisation to write on S3 ACORN server"),
    acorn_file_loaded = list(status = "hidden", msg = "ACORN data loaded"),
    acorn_file_saved = list(status = "hidden", msg = "ACORN data saved"),
    acorn_data_filtered = list(status = "hidden", msg = "ACORN data filter status")
  )
  
  # allow access to info on AWS S3 connection and data availability in UI
  output$state_redcap_cred <- reactive(checklist_status$redcap_cred$status == "okay")
  outputOptions(output, 'state_redcap_cred', suspendWhenHidden = FALSE)
  output$state_s3_connection <- reactive(checklist_status$s3_connection$status == "okay")
  outputOptions(output, 'state_s3_connection', suspendWhenHidden = FALSE)
  output$state_write_s3 <- reactive(checklist_status$s3_write$status == "okay")
  outputOptions(output, 'state_write_s3', suspendWhenHidden = FALSE)
  output$state_dta_available <- reactive(checklist_status$acorn_file_loaded$status == "okay")
  outputOptions(output, 'state_dta_available', suspendWhenHidden = FALSE)
  
  # checklist management if data is filtered
  observe({
    req(acorn_dta())
    req(acorn_dta_filter())
    same_nb_rows <- (nrow(acorn_dta()) == nrow(acorn_dta_filter()))
    if(same_nb_rows)  checklist_status$acorn_data_filtered <- list(status = "okay", msg = "ACORN data not filtered")
    if(! same_nb_rows)  checklist_status$acorn_data_filtered <- list(status = "warning", msg = "ACORN data is filtered")
  })
  
  # On connection ----
  observeEvent(input$cred_login, {
    if (input$cred_username == "demo") {
      
      # Stop is the password is wrong
      cred <- readRDS("./www/cred/encrypted_cred_demo.rds")
      key_user <- sha256(charToRaw(input$cred_password))
      test <- try(unserialize(aes_cbc_decrypt(cred, key = key_user)), silent = TRUE)
      
      if(inherits(test, "try-error"))  {
        show_toast(title = "Wrong password", type = "error", position = "top")
        return()
      }
      
      # Save into reactive element to be able to used later on
      cred <- unserialize(aes_cbc_decrypt(cred, key = key_user))
      
      test <- (cred$user == input$cred_username)
      if(!test)  {
        Sys.sleep(1)
        show_toast(title = "Something strange is happening", type = "error", position = "top")
        return()
      }
      
      acorn_cred(cred)
    }
    if (input$cred_username != "demo") {
      file_cred <- glue("encrypted_cred_{input$cred_username}.rds")
      # Feedback if the connection can't be established
      connect <- try(get_bucket(bucket = "acornamr-cred", 
                                key    = bucket_cred_k,
                                secret = bucket_cred_s,
                                region = "eu-west-3") %>% unlist(),
                     silent = TRUE)
      
      if (inherits(connect, 'try-error')) {
        showNotification("Couldn't connect to server credentials. Please check internet access/firewall.")
        return()
      }
      
      # Test if credentials for this user name exist
      if (! file_cred %in% 
          as.vector(connect[names(connect) == 'Contents.Key'])) {
        showNotification("Couldn't find this user")
        return()
      }
      
      # I can't find a way to pass those credentials directly in s3read_using()
      Sys.setenv("AWS_ACCESS_KEY_ID" = bucket_cred_k,
                 "AWS_SECRET_ACCESS_KEY" = bucket_cred_s,
                 "AWS_DEFAULT_REGION" = "eu-west-3")
      
      cred <- s3read_using(FUN = readRDS_encrypted, 
                           pwd = input$cred_password,
                           object = file_cred,
                           bucket = "acornamr-cred")
      
      # To avoid issues during devel
      Sys.setenv("AWS_ACCESS_KEY_ID" = "",
                 "AWS_SECRET_ACCESS_KEY" = "",
                 "AWS_DEFAULT_REGION" = "")
      
      test <- (cred$user == input$cred_username)
      if(!test)  {
        Sys.sleep(1)
        show_toast(title = "Something strange is happening", type = "error", position = "top")
        return()
      }
      
      acorn_cred(cred)
    }
    showNotification("You are now logged in!")
    
    # Connect to AWS S3 server ----
    if(acorn_cred()$acorn_s3) {
      
      checklist_status$s3_cred <- list(status = "okay", msg = "Server connection credential provided")
      
      ifelse(has_internet(), 
             { checklist_status$internet_con <- list(status = "okay", msg = "Connection to internet") }, 
             { checklist_status$internet_con <- list(status = "ko", msg = "No connection to internet") 
             return()})
      
      connect_server_test <- bucket_exists(
        bucket = acorn_cred()$acorn_s3_bucket,
        key =  acorn_cred()$acorn_s3_key,
        secret = acorn_cred()$acorn_s3_secret,
        region = acorn_cred()$acorn_s3_region)[1]
      
      if(connect_server_test) {
        checklist_status$s3_connection <- list(status = "okay", msg = "Server connection established")
        
        if(acorn_cred()$acorn_s3_write)  checklist_status$s3_write <- list(status = "okay", msg = "Ability to write on server")
        if(! acorn_cred()$acorn_s3_write)  checklist_status$s3_write <- list(status = "ko", msg = "Not allowed to write on server")
        
        # Update select list with .acorn files on the server
        dta <- get_bucket(bucket = acorn_cred()$acorn_s3_bucket,
                          key =  acorn_cred()$acorn_s3_key,
                          secret = acorn_cred()$acorn_s3_secret,
                          region = acorn_cred()$acorn_s3_region)
        dta <- unlist(dta)
        acorn_dates <- as.vector(dta[names(dta) == 'Contents.LastModified'])
        ord_acorn_dates <- order(as.POSIXct(acorn_dates))
        acorn_files <- rev(tail(as.vector(dta[names(dta) == 'Contents.Key'])[ord_acorn_dates], 10))
        
        updatePickerInput(session, 'acorn_files_server', choices = acorn_files, selected = acorn_files[1])
      }
      
      if(!connect_server_test) {
        checklist_status$s3_connection <- list(status = "ko", msg = "No server connection established")
        return()
      }
    }
    
    # Connect to REDCap server ----
    if(acorn_cred()$redcap_server) {
      checklist_status$redcap_cred <- list(status = "okay", msg = "REDCap server connection credential provided")
    }
    
    startAnim(session, 'float', 'bounce')
  })
  
  # On Download of .acorn file from server ----
  observeEvent(input$load_acorn_server, {
    # laod content
    acorn_s3 <- get_object(object = input$acorn_files_server, 
                           bucket = acorn_cred()$acorn_s3_bucket,
                           key =  acorn_cred()$acorn_s3_key,
                           secret = acorn_cred()$acorn_s3_secret,
                           region = acorn_cred()$acorn_s3_region)
    load(rawConnection(acorn_s3))
    
    # update acorn_dta_file
    acorn_dta_file$f01 <- f01
    acorn_dta_file$f02 <- f02
    acorn_dta_file$f03 <- f03
    acorn_dta_file$f04 <- f04
    acorn_dta_file$f05 <- f05
    acorn_dta_file$f06 <- f06
    acorn_dta_file$f01_edit <- f01_edit
    acorn_dta_file$f02_edit <- f02_edit
    acorn_dta_file$f03_edit <- f03_edit
    acorn_dta_file$f04_edit <- f04_edit
    acorn_dta_file$f05_edit <- f05_edit
    acorn_dta_file$f06_edit <- f06_edit
    acorn_dta_file$lab_dta <- lab_dta
    acorn_dta_file$meta <- meta
    
    # update acorn_dta_merged
    acorn_dta_merged$f01 <- f01
    acorn_dta_merged$f02 <- f02
    acorn_dta_merged$f03 <- f03
    acorn_dta_merged$f04 <- f04
    acorn_dta_merged$f05 <- f05
    acorn_dta_merged$f06 <- f06
    acorn_dta_merged$f01_edit <- f01_edit
    acorn_dta_merged$f02_edit <- f02_edit
    acorn_dta_merged$f03_edit <- f03_edit
    acorn_dta_merged$f04_edit <- f04_edit
    acorn_dta_merged$f05_edit <- f05_edit
    acorn_dta_merged$f06_edit <- f06_edit
    acorn_dta_merged$f01_cor <- process_edit(f01, f01_edit)
    acorn_dta_merged$f02_cor <- process_edit(f02, f02_edit)
    acorn_dta_merged$f03_cor <- process_edit(f03, f03_edit)
    acorn_dta_merged$f04_cor <- process_edit(f04, f04_edit)
    acorn_dta_merged$f05_cor <- process_edit(f05, f05_edit)
    acorn_dta_merged$f06_cor <- process_edit(f06, f06_edit)
    acorn_dta_merged$lab_dta <- lab_dta
    acorn_dta_merged$meta <- meta
    
    # update status of the app
    checklist_status$acorn_file_loaded <- list(status = "okay", msg = glue("Successfully loaded data<br>{icon('info-circle')} Data generated on the {acorn_dta_merged$meta$time_generation}; on <strong>{acorn_dta_merged$meta$machine}</strong>; by <strong>{acorn_dta_merged$meta$user}</strong>. {acorn_dta_merged$meta$comment}"))
    
    showModal(modalDialog(
      info_acorn_file(acorn_dta_file),
      title = "Info on file loaded",
      footer = modalButton("Okay"),
      size = "l",
      easyClose = FALSE,
      fade = TRUE
    ))
  })
  
  # On "Load .acorn" file from local ----
  observeEvent(input$load_acorn_local, {
    load(input$load_acorn_local$datapath)
    
    # update acorn_dta_file
    acorn_dta_file$f01 <- f01
    acorn_dta_file$f02 <- f02
    acorn_dta_file$f03 <- f03
    acorn_dta_file$f04 <- f04
    acorn_dta_file$f05 <- f05
    acorn_dta_file$f06 <- f06
    acorn_dta_file$f01_edit <- f01_edit
    acorn_dta_file$f02_edit <- f02_edit
    acorn_dta_file$f03_edit <- f03_edit
    acorn_dta_file$f04_edit <- f04_edit
    acorn_dta_file$f05_edit <- f05_edit
    acorn_dta_file$f06_edit <- f06_edit
    acorn_dta_file$lab_dta <- lab_dta
    acorn_dta_file$meta <- meta
    
    # update acorn_dta_merged
    acorn_dta_merged$f01 <- f01
    acorn_dta_merged$f02 <- f02
    acorn_dta_merged$f03 <- f03
    acorn_dta_merged$f04 <- f04
    acorn_dta_merged$f05 <- f05
    acorn_dta_merged$f06 <- f06
    acorn_dta_merged$f01_edit <- f01_edit
    acorn_dta_merged$f02_edit <- f02_edit
    acorn_dta_merged$f03_edit <- f03_edit
    acorn_dta_merged$f04_edit <- f04_edit
    acorn_dta_merged$f05_edit <- f05_edit
    acorn_dta_merged$f06_edit <- f06_edit
    acorn_dta_merged$f01_cor <- process_edit(f01, f01_edit)
    acorn_dta_merged$f02_cor <- process_edit(f02, f02_edit)
    acorn_dta_merged$f03_cor <- process_edit(f03, f03_edit)
    acorn_dta_merged$f04_cor <- process_edit(f04, f04_edit)
    acorn_dta_merged$f05_cor <- process_edit(f05, f05_edit)
    acorn_dta_merged$f06_cor <- process_edit(f06, f06_edit)
    acorn_dta_merged$lab_dta <- lab_dta
    acorn_dta_merged$meta <- meta
    
    # update status of the app
    checklist_status$acorn_file_loaded <- list(status = "okay", msg = glue("Successfully loaded data<br>{icon('info-circle')} Data generated on the {acorn_dta_merged$meta$time_generation}; on <strong>{acorn_dta_merged$meta$machine}</strong>; by <strong>{acorn_dta_merged$meta$user}</strong>. {acorn_dta_merged$meta$comment}"))
    
    
    showModal(modalDialog(
      info_acorn_file(acorn_dta_file),
      title = "Info on file loaded",
      footer = modalButton("Okay"),
      size = "l",
      easyClose = FALSE,
      fade = TRUE
    ))
    startAnim(session, 'float', 'bounce')
  })
  
  
  # On "Get REDCap data" ----
  observeEvent(input$get_redcap_data, {
    dta <- redcap_read(redcap_uri='https://m-redcap-test.tropmedres.ac/redcap_test/api/', 
                       token = acorn_cred()$redcap_server_api)$data
    
    redcap_dta(dta)
  })
  
  
  # On "Save ACORN" on server ----
  observeEvent(input$save_acorn_server, { 
    
    showModal(modalDialog(
      fluidRow(
        column(6,
               textInput("name_file", value = session_start_time, label = "Choose a name for the file"),
               textInput("meta_acorn_user", label = "User:", value = Sys.info()["user"]),
               textInput("meta_acorn_machine", label = "Machine:", value = Sys.info()["nodename"]),
               textAreaInput("meta_acorn_comment", label = "(Optional) Comment"),
               p(glue("The session id: {session_id} will be added to the file."))
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
                 user = input$meta_acorn_user,
                 machine = input$meta_acorn_machine,
                 comment = input$meta_acorn_comment)
    
    save(f01, f02, f03, f04, f05, f06,
         f01_edit, f02_edit, f03_edit, f04_edit, f05_edit, f06_edit,
         lab_dta, meta,
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
    
    checklist_status$acorn_file_saved <- list(status = "okay", msg = "ACORN file saved")
    
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
      checklist_status$acorn_file_saved <- list(status = "okay", msg = "ACORN file saved")
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
