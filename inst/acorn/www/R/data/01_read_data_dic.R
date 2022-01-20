message("Retrive site data dictionary from AWS.")
ifelse(input$format_lab_data %in% c("WHONET .dBase", "WHONET .SQLite"),
       format_data_dic <- "WHONET",
       format_data_dic <- "TABULAR")

file_dic <- try(aws.s3::save_object(object = glue("ACORN2_lab_data_dictionary_{acorn_cred()$site}_{format_data_dic}.xlsx"), 
                            bucket = acorn_cred()$aws_bucket,
                            key =  acorn_cred()$aws_key,
                            secret = acorn_cred()$aws_secret,
                            region = acorn_cred()$aws_region,
                            file = tempfile()),
                silent = TRUE)

if (inherits(file_dic, "try-error")) {
  removeNotification(id = "processing_lab_data")
  showNotification(i18n$t("We couldn't download the lab data dictionary. Please contact ACORN support"), 
                   type = "error", duration = NULL)
  return()
}

data_dictionary <- list(file_path = file_dic)
data_dictionary$variables <- readxl::read_excel(data_dictionary$file_path, sheet = "variables")
data_dictionary$test.res <- readxl::read_excel(data_dictionary$file_path, sheet = "test.results")
data_dictionary$local.spec <- readxl::read_excel(data_dictionary$file_path, sheet = "spec.types")
data_dictionary$local.orgs <- readxl::read_excel(data_dictionary$file_path, sheet = "organisms")
data_dictionary$notes <- readxl::read_excel(data_dictionary$file_path, sheet = "notes")