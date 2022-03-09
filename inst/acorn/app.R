# ACORN shiny app main script
source('./www/R/startup.R', local = TRUE)

# Definition of UI ----
ui <- page(
  theme = acorn_theme,
  includeCSS("www/styles.css"),
  usei18n(i18n),  # for translation
  shinyjs::useShinyjs(),
  div(id = "loading_page"),
  shinyjs::hidden(
    div(
      id = "content",
      page_navbar(
        title = a(img(src = "logo_acorn.png", style = "height: 45px; position: relative;")),
        id = "tabs",
        selected = "welcome",
        window_title = "ACORN | A Clinically Oriented antimicrobial Resistance Network",
        collapsible = TRUE, inverse = FALSE, 
        position = "static-top",
        
        header = div(conditionalPanel(
          condition = "input.tabs != 'welcome' & input.tabs != 'data_management'",
          uiOutput("quick_access"),
          div(id = "header-filter",
              fluidRow(
                column(12,
                       div(id = "filter_box", class = "well",
                           fluidRow(
                             column(6,
                                    div(class = "smallcaps", class = "text_center", span(icon("hospital-user"), i18n$t("Enrolments"))),
                                    checkboxGroupButtons("filter_enrolments",
                                                         choices = c("Surveillance Category", "Type of Ward", "Ward Name", "Date of Enrolment/Survey", "Age Category",
                                                                     "Initial Diagnosis", "Final Diagnosis", "Clinical Severity", "uCCI", "Clinical/D28 Outcome",
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
                                    conditionalPanel("input.filter_enrolments.includes('Ward Name')",
                                                     pickerInput("filter_ward_name", NULL, choices = NULL, selected = NULL, options = list(`actions-box` = TRUE), multiple = TRUE)
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
                                    conditionalPanel("input.filter_enrolments.includes('uCCI')",
                                                     sliderInput("filter_uCCI", "Updated Charlson Comorbidity Index (only adults)", min = 0, max = 24, value = c(0, 24))
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
                             column(3,
                                    div(class = "smallcaps", class = "text_center", span(icon("vial"), i18n$t("Specimens"))),
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
                                    prettySwitch("filter_not_cultured", label = i18n$t("Remove 'Not Cultured' specimens"), status = "primary", value = FALSE, slim = TRUE)
                             ),
                             column(3,
                                    div(class = "smallcaps", class = "text_center",  span(icon("bacterium"), i18n$t("Isolates"))),
                                    pickerInput("deduplication_method",
                                                choices = c("No deduplication of isolates", "Deduplication by patient-episode", "Deduplication by patient ID")
                                    )
                             )
                           )
                       )
                )
              ),
              fluidRow(
                column(3, htmlOutput("nb_enrolments")),
                column(3, htmlOutput("nb_patients_microbiology")),
                column(3, htmlOutput("nb_specimens")),
                column(3, htmlOutput("nb_isolates_growth"), htmlOutput("nb_isolates_target"))
              )
          )
        )
        ),
        # Tab Welcome ----
        nav(i18n$t("Welcome"), value = "welcome",
            fluidRow(
              column(3,
                     uiOutput("site_logo"),
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
                             div(class = "text-center", i18n$t("(To log out, close the app.)")),
                             pickerInput("cred_site", "", choices = code_sites, selected = "Run Demo"),
                             conditionalPanel("input.cred_site != 'Run Demo' && input.cred_site != 'Upload Local .acorn'", div(
                               textInput("cred_user", tagList(icon("user"), i18n$t("User")), placeholder = "enter user name"),
                               passwordInput("cred_password", tagList(icon("unlock-alt"), i18n$t("Password")), placeholder = "enter password")
                             )
                             ), 
                             div(class = "text_center",
                                 actionButton("cred_login", label = i18n$t("Log in"), class = "btn-primary")
                             )
                         )
                     )
              ),
              column(9,
                     fluidRow(
                       column(6,
                              conditionalPanel("input.selected_language != 'fr' & input.selected_language != 'kh' & input.selected_language != 'vn'",
                                               includeMarkdown("./www/markdown/about_acorn_en.md")),
                              conditionalPanel("input.selected_language == 'fr'", includeMarkdown("./www/markdown/about_acorn_fr.md")),
                              conditionalPanel("input.selected_language == 'vn'", includeMarkdown("./www/markdown/about_acorn_vn.md")),
                              conditionalPanel("input.selected_language == 'kh'", includeMarkdown("./www/markdown/about_acorn_kh.md"))
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
            
            navs_pill_card(id = "data_management_tabs",
                     nav(title = i18n$t("Generate and load .acorn from clinical and lab data"), value = "generate",
                         br(),
                         fluidRow(
                           column(3,    
                                  h5(i18n$t("(1/4) Download Clinical data")), p(i18n$t("and generate enrolment log.")),
                                  actionButton("get_redcap_data", i18n$t("Get data from REDCap"), icon = icon('cloud-download-alt'))
                           ),
                           column(6,
                                  htmlOutput("checklist_qc_clinical")
                           ),
                           column(3,
                                  uiOutput("enrolment_log_dl")
                           )
                         ),
                         fluidRow(column(9, offset = 3, br(), uiOutput("enrolment_log_table"))),
                         hr(),
                         fluidRow(
                           column(3,
                                  h5(i18n$t("(2/4) Provide Lab data")),
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
                           column(6,
                                  htmlOutput("checklist_qc_lab")
                           ),
                           column(3,
                                  uiOutput("lab_log_dl")
                           )
                         ),
                         hr(),
                         fluidRow(
                           column(3, 
                                  h5(i18n$t("(3/4) Combine Clinical and Lab data")),
                                  actionButton("generate_acorn_data", i18n$t("Generate .acorn file"))
                           ),
                           column(6,
                                  htmlOutput("checklist_generate")
                           )
                         ),
                         hr(),
                         fluidRow(
                           column(3, 
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
                     ),
                     nav(title = i18n$t("Load .acorn from cloud"), value = "load_cloud",
                         br(),
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
                     nav(title = i18n$t("Load .acorn from local file"), value = "load_local",
                         br(),
                         fileInput("load_acorn_local", label = NULL, buttonLabel =  i18n$t("Load .acorn"), accept = '.acorn')
                     ),
                     nav(title = i18n$t("Info on loaded .acorn"),  value = "info",
                         br(),
                         htmlOutput("info_data")
                     )
            )
        ),
        # Tab Overview ----
        nav(i18n$t("Overview"), value = "overview", 
            fluidRow(
              column(6,
                     HTML("<span id='anchor_101'></span>"),
                     div(class = "box_outputs", 
                         h4_title(icon("calendar-check"), i18n$t("Date of Enrolment")),
                         div(class = "box_outputs_content",
                             prettySwitch("show_date_week", label = i18n$t("See by Week"), status = "primary"),
                             highchartOutput("profile_date_enrolment")
                         )
                     ),
                     HTML("<span id='anchor_103'></span>"),
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
                     HTML("<span id='anchor_102'></span>"),
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
                     HTML("<span id='anchor_104'></span>"),
                     div(class = "box_outputs",
                         h4_title(i18n$t("Enrolments by (type of) Ward")),
                         div(class = "box_outputs_content",
                             prettySwitch("show_ward_breakdown", label = i18n$t("See Breakdown by Ward"), status = "primary"),
                             highchartOutput("profile_type_ward")
                         )
                     )
              ),
              column(6, 
                     HTML("<span id='anchor_105'></span>"),
                     div(class = "box_outputs", h4_title(i18n$t("Patient Age Distribution")),
                         div(class = "box_outputs_content",
                             highchartOutput("profile_age")
                         )
                     )
              )
            ),
            fluidRow(
              column(6, 
                     HTML("<span id='anchor_106'></span>"),
                     div(class = "box_outputs",
                         h4_title(i18n$t("Diagnosis at Enrolment")),
                         div(class = "box_outputs_content",
                             highchartOutput("profile_diagnosis", height = "500px")
                         )
                     )
              ),
              column(6, 
                     HTML("<span id='anchor_107'></span>"),
                     div(class = "box_outputs",
                         h4_title(i18n$t("Empiric Antibiotics Prescribed")),
                         div(class = "box_outputs_content",
                             prettySwitch("antibiotics_combinations", label = i18n$t("Show antibiotics combinations"), status = "primary", value = FALSE, slim = TRUE),
                             highchartOutput("profile_antibiotics", height = "500px")
                         )
                     )
              )
            ),
            fluidRow(
              column(6, 
                     HTML("<span id='anchor_108'></span>"),
                     div(class = "box_outputs",
                         h4_title(i18n$t("Updated Charlson Comorbidity Index (uCCI)")),
                         div(class = "box_outputs_content",
                             highchartOutput("profile_ucci", height = "300px")
                         )
                     ),
                     HTML("<span id='anchor_110'></span>"),
                     div(class = "box_outputs",
                         h4_title(icon("arrows-alt-h"), i18n$t("Patients Transferred")),
                         div(class = "box_outputs_content",
                             highchartOutput("profile_transfer_hospital", height = "200px")
                         )
                     )
              ),
              column(6, 
                     HTML("<span id='anchor_109'></span>"),
                     div(class = "box_outputs",
                         h4_title(i18n$t("Patient Comorbidities")),
                         div(class = "box_outputs_content",
                             prettySwitch("comorbidities_combinations", label = i18n$t("Show comorbidities combinations"), status = "primary", value = FALSE, slim = TRUE),
                             highchartOutput("profile_comorbidities", height = "500px")
                         )
                     )
              )
            ),
            fluidRow(
              column(6, 
                     HTML("<span id='anchor_111'></span>"),
                     div(class = "box_outputs",
                         h4_title(i18n$t("Enrolments with Blood Culture")),
                         a(id = "anchor_bcc", style = "visibility: hidden", ""),
                         div(class = "box_outputs_content",
                             pickerInput("display_unit_ebc", label = NULL, 
                                         choices = c("Use heuristic for time unit", "Display by month", "Display by year")),
                             highchartOutput("enrolment_blood_culture")
                         )
                     )
              ),
              column(6, 
                     HTML("<span id='anchor_112'></span>"),
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
                     HTML("<span id='anchor_201'></span>"),
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
                     HTML("<span id='anchor_202'></span>"),
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
                     HTML("<span id='anchor_203'></span>"),
                     div(class = "box_outputs",
                         h4_title(i18n$t("Bloodstream Infection (BSI)")),
                         div(class = "box_outputs_content",
                             htmlOutput("bsi_summary")
                         )
                     )
              ),
              column(8, 
                     HTML("<span id='anchor_204'></span>"),
                     div(class = "box_outputs",
                         h4_title(i18n$t("Initial and Final Surveillance Diagnosis")),
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
            HTML("<span id='anchor_301'></span>"),
            div(class = "box_outputs",
                h4_title(i18n$t("Ward Occupancy Rates")),
                div(class = "box_outputs_content",
                    i18n$t("Occupancy rate per type of ward per month"),
                    plotOutput("bed_occupancy_ward", width = "80%")
                )
            ),
            HTML("<span id='anchor_302'></span>"),
            div(class = "box_outputs",
                h4_title(i18n$t("HAI Prevalence")),
                div(class = "box_outputs_content",
                    span(
                      i18n$t("HAI point prevalence by "),
                      selectInput("hai_ward_display", NULL, c("type of ward", "ward"), selected = "type of ward", multiple = FALSE, selectize = TRUE)
                    ),
                    plotOutput("hai_rate_ward", width = "80%")
                )
            )
        ),
        # Tab Microbiology ----
        nav(i18n$t("Microbiology"), value = "microbiology", 
            prettySwitch("filter_rm_contaminant", label = i18n$t("Remove blood culture contaminants from the following visualizations"), status = "primary", value = FALSE, slim = TRUE),
            fluidRow(
              column(6,
                     HTML("<span id='anchor_401'></span>"),
                     div(class = "box_outputs",
                         h4_title(i18n$t("Blood Culture Contaminants")),
                         div(class = "box_outputs_content",
                             fluidRow(
                               column(6, flexdashboard::gaugeOutput("contaminants_gauge", width = "100%", height = "100px"), br()),
                               column(6, htmlOutput("contaminants_pct", width = "100%", height = "100px"))
                             )
                         )
                     ),
                     HTML("<span id='anchor_403'></span>"),
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
                     HTML("<span id='anchor_402'></span>"),
                     div(class = "box_outputs",
                         h4_title(i18n$t("Growth / No Growth")),
                         div(class = "box_outputs_content",
                             fluidRow(
                               column(6, flexdashboard::gaugeOutput("isolates_growth_gauge", width = "100%", height = "100px"), br()),
                               column(6, htmlOutput("isolates_growth_pct", width = "100%", height = "100px"))
                             )
                         )
                     ),
                     HTML("<span id='anchor_404'></span>"),
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
            prettySwitch("combine_SI", i18n$t("Combine Susceptible + Intermediate"), status = "primary"),
            HTML("<span id='anchor_amr'></span>"),
            navs_pill_card(id = "amr_panel",
                        nav(value = "amr_aci",
                            span(em("Acinetobacter"), br(), " species"),
                            
                            conditionalPanel(condition = "! output.test_acinetobacter_sir", 
                                             h4(i18n$t("There is no data to display for this organism."))),
                            conditionalPanel(condition = "output.test_acinetobacter_sir", 
                                             div(
                                               fluidRow(
                                                 column(6,
                                                        htmlOutput("nb_isolates_acinetobacter")
                                                 ),
                                                 column(6,
                                                        div(class = "text-warning", 
                                                            span(icon("exclamation-triangle"),
                                                                 i18n$t("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")))
                                                 )
                                               ),
                                               br(),
                                               fluidRow(
                                                 column(6,
                                                        h4(i18n$t("SIR Evaluation")),
                                                        highchartOutput("acinetobacter_sir", height = "400px")
                                                 ),
                                                 column(6,
                                                        h4(i18n$t("Co-resistances")),
                                                        plotOutput("acinetobacter_co_resistance", height = "400px"),
                                                        conditionalPanel(condition = "! input.combine_SI", 
                                                                         i18n$t("Susceptible and Intermediate are always combined in this visualisation of co-resistances.")
                                                        ),
                                                        i18n$t("Horizontal bars show the size of a set of SR results while vertical bars show the number of resistant isolates for the corresponding antibiotic."),
                                                        i18n$t("Only isolates that have been tested against all of the drugs are included in the upset plot.")
                                                 )
                                               ),
                                               fluidRow(
                                                 column(12,
                                                        h4(i18n$t("Resistance to Carbapenems Over Time")),
                                                        highchartOutput("acinetobacter_sir_evolution", height = "400px")
                                                 ))
                                             )
                            )
                        ),
                        nav(value = "amr_esc",
                            HTML("<em>Escherichia <br/>coli</em>"),
                            
                            conditionalPanel(condition = "! output.test_ecoli_sir", 
                                             h4(i18n$t("There is no data to display for this organism."))),
                            conditionalPanel(condition = "output.test_ecoli_sir", 
                                             div(
                                               fluidRow(
                                                 column(6,
                                                        htmlOutput("nb_isolates_ecoli")
                                                 ),
                                                 column(6,
                                                        div(class = "text-warning", 
                                                            span(icon("exclamation-triangle"),
                                                                 i18n$t("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")))
                                                 )
                                               ),
                                               br(),
                                               fluidRow(
                                                 column(6,
                                                        h4(i18n$t("SIR Evaluation")),
                                                        highchartOutput("ecoli_sir", height = "400px")
                                                 ),
                                                 column(6,
                                                        h4(i18n$t("Co-resistances")),
                                                        plotOutput("ecoli_co_resistance", height = "400px"),
                                                        conditionalPanel(condition = "! input.combine_SI", 
                                                                         i18n$t("Susceptible and Intermediate are always combined in this visualisation of co-resistances.")
                                                        ),
                                                        i18n$t("Horizontal bars show the size of a set of SR results while vertical bars show the number of resistant isolates for the corresponding antibiotic."),
                                                        i18n$t("Only isolates that have been tested against all of the drugs are included in the upset plot.")
                                                 )
                                               ),
                                               fluidRow(
                                                 column(12,
                                                        h4(i18n$t("Resistance to Carbapenems Over Time")),
                                                        highchartOutput("ecoli_sir_evolution", height = "400px")
                                                 )),
                                               fluidRow(
                                                 column(12,
                                                        h4(i18n$t("Resistance to 3rd gen. Cephalosporins Over Time")),
                                                        highchartOutput("ecoli_sir_evolution_ceph", height = "400px")
                                                 ))
                                             )
                            )
                        ),
                        nav(value = "amr_hae",
                            HTML("<em>Haemophilus <br/>influenzae</em>"),
                            
                            conditionalPanel(condition = "! output.test_haemophilus_influenzae_sir", 
                                             h4(i18n$t("There is no data to display for this organism."))),
                            conditionalPanel(condition = "output.test_haemophilus_influenzae_sir", 
                                             div(
                                               fluidRow(
                                                 column(6,
                                                        htmlOutput("nb_isolates_haemophilus_influenzae")
                                                 ),
                                                 column(6,
                                                        div(class = "text-warning", 
                                                            span(icon("exclamation-triangle"),
                                                                 i18n$t("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")))
                                                 )
                                               ),
                                               br(),
                                               fluidRow(
                                                 column(6,
                                                        h4(i18n$t("SIR Evaluation")),
                                                        highchartOutput("haemophilus_influenzae_sir", height = "400px")
                                                 ),
                                                 column(6,
                                                        h4(i18n$t("Co-resistances")),
                                                        plotOutput("haemophilus_influenzae_co_resistance", height = "400px"),
                                                        conditionalPanel(condition = "! input.combine_SI", 
                                                                         i18n$t("Susceptible and Intermediate are always combined in this visualisation of co-resistances.")
                                                        ),
                                                        i18n$t("Horizontal bars show the size of a set of SR results while vertical bars show the number of resistant isolates for the corresponding antibiotic."),
                                                        i18n$t("Only isolates that have been tested against all of the drugs are included in the upset plot.")
                                                 )
                                               )
                                             )
                            )
                        ),
                        nav(value = "amr_kle",
                            HTML("<em>Klebsiella <br/>pneumoniae</em>"), 
                            
                            conditionalPanel(condition = "! output.test_kpneumoniae_sir", 
                                             h4(i18n$t("There is no data to display for this organism."))),
                            conditionalPanel(condition = "output.test_kpneumoniae_sir", 
                                             div(
                                               fluidRow(
                                                 column(6,
                                                        htmlOutput("nb_isolates_kpneumoniae")
                                                 ),
                                                 column(6,
                                                        div(class = "text-warning", 
                                                            span(icon("exclamation-triangle"),
                                                                 i18n$t("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")))
                                                 )
                                               ),
                                               br(),
                                               fluidRow(
                                                 column(6,
                                                        h4(i18n$t("SIR Evaluation")),
                                                        highchartOutput("kpneumoniae_sir", height = "400px")
                                                 ),
                                                 column(6,
                                                        h4(i18n$t("Co-resistances")),
                                                        plotOutput("kpneumoniae_co_resistance", height = "400px"),
                                                        conditionalPanel(condition = "! input.combine_SI", 
                                                                         i18n$t("Susceptible and Intermediate are always combined in this visualisation of co-resistances.")
                                                        ),
                                                        i18n$t("Horizontal bars show the size of a set of SR results while vertical bars show the number of resistant isolates for the corresponding antibiotic."),
                                                        i18n$t("Only isolates that have been tested against all of the drugs are included in the upset plot.")
                                                 )
                                               ),
                                               fluidRow(
                                                 column(12,
                                                        h4(i18n$t("Resistance to Carbapenems Over Time")),
                                                        highchartOutput("kpneumoniae_sir_evolution", height = "400px")
                                                 )),
                                               fluidRow(
                                                 column(12,
                                                        h4(i18n$t("Resistance to 3rd gen. Cephalosporins Over Time")),
                                                        highchartOutput("kpneumoniae_sir_evolution_ceph", height = "400px")
                                                 ))
                                             )
                            )
                        ),
                        nav(value = "amr_nei",
                            HTML("<em>Neisseria <br/>meningitidis</em>"), 
                            
                            conditionalPanel(condition = "! output.test_neisseria_meningitidis_sir", 
                                             h4(i18n$t("There is no data to display for this organism."))),
                            conditionalPanel(condition = "output.test_neisseria_meningitidis_sir", 
                                             div(
                                               fluidRow(
                                                 column(6,
                                                        htmlOutput("nb_isolates_neisseria_meningitidis")
                                                 ),
                                                 column(6,
                                                        div(class = "text-warning", 
                                                            span(icon("exclamation-triangle"),
                                                                 i18n$t("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")))
                                                 )
                                               ),
                                               br(),
                                               fluidRow(
                                                 column(6,
                                                        h4(i18n$t("SIR Evaluation")),
                                                        highchartOutput("neisseria_meningitidis_sir", height = "400px")
                                                 ),
                                                 column(6,
                                                        h4(i18n$t("Co-resistances")),
                                                        plotOutput("neisseria_meningitidis_co_resistance", height = "400px"),
                                                        conditionalPanel(condition = "! input.combine_SI", 
                                                                         i18n$t("Susceptible and Intermediate are always combined in this visualisation of co-resistances.")
                                                        ),
                                                        i18n$t("Horizontal bars show the size of a set of SR results while vertical bars show the number of resistant isolates for the corresponding antibiotic."),
                                                        i18n$t("Only isolates that have been tested against all of the drugs are included in the upset plot.")
                                                 )
                                               )
                                             )
                            )
                        ),
                        nav(value = "amr_pse",
                            HTML("<em>Pseudomonas <br/>aeruginosa</em>"), 
                            
                            conditionalPanel(condition = "! output.test_pseudomonas_aeruginosa_sir", 
                                             h4(i18n$t("There is no data to display for this organism."))),
                            conditionalPanel(condition = "output.test_pseudomonas_aeruginosa_sir", 
                                             div(
                                               fluidRow(
                                                 column(6,
                                                        htmlOutput("nb_isolates_pseudomonas_aeruginosa")
                                                 ),
                                                 column(6,
                                                        div(class = "text-warning", 
                                                            span(icon("exclamation-triangle"),
                                                                 i18n$t("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")))
                                                 )
                                               ),
                                               br(),
                                               fluidRow(
                                                 column(6,
                                                        h4(i18n$t("SIR Evaluation")),
                                                        highchartOutput("pseudomonas_aeruginosa_sir", height = "400px")
                                                 ),
                                                 column(6,
                                                        h4(i18n$t("Co-resistances")),
                                                        plotOutput("pseudomonas_aeruginosa_co_resistance", height = "400px"),
                                                        conditionalPanel(condition = "! input.combine_SI", 
                                                                         i18n$t("Susceptible and Intermediate are always combined in this visualisation of co-resistances.")
                                                        ),
                                                        i18n$t("Horizontal bars show the size of a set of SR results while vertical bars show the number of resistant isolates for the corresponding antibiotic."),
                                                        i18n$t("Only isolates that have been tested against all of the drugs are included in the upset plot.")
                                                 )
                                               ),
                                               fluidRow(
                                                 column(12,
                                                        h4(i18n$t("Resistance to Carbapenems Over Time")),
                                                        highchartOutput("pseudomonas_aeruginosa_sir_evolution", height = "400px")
                                                 ))
                                             )
                            )
                        ),
                        nav(value = "amr_sal",
                            HTML("<em>Salmonella</em> <br/>species"),
                            br(),
                            prettyRadioButtons("select_salmonella", label = NULL,  shape = "curve",
                                               choices = c("Salmonella Typhi", "Salmonella Paratyphi", "Salmonella sp (not S. Typhi or S. Paratyphi)"), 
                                               selected = "Salmonella Typhi", inline = TRUE),
                            conditionalPanel(condition = "! output.test_salmonella_sir", 
                                             h4(i18n$t("There is no data to display for this organism."))),
                            conditionalPanel(condition = "output.test_salmonella_sir", 
                                             div(
                                               fluidRow(
                                                 column(6,
                                                        htmlOutput("nb_isolates_salmonella")
                                                 ),
                                                 column(6,
                                                        div(class = "text-warning", 
                                                            span(icon("exclamation-triangle"),
                                                                 i18n$t("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")))
                                                 )
                                               ),
                                               br(),
                                               fluidRow(
                                                 column(6,
                                                        h4(i18n$t("SIR Evaluation")),
                                                        highchartOutput("salmonella_sir", height = "500px"),
                                                 ),
                                                 column(6,
                                                        h4(i18n$t("Co-resistances")),
                                                        plotOutput("salmonella_co_resistance", height = "400px"),
                                                        conditionalPanel(condition = "! input.combine_SI", 
                                                                         i18n$t("Susceptible and Intermediate are always combined in this visualisation of co-resistances.")
                                                        ),
                                                        i18n$t("Horizontal bars show the size of a set of SR results while vertical bars show the number of resistant isolates for the corresponding antibiotic."),
                                                        i18n$t("Only isolates that have been tested against all of the drugs are included in the upset plot.")
                                                 )
                                               ),
                                               fluidRow(
                                                 column(12,
                                                        h4(i18n$t("Resistance to 3rd gen. Cephalosporins Over Time")),
                                                        highchartOutput("salmonella_sir_evolution_ceph", height = "400px"),
                                                 )),
                                               fluidRow(
                                                 column(12,
                                                        h4(i18n$t("Resistance to Fluoroquinolones Over Time")),
                                                        highchartOutput("salmonella_sir_evolution_fluo", height = "400px")
                                                 ))
                                             )
                            )
                        ),
                        nav(value = "amr_sta",
                            HTML("<em>Staphylococcus <br/>aureus</em>"),
                            conditionalPanel(condition = "! output.test_saureus_sir", 
                                             h4(i18n$t("There is no data to display for this organism."))),
                            conditionalPanel(condition = "output.test_saureus_sir", 
                                             div(
                                               fluidRow(
                                                 column(6,
                                                        htmlOutput("nb_isolates_saureus")
                                                 ),
                                                 column(6,
                                                        div(class = "text-warning", 
                                                            span(icon("exclamation-triangle"),
                                                                 i18n$t("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")))
                                                 )
                                               ),
                                               br(),
                                               fluidRow(
                                                 column(6,
                                                        h4(i18n$t("SIR Evaluation")),
                                                        highchartOutput("saureus_sir", height = "400px")
                                                 ),
                                                 column(6,
                                                        h4(i18n$t("Co-resistances")),
                                                        plotOutput("saureus_co_resistance", height = "400px"),
                                                        conditionalPanel(condition = "! input.combine_SI", 
                                                                         i18n$t("Susceptible and Intermediate are always combined in this visualisation of co-resistances.")
                                                        ),
                                                        i18n$t("Horizontal bars show the size of a set of SR results while vertical bars show the number of resistant isolates for the corresponding antibiotic."),
                                                        i18n$t("Only isolates that have been tested against all of the drugs are included in the upset plot.")
                                                 )
                                               ),
                                               fluidRow(
                                                 column(12,
                                                        h4(i18n$t("Resistance to Oxacillin Over Time")),
                                                        highchartOutput("saureus_sir_evolution", height = "400px")
                                                 ))
                                             )
                            )
                        ),
                        nav(value = "amr_str",
                            HTML("<em>Streptococcus <br/>pneumoniae</em>"),
                            conditionalPanel(condition = "! output.test_spneumoniae_sir", 
                                             h4(i18n$t("There is no data to display for this organism."))),
                            conditionalPanel(condition = "output.test_spneumoniae_sir", 
                                             div(
                                               fluidRow(
                                                 column(6,
                                                        htmlOutput("nb_isolates_spneumoniae")
                                                 ),
                                                 column(6,
                                                        div(class = "text-warning", 
                                                            span(icon("exclamation-triangle"),
                                                                 i18n$t("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable.")))
                                                 )
                                               ),
                                               br(),
                                               fluidRow(
                                                 column(6,
                                                        h4(i18n$t("SIR Evaluation")),
                                                        highchartOutput("spneumoniae_sir", height = "400px")
                                                 ),
                                                 column(6,
                                                        h4(i18n$t("Co-resistances")),
                                                        plotOutput("spneumoniae_co_resistance", height = "400px"),
                                                        conditionalPanel(condition = "! input.combine_SI", 
                                                                         i18n$t("Susceptible and Intermediate are always combined in this visualisation of co-resistances.")
                                                        ),
                                                        i18n$t("Horizontal bars show the size of a set of SR results while vertical bars show the number of resistant isolates for the corresponding antibiotic."),
                                                        i18n$t("Only isolates that have been tested against all of the drugs are included in the upset plot.")
                                                 )
                                               ),
                                               fluidRow(
                                                 column(12,
                                                        h4(i18n$t("Resistance to Penicillin G Over Time")),
                                                        highchartOutput("spneumoniae_sir_evolution_pen", height = "400px")
                                                 )),
                                               fluidRow(
                                                 column(12,
                                                        h4(i18n$t("Resistance to Penicillin G - meningitis Over Time")),
                                                        highchartOutput("spneumoniae_sir_evolution_pen_men", height = "400px")
                                                 ))
                                             )
                            )
                        ),
                        nav(value = "amr_all",
                            i18n$t("All Other Organisms"),
                            br(),
                            fluidRow(
                              column(4,
                                     div(id = "other_organism_div", selectInput("other_organism", label = NULL, multiple = FALSE, choices = NULL, selected = NULL))
                              ),
                              column(8,
                                     conditionalPanel(condition = "! output.test_other_sir", 
                                                      h4(i18n$t("There is no data to display for this organism."))),
                                     conditionalPanel(condition = "output.test_other_sir", 
                                                      div(
                                                        htmlOutput("nb_isolates_other"),
                                                        div(class = "text-warning", 
                                                            span(icon("exclamation-triangle"),
                                                                 i18n$t("Care should be taken when interpreting rates and AMR profiles where there are small numbers of cases or bacterial isolates: point estimates may be unreliable."))),
                                                        h4(i18n$t("SIR Evaluation")),
                                                        highchartOutput("other_organism_sir", height = "500px"),
                                                      )
                                     )
                              )
                            )
                        )
                        
            )
        ),
        nav_item(
          actionLink("show_faq", label = "FAQ")
        )
      )
    )
  )
)

# Definition of server ----
server <- function(input, output, session) {
  # Quick access.
  source("./www/R/quick_access.R", local = TRUE)
  
  # Hide tabs on app launch.
  nav_hide("tabs", target = "data_management")
  nav_hide("tabs", target = "overview")
  nav_hide("tabs", target = "follow_up")
  nav_hide("tabs", target = "hai")
  nav_hide("tabs", target = "microbiology")
  nav_hide("tabs", target = "amr")
  
  # Create a blank page while the app is loading.
  shinyjs::delay(100, {
                 shinyjs::hide("loading_page")
                 shinyjs::show("content")
  })
  
  output$twitter_feed <- renderText({
    ifelse(!nzchar(Sys.getenv("SHINY_PORT")),
           HTML(glue("<div id='twitter_follow'><a href = 'https://twitter.com/ACORN_AMR' target='_blank'><i class='fab fa-twitter' role='presentation' aria-label='twitter icon'></i>{i18n$t('Follow us on Twitter')}, @ACORN_AMR</a></div>")),
           HTML("<a class='twitter-timeline' data-width='100%' data-height='700' data-theme='light' href='https://twitter.com/ACORN_AMR?ref_src=twsrc%5Etfw'>Tweets by ACORN_AMR</a> <script async src='https://platform.twitter.com/widgets.js' charset='utf-8'></script>")
    )
  })
  
  observeEvent(input$show_faq, {
    if(input$selected_language != "kh") {
      showModal(modalDialog(
        title = "Frequently Asked Questions",
        size = "l",
        easyClose = TRUE,
        includeMarkdown("./www/markdown/faq_acorn_en.md")
      ))}
    
    if(input$selected_language == "kh") {
      showModal(modalDialog(
        title = "Frequently Asked Questions",
        size = "l",
        easyClose = TRUE,
        includeMarkdown("./www/markdown/faq_acorn_kh.md")
      ))}
    
    if(input$selected_language == "vn") {
      showModal(modalDialog(
        title = "Frequently Asked Questions",
        size = "l",
        easyClose = TRUE,
        includeMarkdown("./www/markdown/faq_acorn_vn.md")
      ))}
  })
  
  # Download in acorn/Excel formats. ----
  output$download_data_acorn_format <- downloadHandler(
    filename = function()  glue("acorn_data_{session_start_time}.acorn"),
    content = function(file) {
      ## Anonymised data ----
      acorn <- list(about = about,
                    meta = meta(), 
                    redcap_f01f05_dta = redcap_f01f05_dta() %>% mutate(patient_id = openssl::md5(patient_id)), 
                    redcap_hai_dta = redcap_hai_dta(), 
                    lab_dta = lab_dta() %>% filter(patid %in% redcap_f01f05_dta()$patient_id) %>% mutate(patid = openssl::md5(patid)), 
                    acorn_dta = acorn_dta() %>% mutate(patient_id = openssl::md5(patient_id)), 
                    tables_dictionary = tables_dictionary(),
                    corresp_org_antibio = corresp_org_antibio(), 
                    lab_code = lab_code(), 
                    data_dictionary = data_dictionary())
      
      save(acorn, file = file)
    })
  
  
  output$download_data_excel_format <- downloadHandler(
    filename = function()  glue("acorn_data_{session_start_time}.xlsx"),
    content = function(file) {
      
      ifelse(is.null(data_dictionary()$organisms.patterns), 
             org_patterns <- tibble(info = "No organisms.patterns sheet."),
             org_patterns <- data_dictionary()$organisms.patterns)
      
      writexl::write_xlsx(
        ## Anonymised data ----
        list(
          "about" = about,
          "meta" = meta() |> as_tibble(),
          "redcap_hai_dta" = redcap_hai_dta(),
          "redcap_f01f05_dta" = redcap_f01f05_dta() %>% mutate(patient_id = openssl::md5(patient_id)),
          "lab_dta" = lab_dta() %>% filter(patid %in% redcap_f01f05_dta()$patient_id) %>% mutate(patid = openssl::md5(patid)),
          "acorn_dta" = acorn_dta() %>% mutate(patient_id = openssl::md5(patient_id)),
          "tables_dictionary" = tables_dictionary(),
          "corresp_org_antibio" = corresp_org_antibio(),
          "data_dictionary_variables" = data_dictionary()$variables,
          "data_dictionary_test.res" = data_dictionary()$test.res,
          "data_dictionary_local.spec" = data_dictionary()$local.spec,
          "data_dictionary_organisms.patterns" = org_patterns,
          "data_dictionary_local.orgs" = data_dictionary()$local.orgs,
          "data_dictionary_notes" = data_dictionary()$notes,
          "lab_codes_whonet.spec" = lab_code()$whonet.spec,
          "lab_codes_orgs.antibio" = lab_code()$orgs.antibio,
          "lab_codes_orgs.whonet" = lab_code()$orgs.whonet |> as_tibble(),
          "lab_codes_acorn.bccontaminants" = lab_code()$acorn.bccontaminants,
          "lab_codes_acorn.ast.groups" = lab_code()$acorn.ast.groups,
          "lab_codes_ast.aci" = lab_code()$ast.aci,
          "lab_codes_ast.col" = lab_code()$ast.col,
          "lab_codes_ast.hin" = lab_code()$ast.hin,
          "lab_codes_ast.ngo" = lab_code()$ast.ngo,
          "lab_codes_ast.nmen" = lab_code()$ast.nmen,
          "lab_codes_ast.pae" = lab_code()$ast.pae,
          "lab_codes_ast.sal" = lab_code()$ast.sal,
          "lab_codes_ast.shi" = lab_code()$ast.shi,
          "lab_codes_ast.ent" = lab_code()$ast.ent,
          "lab_codes_ast.sau" = lab_code()$ast.sau,
          "lab_codes_ast.spn" = lab_code()$ast.spn,
          "lab_codes_notes" = lab_code()$notes
        ), path = file)
    }
  )
  
  # Management of filters. ----
  observeEvent(input$shortcut_reset_filters, source("./www/R/reset_filters/reset_filter_enrolments.R", local = TRUE))
  
  observe({
    req(acorn_dta())
    if(! "Surveillance Category" %in% input$filter_enrolments)     source("./www/R/reset_filters/reset_filter_surveillance_cat.R", local = TRUE)
    if(! "Type of Ward" %in% input$filter_enrolments)              source("./www/R/reset_filters/reset_filter_ward_type.R", local = TRUE)
    if(! "Ward Name" %in% input$filter_enrolments)                 source("./www/R/reset_filters/reset_filter_ward_name.R", local = TRUE)
    if(! "Date of Enrolment/Survey" %in% input$filter_enrolments)  source("./www/R/reset_filters/reset_filter_date_enrolment.R", local = TRUE)
    if(! "Age Category" %in% input$filter_enrolments)              source("./www/R/reset_filters/reset_filter_age_cat.R", local = TRUE)
    if(! "Initial Diagnosis" %in% input$filter_enrolments)         source("./www/R/reset_filters/reset_filter_diagnosis_initial.R", local = TRUE)
    if(! "Final Diagnosis" %in% input$filter_enrolments)           source("./www/R/reset_filters/reset_filter_diagnosis_final.R", local = TRUE)
    if(! "Clinical Severity" %in% input$filter_enrolments)         source("./www/R/reset_filters/reset_filter_clinical_severity.R", local = TRUE)
    if(! "uCCI" %in% input$filter_enrolments)                      source("./www/R/reset_filters/reset_filter_uCCI.R", local = TRUE)
    if(! "Clinical/D28 Outcome" %in% input$filter_enrolments)      source("./www/R/reset_filters/reset_filter_outcome.R", local = TRUE)
    if(! "Transfer" %in% input$filter_enrolments)                  source("./www/R/reset_filters/reset_filter_transfer.R", local = TRUE)
  })
  
  # Source files with code to generate outputs ----
  file_list <- list.files(path = "./www/R/outputs", pattern = "*.R", recursive = TRUE)
  for (file in file_list) source(paste0("./www/R/outputs/", file), local = TRUE)$value
  
  
  # Live language change on the browser side ----
  observeEvent(input$selected_language, {
    update_lang(session, input$selected_language)
    
    if (isTRUE(!input$selected_language %in% c("la", "vn")))  session$setCurrentTheme(acorn_theme)
    if (isTRUE(input$selected_language == "la"))  session$setCurrentTheme(acorn_theme_la)
    if (isTRUE(input$selected_language == "vn"))  session$setCurrentTheme(acorn_theme_vn)
  })
  
  # Definition of reactive elements ----
  acorn_cred <- reactiveVal()
  acorn_origin <- reactiveVal()
  
  # Primary datatsets
  meta <- reactiveVal()
  redcap_f01f05_dta <- reactiveVal()
  redcap_hai_dta <- reactiveVal()
  lab_dta <- reactiveVal()
  lab_log <- reactiveVal()
  acorn_dta <- reactiveVal()
  tables_dictionary <-  reactiveVal(current_tables_dictionary)
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
    redcap_D28_date            = list(status = "hidden", msg = ""),
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
    linkage_result = list(status = "info", msg = ""),
    
    redcap_f01f05_dta = list(status = "info", msg = ""),
    lab_dta           = list(status = "info", msg = ""),
    
    acorn_dta_saved_local = list(status = "hidden", msg = ""),
    acorn_dta_saved_server = list(status = "info", msg = "")
  )
  
  # Secondary datasets (derived from primary datasets)
  redcap_f01f05_dta_filter <- reactive(redcap_f01f05_dta() %>% 
                                         fun_filter_enrolment(input = input))
  redcap_hai_dta_filter <- reactive(redcap_hai_dta() %>% 
                                      fun_filter_survey(input = input))
  acorn_dta_filter <- reactive(acorn_dta() %>% 
                                 fun_filter_enrolment(input = input) %>% 
                                 fun_filter_specimen(input = input))
  
  # Enrolment log ----
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
      br(), br(),
      downloadButton("download_enrolment_log", i18n$t("Download Enrolment Log (.xlsx)")),
      p(i18n$t("First sheet is the log of all enrolments retrived from REDCap (as per adjacent table). The second sheet is a listing of all flagged elements."))
    )
  })
  
  # Lab log ----
  output$lab_log_dl <- renderUI({
    req(lab_log())
    tagList(
      br(), br(),
      downloadButton("download_lab_log", i18n$t("Download Lab Log (.xlsx)")),
      p(i18n$t("Contains names of organisms before and after mapping."))
    )
  })
  
  # On login ----
  observeEvent(input$cred_login, {
    if (input$cred_site == "Upload Local .acorn") {
      nav_hide("data_management_tabs", target = "generate")
      nav_hide("data_management_tabs", target = "load_cloud")
      nav_show("tabs", target = "data_management", select = TRUE)
      nav_show("data_management_tabs", target = "load_local", select = TRUE)
      return()
    }
    
    id <- notify(i18n$t("Attempting to connect."))
    on.exit({Sys.sleep(2); removeNotification(id)}, add = TRUE)
    
    if (input$cred_site == "Run Demo") {
      cred <- readRDS("./www/cred/bucket_site/encrypted_cred_demo_demo.rds")
      key_user <- openssl::sha256(charToRaw("demo"))
      cred <- unserialize(openssl::aes_cbc_decrypt(cred, key = key_user))
      
      acorn_cred(cred)
      notify(i18n$t("Successfully logged in."), id = id)
      
      nav_hide("data_management_tabs", target = "generate")
      nav_hide("data_management_tabs", target = "load_local")
      nav_show("tabs", target = "data_management", select = TRUE)
      nav_show("data_management_tabs", target = "load_cloud", select = TRUE)
    }
    
    if (input$cred_site != "Run Demo") {
      file_cred <- glue("encrypted_cred_{tolower(input$cred_site)}_{input$cred_user}.rds")
      # Stop if the connection can't be established
      connect <- try(aws.s3::get_bucket(bucket = "shared-acornamr", 
                                        key    = shared_acornamr_key,
                                        secret = shared_acornamr_sec,
                                        region = "eu-west-3") %>% unlist(),
                     silent = TRUE)
      
      if (inherits(connect, "try-error")) {
        showNotification(i18n$t("Couldn't connect to server. Please check internet access."), type = "error")
        return()
      }
      
      # Test if credentials for this user name exist
      if (! file_cred %in% as.vector(connect[names(connect) == "Contents.Key"])) {
        showNotification(i18n$t("Wrong connection credentials."), type = "error")
        return()
      }
      
      Sys.setenv("AWS_ACCESS_KEY_ID" = shared_acornamr_key,
                 "AWS_SECRET_ACCESS_KEY" = shared_acornamr_sec,
                 "AWS_DEFAULT_REGION" = "eu-west-3")
      
      cred <- try(aws.s3::s3read_using(FUN = read_encrypted_cred, 
                                       pwd = input$cred_password,
                                       object = file_cred,
                                       bucket = "shared-acornamr"),
                  silent = TRUE)
      
      if (inherits(cred, "try-error")) {
        showNotification(i18n$t("Wrong connection credentials."), type = "error")
        return()
      }
      
      # remove AWS environment variables
      Sys.unsetenv("AWS_ACCESS_KEY_ID")
      Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
      Sys.unsetenv("AWS_DEFAULT_REGION")
      
      acorn_cred(cred)
      notify(i18n$t("Successfully logged in."), id = id)
      
      nav_show("tabs", target = "data_management", select = TRUE)
      if(! acorn_cred()$redcap_access) nav_hide("data_management_tabs", target = "generate")
      if(! acorn_cred()$redcap_access) nav_select("data_management_tabs", selected = "load_cloud")
      if(acorn_cred()$redcap_access) nav_select("data_management_tabs", selected = "generate")
    }
    
    # Remove previousely loaded .acorn data.
    meta(NULL)
    redcap_f01f05_dta(NULL)
    redcap_hai_dta(NULL)
    lab_dta(NULL)
    acorn_dta(NULL)
    corresp_org_antibio(NULL)
    data_dictionary(NULL)
    lab_code(NULL)
    
    # Reset status messages.
    checklist_status$linkage_result$msg <- i18n$t("No .acorn has been generated")
    checklist_status$redcap_f01f05_dta$msg = i18n$t("Clinical data not provided")
    checklist_status$lab_dta$msg <- i18n$t("Lab data not provided")
    checklist_status$acorn_dta_saved_server$msg <-  i18n$t("No .acorn has been saved")
    
    nav_hide("tabs", target = "overview")
    nav_hide("tabs", target = "follow_up")
    nav_hide("tabs", target = "hai")
    nav_hide("tabs", target = "microbiology")
    nav_hide("tabs", target = "amr")
    
    # Connect to AWS S3 server ----
    if(acorn_cred()$aws_access) {
      
      connect_server_test <- aws.s3::bucket_exists(
        bucket = acorn_cred()$aws_bucket,
        key =  acorn_cred()$aws_key,
        secret = acorn_cred()$aws_secret,
        region = acorn_cred()$aws_region)[1]
      
      if(connect_server_test) {
        # Update select list with .acorn files on the server
        dta <- aws.s3::get_bucket(bucket = acorn_cred()$aws_bucket,
                                  key =  acorn_cred()$aws_key,
                                  secret = acorn_cred()$aws_secret,
                                  region = acorn_cred()$aws_region) %>%
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
                                     bucket = acorn_cred()$aws_bucket,
                                     key =  acorn_cred()$aws_key,
                                     secret = acorn_cred()$aws_secret,
                                     region = acorn_cred()$aws_region)
    load(rawConnection(acorn_file))
    
    acorn_origin("loaded")
    meta(acorn$meta)
    redcap_f01f05_dta(acorn$redcap_f01f05_dta)
    redcap_hai_dta(acorn$redcap_hai_dta)
    lab_dta(acorn$lab_dta)
    acorn_dta(acorn$acorn_dta)
    
    # For backward compatibility with 2.1.1 (no tables_dictionary).
    ifelse(!is.null(acorn$tables_dictionary),
           tables_dictionary(acorn$tables_dictionary),
           tables_dictionary(current_tables_dictionary)
    )
    
    corresp_org_antibio(acorn$corresp_org_antibio)
    lab_code(acorn$lab_code)
    data_dictionary(acorn$data_dictionary)
    
    source('./www/R/update_input_widgets.R', local = TRUE)
    notify(i18n$t("Successfully loaded data."), id = id)
    on_acorn_load(session)
  })
  
  # On "Load .acorn" file from local ----
  observeEvent(input$load_acorn_local, {
    load(input$load_acorn_local$datapath)
    
    acorn_origin("loaded")
    meta(acorn$meta)
    redcap_f01f05_dta(acorn$redcap_f01f05_dta)
    redcap_hai_dta(acorn$redcap_hai_dta)
    lab_dta(acorn$lab_dta)
    acorn_dta(acorn$acorn_dta)
    corresp_org_antibio(acorn$corresp_org_antibio)
    lab_code(acorn$lab_code)
    data_dictionary(acorn$data_dictionary)
    
    source('./www/R/update_input_widgets.R', local = TRUE)
    notify(i18n$t("Successfully loaded data."), id = id)
    on_acorn_load(session)
  })
  
  # On "Get Clinical Data from REDCap server" ----
  observeEvent(input$get_redcap_data, {
    continue <<- TRUE
    
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
    filename = function()  glue("enrolment_log_{format(Sys.time(), '%Y-%m-%d_%H%M')}.xlsx"),
    content = function(file)  writexl::write_xlsx(
      list(
        "Enrolment Log" = enrolment_log(),
        "Errors Log" = checklist_status$log_errors
      ), path = file)
  )
  
  # On "Download Lab Log" ----
  output$download_lab_log <- downloadHandler(
    filename = function()  glue("lab_log_{format(Sys.time(), '%Y-%m-%d_%H%M')}.xlsx"),
    content = function(file)  writexl::write_xlsx(
      list(
        "Organisms" = lab_log()
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
                        orgs.whonet = lab_code$orgs.whonet,
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
                        organisms.patterns = data_dictionary$organisms.patterns,
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
        textInput("name_file_server", value = glue("{input$cred_site}_{session_start_time}"), label = i18n$t("File name:")),
        textAreaInput("meta_acorn_comment_server", label = i18n$t("(Optional) Comments:"), value = "There are no comments."),
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
        textInput("name_file_local", value = glue("{input$cred_site}_{session_start_time}"), label = i18n$t("File name:")),
        textAreaInput("meta_acorn_comment_local", label = i18n$t("(Optional) Comments:"), value = "There are no comments."),
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
                 comment = input$meta_acorn_comment_server)
    meta(meta)
    
    ## Anonymised data ----
    name_file <- glue("{input$name_file_server}.acorn")
    file <- file.path(tempdir(), name_file)
    acorn <- list(about = about,
                  meta = meta(), 
                  redcap_f01f05_dta = redcap_f01f05_dta() %>% mutate(patient_id = openssl::md5(patient_id)), 
                  redcap_hai_dta = redcap_hai_dta(), 
                  lab_dta = lab_dta() %>% filter(patid %in% redcap_f01f05_dta()$patient_id) %>% mutate(patid = openssl::md5(patid)), 
                  acorn_dta = acorn_dta() %>% mutate(patient_id = openssl::md5(patient_id)), 
                  tables_dictionary = tables_dictionary(),
                  corresp_org_antibio = corresp_org_antibio(), 
                  lab_code = lab_code(), 
                  data_dictionary = data_dictionary())
    save(acorn, file = file)
    
    aws.s3::put_object(file = file,
                       object = name_file,
                       bucket = acorn_cred()$aws_bucket,
                       key =  acorn_cred()$aws_key,
                       secret = acorn_cred()$aws_secret,
                       region = acorn_cred()$aws_region)
    
    ## Non anonymised data ----
    name_file <- glue("{input$name_file_server}.acorn_non_anonymised")
    file <- file.path(tempdir(), name_file)
    acorn <- list(about = about,
                  meta = meta(), 
                  redcap_f01f05_dta = redcap_f01f05_dta(), 
                  redcap_hai_dta = redcap_hai_dta(), 
                  lab_dta = lab_dta() %>% filter(patid %in% redcap_f01f05_dta()$patient_id), 
                  acorn_dta = acorn_dta(), 
                  tables_dictionary = tables_dictionary(),
                  corresp_org_antibio = corresp_org_antibio(), 
                  lab_code = lab_code(), 
                  data_dictionary = data_dictionary())
    save(acorn, file = file)
    
    aws.s3::put_object(file = file,
                       object = name_file,
                       bucket = acorn_cred()$aws_bucket,
                       key =  acorn_cred()$aws_key,
                       secret = acorn_cred()$aws_secret,
                       region = acorn_cred()$aws_region)
    
    ## Update list of files to load ----
    acorn_files <- aws.s3::get_bucket_df(bucket = acorn_cred()$aws_bucket,
                                         key =  acorn_cred()$aws_key,
                                         secret = acorn_cred()$aws_secret,
                                         region = acorn_cred()$aws_region) |> 
      filter(endsWith(Key, ".acorn")) |> 
      mutate(date_mod = as.POSIXct(LastModified)) |> 
      arrange(desc(date_mod)) |> 
      slice_head(n = 10) |> 
      pull(Key)
    
    updatePickerInput(session, 'acorn_files_server', choices = acorn_files, selected = acorn_files[1])
    
    
    ## Switch to analysis ----
    checklist_status$acorn_dta_saved_server <- list(status = "okay", msg = i18n$t(".acorn file saved on server."))
    notify(i18n$t("Successfully saved .acorn file in the cloud. You can now explore acorn data."), id = id)
    on_acorn_load(session)
  })
  
  
  
  output$save_acorn_local_confirm <- downloadHandler(
    # On confirmation that the file is being saved locally ----
    filename = function()  glue("{input$name_file_local}.acorn"),
    content = function(file) {
      removeModal()
      ## Common to anonymised and non-anonymised. ----
      meta <- list(time_generation = session_start_time,
                   app_version = app_version,
                   site = input$cred_site,
                   user = input$cred_user,
                   comment = input$meta_acorn_comment_local)
      meta(meta)
      
      acorn <- list(about = about,
                    meta = meta(), 
                    redcap_f01f05_dta = redcap_f01f05_dta() %>% mutate(patient_id = openssl::md5(patient_id)), 
                    redcap_hai_dta = redcap_hai_dta(), 
                    lab_dta = lab_dta() %>% filter(patid %in% redcap_f01f05_dta()$patient_id) %>% mutate(patid = openssl::md5(patid)), 
                    acorn_dta = acorn_dta() %>% mutate(patient_id = openssl::md5(patient_id)), 
                    tables_dictionary = tables_dictionary(),
                    corresp_org_antibio = corresp_org_antibio(), 
                    lab_code = lab_code(), 
                    data_dictionary = data_dictionary())
      
      save(acorn, file = file)
      
      checklist_status$acorn_dta_saved_local <- list(status = "okay", msg = i18n$t("Successfully saved .acorn file locally."))
      showNotification(i18n$t("Successfully saved .acorn file locally."), duration = 5)
      on_acorn_load(session)
      
      if(checklist_status$acorn_dta_saved_server$status != "okay")  {
        checklist_status$acorn_dta_saved_server <- list(status = "warning", msg = i18n$t("Consider saving .acorn file on the cloud for additional security."))
      }
    })
}

shinyApp(ui = ui, server = server)  # port 3872
