ifelse(input$format_lab_data %in% c("WHONET .dBase", "WHONET .SQLite"),
       format_data_dic <- "WHONET",
       format_data_dic <- "TABULAR")

data_dictionary <- list()
path_data_dictionary_file <- glue("./www/data/data_dictionary/ACORN2_lab_data_dictionary_{acorn_cred()$site}-{format_data_dic}.xlsx")