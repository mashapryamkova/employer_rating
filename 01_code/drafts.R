########

link <- 'https://rating.hh.ru/profile/rating2019/'

# Парсим содержание рейтинга
single_year_source <- link %>% 
  read_html(.) %>%
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//tr[contains(@class, 'rating_row')]") %>% 
  rvest::html_text() %>%
  gsub("\n", "*", .)

# Разбиваем данные по столбцам
# Очищаем датасет: удаляем лишние пробелы
single_year_clean <- single_year_source %>% 
  data.frame(alldata = .) %>%
  separate(., alldata, into = c("order", "company", "city", "indistry", "hc", "score"), sep = "\\*") %>%
  mutate_if(is.character, str_trim) %>% 
  mutate(order = as.numeric(order),
         hc = factor(hc, levels = c("от 100 до 500 человек", "от 500 до 1000 человек", "более 1000 человек")),
         score = as.numeric(str_replace(score, ",", ".")))


link_2020 <- "https://rating.hh.ru/history/rating2020/summary/?tab=giant"
single_year_source_2020 <- link_2020 %>% 
  read_html(.) %>%
  rvest::html_nodes('body') %>% 
  xml2::xml_find_all("//tr[contains(@class, 'rating_row')]") %>% 
  rvest::html_text() %>%
  gsub("\n", "\\|", .)

single_year_clean <- single_year_source %>% 
  data.frame(alldata = .) %>%
  mutate(order = word(alldata,2,sep = "\\|"),
         company = word(alldata, 5,sep = "\\|"),
         city = case_when(grepl("офисных", alldata) ~ word(alldata, 10, sep = "\\|"), 
                          TRUE ~ word(alldata, 8, sep = "\\|")),
         industry = case_when(grepl("офисных", alldata) ~ word(alldata, 11, sep = "\\|"),
                              TRUE ~ word(alldata, 9, sep = "\\|")),
         hc = as.numeric(NA),
         score = case_when(grepl("офисных", alldata) ~ word(alldata, 12, sep = "\\|"),
                           TRUE ~ word(alldata, 10, sep = "\\|"))) %>%
  select(-alldata) %>%
  mutate_if(is.character, str_trim) %>%
  mutate(year = str_remove_all(links_all_years[i], "[^0-9]"))


