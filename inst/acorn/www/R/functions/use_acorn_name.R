# rename with data dictionary variables
use_acorn_name <- function(x, acorn_names, local_names) {
  if(x %in% local_names)  return(acorn_names[which(local_names == x)])
  if(x %in% acorn_names)  return(x)
  return(paste0("NOT_ACORN_COLUMN_", x))
}

use_acorn_name <- Vectorize(use_acorn_name, vectorize.args = "x")