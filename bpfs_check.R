.libPaths("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/r_library")
library(tidyverse)
library(rio)
library(openxlsx)
library(lubridate)
library(dplyr)
library(scales)

devtools::load_all("G:/Analyst Folders/Sara Brumfield/bbmR")
source("G:/Budget Publications/automation/0_data_prep/bookHelpers/R/formatting.R")

bpfs <- import("G:/Theo/DB Procedures/planningyear-reports/py24/1. CLS/line_items/line_items_2022-10-27.xlsx", which = "Details")

prior <- import("G:/Fiscal Years/Fiscal 2024/Planning Year/1. CLS/1. Line Item Reports/line_items_2022-09-14.xlsx", which = "Details")
  
maggie <- import("G:/Theo/DB Procedures/data_loads/line_item/line_items_2022-10-26_upload to dev.xlsx") %>%
  select(`agency_id`:`Justification (If any)`) %>%
  mutate(Amount = round(Amount, 0))

bpfs_changes <- bpfs %>% full_join(prior, by = c("Agency ID",             "Agency Name",           "Program ID",            "Program Name",          "Activity ID",           "Activity Name",        
                                                 "Subactivity ID",        "Subactivity Name",      "Fund ID",               "Fund Name",             "DetailedFund ID",       "DetailedFund Name",    
                                                 "Object ID",            "Object Name",           "Subobject ID",          "Subobject Name",        "Objective ID",          "Objective Name" )) %>%
  filter(`FY24 CLS.x` != `FY24 CLS.y`)

maggie_check <- bpfs %>% full_join(maggie, by = c("Agency ID" = "agency_id",
                                                          "Program ID" = "program_id",
                                                          "Activity ID" = "activity_id",
                                                          "Subactivity ID" = "subactivity_id",
                                                          "Fund ID" = "fund_id",
                                                          "DetailedFund ID" = "detailed_fund_id",
                                                          "Object ID" = "object_id",
                                                          "Subobject ID" = "subobject_id")) %>%
  mutate(Check = case_when(!is.na(Amount) & Amount != `FY24 CLS` ~ "Error",
                           is.na(Amount) ~ "N/A",
                           !is.na(Amount) & Amount == `FY24 CLS` ~ "Match",
                           TRUE ~ "Other"))

check <- maggie_check %>% filter(`FY24 CLS` != Amount)

export_excel(check, "Missing from BPFS", "Missing from BPFS.xlsx")

export_excel(bpfs_changes, "BPFS Changes", "BPFS Before After Comparison.xlsx")
export_excel(maggie_check, "Test File and BPFS", "BPFS Before After Comparison.xlsx", type = "new")


bpfs_update <- import("BPFS Line Item Table.xlsx")

update_check <- bpfs_update %>% full_join(maggie, by = c("AGENCY_ID" = "agency_id",
                                                               "PROGRAM_ID" = "program_id",
                                                               "ACTIVITY_ID" = "activity_id",
                                                               "SUBACTIVITY_ID" = "subactivity_id",
                                                               "FUND_ID" = "fund_id",
                                                               "DETAILED_FUND_ID" = "detailed_fund_id",
                                                               "OBJECT_ID" = "object_id",
                                                               "SUBOBJECT_ID" = "subobject_id")) %>%
  filter(!is.na(Amount))

export_excel(update_check, "BPFS Update", "BPFS Line Item Table Update.xlsx")