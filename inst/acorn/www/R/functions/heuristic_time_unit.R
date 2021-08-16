# example call:
#   heuristic_time_unit(dengue_dta_filt()$collected_date_dd_mm_yy)

heuristic_time_unit <- function(vec_date) {
  nb_days <- interval(start = min(vec_date, na.rm = TRUE),
                      end = max(vec_date, na.rm = TRUE)) %>%
    int_length() %>%
    make_difftime(units = "days")
  
  stopifnot(nb_days >= 0)
  
  case_when((nb_days > 3*12*30) ~ "years",
            TRUE ~ "months")
  
  # case_when((nb_days > 3*12*30) ~ "years",
  #           (nb_days > 12*30) ~ "quarters",
  #           (nb_days > 4*30) ~ "months",
  #           TRUE ~ "weeks")
}
 