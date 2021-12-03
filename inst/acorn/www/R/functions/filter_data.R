fun_filter_enrolment <- function(data, input) {
  if( is_empty(data) ) return(NULL)
  
  data <- data %>% 
    filter(surveillance_category %in% input$filter_surveillance_cat,
           ward_type %in% input$filter_ward_type,
           date_episode_enrolment >= input$filter_date_enrolment[1],
           date_episode_enrolment <= input$filter_date_enrolment[2],
           age_category %in% input$filter_age_cat,
           surveillance_diag %in% input$filter_diagnosis_initial,
           ho_final_diag %in% input$filter_diagnosis_final,
           cci >= input$filter_uCCI[1],
           cci <= input$filter_uCCI[2]
           )
  
  
  data <- bind_rows(data %>% 
                      filter(age_category == "Adult",
                             clinical_severity_score >= input$filter_severity_adult[1],
                             clinical_severity_score <= input$filter_severity_adult[2]),
                    data %>% 
                      filter(age_category %in% c("Child", "Neonate"),
                             clinical_severity_score >= 1 - input$filter_severity_child_0,
                             clinical_severity_score <= 7 * (1 - (! input$filter_severity_child_1)))
  )
  
  if(input$filter_outcome_clinical) data <- data %>% filter(has_clinical_outcome)
  if(input$filter_outcome_d28)      data <- data %>% filter(has_d28_outcome)
  if(input$filter_transfer)         data <- data %>% filter(transfer_hospital == "No")
  
  return(data)
}

fun_filter_specimen <- function(data, input) { 
  if( is_empty(data) ) return(NULL)
  
  if(! "blood" %in% input$filter_method_collection)           data <- data %>% filter(specgroup != "Blood")
  if(! "other_not_blood" %in% input$filter_method_collection) data <- data %>% filter(specgroup == "Blood")
  data <- data %>% filter(specgroup %in% c("Blood", input$filter_method_other))
  
  return(data)
}

fun_filter_survey <- function(data, input) {
  if( is_empty(data) ) return(NULL)
  
  data %>% filter(ward_type %in% input$filter_ward_type,
                  survey_date >= input$filter_date_enrolment[1],
                  survey_date <= input$filter_date_enrolment[2])
}

# Function that keeps only "Blood" specimen types
fun_filter_blood_only <- function(data)  data %>% filter(specgroup == "Blood")

# Function that returns a deduplicated dataset following the provided method: by patient-episode or by patient Id
# It's essential to use this only once possible other filters (surveillance type...) have already been applied
# Function last updated on 2021-12-03, using slice_min(specdate)
fun_deduplication <- function(data, method = NULL) {
  if(is_empty(method)) stop("No deduplication method provided.")
  
  if(method == "No deduplication of isolates")  return(data)
  
  if(method == "Deduplication by patient-episode") { 
    data_dedup <- data |> 
      arrange(date_episode_enrolment) |> 
      group_by(patient_id, episode_id, orgname, specgroup) |>
      slice_min(specdate) |> ungroup()
    return(data_dedup)
  }
  
  if(method == "Deduplication by patient ID") { 
    data_dedup <- data |> 
      arrange(date_episode_enrolment) |>
      mutate(surveillance_category_regroup = 
               case_when(
                 surveillance_category == "HAI" ~ "HAI",
                 surveillance_category == "CAI" | surveillance_category == "HCAI" ~ "CAI",
                 TRUE ~ "Unknown"
               )) |> 
      group_by(patient_id, orgname, specgroup, surveillance_category_regroup) |> 
      slice_min(specdate) |> ungroup() |> select(-surveillance_category_regroup)
    return(data_dedup)
  }
}

# Function that removes organisms "No growth (specific organism)" and "No growth"
# Note that "No significant growth" should be categorised as growth
fun_filter_growth_only <- function(data) data %>% filter(! orgname %in% c("No growth (specific organism)", "No growth"))

# Function that removes organisms "No significant growth"
fun_filter_signifgrowth_only <- function(data) data %>% filter(orgname != "No significant growth")

# Function that removes organisms "Not cultured"
fun_filter_cultured_only <- function(data) data %>% filter(! orgname == "Not cultured")

# Function that keeps only target pathogens
fun_filter_target_pathogens <- function(data)  data %>% filter(orgname %in% c("Acinetobacter baumannii", "Escherichia coli", "Klebsiella pneumoniae", 
                                                                              "Staphylococcus aureus", "Streptococcus pneumoniae") | str_detect(orgname, "Salmonella"))