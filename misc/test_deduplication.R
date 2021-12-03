library(tidyverse)
library(gt)

test_data <- tribble(
  ~row_nb,	~patient_id,	~date_episode_enrolment,	~episode_id,	~surveillance_category,	~orgname,	~specgroup,	~specdate,
  1,	"A",	"2020-01-01",	"1-2020-01-01",	"CAI",	"E coli",	"Blood Culture",	"2020-01-01",
  2,  "A",	"2020-01-01",	"1-2020-01-01",	"CAI",	"E coli",	"Blood Culture",	"2020-01-01",
  3,	"A",	"2020-01-01",	"1-2020-01-01",	"CAI",	"E coli",	"Blood Culture",	"2020-01-02",
  4,	"A",	"2020-01-01",	"1-2020-01-01",	"CAI",	"E coli",	"Urine",	"2020-01-01",
  5,	"A",	"2020-01-10",	"2-2020-01-10",	"HAI",	"E coli",	"Urine",	"2020-01-10",
  6,	"A",	"2020-01-21",	"3-2020-01-21",	"HAI",	"E coli",	"Urine",	"2020-01-22",
  
  7,	"B",	"2020-06-30",	"1-2020-06-30",	"CAI",	"E coli",	"Urine",	"2020-06-30",
  8,	"B",	"2020-06-30",	"1-2020-06-30",	"CAI",	"E coli",	"Urine",	"2020-07-01",
  9,	"B",	"2020-06-30",	"1-2020-06-30",	"CAI",	"E coli",	"Blood Culture",	"2020-06-29",
  10,	"B",	"2020-12-01",	"2-2020-12-01",	"HAI",	"E coli",	"Blood Culture",	"2020-12-01",
  11,	"B",	"2020-12-25",	"3-2020-12-25",	"CAI",	"E coli",	"Blood Culture",	"2020-12-25",
)

test_data |> gt() |> tab_header(title = "No Deduplication") |> 
  cols_align("center") |> 
  gtsave("./inst/acorn/www/images/table_dedup_no_dedup.png")

# Function updated on 2021-12-03
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

# Resulting Table 1
test_data |> fun_deduplication(method = "Deduplication by patient-episode") |>
  arrange(row_nb) |> 
  gt() |> tab_header(title = "Deduplication by patient-episode") |> 
  cols_align("center") |> 
  gtsave("./inst/acorn/www/images/table_dedup_patient_episode.png")

# Resulting Table 2
test_data |> fun_deduplication(method = "Deduplication by patient ID") |> 
  arrange(row_nb) |> 
  gt() |> tab_header(title = "Deduplication by patient ID") |>
  cols_align("center") |> 
  gtsave("./inst/acorn/www/images/table_dedup_patient_id.png")
