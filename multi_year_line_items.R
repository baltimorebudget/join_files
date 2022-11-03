.libPaths("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/r_library")
library(tidyverse)
library(rio)
library(openxlsx)
library(lubridate)
library(dplyr)
library(scales)

devtools::load_all("G:/Analyst Folders/Sara Brumfield/_packages/bbmR")
source("G:/Budget Publications/automation/0_data_prep/bookHelpers/R/formatting.R")

fy22_actuals <- import("G:/Fiscal Years/Fiscal 2022/Projections Year/2. Monthly Expenditure Data/Month 12_June Projections/Expenditure 2022-06_Run7.xlsx", which = "CurrentYearExpendituresActLevel")

fy23_adopted <- import("G:/Fiscal Years/Fiscal 2023/Projections Year/1. July 1 Prepwork/Appropriation File/Fiscal 2023 Appropriation File_With_Positions_WK_Accounts.xlsx", which = "FY23 Appropriation File")

fy24_cls <- import("G:/Fiscal Years/Fiscal 2024/Planning Year/1. CLS/1. Line Item Reports/line_items_2022-11-2_CLS FINAL AFTER BPFS.xlsx", which = "Details")
