merge_clinical_lab <- function(acorn_dta_merged) {
  
  lab_dta <- acorn_dta_merged$lab_dta %>%
    group_by(acorn_id, result) %>%
    summarise(n = n(), .groups = "drop") %>%
    pivot_wider(names_from = result, values_from = n, values_fill = 0)
  
  left_join(acorn_dta_merged$f01_cor,
            lab_dta,
            by = "acorn_id")
}