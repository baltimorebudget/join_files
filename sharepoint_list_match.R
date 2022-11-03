.libPaths("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/r_library")
library(tidyverse)
library(rio)
library(openxlsx)
library(lubridate)
library(dplyr)
library(scales)

devtools::load_all("G:/Analyst Folders/Sara Brumfield/_packages/bbmR")
source("G:/Budget Publications/automation/0_data_prep/bookHelpers/R/formatting.R")

sharepoint <- import("G:/Fiscal Years/Fiscal 2024/Planning Year/SharePoint Users.xlsx", which = "SharePoint ODataFeed")
  
main_list <- import("C:/Users/sara.brumfield2/Downloads/Agency Contacts.xlsx")

not_in_sharepoint <- anti_join(main_list, sharepoint, by = "Email")

not_in_main <- anti_join(sharepoint, main_list, by = "Email")