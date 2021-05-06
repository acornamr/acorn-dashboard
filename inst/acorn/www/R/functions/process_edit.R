# process the edits
process_edit <- function(df, df_edit) {
  if(nrow(df_edit) == 0)  return(df)
  
  bind_rows(
    df %>% filter(!acorn_id %in% df_edit$acorn_id),
    df_edit %>% filter(edit) %>%
      group_by(acorn_id) %>%
      arrange(edit_date) %>%
      filter(row_number() == n()) %>%
      select(-edit, -edit_by, -edit_date)) %>%
    arrange(acorn_id)
}