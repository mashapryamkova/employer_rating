# Load required packages
library(tidyverse)
library(readxl)
library(writexl)
library(here)
library(rvest)
library(skimr)
library(janitor)
# library(V8)


# Set environment language to English
Sys.setenv(LANGUAGE='en')

#if (!(“rvest” %in% installed.packages())) {
#  install.packages(“rvest”)
#}

# Links
# https://towardsdatascience.com/tidy-web-scraping-in-r-tutorial-and-resources-ac9f72b4fe47
# https://medium.com/@kyleake/wikipedia-data-scraping-with-r-rvest-in-action-3c419db9af2d