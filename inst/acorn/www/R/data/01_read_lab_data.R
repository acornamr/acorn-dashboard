try({
  if (input$format_lab_data == "WHONET .dBase") {
    path_lab_file <- input$file_lab_dba[[1, 'datapath']]
    dta <- foreign::read.dbf(path_lab_file, as.is = TRUE)
  }
  
  if (input$format_lab_data == "WHONET .SQLite") {
    path_lab_file <- input$file_lab_sql[[1, 'datapath']]
    dta <- DBI::dbConnect(RSQLite::SQLite(), path_lab_file)
    dta <- as.data.frame(DBI::dbReadTable(dta, "Isolates"))
  }
  
  if (input$format_lab_data == "Tabular") {
    path_lab_file <- input$file_lab_tab[[1, 'datapath']]
    extension_file_lab_data <- tools::file_ext(path_lab_file)
    
    if (extension_file_lab_data == "csv")  dta <- readr::read_csv(path_lab_file, guess_max = 10000)
    if (extension_file_lab_data == "txt")  dta <- readr::read_tsv(path_lab_file, guess_max = 10000)
    if (extension_file_lab_data %in% c("xls", "xlsx")) dta <- readxl::read_excel(path_lab_file, guess_max = 10000)
  }
})

if (! exists("dta")) {
  showNotification("Something went wrong with the import of lab data.", type = "error")
  return()
}

if (nrow(dta) == 0) {
  showNotification("Something went wrong with the import of lab data.", type = "error")
  return()
}