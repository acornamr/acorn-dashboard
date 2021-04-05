# # Replace status (character) inito a nice icon
# # via '%>% mutate(status = icon_trans_vec(status))'
# icon_trans <- function(icon) {
#   if(icon == "check")     return("<i class='fa fa-check cl-success'></i>")
#   if(icon == "question")  return("<i class='fa fa-question cl-info'></i>")
# }
# 
# icon_trans_vec <- Vectorize(icon_trans)
# 
# output$table_f01_dta <- renderDT({
#   req(acorn_dta_merged$f01_cor)
#   
#   dta <- acorn_dta_merged$f01_cor %>%
#     mutate(status = icon_trans_vec(status))
#   
#   datatable(dta, escape = FALSE, selection = "single", rownames = FALSE)
# })
# 
# output$table_f01_edits <- renderDT({
#   req(acorn_dta_merged$f01_edit)
#   
#   dta <- acorn_dta_merged$f01_edit %>%
#     mutate(status = icon_trans_vec(status))
#   
#   datatable(dta, escape = FALSE, selection = "none", rownames = FALSE) %>%
#     formatStyle("edit", target = "row",
#                 color = styleEqual(c(1, 0), c('green', 'grey')),
#                 fontWeight = styleEqual(c(1, 0), c('bold', 'normal')))
# })