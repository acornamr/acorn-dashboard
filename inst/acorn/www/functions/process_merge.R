process_merge <- function(form_file, form_session) {
  bind_rows(form_file,
            form_session %>% filter(! acorn_id %in% form_file$acorn_id))
}