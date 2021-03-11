# Function that returns a filtered dataset
filter_data <- function(data, input) {
  
  if( is.null(data) ) return(NULL)
  
  data <- data %>%
    filter(
      sex %in% input$filter_sex
    )
  
  return(data)
}

# Function that keeps only "Blood" specimen types
fun_filter_blood_only <- function(data)  data %>% filter(specimen_type == "Blood")


# Function that returns a deduplicated dataset following the provided method: by patient-episode or by patient Id
# It's essential to use this only once possible other filters (surveillance type...) have already been applied
fun_deduplication <- function(data, method = NULL) {
  if(is.null(method)) stop("No deduplication method provided.")
  
  if(method == "No deduplication of isolates")  return(data)
  
  if(method == "Deduplication by patient-episode") { 
    data_dedup <- data %>% group_by(patient_id, episode_id, organism, specimen_type) %>% 
      slice(1) %>% ungroup()
    # print(paste0("Deduplication: before ", nrow(data), " isolates; after ", nrow(data_dedup), 
    #              " isolates (-",  nrow(data) - nrow(data_dedup), ")."))
    return(data_dedup)
  }
  
  if(method == "Deduplication by patient ID") { 
    data_dedup <- data %>% group_by(patient_id, organism, specimen_type) %>% 
      slice(1) %>% ungroup()
    # print(paste0("Deduplication: before ", nrow(data), " isolates; after ", nrow(data_dedup), 
    #              " isolates (-",  nrow(data) - nrow(data_dedup), ")."))
    return(data_dedup)
  }
}

# Function that removes organisms "No growth (specific organism)" and "No growth"
# Note that "No significant growth" should be categorised as growth
fun_filter_growth_only <- function(data) data %>% filter(! organism %in% c("No growth (specific organism)", "No growth"))


# Function that removes organisms "No significant growth"
fun_filter_signifgrowth_only <- function(data) data %>% filter(organism != "No significant growth")

# Function that removes organisms "Not cultured"
fun_filter_cultured_only <- function(data) data %>% filter(! organism == "Not cultured")