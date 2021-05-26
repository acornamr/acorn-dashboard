generation_status$log <- c(generation_status$log, 
                           ifelse(all(!is.na(microbio$patid)), "Okay, all patients ids are provided",
                              paste0("Warning: there are ", sum(is.na(microbio$patid)), " rows with missing patid data.")))

generation_status$log <- c(generation_status$log, 
                           ifelse(all(!is.na(microbio$specid)), "Okay, all specid are provided",
                               paste0("Warning: there are ", sum(is.na(microbio$specid)), " rows with missing specid data.")))

generation_status$log <- c(generation_status$log, 
                           ifelse(all(!is.na(microbio$specdate)), "Okay: all specdate are provided",
                                 paste0("Warning: there are ", sum(is.na(microbio$specdate)), " rows with missing specdate data.")))

generation_status$log <- c(generation_status$log, 
                           ifelse(microbio$specdate <= Sys.Date(), "Okay: all specdate happen today or before today",
                                  paste0("Warning: there are ", sum(microbio$specdate > Sys.Date()), " rows with specdate after today.")))

generation_status$log <- c(generation_status$log, 
                           ifelse(all(!is.na(microbio$specgroup)), "Okay: all specgroup are provided",
                                  paste0("Warning: there are ", sum(is.na(microbio$specgroup)), " rows with missing specgroup data.")))

generation_status$log <- c(generation_status$log, 
                           ifelse(all(!is.na(microbio$orgname)), "Okay: all orgname are provided",
                                paste0("Warning: there are ", sum(is.na(microbio$orgname)), " rows with missing orgname data.")))