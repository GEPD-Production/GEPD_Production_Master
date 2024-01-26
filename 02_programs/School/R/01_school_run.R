# Purpose:  Run file to pull data from Survey Solutions Server and save it to GEPD-Confidential Drive
# Author: Brian Stacy
# This file will run four R scripts in order.
# Each file can be run independently, but you will be prompted for certain paths that may not be specified
# This file will sequency the R scripts the correct way to produce an
# R markdown html file with high frequency and data quality checks for the school survey.
# 1. school_api.R                       #This file will access the Survey Solutions API and pull rawdata and paradata  
# 2. school_data_cleaner.R              #This file opens the raw data and cleans it to produce our indicators for the Dashboard

# 4. school_data_quality_checks.Rmd     #This file produces an R Markdown report containing several quality checks.

######################################
# Load Required Packages#
######################################
library(tidyverse)
library(here)
library(knitr)
library(markdown)
library(rmarkdown)
######################################
# User Inputs for Run File #
######################################
# Here you need to indicate the path where you replicated the folder structures on your own computer
here() #"C:/Users/wb469649/Documents/Github/GEPD"





#Country name and year of survey
country_name <-'Nigeria - Edo State'
country <- "NGA"
year <- '2023'

#########################
# File paths #
#########################
#The download_folder will be the location of where raw data is downloaded from the API
#The save_folder will be the location of where cleaned data is stored
dir <- here()
data_dir <- here('/01_GEPD_raw_data/')
processed_dir <- here('/03_GEPD_processed_data/')




#########################
# Launch Code
########################


# #launch file to access data from API
need_api=0
school_file<-"epdash.dta"

 
# #launch file to clean data=
rmarkdown::render(here('02_programs','School','R',"02_school_data_cleaner.Rmd"))



