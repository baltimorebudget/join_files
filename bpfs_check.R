.libPaths("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/r_library")
library(tidyverse)
library(rio)
library(openxlsx)
library(lubridate)
library(dplyr)
library(scales)

devtools::load_all("G:/Analyst Folders/Sara Brumfield/_packages/bbmR")
source("G:/Budget Publications/automation/0_data_prep/bookHelpers/R/formatting.R")

bpfs <- import("G:/Theo/DB Procedures/planningyear-reports/py24/1. CLS/line_items/line_items_2022-11-1.xlsx", which = "Details") %>%
  mutate_if(is.numeric, round, 0)

prior <- import("G:/Fiscal Years/Fiscal 2024/Planning Year/1. CLS/1. Line Item Reports/line_items_2022-10-28-145PM-FINAL.xlsx", which = "FY24 Line Item")

bpfs_changes <- bpfs %>% full_join(prior, by = c("Agency ID",             "Agency Name",           "Program ID",            "Program Name",          "Activity ID",           "Activity Name",        
                                                 "Subactivity ID",        "Subactivity Name",      "Fund ID",               "Fund Name",             "DetailedFund ID",       "DetailedFund Name",    
                                                 "Object ID",            "Object Name",           "Subobject ID",          "Subobject Name",        "Objective ID",          "Objective Name" )) %>%
  filter(`FY24 CLS.x` != `FY24 CLS.y` & `Fund ID` == 1001) %>%
  mutate(`Difference` = `FY24 CLS.y` - `FY24 CLS.x`) %>%
  select(-ends_with("ID"), -`$ - Change vs Adopted`, -`% - Change vs Adopted`, -`Justification`, -`Globals`, -`FY23 Adopted.x`, -`FY23 Adopted.y`, -`Agency Specific BIOs`, -`...23`, -`...24`, -`...25`, -`...26`, -`...27`) %>%
  rename(`BPFS CLS` = `FY24 CLS.x`, `Excel CLS` = `FY24 CLS.y`) 

bpfs_summary <- bpfs_changes %>%
  group_by(`Agency Name`) %>%
  summarize_if(is.numeric, sum, na.rm = TRUE) %>%
  filter(abs(Difference) > 999999 )

bpfs_total_gf <- sum(filter(bpfs, `Fund ID` == 1001)$`FY24 CLS`, na.rm = TRUE)
bpfs_target_gf <- 2122884930
bpfs_diff <- bpfs_target_gf - bpfs_total_gf

# bpfs_check <- bpfs %>% full_join(prior, by = c("Agency ID" = "agency_id",
#                                                           "Program ID" = "program_id",
#                                                           "Activity ID" = "activity_id",
#                                                           "Subactivity ID" = "subactivity_id",
#                                                           "Fund ID" = "fund_id",
#                                                           "DetailedFund ID" = "detailed_fund_id",
#                                                           "Object ID" = "object_id",
#                                                           "Subobject ID" = "subobject_id")) %>%
#   mutate(Check = case_when(!is.na(Amount) & Amount != `FY24 CLS` ~ "Error",
#                            is.na(Amount) ~ "N/A",
#                            !is.na(Amount) & Amount == `FY24 CLS` ~ "Match",
#                            TRUE ~ "Other"))

# check <- bpfs_check %>% filter(`FY24 CLS` != Amount)

# export_excel(check, "Missing from BPFS", "Missing from BPFS.xlsx")

export_excel(bpfs_changes, "All Mismatches", "BPFS Before After Comparison.xlsx", type = "new")
export_excel(bpfs_summary, "Mismatches over 1M", "BPFS Before After Comparison.xlsx", type = "existing")
