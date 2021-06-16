fun_filter_enrolment <- function(data, input) {
  return(data)
}

fun_filter_isolate <- function(data, input) {
  return(data)
}

fun_filter_survey <- function(data, input) {
  return(data)
}


# Function that returns a filtered dataset
fun_filter_patient <- function(data, input) {
  
  if( is.null(data) ) return(NULL)
  
  if(input$filter_origin_infection != "All Origins") data <- data %>% filter(surveillance_cat == input$filter_origin_infection)
  
  return(data)
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
    # print(paste0("Deduplication: before ", nrow(data), " isolates; after ", nrow(data_dedup), 
    #              " isolates (-",  nrow(data) - nrow(data_dedup), ")."))
    return(data_dedup)
  }
  
  if(method == "Deduplication by patient ID") { 
    data_dedup <- data %>% group_by(patient_id, orgname, specgroup) %>% 
      slice(1) %>% ungroup()
    # print(paste0("Deduplication: before ", nrow(data), " isolates; after ", nrow(data_dedup), 
    #              " isolates (-",  nrow(data) - nrow(data_dedup), ")."))
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