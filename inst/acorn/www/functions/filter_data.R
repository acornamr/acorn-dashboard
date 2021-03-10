# Function that returns a filtered dataset
filter_data <- function(data, input) {
  
  if( is.null(data) ) return(NULL)
  
  data <- data %>%
    filter(
      sex %in% input$filter_sex
    )
  
  return(data)
}

# Function that keeps only "Blood" specimen types
fun_filter_blood_only <- function(data)  data %>% filter(specimen_type == "Blood")