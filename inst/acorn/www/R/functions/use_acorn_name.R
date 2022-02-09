# rename with data dictionary variables
use_acorn_name <- function(x, acorn_names, local_names) {
  if(x %in% local_names) {
    name_index <- which(local_names == x)
    if (length(name_index) > 1)  stop("Duplicated names in the data dictionary.")
    return(acorn_names[name_index])
  }
  if(x %in% acorn_names)  return(x)
  return(paste0("NOT_ACORN_COLUMN_", x))
}

use_acorn_name <- Vectorize(use_acorn_name, vectorize.args = "x")