fun_filter_enrolment <- function(data, input) {
  if( is.null(data) ) return(NULL)
  
  data <- data %>% 
    filter(surveillance_category %in% input$filter_surveillance_cat,
           ward_type %in% input$filter_ward_type,
           date_episode_enrolment >= input$filter_date_enrolment[1],
           date_episode_enrolment <= input$filter_date_enrolment[2],
           age_category %in% input$filter_age_cat,
           surveillance_diag %in% input$filter_diagnosis_initial,
           ho_final_diag %in% input$filter_diagnosis_final,
           clinical_severity_score >= input$filter_severity[1],
           clinical_severity_score <= input$filter_severity[2])
  
  if(input$filter_outcome_clinical) data <- data %>% filter(has_clinical_outcome)
  if(input$filter_outcome_d28)      data <- data %>% filter(has_d28_outcome)
  
  return(data)
}

fun_filter_specimen <- function(data, input) { 
  if( is.null(data) ) return(NULL)
  
  if(! "blood" %in% input$filter_method_collection)           data <- data %>% filter(specgroup != "Blood")
  if(! "other_not_blood" %in% input$filter_method_collection) data <- data %>% filter(specgroup == "Blood")
  data <- data %>% filter(specgroup %in% c("Blood", input$filter_method_other))
  
  return(data)
}

fun_filter_isolate <- function(data, input) {
  return(data)
}

fun_filter_survey <- function(data, input) {
  if( is.null(data) ) return(NULL)
  
  data %>% filter(ward_type %in% input$filter_ward_type,
                  survey_date >= input$filter_date_enrolment[1],
                  survey_date <= input$filter_date_enrolment[2])
}

# Function that keeps only "Blood" specimen types
fun_filter_blood_only <- function(data)  data %>% filter(specgroup == "Blood")

# Function that returns a deduplicated dataset following the provided method: by patient-episode or by patient Id
# It's essential to use this only once possible other filters (surveillance type...) have already been applied
fun_deduplication <- function(data, method = NULL) {
  if(is.null(method)) stop("No deduplication method provided.")
  
  if(method == "No deduplication of isolates")  return(data)
  
  if(method == "Deduplication by patient-episode") { 
    data_dedup <- data %>% group_by(patient_id, episode_id, orgname, specgroup) %>% 
      slice(1) %>% ungroup()

    return(data_dedup)
  }
  
  if(method == "Deduplication by patient ID") { 
    data_dedup <- data %>% group_by(patient_id, orgname, specgroup) %>% 
      slice(1) %>% ungroup()

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