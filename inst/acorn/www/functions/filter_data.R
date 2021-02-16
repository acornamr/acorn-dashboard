# Function that returns a filtered dataset
filter_data <- function(data, input) {
  
  if( is.null(data) ) return(NULL)
  
  data <- data %>%
    filter(
      sex %in% input$filter_sex
    )
  
  return(data)
}