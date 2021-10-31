# If df not loaded to memory - load last file from 02_temporary
if(!exists("empl_mult_year")) { 
  
  file_list <- list.files(path = here("02_temporary"))
  
  if(length(file_list) == 1) {
    mult_year_df <- read_excel(path = here("02_temporary", file_list))
  } else {
    
    file_create_date <- as.Date(substr(file_list, 16, 25))
    last_file <- file_list[which.max(file_create_date)]
    mult_year_df <- read_excel(path = here("02_temporary", last_file))
    
  }
  

  } 

# Exploratory analysis
glimplse(mult_year_df)
skimr::skim(mult_year_df)
companies <- tabyl(mult_year_df, company)

# Clean data
hh_data_clean <- mult_year_df %>%
  mutate(company = str_replace_all(company, '\\*|"|<>', ""))

companies <- tabyl(hh_data_clean, company)

