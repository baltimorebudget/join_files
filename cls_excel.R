.libPaths("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/r_library")
library(tidyverse)
library(rio)
library(openxlsx)
library(lubridate)
library(dplyr)

devtools::load_all("G:/Analyst Folders/Sara Brumfield/bbmR")

df_global <- import("G:/Analyst Folders/Sara Brumfield/exp_planning_year/1_cls_join_files/FY24 CLS - 10.20.2022 - For Tollgate I.xlsx",which = "Details") %>%
  select(-Justification, -`$ - Change vs Adopted`, -`% - Change vs Adopted`, -`FY24 CLS`, -`FY23 Adopted`)

df_bios <- import("G:/Analyst Folders/Sara Brumfield/exp_planning_year/1_cls_join_files/FY24 CLS - 10.24.2022 - No Globals.xlsx", which = "Details") %>%
  select(-Justification, -`$ - Change vs Adopted`, -`% - Change vs Adopted`, -`FY24 CLS`, -`True BIO?`, -`Global Adjustments`)

anti_join_x <- anti_join(df_global, df_bios, by = c("Agency ID",         "Agency Name",       "Program ID",        "Program Name",      "Activity ID",       "Activity Name",     "Subactivity ID",   
                                                      "Subactivity Name",  "Fund ID",           "Fund Name",         "DetailedFund ID",   "DetailedFund Name", "Object ID",        "Object Name",      
                                                      "Subobject ID",      "Subobject Name",    "Objective ID",      "Objective Name"))

anti_join_y <- anti_join(df_bios, df_global, by = c("Agency ID",         "Agency Name",       "Program ID",        "Program Name",      "Activity ID",       "Activity Name",     "Subactivity ID",   
                                                      "Subactivity Name",  "Fund ID",           "Fund Name",         "DetailedFund ID",   "DetailedFund Name", "Object ID",        "Object Name",      
                                                      "Subobject ID",      "Subobject Name",    "Objective ID",      "Objective Name"))

export_excel(anti_join_y, "Missing from Tollgate File", "Missing from Tollgate File.xlsx")
export_excel(anti_join_x, "Missing from Globals File", "Missing from Globals File.xlsx")

df <- full_join(df_bios, df_global, by = c("Agency ID",         "Agency Name",       "Program ID",        "Program Name",      "Activity ID",       "Activity Name",     "Subactivity ID",   
                                                    "Subactivity Name",  "Fund ID",           "Fund Name",         "DetailedFund ID",   "DetailedFund Name", "Object ID",        "Object Name",      
                                                    "Subobject ID",      "Subobject Name",    "Objective ID",      "Objective Name"))%>%
  mutate_if(is.numeric, replace_na, 0) %>%
  mutate(`FY24 CLS` = `FY23 Adopted` + Globals + `Agency Specific BIOs`,
         `$ Change` = `FY24 CLS` - `FY23 Adopted`,
         `% Change` = round((`FY24 CLS` - `FY23 Adopted`) / `FY23 Adopted`, 4) * 100)

pivot <- df %>% 
  group_by(`Agency Name`, `Fund Name`) %>%
  summarise(Total = sum(`FY24 CLS`, na.rm = TRUE)) %>%
  pivot_wider(names_from = `Fund Name`, values_from = Total)

sum(pivot$General, na.rm = TRUE)

export_excel(df, "Line Items", "FY24 CLS.xlsx", type = "new", save = TRUE)
export_excel(pivot, "Fund Summary", "FY24 CLS.xlsx", type = "existing", save = TRUE)