# DO ONCE:
# install.packages(c("dplyr", "stringr"))

# Path containing folders with all .acorn files.
path_data_folder <- "/Users/olivier/Documents/Consultances/ACORN/Backup AWS"

all_files <- list.files(
  path_data_folder, 
  full.names = TRUE,
  recursive = TRUE
)

all_files_short <- list.files(
  path_data_folder, 
  full.names = FALSE,
  recursive = TRUE
)

data.files <- all_files |> 
  file.info() |> 
  dplyr::mutate(name_short = all_files_short) |> 
  dplyr::mutate(acorn.file = dplyr::if_else(
    stringr::str_detect(name_short, ".acorn"), 
    "acorn", 
    "not.acorn")
  ) |> 
  dplyr::filter(acorn.file == "acorn") |> 
  dplyr::select(name_short, mtime) |> 
  dplyr::mutate(site_id = stringr::str_sub(name_short, start = 1, end = 5))

# Check the site_id.
data.files |> 
  dplyr::pull(site_id) |> 
  unique()

# For each site_id, keep just the most recent file (most recent mtime).
last_updated <- data.files |> 
  dplyr::group_by(site_id) |> 
  dplyr::mutate(newestfile = max(mtime, na.rm = TRUE)) |> 
  dplyr::filter(mtime == newestfile) |> 
  dplyr::select(site_id, name_short, newestfile) |> 
  dplyr::ungroup()


write.csv(
  last_updated, 
  file = "/Users/olivier/Documents/Consultances/ACORN/Backup AWS/latest_acorn_per_site.csv",
  row.names = FALSE
)

