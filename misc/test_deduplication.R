library(tidyverse)
# episode_id is built as episode_id = glue("{acorn_id}-{date_enrolment}")

# Original Table
test_data <- tribble(
  ~patient_id, ~episode_id, ~surveillance_category, ~orgname, ~specgroup,         ~random_var,
  "pat_01",    "ep_01",    "CAI",                   "E coli",   "Blood Culture",    "Blue",
  "pat_01",    "ep_01",    "CAI",                   "E coli",   "Blood Culture",    "Red",
  "pat_01",    "ep_01",    "CAI",                   "E coli",   "Blood Culture",    "Green",
  "pat_01",    "ep_01",    "CAI",                   "E coli",   "Urine",            "Yellow",
  
  "pat_02",    "ep_01",    "CAI",                   "E coli",   "Urine",            "Magenta",
  "pat_02",    "ep_01",    "CAI",                   "E coli",   "Urine",            "Black",
  
  "pat_02",    "ep_02",    "HAI",                   "E coli",   "Blood Culture",    "Orange",
  "pat_02",    "ep_02",    "HAI",                   "E coli",   "Blood Culture",    "White",
  
  "pat_02",    "ep_03",    "HAI",                   "E coli",   "Blood Culture",    "Gray",
  "pat_02",    "ep_03",    "HAI",                   "E coli",   "Blood Culture",    "Brown"
)

# Function used in app as per 2021-11-09
# The surveillance_category variable isn't used.
fun_deduplication <- function(data, method = NULL) {
  if(is_empty(method)) stop("No deduplication method provided.")
  
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

# Resulting Table 1
test_data |> fun_deduplication(method = "Deduplication by patient-episode")

# Resulting Table 2
test_data |> fun_deduplication(method = "Deduplication by patient ID")
