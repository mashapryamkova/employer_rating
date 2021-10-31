# Scrape data from https://rating.hh.ru/history/all/
# Ratings are available for years 2013 through 2020
# Results for 2020 are published in a format different from others

## Scrape data for years 2013-2019

### Generate a string with webpage addresses for each year
links_mult_years <- c()
for (i in 2013:2019) {
  link_one_year <- paste("https://rating.hh.ru/history/rating", i, "/", sep = "")
  links_mult_years <- c(links_mult_years , link_one_year)
}
rm(link_one_year)

### Parse data for each year and bind into a list
empl_mult_years_list <- list()
for (i in 1:length(links_mult_years)) {
  
  # Parse data for each year into a string
  empl_single_year <- links_mult_years[i] %>% 
    read_html(.) %>%
    rvest::html_nodes('body') %>% 
    xml2::xml_find_all("//tr[contains(@class, 'rating_row')]") %>% 
    rvest::html_text() %>%
    
    # Replace line break with a delimiter "|"
    gsub("\n", "\\|", .)  %>%
    
    data.frame(alldata = .) %>%
    # Split columns by delimiter
    
    separate(., alldata, into = c("order", "company", "city", "industry", "hc", "score"), sep = "\\|") %>%
    
    # Trim whitespace
    mutate_if(is.character, str_trim) %>%
    
    # Add column with rating year
    mutate(year = str_remove_all(links_mult_years[i], "[^0-9]"))
 
  # Add to list 
  empl_mult_years_list[[i]] <- empl_single_year
}
### Warning messages are OK: empty cols are removed

# Scrape data for 2020
links_2020 <- c("https://rating.hh.ru/history/rating2020/summary/?tab=giant", 
                "https://rating.hh.ru/history/rating2020/summary/?tab=big",
                "https://rating.hh.ru/history/rating2020/summary/?tab=regular",
                "https://rating.hh.ru/history/rating2020/summary/?tab=small")

# Parse data for year 2020 and bind into a list
empl_2020_list <- list()
for (i in 1:length(links_2020)) {

  # Parse data for each year into a string
  empl_single <- links_2020[i] %>% 
    read_html(.) %>%
    rvest::html_nodes('body') %>% 
    xml2::xml_find_all("//tr[contains(@class, 'rating_row')]") %>% 
    rvest::html_text() %>%
    
    # Replace line break with a delimiter "|"
    gsub("\n", "\\|", .)  %>% 
    
    data.frame(alldata = .) %>%
    
    # Split into columns
    mutate(order = word(alldata, 2, sep = "\\|"),
           company = word(alldata, 6, sep = "\\|"),
           city = case_when(grepl("офисных", alldata) ~ word(alldata, 12, sep = "\\|"), 
                            TRUE ~ word(alldata, 10, sep = "\\|")),
           industry = case_when(grepl("офисных", alldata) ~ word(alldata, 13, sep = "\\|"),
                                TRUE ~ word(alldata, 11, sep = "\\|")),
           hc = as.numeric(NA),
           score = case_when(grepl("офисных", alldata) ~ word(alldata, 14, sep = "\\|"),
                             TRUE ~ word(alldata, 12, sep = "\\|"))) %>%
    
    select(-alldata) %>%

    # Trim whitespaces
    mutate_if(is.character, str_trim) %>%
    
    # Add a column with rating year
    mutate(year = "2020") 

 # Add to list 
  empl_2020_list[[i]] <- empl_single
}

# Transform lists into single df
test <- bind_rows(empl_2020_list)
map(test, ~sum(is.na(.)))
test %>% summarise_all(funs(sum(is.na(.))))

empl_mult_year <- plyr::rbind.fill(bind_rows(empl_mult_years_list), bind_rows(empl_2020_list))

# Save to 02_temporary
ifelse(!dir.exists(here("02_temporary")), dir.create(file.path(here(), "02_temporary")), FALSE)
write_xlsx(empl_mult_year, path = here("02_temporary", paste0("empl_mult_year_", Sys.Date(), ".xlsx")))