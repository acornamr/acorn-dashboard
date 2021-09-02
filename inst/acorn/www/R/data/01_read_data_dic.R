message("Retrive site data dictionary from AWS.")
ifelse(input$format_lab_data %in% c("WHONET .dBase", "WHONET .SQLite"),
       format_data_dic <- "WHONET",
       format_data_dic <- "TABULAR")

file_dic <- try(save_object(object = glue("ACORN2_lab_data_dictionary_{acorn_cred()$site}_{format_data_dic}.xlsx"), 
                            bucket = acorn_cred()$acorn_s3_bucket,
                            key =  acorn_cred()$acorn_s3_key,
                            secret = acorn_cred()$acorn_s3_secret,
                            region = acorn_cred()$acorn_s3_region,
                            file = tempfile()),
                silent = TRUE)

if (inherits(file_dic, "try-error")) {
  removeNotification(id = "processing_lab_data")
  showNotification(i18n$t("We couldn't download the lab data dictionary. Please contact ACORN support"), 
                   type = "error", duration = NULL)
  return()
}

data_dictionary <- list(file_path = file_dic)
data_dictionary$variables <- read_excel(data_dictionary$file_path, sheet = "variables")
data_dictionary$test.res <- read_excel(data_dictionary$file_path, sheet = "test.results")
data_dictionary$local.spec <- read_excel(data_dictionary$file_path, sheet = "spec.types")
data_dictionary$local.orgs <- read_excel(data_dictionary$file_path, sheet = "organisms")
data_dictionary$notes <- read_excel(data_dictionary$file_path, sheet = "notes")