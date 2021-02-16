info_acorn_file <- function(acorn_dta_file) {
  
  nb_acorn_id_f01 <- length(unique(acorn_dta_file$f01$acorn_id))
  # nb_acorn_id_f02 <- length(unique(acorn_dta_file$f02$acorn_id))
  nb_acorn_id_f02 <- 0
  
  nb_acorn_id_lab <- length(unique(acorn_dta_file$lab_dta$acorn_id))
  
  acorn_dta_file$meta
  return(
    div(
      HTML(glue("Data generated on the {acorn_dta_file$meta$time_generation}; on <strong>{acorn_dta_file$meta$machine}</strong>; by <strong>{acorn_dta_file$meta$user}</strong>. {acorn_dta_file$meta$comment}")),
      h4("Clinical data:"),
      tags$ul(
        tags$li(glue("{nb_acorn_id_f01} distinct acorn id in the enrollment form (f01)")),
        tags$li(glue("{nb_acorn_id_f02} distinct acorn id in the form f02")),
        tags$li("..."),
      ),
      h4("Lab data:"),
      tags$ul(
        tags$li(glue("{nb_acorn_id_lab} distinct acorn id in the lab data"))
      )
    )
  )
}