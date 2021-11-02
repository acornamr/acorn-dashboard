# ACORN shiny app main script

source('./www/R/startup.R', local = TRUE)

# Definition of UI ----
ui <- page(
  theme = acorn_theme,
  includeCSS("www/styles.css"),
  shinyanimate::withAnim(),
  usei18n(i18n),  # for translation
  shinyjs::useShinyjs(),
  page_navbar(
    title = a(img(src = "logo_acorn.png", style = "height: 45px; position: relative;")),
    id = "tabs",
    selected = "welcome",
    window_title = "ACORN | A Clinically Oriented antimicrobial Resistance Network",
    collapsible = TRUE, inverse = FALSE, 
    position = "static-top",
    header = div(conditionalPanel(
      condition = "input.tabs != 'welcome' & input.tabs != 'data_management'",
      div(id = "header-filter",
          fluidRow(
            column(9,
                   div(id = "filter_box", class = "well",
                       fluidRow(
                         column(8,
                                div(class = "smallcaps", class = "text_center", span(icon("hospital-user"), i18n$t("Enrolments"))),
                                checkboxGroupButtons("filter_enrolments",
                                                     choices = c("Surveillance Category", "Type of Ward", "Date of Enrolment/Survey", "Age Category",
                                                                 "Initial Diagnosis", "Final Diagnosis", "Clinical Severity", "Clinical/D28 Outcome",
                                                                 "Transfer"),
                                                     selected = NULL,
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
                                                 prettySwitch("filter_severity_child_0", "Include Child/Neonate with 0 severity criteria", status = "primary", value = TRUE, slim = TRUE),
                                                 prettySwitch("filter_severity_child_1", "Include Child/Neonate with ≥ 1 severity criteria", status = "primary", value = TRUE, slim = TRUE)
                                ),
                                conditionalPanel("input.filter_enrolments.includes('Clinical/D28 Outcome')",
                                                 prettySwitch("filter_outcome_clinical", "Only with Clinical Outcome", status = "primary", value = FALSE, slim = TRUE),
                                                 prettySwitch("filter_outcome_d28", "Only with Day-28 Outcome", status = "primary", value = FALSE, slim = TRUE)
                                ),
                                conditionalPanel("input.filter_enrolments.includes('Transfer')",
                                                 prettySwitch("filter_transfer", "Only Non-Transferred Patients", status = "primary", value = FALSE, slim = TRUE)
                                ),
                                actionLink("shortcut_reset_filters", label = span(icon("ban"), i18n$t("Reset Enrolments Filters")))
                         ),
                         column(4,
                                div(class = "smallcaps", class = "text_center", span(icon("vial"), i18n$t("Specimens, Isolates"))),
                                prettyCheckboxGroup("filter_method_collection", NULL,  shape = "curve", status = "primary", inline = TRUE,
                                                    choiceNames = c("Blood Culture", "Other Specimens:"),
                                                    choiceValues = c("blood", "other_not_blood"),
                                                    selected = c("blood", "other_not_blood")),
                                conditionalPanel("input.filter_method_collection.includes('other_not_blood')",
                                                 pickerInput("filter_method_other", NULL, multiple = TRUE,
                                                             choices = "", selected = NULL,
                                                             options = list(`actions-box` = TRUE, `deselect-all-text` = "None...",
                                                                            `select-all-text` = "Select All", `none-selected-text` = "None Selected"))
                                ),
                                pickerInput("deduplication_method",
                                            choices = c("No deduplication of isolates", "Deduplication by patient-episode", "Deduplication by patient ID")
                                )
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
          )
      )
    )
    ),
    
    # Tab Welcome ----
    nav(i18n$t("Welcome"), value = "welcome",
        fluidRow(
          column(3,
                 uiOutput('site_logo'),
                 htmlOutput("app_github_versions"), br(),
                 pickerInput(
                   "selected_language", label = span(icon("language"), i18n$t("Language")),
                   choices = lang$val,
                   selected = "en",
                   choicesOpt = list(content = lang$img)
                 ),
                 div(id = "login-basic",
                     div(class = "well",
                         h5(class = "text_center",  i18n$t("Please log in")),
                         selectInput("cred_site", tagList(icon("hospital"), i18n$t("Site")),
                                     choices = code_sites),
                         conditionalPanel("input.cred_site != 'demo'", div(
                           textInput("cred_user", tagList(icon("user"), i18n$t("User")), placeholder = "enter user name"),
                           passwordInput("cred_password", tagList(icon("unlock-alt"), i18n$t("Password")), placeholder = "enter password")
                         )
                         ), 
                         div(class = "text_center",
                             actionButton("cred_login", label = i18n$t("Log in"), class = "btn-primary"),
                             div(em(i18n$t("To log out, close the app.")))
                         )
                     ),
                     span(i18n$t("or "), actionLink("direct_upload_acorn", i18n$t("upload a local acorn file.")))
                 )
          ),
          column(9,
                 fluidRow(
                   column(6,
                          conditionalPanel("input.selected_language != 'fr'",
                                           includeMarkdown("./www/markdown/about_acorn_en.md")
                          ),
                          conditionalPanel("input.selected_language == 'fr'",
                                           includeMarkdown("./www/markdown/about_acorn_fr.md")
                          )
                   ),
                   column(6,
                          h5(i18n$t("ACORN Participating Countries")),
                          span(img(src = "./images/Map-ACORN-Sites-Global.png", id = "map_sites")),
                          htmlOutput("twitter_feed")
                   )
                 )
          )
        )
    ),
    # Tab Data Management ----
    nav(span(icon("database"), i18n$t("Data Management")), value = "data_management",
        p(i18n$t("What do you want to do?")),
        div(class = "text_center",
            radioGroupButtons("choice_datamanagement", NULL,
                              choiceValues = c("generate", "load_cloud", "load_local", "info"),
                              choiceNames = choices_datamanagement,
                              selected = NULL, individual = TRUE,
                              checkIcon = list(yes = icon("hand-point-right")))
        ),
        hr(),
        ## Choice Generate ----
        conditionalPanel("input.choice_datamanagement == 'generate'",
                         div(
                           fluidRow(
                             column(4,    
                                    h5(i18n$t("(1/4) Download Clinical data")), p(i18n$t("and generate enrolment log.")),
                                    actionButton("get_redcap_data", i18n$t("Get data from REDCap"), icon = icon('cloud-download-alt'))
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
                                    h5(i18n$t("(2/4) Provide Lab data")),
                                    pickerInput("format_lab_data", 
                                                options = list(title = "Select lab data format"),
                                                # options = list(title = i18n$t("Select lab data format:")),
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
                                    h5(i18n$t("(3/4) Combine Clinical and Lab data")),
                                    actionButton("generate_acorn_data", i18n$t("Generate .acorn file"))
                             ),
                             column(8,
                                    htmlOutput("checklist_generate")
                             )
                           ),
                           hr(),
                           fluidRow(
                             column(4, 
                                    h5(i18n$t("(4/4) Save .acorn file")),
                                    tags$div(
                                      materialSwitch("save_switch", label = "Local", 
                                                     inline = TRUE, status = "primary", value = TRUE),
                                      tags$span(icon("cloud"), "Server"),
                                      conditionalPanel("! input.save_switch",
                                                       actionButton("save_acorn_local", i18n$t("Save .acorn file"))
                                      ),
                                      conditionalPanel("input.save_switch",
                                                       actionButton("save_acorn_server", span(icon('cloud-upload-alt'), i18n$t("Save .acorn file")))
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
        conditionalPanel("input.choice_datamanagement == 'load_cloud'",
                         fluidRow(
                           column(3,
                                  pickerInput('acorn_files_server', choices = NULL, label = NULL,
                                              options = pickerOptions(actionsBox = TRUE, noneSelectedText = "No file selected", liveSearch = FALSE,
                                                                      showTick = TRUE, header = "10 most recent files:"))
                           ),
                           column(9,
                                  conditionalPanel(condition = "input.acorn_files_server",
                                                   actionButton("load_acorn_server", span(icon("cloud-download-alt"), i18n$t("Load selected .acorn")))
                                  )
                           )
                         )
        ),
        ## Choice Load local ----
        conditionalPanel("input.choice_datamanagement == 'load_local'",
                         fileInput("load_acorn_local", label = NULL, buttonLabel =  i18n$t("Load .acorn"), accept = '.acorn')
        ),
        ## Choice Info ----
        conditionalPanel("input.choice_datamanagement == 'info'",
                         htmlOutput("info_data"),
        )
    ),
    # Tab Overview ----
    nav(i18n$t("Overview"), value = "overview", 
        fluidRow(
          column(6,
                 div(class = "box_outputs", 
                     h4_title(icon("calendar-check"), i18n$t("Date of Enrolment")),
                     div(class = "box_outputs_content",
                         prettySwitch("show_date_week", label = i18n$t("See by Week"), status = "primary"),
                         highchartOutput("profile_date_enrolment")
                     )
                 ),
                 div(class = "box_outputs",
                     h4_title(icon("tint"), i18n$t("Enrolments with Blood Culture")),
                     div(class = "box_outputs_content",
                         fluidRow(
                           column(6, flexdashboard::gaugeOutput("profile_blood_culture_gauge", width = "100%", height = "100px")),
                           column(6, htmlOutput("profile_blood_culture_pct", width = "100%", height = "100px"))
                         )
                     )
                 )
          ),
          column(6,
                 div(class = "box_outputs",
                     h4_title(i18n$t("Distribution of Enrolments")),
                     div(class = "box_outputs_content",
                         fluidRow(
                           column(3, i18n$t("Variables in Table:")),
                           column(9,
                                  checkboxGroupButtons("variables_table", label = NULL, 
                                                       size = "sm", status = "primary", checkIcon = list(yes = icon("check-square"), no = icon("square")), individual = TRUE,
                                                       choices = c("Place of Infection" = "surveillance_category", "Type of Ward" = "ward_type", "Ward" = "ward", "Clinical Outcome" = "clinical_outcome", "Day-28 Outcome" = "d28_outcome"), 
                                                       selected = c("surveillance_category", "ward_type", "ward", "clinical_outcome", "d28_outcome"))
                           )
                         ),
                         DT::DTOutput("table_patients", width = "95%")
                     )
                 )
          )
        ),
        fluidRow(
          column(6, 
                 div(class = "box_outputs",
                     h4_title(i18n$t("Enrolments by (type of) Ward")),
                     div(class = "box_outputs_content",
                         prettySwitch("show_ward_breakdown", label = i18n$t("See Breakdown by Ward"), status = "primary"),
                         highchartOutput("profile_type_ward")
                     )
                 )
          ),
          column(6, 
                 div(class = "box_outputs", h4_title(i18n$t("Patient Age Distribution")),
                     div(class = "box_outputs_content",
                         highchartOutput("profile_age")
                     )
                 )
          )
        ),
        fluidRow(
          column(6, 
                 div(class = "box_outputs",
                     h4_title(i18n$t("Diagnosis at Enrolment")),
                     div(class = "box_outputs_content",
                         highchartOutput("profile_diagnosis")
                     )
                 )
          ),
          column(6, 
                 div(class = "box_outputs",
                     h4_title(i18n$t("Empiric Antibiotics Prescribed")),
                     div(class = "box_outputs_content",
                         highchartOutput("profile_antibiotics")
                     )
                 )
          )
        ),
        fluidRow(
          column(6, 
                 div(class = "box_outputs",
                     h4_title(icon("arrows-alt-h"), i18n$t("Patients Transferred")),
                     div(class = "box_outputs_content",
                         highchartOutput("profile_transfer_hospital")
                     )
                 )
          ),
          column(6, 
                 div(class = "box_outputs",
                     h4_title(i18n$t("Patient Comorbidities")),
                     div(class = "box_outputs_content",
                         prettySwitch("comorbidities_combinations", label = i18n$t("Show comorbidities combinations"), status = "primary", value = FALSE, slim = TRUE),
                         highchartOutput("profile_comorbidities")
                     )
                 )
          )
        ),
        fluidRow(
          column(6, 
                 div(class = "box_outputs",
                     h4_title(i18n$t("Enrolments with Blood Culture")),
                     div(class = "box_outputs_content",
                         pickerInput("display_unit_ebc", label = NULL, 
                                     choices = c("Use heuristic for time unit", "Display by month", "Display by year")),
                         highchartOutput("enrolment_blood_culture")
                     )
                 )
          ),
          column(6, 
                 div(class = "box_outputs", h4_title(i18n$t("Blood culture collected within 24 hours of admission (CAI) / symptom onset (HAI)")),
                     div(class = "box_outputs_content",
                         highchartOutput("profile_blood")
                     )
                 )
          )
        )
    ),
    # Tab Follow-up ----
    nav(i18n$t("Follow-up"), value = "follow_up",
        fluidRow(
          column(6,
                 div(class = "box_outputs",
                     h4_title(i18n$t("Clinical Outcome")),
                     div(class = "box_outputs_content",
                         fluidRow(
                           column(6, flexdashboard::gaugeOutput("clinical_outcome_gauge", width = "100%", height = "100px")),
                           column(6, htmlOutput("clinical_outcome_pct", width = "100%", height = "70px"))
                         ),
                         h5(i18n$t("Clinical Outcome Status:")),
                         highchartOutput("clinical_outcome_status", height = "250px")
                     )
                 ),
          ),
          column(6,
                 div(class = "box_outputs",
                     h4_title(i18n$t("Day 28")),
                     div(class = "box_outputs_content",
                         fluidRow(
                           column(6, flexdashboard::gaugeOutput("d28_outcome_gauge", width = "100%", height = "100px")),
                           column(6, htmlOutput("d28_outcome_pct", width = "100%", height = "70px"))
                         ),
                         h5(i18n$t("Day 28 Status:")),
                         highchartOutput("d28_outcome_status", height = "250px")
                     )
                 )
          )
        ),
        fluidRow(
          column(4,
                 div(class = "box_outputs",
                     h4_title(i18n$t("Bloodstream Infection (BSI)")),
                     div(class = "box_outputs_content",
                         htmlOutput("bsi_summary")
                     )
                 )
          ),
          column(8, 
                 div(class = "box_outputs",
                     h4_title(i18n$t("Initial & Final Surveillance Diagnosis")),
                     div(class = "box_outputs_content",
                         i18n$t("The 10 most common initial-final diagnosis combinations:"),
                         highchartOutput("followup_outcome_clin_diag", height = "500px")
                     )
                 )
          )
        )
    ),
    # Tab HAI ----
    nav("HAI", value = "hai", 
        div(class = "box_outputs",
            h4_title(i18n$t("Ward Occupancy Rates")),
            div(class = "box_outputs_content",
                i18n$t("Occupancy rate per type of ward per month"),
                plotOutput("bed_occupancy_ward", width = "80%")
            )
        ),
        div(class = "box_outputs",
            h4_title(i18n$t("HAI Prevalence")),
            div(class = "box_outputs_content",
                i18n$t("HAI point prevalence by type of ward"),
                plotOutput("hai_rate_ward", width = "80%")
            )
        )
    ),
    # Tab Microbiology ----
    nav(i18n$t("Microbiology"), value = "microbiology", 
        prettySwitch("filter_rm_contaminant", label = i18n$t("Remove blood culture contaminants from the following visualizations"), status = "primary", value = FALSE, slim = TRUE),
        fluidRow(
          column(6,
                 div(class = "box_outputs",
                     h4_title(i18n$t("Blood Culture Contaminants")),
                     div(class = "box_outputs_content",
                         fluidRow(
                           column(6, flexdashboard::gaugeOutput("contaminants_gauge", width = "100%", height = "100px"), br()),
                           column(6, htmlOutput("contaminants_pct", width = "100%", height = "100px"))
                         )
                     )
                 ),
                 div(class = "box_outputs",
                     h4_title(i18n$t("Specimen Types")),
                     div(class = "box_outputs_content",
                         i18n$t("Number of specimens per specimen type"),
                         highchartOutput("culture_specimen_type", height = "400px"),
                         
                         i18n$t("Culture results per specimen type"),
                         highchartOutput("culture_specgroup", height = "350px")
                     )
                 )
          ),
          column(6,
                 div(class = "box_outputs",
                     h4_title(i18n$t("Growth / No Growth")),
                     div(class = "box_outputs_content",
                         fluidRow(
                           column(6, flexdashboard::gaugeOutput("isolates_growth_gauge", width = "100%", height = "100px"), br()),
                           column(6, htmlOutput("isolates_growth_pct", width = "100%", height = "100px"))
                         )
                     )
                 ),
                 div(class = "box_outputs",
                     h4_title(i18n$t("Isolates")),
                     div(class = "box_outputs_content",
                         i18n$t("Most frequent 10 organisms in the plot and complete listing in the table. Contaminants are in red."),
                         highchartOutput("isolates_organism_nc"),
                         highchartOutput("isolates_organism_contaminant"),
                         br(), br(),
                         DT::DTOutput("isolates_organism_table", width = "95%"),
                         br()
                     )
                 )
          )
        )
    ),
    # Tab AMR ----
    nav(span(icon("bug"), "AMR"), value = "amr", 
        fluidRow(
          column(3,
                 prettySwitch("combine_SI", i18n$t("Combine Susceptible + Intermediate"), status = "primary")
          ),
          column(8, offset = 1,
                 em(i18n$t("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable."))
          )
        ),
        tabsetPanel(
          nav(
            span(em("Acinetobacter"), " species"), 
            fluidRow(
              column(2,
                     br(), 
                     htmlOutput("nb_isolates_acinetobacter")
              ),
              column(10,
                     conditionalPanel(condition = "output.test_acinetobacter_sir",
                                      highchartOutput("acinetobacter_sir", height = "400px"),
                                      h4(i18n$t("Resistance to Carbapenems Over Time")),
                                      highchartOutput("acinetobacter_sir_evolution", height = "400px")
                     ),
                     conditionalPanel(condition = "! output.test_acinetobacter_sir", 
                                      h4(i18n$t("There is no data to display for this organism.")))
              )
            )
          ),
          nav(
            em("Escherichia coli"),
            fluidRow(
              column(2,
                     br(), 
                     htmlOutput("nb_isolates_ecoli")
              ),
              column(10,
                     conditionalPanel(condition = "output.test_ecoli_sir",
                                      highchartOutput("ecoli_sir", height = "500px"), br(), br(),
                                      h4(i18n$t("Resistance to Carbapenems Over Time")),
                                      highchartOutput("ecoli_sir_evolution", height = "400px"),
                                      h4(i18n$t("Resistance to 3rd gen. Cephalosporins Over Time")),
                                      highchartOutput("ecoli_sir_evolution_ceph", height = "400px")
                     ),
                     conditionalPanel(condition = "! output.test_ecoli_sir", 
                                      h4(i18n$t("There is no data to display for this organism.")))
              )
            )
          ),
          nav(
            em("Haemophilus influenzae"), 
            fluidRow(
              column(2,
                     br(), 
                     htmlOutput("nb_isolates_haemophilus_influenzae")
              ),
              column(10,
                     conditionalPanel(condition = "output.test_haemophilus_influenzae_sir",
                                      highchartOutput("haemophilus_influenzae_sir", height = "400px"),
                     ),
                     conditionalPanel(condition = "! output.test_haemophilus_influenzae_sir", 
                                      h4(i18n$t("There is no data to display for this organism.")))
              )
            )
          ),
          nav(
            em("Klebsiella pneumoniae"),
            fluidRow(
              column(2,
                     br(), 
                     htmlOutput("nb_isolates_kpneumoniae")
              ),
              column(10,
                     conditionalPanel(condition = "output.test_kpneumoniae_sir",
                                      highchartOutput("kpneumoniae_sir", height = "600px"), br(), br(),
                                      h4(i18n$t("Resistance to Carbapenems Over Time")),
                                      highchartOutput("kpneumoniae_sir_evolution", height = "400px"),
                                      h4(i18n$t("Resistance to 3rd gen. Cephalosporins Over Time")),
                                      highchartOutput("kpneumoniae_sir_evolution_ceph", height = "400px")
                     ),
                     conditionalPanel(condition = "! output.test_kpneumoniae_sir", 
                                      h4(i18n$t("There is no data to display for this organism.")))
              )
            )
          ),
          nav(
            em("Neisseria meningitidis"), 
            fluidRow(
              column(2,
                     br(), 
                     htmlOutput("nb_isolates_neisseria_meningitidis")
              ),
              column(10,
                     conditionalPanel(condition = "output.test_neisseria_meningitidis_sir",
                                      highchartOutput("neisseria_meningitidis_sir", height = "400px"),
                     ),
                     conditionalPanel(condition = "! output.test_neisseria_meningitidis_sir", 
                                      h4(i18n$t("There is no data to display for this organism.")))
              )
            )
          ),
          nav(
            em("Pseudomonas aeruginosa"), 
            fluidRow(
              column(2,
                     br(), 
                     htmlOutput("nb_isolates_pseudomonas_aeruginosa")
              ),
              column(10,
                     conditionalPanel(condition = "output.test_pseudomonas_aeruginosa_sir",
                                      highchartOutput("pseudomonas_aeruginosa_sir", height = "400px"),
                                      h4(i18n$t("Resistance to Carbapenems Over Time")),
                                      highchartOutput("pseudomonas_aeruginosa_sir_evolution", height = "400px")
                     ),
                     conditionalPanel(condition = "! output.test_pseudomonas_aeruginosa_sir", 
                                      h4(i18n$t("There is no data to display for this organism.")))
              )
            )
          ),
          nav(
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
                                      h4(i18n$t("Resistance to 3rd gen. Cephalosporins Over Time")),
                                      highchartOutput("salmonella_sir_evolution_ceph", height = "400px"),
                                      h4(i18n$t("Resistance to Fluoroquinolones Over Time")),
                                      highchartOutput("salmonella_sir_evolution_fluo", height = "400px")
                     ),
                     conditionalPanel(condition = "! output.test_salmonella_sir", 
                                      h4(i18n$t("There is no data to display for this organism.")))
              )
            )
          ),
          nav(
            em("Staphylococcus aureus"),
            fluidRow(
              column(2,
                     br(), 
                     htmlOutput("nb_isolates_saureus")
              ),
              column(10,
                     conditionalPanel(condition = "output.test_saureus_sir",
                                      highchartOutput("saureus_sir", height = "400px"),
                                      h4(i18n$t("Resistance to Oxacillin Over Time")),
                                      highchartOutput("saureus_sir_evolution", height = "400px")
                     ),
                     conditionalPanel(condition = "! output.test_saureus_sir", 
                                      h4(i18n$t("There is no data to display for this organism.")))
              )
            )
          ),
          nav(
            em("Streptococcus pneumoniae"),
            fluidRow(
              column(2,
                     br(),
                     htmlOutput("nb_isolates_spneumoniae")
              ),
              column(10,
                     conditionalPanel(condition = "output.test_spneumoniae_sir",
                                      highchartOutput("spneumoniae_sir", height = "400px"),
                                      h4(i18n$t("Resistance to Penicillin G Over Time")),
                                      highchartOutput("spneumoniae_sir_evolution_pen", height = "400px"),
                                      h4(i18n$t("Resistance to Penicillin G - meningitis Over Time")),
                                      highchartOutput("spneumoniae_sir_evolution_pen_men", height = "400px")
                     ),
                     conditionalPanel(condition = "! output.test_spneumoniae_sir", 
                                      h4(i18n$t("There is no data to display for this organism.")))
              )
            )
          ),
          nav(
            i18n$t("All Other Organisms"),
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
                     conditionalPanel(condition = "! output.test_other_sir", 
                                      h4(i18n$t("There is no data to display for this organism.")))
              )
            )
          )
        )
    ),
    nav_spacer(),
    nav_item(
      actionLink("show_faq", label = "FAQ")
    )
  )
)

# Definition of server ----
server <- function(input, output, session) {
  
  observeEvent(input$show_faq, {
    showModal(modalDialog(
      title = "Frequently Asked Questions",
      size = "l",
      easyClose = TRUE,
      includeMarkdown("./www/markdown/faq_acorn_en.md")
    ))
  })
  
  
  output$download_data_acorn_format <- downloadHandler(
    filename = glue("loaded.acorn"),
    content = function(file) {
      meta <- meta()
      redcap_hai_dta <- redcap_hai_dta()
      corresp_org_antibio <- corresp_org_antibio()
      lab_code <- lab_code()
      data_dictionary <- data_dictionary()
      
      ## Anonymised data ----
      redcap_f01f05_dta <- redcap_f01f05_dta() %>% mutate(patient_id = openssl::md5(patient_id))
      acorn_dta <- acorn_dta() %>% mutate(patient_id = openssl::md5(patient_id))
      lab_dta <- "only in ACORN 2.1"
      # lab_dta <- lab_dta() %>% filter(patid %in% redcap_f01f05_dta$patient_id) %>% mutate(patid = openssl::md5(patid))
      
      save(meta, redcap_f01f05_dta, redcap_hai_dta, lab_dta, acorn_dta, corresp_org_antibio, lab_code, data_dictionary,
           file = file)
    })
  
  
  output$download_data_excel_format <- downloadHandler(
    filename = glue("acorn_data_{format(Sys.time(), '%Y-%m-%d_%H%M')}.xlsx"),
    content = function(file) {
      writexl::write_xlsx(
        list(
          "meta" = meta() |> as.tibble(),
          "redcap_hai_dta" = redcap_hai_dta(),
          "corresp_org_antibio" = corresp_org_antibio(),
          # Not Tibbles:
          # "lab_code" = lab_code(), 
          # "data_dictionary" = data_dictionary(),
          
          ## Anonymised data ----
          "redcap_f01f05_dta" = redcap_f01f05_dta() %>% mutate(patient_id = openssl::md5(patient_id)),
          "acorn_dta" = acorn_dta() %>% mutate(patient_id = openssl::md5(patient_id)),
          "lab_data" = tibble("only in ACORN 2.1")
          # "lab_dta" = lab_dta() %>% filter(patid %in% redcap_f01f05_dta$patient_id) %>% mutate(patid = openssl::md5(patid))
          
        ), path = file)
    }
  )
  
  # Hide tabs on app launch ----
  nav_hide("tabs", target = "data_management")
  nav_hide("tabs", target = "overview")
  nav_hide("tabs", target = "follow_up")
  nav_hide("tabs", target = "hai")
  nav_hide("tabs", target = "microbiology")
  nav_hide("tabs", target = "amr")
  
  output$twitter_feed <- renderText({
    ifelse(!nzchar(Sys.getenv("SHINY_PORT")),
           HTML(glue("<div id='twitter_follow'><a href = 'https://twitter.com/ACORN_AMR' target='_blank'><i class='fab fa-twitter' role='presentation' aria-label='twitter icon'></i>{i18n$t('Follow us on Twitter')}, @ACORN_AMR</a></div>")),
           HTML("<a class='twitter-timeline' data-width='100%' data-height='700' data-theme='light' href='https://twitter.com/ACORN_AMR?ref_src=twsrc%5Etfw'>Tweets by ACORN_AMR</a> <script async src='https://platform.twitter.com/widgets.js' charset='utf-8'></script>")
    )
  })
  
  # Management of filters. ----
  observeEvent(input$shortcut_reset_filters, source("./www/R/reset_filter_enrolments.R", local = TRUE))
  
  observe({
    req(acorn_dta())
    if(! "Surveillance Category" %in% input$filter_enrolments)  source("./www/R/reset_filter_surveillance_cat.R", local = TRUE)
    if(! "Type of Ward" %in% input$filter_enrolments)  source("./www/R/reset_filter_ward_type.R", local = TRUE)
    if(! "Date of Enrolment/Survey" %in% input$filter_enrolments)  source("./www/R/reset_filter_date_enrolment.R", local = TRUE)
    if(! "Age Category" %in% input$filter_enrolments)  source("./www/R/reset_filter_age_cat.R", local = TRUE)
    if(! "Initial Diagnosis" %in% input$filter_enrolments)  source("./www/R/reset_filter_diagnosis_initial.R", local = TRUE)
    if(! "Final Diagnosis" %in% input$filter_enrolments)  source("./www/R/reset_filter_diagnosis_final.R", local = TRUE)
    if(! "Clinical Severity" %in% input$filter_enrolments)  source("./www/R/reset_filter_clinical_severity.R", local = TRUE)
    if(! "Clinical/D28 Outcome" %in% input$filter_enrolments)  source("./www/R/reset_filter_outcome.R", local = TRUE)
    if(! "Transfer" %in% input$filter_enrolments)  source("./www/R/reset_filter_transfer.R", local = TRUE)
  })
  
  # Source files with code to generate outputs ----
  file_list <- list.files(path = "./www/R/outputs", pattern = "*.R", recursive = TRUE)
  for (file in file_list) source(paste0("./www/R/outputs/", file), local = TRUE)$value
  
  # Multi-language ----
  # translation of radioGroupButtons - https://github.com/Appsilon/shiny.i18n/issues/54
  i18n_r <- reactive(i18n)  # translation of radioGroupButtons 1/3
  
  # live language change on the browser side
  observeEvent(input$selected_language, {
    update_lang(session, input$selected_language)
    i18n_r()$set_translation_language(input$selected_language) # translation of radioGroupButtons 2/3
    
    if (isTRUE(input$selected_language != "la"))  session$setCurrentTheme(acorn_theme)
    if (isTRUE(input$selected_language == "la"))  session$setCurrentTheme(acorn_theme_la)
  })
  
  # translation of radioGroupButtons 3/3
  observe({
    updateRadioGroupButtons(session = session, "choice_datamanagement", NULL,
                            choiceValues = c("generate", "load_cloud", "load_local", "info"),
                            choiceNames = i18n_r()$t(choices_datamanagement),
                            selected = NULL, status = "success",
                            checkIcon = list(yes = icon("hand-point-right")))
  })
  
  # allow to upload acorn file and not being logged
  observeEvent(input$direct_upload_acorn, {
    nav_show("tabs", target = "data_management", select = TRUE)
    
    updateRadioGroupButtons(session = session, "choice_datamanagement", i18n$t("What do you want to do?"),
                            choiceNames = i18n_r()$t(choices_datamanagement[3]),
                            choiceValues = "load_local",
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
    
    redcap_f01f05_status       = list(status = "hidden", msg = ""),
    redcap_columns             = list(status = "hidden", msg = ""),
    redcap_F04F01              = list(status = "hidden", msg = ""),
    redcap_F03F02              = list(status = "hidden", msg = ""),
    redcap_F02F01              = list(status = "hidden", msg = ""),
    redcap_F03F01              = list(status = "hidden", msg = ""),
    redcap_multiple_F02        = list(status = "hidden", msg = ""),
    redcap_consistent_outcomes = list(status = "hidden", msg = ""),
    redcap_missing_acorn_id    = list(status = "hidden", msg = ""),
    redcap_age_category        = list(status = "hidden", msg = ""),
    redcap_hai_status          = list(status = "hidden", msg = ""),
    
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
                                 fun_filter_specimen(input = input))
  
  # Enrolment log
  enrolment_log <- reactive({
    req(redcap_f01f05_dta())
    
    left_join(redcap_f01f05_dta(),
              redcap_f01f05_dta() %>% 
                group_by(redcap_id) %>%  # one acorn_id/redcap_id per enrolment but some acorn_id are missing so we prefer to group by redcap_id
                summarise(expected_d28_date = max(date_episode_enrolment) + 28, .groups = "drop"),
              by = "redcap_id") %>%
      transmute("Category" = surveillance_category,
                "Patient ID" = patient_id, 
                "ACORN ID" = acorn_id,
                "Date of admission" = date_admission, 
                "Infection Episode" = episode_count,
                "Date of episode enrolment" = date_episode_enrolment, 
                "Discharge date" = ho_discharge_date, 
                "Discharge status" = ho_discharge_status,
                "Expected Day-28 date" =  expected_d28_date,
                "Actual Day-28 date" = d28_date)
  })
  
  output$enrolment_log_table <- renderUI({
    req(enrolment_log())
    req(acorn_origin() == "generated")
    DT::DTOutput("table_enrolment_log")
  })
  
  output$enrolment_log_dl <- renderUI({
    req(enrolment_log())
    req(acorn_origin() == "generated")
    tagList(
      br(), br(), br(),
      downloadButton("download_enrolment_log", i18n$t("Download Enrolment Log (.xlsx)")),
      p(i18n$t("First sheet is the log of all enrolments retrived from REDCap (as per adjacent table). The second sheet is a listing of all flagged elements."))
    )
  })
  
  # On login ----
  observeEvent(input$cred_login, {
    id <- notify(i18n$t("Attempting to connect."))
    on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
    
    if (input$cred_site == "demo") {
      # The demo should work offline
      cred <- readRDS("./www/cred/bucket_site/encrypted_cred_demo.rds")
      key_user <- openssl::sha256(charToRaw("demo"))
      cred <- unserialize(openssl::aes_cbc_decrypt(cred, key = key_user))
      
      if(cred$site != input$cred_site)  {
        showNotification(i18n$t("Problem with credentials. Please contact ACORN support."), 
                         duration = 20, type = "error")
        return()
      }
      
      acorn_cred(cred)
      notify(i18n$t("Successfully logged in."), id = id)
    }
    
    if (input$cred_site != "demo") {
      file_cred <- glue("encrypted_cred_{tolower(input$cred_site)}_{input$cred_user}.rds")
      # Stop if the connection can't be established
      connect <- try(aws.s3::get_bucket(bucket = "shared-acornamr", 
                                        key    = shared_acornamr_key,
                                        secret = shared_acornamr_sec,
                                        region = "eu-west-3") %>% unlist(),
                     silent = TRUE)
      
      if (inherits(connect, 'try-error')) {
        showNotification(i18n$t("Couldn't connect to server. Please check internet access."), type = "error")
        return()
      }
      
      # Test if credentials for this user name exist
      if (! file_cred %in% as.vector(connect[names(connect) == "Contents.Key"])) {
        showNotification(i18n$t("Wrong connection credentials."), type = "error")
        return()
      }
      
      # I can't find a way to pass those credentials directly in s3read_using()
      Sys.setenv("AWS_ACCESS_KEY_ID" = shared_acornamr_key,
                 "AWS_SECRET_ACCESS_KEY" = shared_acornamr_sec,
                 "AWS_DEFAULT_REGION" = "eu-west-3")
      
      cred <- try(aws.s3::s3read_using(FUN = read_encrypted_cred, 
                                       pwd = input$cred_password,
                                       object = file_cred,
                                       bucket = "shared-acornamr"),
                  silent = TRUE)
      
      if (inherits(cred, 'try-error')) {
        showNotification(i18n$t("Wrong connection credentials."), type = "error")
        return()
      }
      
      # remove AWS environment variables
      Sys.unsetenv("AWS_ACCESS_KEY_ID")
      Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
      Sys.unsetenv("AWS_DEFAULT_REGION")
      
      acorn_cred(cred)
      notify(i18n$t("Successfully logged in."), id = id)
    }
    
    nav_show("tabs", target = "data_management", select = TRUE)
    
    updateRadioGroupButtons(session = session, "choice_datamanagement", i18n$t("What do you want to do?"),
                            choiceValues = c("generate", "load_cloud", "load_local", "info"),
                            choiceNames = i18n_r()$t(choices_datamanagement),
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
    
    nav_hide("tabs", target = "overview")
    nav_hide("tabs", target = "follow_up")
    nav_hide("tabs", target = "hai")
    nav_hide("tabs", target = "microbiology")
    nav_hide("tabs", target = "amr")
    
    # Connect to AWS S3 server ----
    if(acorn_cred()$acorn_s3) {
      
      connect_server_test <- aws.s3::bucket_exists(
        bucket = acorn_cred()$acorn_s3_bucket,
        key =  acorn_cred()$acorn_s3_key,
        secret = acorn_cred()$acorn_s3_secret,
        region = acorn_cred()$acorn_s3_region)[1]
      
      if(connect_server_test) {
        # Update select list with .acorn files on the server
        dta <- aws.s3::get_bucket(bucket = acorn_cred()$acorn_s3_bucket,
                                  key =  acorn_cred()$acorn_s3_key,
                                  secret = acorn_cred()$acorn_s3_secret,
                                  region = acorn_cred()$acorn_s3_region) %>%
          unlist()
        acorn_dates <- as.vector(dta[names(dta) == 'Contents.LastModified'])
        ord_acorn_dates <- order(as.POSIXct(acorn_dates))
        acorn_files <- rev(tail(as.vector(dta[names(dta) == 'Contents.Key'])[ord_acorn_dates], 20))  # 20 because of .acorn_non_anonymised
        
        if(! is.null(acorn_files)) { acorn_files <- acorn_files[endsWith(acorn_files, ".acorn")] }
        if(! is.null(acorn_files)) { updatePickerInput(session, 'acorn_files_server', choices = acorn_files, selected = acorn_files[1]) }
      }
    }
  })
  
  # On "Load .acorn" file from server ----
  observeEvent(input$load_acorn_server, {
    id <- notify(i18n$t("Loading data."))
    on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
    
    acorn_file <- aws.s3::get_object(object = input$acorn_files_server, 
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
    notify(i18n$t("Successfully loaded data."), id = id)
    on_acorn_load(session)
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
    notify(i18n$t("Successfully loaded data."), id = id)
    on_acorn_load(session)
  })
  
  # On "Get Clinical Data from REDCap server" ----
  observeEvent(input$get_redcap_data, {
    continue <<- TRUE
    
    if(input$cred_site == "demo") {
      showNotification(i18n$t("Can't connect to REDCap with 'demo' credentials"), type = "error")
      continue <<- FALSE
      fail_read_redcap  <<- FALSE
    }
    
    if (!has_internet()) {
      showNotification(i18n$t("Not connected to internet."), type = "error")
      continue <<- FALSE
      fail_read_redcap  <<- FALSE
    }
    
    if (continue) {
      showModal(modalDialog(
        title = i18n$t("Retriving data from REDCap server."), footer = modalButton(i18n$t("Dismiss")), size = "l",
        div(
          p(i18n$t("It might take a couple of minutes. This window will close on completion.")),
          textOutput("text_redcap_f01f05_log"),
          textOutput("text_redcap_hai_log")
        )
      ))
      fail_read_redcap  <<- FALSE
      source("./www/R/data/01_read_redcap_f01f05.R", local = TRUE)
      
      # Case when REDCap log "CRITICAL ERROR: REDCap server is offline!" and also returns an empty dataframe.
      if (!fail_read_redcap) {
        if (is_empty(dl_redcap_f01f05_dta))  fail_read_redcap  <<- TRUE
      }
      
      if(fail_read_redcap) {
        shinyjs::html(id = "text_redcap_f01f05_log", i18n$t("Issue detected with REDCap data. Please report to ACORN data managers. Until resolution, only existing .acorn files can be used."), add = TRUE)
        checklist_status$redcap_f01f05_status <- list(status = "ko", msg = i18n$t("The REDCap dataset is empty/in wrong format. Please contact ACORN support."))
        continue <<- FALSE
      }
    }
    
    if (continue) {
      if (!fail_read_redcap) {
        if(nrow(dl_redcap_f01f05_dta) == 0 | ncol(dl_redcap_f01f05_dta) != 211 & ! all(names(dl_redcap_f01f05_dta) == columns_redcap)) {
          shinyjs::html(id = "text_redcap_f01f05_log", i18n$t("Issue detected with REDCap data. Please report to ACORN data managers. Until resolution, only existing .acorn files can be used."), add = TRUE)
          checklist_status$redcap_f01f05_status <- list(status = "ko", msg = i18n$t("The REDCap dataset is empty/in wrong format. Please contact ACORN support."))
          continue <<- FALSE
        }
      }
    }
    
    if(continue) { 
      shinyjs::html(id = "text_redcap_f01f05_log", "<hr/>", add = TRUE)
      checklist_status$redcap_f01f05_status <- list(status = "okay", msg = i18n$t("The REDCap dataset is in the right format."))
      source("./www/R/data/02_process_redcap_f01f05.R", local = TRUE)
    }
    
    if(continue) {
      source("./www/R/data/01_read_redcap_hai.R", local = TRUE)
    }
    
    # Case when REDCap log "CRITICAL ERROR: REDCap server is offline!" and also returns an empty dataframe.
    if(continue) {
      if (!fail_read_redcap) {
        if (is_empty(dl_hai_dta))  fail_read_redcap  <<- TRUE
      }
      
      if(fail_read_redcap) {
        shinyjs::html(id = "text_redcap_f01f05_log", i18n$t("Issue detected with REDCap data. Please report to ACORN data managers. Until resolution, only existing .acorn files can be used."), add = TRUE)
        checklist_status$redcap_hai_status <- list(status = "warning", msg = i18n$t("There is no HAI survey data"))
      }
      
      source("./www/R/data/02_process_redcap_hai.R", local = TRUE)
      
      ifelse(any(c(checklist_status$redcap_F04F01$status,
                   checklist_status$redcap_F03F02$status,
                   checklist_status$redcap_F02F01$status,
                   checklist_status$redcap_F03F01$status,
                   checklist_status$redcap_consistent_outcomes$status,
                   checklist_status$redcap_age_category$status) == "ko"),
             {
               checklist_status$redcap_f01f05_dta <- list(status = "ko", msg = i18n$t("Critical errors with clinical data."))
               showNotification(i18n$t("There is a critical issue with clinical data. The issue should be fixed in REDCap."), type = "error", duration = NULL)
               continue <<- FALSE
             },
             {
               checklist_status$redcap_f01f05_dta <- list(status = "okay", msg = i18n$t(("Clinical data successfully provided."))) 
             }
      )
    }
    
    if(continue) {
      redcap_f01f05_dta(infection)
      redcap_hai_dta(dl_hai_dta)
      acorn_origin("generated")
      removeModal()
    }
  })
  
  # On "Download Enrolment Log" ----
  output$download_enrolment_log <- downloadHandler(
    filename = glue("enrolment_log_{format(Sys.time(), '%Y-%m-%d_%H%M')}.xlsx"),
    content = function(file)  writexl::write_xlsx(
      list(
        "Enrolment Log" = enrolment_log(),
        "Errors Log" = checklist_status$log_errors
      ), path = file)
  )
  
  
  # On "Provide Lab data" ----
  observeEvent(c(input$file_lab_tab, input$file_lab_dba, input$file_lab_sql), 
               {
                 id <- notify(i18n$t("Reading lab data."))
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
                 
                 notify(i18n$t("Processing lab data."), id = id)
                 source("./www/R/data/03_map_variables.R", local = TRUE)
                 source("./www/R/data/04_map_specimens.R", local = TRUE)
                 source("./www/R/data/05_map_organisms.R", local = TRUE)
                 source("./www/R/data/06_make_ast_group.R", local = TRUE)
                 source("./www/R/data/07_ast_interpretation.R", local = TRUE)
                 source("./www/R/data/08_ast_interpretation_nonstandard.R", local = TRUE)
                 source("./www/R/data/09_checklist_lab.R", local = TRUE)
                 
                 lab_dta(amr)
                 notify(i18n$t("Lab data successfully processed!"), id = id)
               })
  
  # On "Generate ACORN" ----
  observeEvent(input$generate_acorn_data, {
    id <- notify(i18n$t("Generating .acorn"))
    on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
    
    if(checklist_status$redcap_f01f05_dta$status != "okay" | checklist_status$lab_dta$status != "okay") {
      notify(i18n$t("Supply first valid clinical and lab data."), type = "error", id = id)
      return()
    }
    
    source("./www/R/data/10_link_clinical_assembly.R", local = TRUE)
    
    acorn_dta(acorn_dta)
    source('./www/R/update_input_widgets.R', local = TRUE)
    
    notify(i18n$t(".acorn data successfully generated!"), id = id)
    checklist_status$acorn_dta_saved = list(status = "warning", msg = i18n$t(".acorn not saved."))
  })
  
  # On "Save ACORN" on server ----
  observeEvent(input$save_acorn_server, { 
    if(checklist_status$linkage_result$status != "okay") {
      showNotification(i18n$t("No .acorn data loaded."), type = "error", duration = 10)
      return()
    }
    
    if(! has_internet()) {
      showNotification(i18n$t("Not connected to internet."), type = "error", duration = 10)
      return()
    }
    
    showModal(modalDialog(
      title = i18n$t("Save acorn data"), footer = modalButton(i18n$t("Cancel")), size = "m", easyClose = FALSE, fade = TRUE,
      div(
        textInput("name_file", value = glue("{input$cred_site}_{session_start_time}"), label = i18n$t("File name:")),
        textAreaInput("meta_acorn_comment", label = i18n$t("(Optional) Comments:"), value = "There are no comments."),
        br(), br(),
        actionButton("save_acorn_server_confirm", label = i18n$t("Save on Server"))
      )
    ))
  })
  
  # On "Save ACORN" as a local file ----
  observeEvent(input$save_acorn_local, { 
    if(checklist_status$linkage_result$status != "okay") {
      showNotification(i18n$t("No .acorn data loaded."), type = "error", duration = 10)
      return()
    }
    
    showModal(modalDialog(
      title = "Save acorn data", footer = modalButton("Cancel"), size = "m", easyClose = FALSE, fade = TRUE,
      div(
        textInput("name_file_dup", value = glue("{input$cred_site}_{session_start_time}"), label = i18n$t("File name:")),
        textAreaInput("meta_acorn_comment_dup", label = i18n$t("(Optional) Comments:"), value = "There are no comments."),
        br(), br(),
        downloadButton("save_acorn_local_confirm", label = "Save")
      )
    ))
  })
  
  
  observeEvent(input$save_acorn_server_confirm, { 
    # On confirmation that the file is being saved on server ----
    
    removeModal()
    id <- notify(i18n$t("Trying to save .acorn file on server."))
    on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
    
    ## Common to anonymised and non-anonymised. ----
    meta <- list(time_generation = session_start_time,
                 app_version = app_version,
                 site = input$cred_site,
                 user = input$cred_user,
                 comment = input$meta_acorn_comment)
    meta(meta)
    
    redcap_hai_dta <- redcap_hai_dta()
    corresp_org_antibio <- corresp_org_antibio()
    lab_code <- lab_code()
    data_dictionary <- data_dictionary()
    
    ## Anonymised data ----
    redcap_f01f05_dta <- redcap_f01f05_dta() %>% mutate(patient_id = openssl::md5(patient_id))
    acorn_dta <- acorn_dta() %>% mutate(patient_id = openssl::md5(patient_id))
    lab_dta <- lab_dta() %>% filter(patid %in% redcap_f01f05_dta$patient_id) %>% mutate(patid = openssl::md5(patid))
    
    name_file <- glue("{input$name_file}.acorn")
    file <- file.path(tempdir(), name_file)
    save(meta, redcap_f01f05_dta, redcap_hai_dta, lab_dta, acorn_dta, corresp_org_antibio, lab_code, data_dictionary,
         file = file)
    
    aws.s3::put_object(file = file,
                       object = name_file,
                       bucket = acorn_cred()$acorn_s3_bucket,
                       key =  acorn_cred()$acorn_s3_key,
                       secret = acorn_cred()$acorn_s3_secret,
                       region = acorn_cred()$acorn_s3_region)
    
    ## Non anonymised data ----
    redcap_f01f05_dta <- redcap_f01f05_dta()
    acorn_dta <- acorn_dta()
    lab_dta <- lab_dta() %>% filter(patid %in% redcap_f01f05_dta$patient_id) 
    
    name_file <- glue("{input$name_file}.acorn_non_anonymised")
    file <- file.path(tempdir(), name_file)
    save(meta, redcap_f01f05_dta, redcap_hai_dta, lab_dta, acorn_dta, corresp_org_antibio, lab_code, data_dictionary,
         file = file)
    
    aws.s3::put_object(file = file,
                       object = name_file,
                       bucket = acorn_cred()$acorn_s3_bucket,
                       key =  acorn_cred()$acorn_s3_key,
                       secret = acorn_cred()$acorn_s3_secret,
                       region = acorn_cred()$acorn_s3_region)
    
    ## Update list of files to load ----
    dta <- aws.s3::get_bucket(bucket = acorn_cred()$acorn_s3_bucket,
                              key =  acorn_cred()$acorn_s3_key,
                              secret = acorn_cred()$acorn_s3_secret,
                              region = acorn_cred()$acorn_s3_region) |> 
      unlist()
    acorn_dates <- as.vector(dta[names(dta) == 'Contents.LastModified'])
    ord_acorn_dates <- order(as.POSIXct(acorn_dates))
    acorn_files <- rev(tail(as.vector(dta[names(dta) == 'Contents.Key'])[ord_acorn_dates], 20))  # 20 because of .acorn_non_anonymised
    acorn_files <- acorn_files[endsWith(acorn_files, ".acorn")]
    
    updatePickerInput(session, 'acorn_files_server', choices = acorn_files, selected = acorn_files[1])
    
    
    ## Switch to analysis ----
    checklist_status$acorn_dta_saved_server <- list(status = "okay", msg = i18n$t(".acorn file saved on server."))
    notify(i18n$t("Successfully saved .acorn file in the cloud. You can now explore acorn data."), id = id)
    on_acorn_load(session)
  })
  
  
  
  output$save_acorn_local_confirm <- downloadHandler(
    # On confirmation that the file is being saved locally ----
    filename = glue("{input$name_file_dup}.acorn"),
    content = function(file) {
      removeModal()
      
      ## Common to anonymised and non-anonymised. ----
      meta <- list(time_generation = session_start_time,
                   app_version = app_version,
                   site = input$cred_site,
                   user = input$cred_user,
                   comment = input$meta_acorn_comment_dup)
      meta(meta)
      
      redcap_hai_dta <- redcap_hai_dta()
      corresp_org_antibio <- corresp_org_antibio()
      lab_code <- lab_code()
      data_dictionary <- data_dictionary()
      
      ## Anonymised data ----
      redcap_f01f05_dta <- redcap_f01f05_dta() %>% mutate(patient_id = openssl::md5(patient_id))
      acorn_dta <- acorn_dta() %>% mutate(patient_id = openssl::md5(patient_id))
      lab_dta <- lab_dta() %>% filter(patid %in% redcap_f01f05_dta$patient_id) %>% mutate(patid = openssl::md5(patid))
      
      save(meta, redcap_f01f05_dta, redcap_hai_dta, lab_dta, acorn_dta, corresp_org_antibio, lab_code, data_dictionary,
           file = file)
      
      checklist_status$acorn_dta_saved_local <- list(status = "okay", msg = i18n$t("Successfully saved .acorn file locally."))
      showNotification(i18n$t("Successfully saved .acorn file locally."), duration = 5)
      on_acorn_load(session)
      
      if(checklist_status$acorn_dta_saved_server$status != "okay")  {
        checklist_status$acorn_dta_saved_server <- list(status = "warning", msg = i18n$t("Consider saving .acorn file on the cloud for additional security."))
      }
    })
}

shinyApp(ui = ui, server = server)  # port 3872
