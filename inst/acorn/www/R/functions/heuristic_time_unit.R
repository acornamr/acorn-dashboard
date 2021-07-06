# example call:
# heuristic_unit <- interval(start = min(dta$collected_date_dd_mm_yy, na.rm = TRUE),
#                            end = max(dta$collected_date_dd_mm_yy, na.rm = TRUE)) %>%
#   int_length() %>%
#   make_difftime(units = "days") %>%
#   heuristic_time_unit()

heuristic_time_unit <- function(nb_days) {
  stopifnot(nb_days >= 0)
  
  case_when((nb_days > 3*12*30) ~ "years",
            (nb_days > 12*30) ~ "quarters",
            (nb_days > 4*30) ~ "months",
            TRUE ~ "weeks")
}