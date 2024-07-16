# Load libraries
library(tidyverse)
library(haven)
library(stringr)
library(Hmisc)
library(survey)
library(here)
library(readxl)
library(srvyr)
library(writexl)
#Country name and year of survey
country_name <-'Pakistan-Punjab'
country <- "PAK"
year <- '2023'
software <- "Stata" #choose R or Stata


#########################
# File paths #
#########################

dir <- here()
data_dir <- here('01_GEPD_raw_data/')
processed_dir <- here('03_GEPD_processed_data/')



## Summary Statistics
strata <- c('strata')

options(survey.lonely.psu="adjust")

# load indicator template
GEPD_template <- read_csv(here("04_GEPD_Indicators","GEPD_indicator_template.csv"))

#load main files
school_dta <- read_dta(here(processed_dir,"School","Confidential","Cleaned", paste0("school_",software,".dta")))
teachers_dta <- read_dta(here(processed_dir,"School","Confidential","Cleaned", paste0("teachers_",software,".dta"))) %>%
  filter(!is.na(teachers_id))
first_grade <- read_dta(here(processed_dir,"School","Confidential","Cleaned", paste0("first_grade_",software,".dta")))
fourth_grade <- read_dta(here(processed_dir,"School","Confidential","Cleaned", paste0("fourth_grade_",software,".dta")))
public_officials_dta <- read_dta(here(processed_dir,"Public_Officials","Confidential", "public_officials.dta"))
expert_df <- read_dta(here(processed_dir,"Policy_Survey", "expert_dta_final.dta"))
defacto_dta_learners <- read_excel(here(processed_dir,"Other_Indicators", "Learners_defacto_indicators.xlsx"))
finance_df <- read_excel(here(processed_dir,"Other_Indicators", "Finance_scoring.xlsx"))


#some reshaping

finance_df_shaped<-data.frame(t(finance_df[-1]), stringsAsFactors = FALSE)
colnames(finance_df_shaped) <- finance_df$Question

#create indicatorsTS
finance_df_final <- finance_df_shaped %>%
  rownames_to_column() %>%
  filter(rowname=='Scores') %>%
  select(-rowname)

defacto_dta_learners_shaped<-data.frame(t(defacto_dta_learners[-1]), stringsAsFactors = FALSE)
colnames(defacto_dta_learners_shaped) <- defacto_dta_learners$Question

#create indicators
defacto_dta_learners_final <- defacto_dta_learners_shaped %>%
  rownames_to_column() %>%
  filter(rowname=='Scoring') %>%
  select(-rowname)
#Create a function which will generate new binary variable using case_when, but 
#if value is misisng it will generate binary variable to be missing
#This is done a lot so will create function for it.
#e.g. school_absent=case_when(
#         m2sbq6_efft==6  ~ 1,
#         m2sbq6_efft!=6   ~ 0,
#         is.na(m2sbq6_efft) ~ as.numeric(NA))


bin_var <- function(var, val) {
  case_when(
    var==val  ~ 1,
    var!=val   ~ 0,
    is.na(var) ~ as.numeric(NA))
}


bin_var_NA0 <- function(var, val) {
  case_when(
    var==val  ~ 1,
    var!=val   ~ 0,
    is.na(var) ~ 0)
}

#create function to extract mean and sd from survey data
indicator_stats <- function(name, indicator, dataset, tag,  unit) {
  
  name <- str_trim(name)
  indicator <- str_trim(indicator)
  
  if (dataset=='school') {
    
    
    if (unit=="All") {
      
      stat_df<-school_dta
      
      
    } else if (unit=="Female") {
      
      stat_df<-school_dta %>%
        filter(m7saq10==2)
      
    } else if (unit=="Male") {
      
      stat_df<-school_dta %>%
        filter(m7saq10==1)
      
    } else if (unit=="Rural") {
      
      stat_df<-school_dta %>%
        filter(urban_rural=="Rural")
      
    } else if (unit=="Urban") {
      
      stat_df<-school_dta %>%
        filter(urban_rural=="Urban")
      
    }
    
    stat_df %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator))
      ) %>%
      filter(!is.na(school_weight)) %>%
      filter(!is.infinite(school_weight)) %>%
      select(VALUE, one_of(strata), school_weight ) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='value') %>%
      as_survey_design(strata=strata,
                       weight=school_weight) %>%
      ungroup() %>%
      summarise(mean=survey_mean(value, na.rm=T, vartype=c('se', 'ci','var')),
                N=sum(!(is.na(value) | is.na(school_weight) ))) %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything())
    
    
  } else if  (dataset=='teacher_abs') {
    
    
    if (unit=="All") {
      
      stat_df<-teachers_dta
      
      
    } else if (unit=="Female") {
      
      stat_df<-teachers_dta %>%
        filter(m2saq3==2)
      
    } else if (unit=="Male") {
      
      stat_df<-teachers_dta %>%
        filter(m2saq3==1)
      
    } else if (unit=="Rural") {
      
      stat_df<-teachers_dta %>%
        filter(urban_rural=="Rural")
      
    } else if (unit=="Urban") {
      
      stat_df<-teachers_dta %>%
        filter(urban_rural=="Urban")
      
    }
    
    
    
    stat_df %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator))
      ) %>%
      filter(!is.na(school_weight)) %>%
      filter(!is.infinite(school_weight)) %>%
      filter(!is.na(teacher_abs_weight)) %>%
      select(VALUE, one_of(strata), school_weight, teacher_abs_weight, school_code, teachers_id ) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='value') %>%
      as_survey_design(
        id=c(school_code, teachers_id),
        strata=strata,
        weight=c(school_weight, teacher_abs_weight)) %>%
      ungroup() %>%
      summarise(mean=survey_mean(value, na.rm=T, vartype=c('se', 'ci','var')),
                N=sum(!(is.na(value) | is.na(school_weight) | is.na(teacher_abs_weight)))) %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything())
    
    
  } else if  (dataset=='teacher_questionnaire') {
    
    
    if (unit=="All") {
      
      stat_df<-teachers_dta
      
      
    } else if (unit=="Female") {
      
      stat_df<-teachers_dta %>%
        filter(m2saq3==2)
      
    } else if (unit=="Male") {
      
      stat_df<-teachers_dta %>%
        filter(m2saq3==1)
      
    } else if (unit=="Rural") {
      
      stat_df<-teachers_dta %>%
        filter(urban_rural=="Rural")
      
    } else if (unit=="Urban") {
      
      stat_df<-teachers_dta %>%
        filter(urban_rural=="Urban")
      
    }
    
    
    
    stat_df %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator))
      ) %>%
      filter(!is.na(school_weight)) %>%
      filter(!is.infinite(school_weight)) %>%
      filter(!is.na(teacher_questionnaire_weight)) %>%
      select(VALUE, one_of(strata), school_weight, teacher_questionnaire_weight, school_code, teachers_id ) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='value') %>%
      as_survey_design(
        id=c(school_code, teachers_id),
        strata=strata,
        weight=c(school_weight, teacher_questionnaire_weight)) %>%
      ungroup() %>%
      summarise(mean=survey_mean(value, na.rm=T, vartype=c('se', 'ci','var')),
                N=sum(!(is.na(value) | is.na(school_weight) | is.na(teacher_questionnaire_weight)))) %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything())
    
    
  } else if  (dataset=='teacher_content') {
    
    
    if (unit=="All") {
      
      stat_df<-teachers_dta
      
      
    } else if (unit=="Female") {
      
      stat_df<-teachers_dta %>%
        filter(m2saq3==2)
      
    } else if (unit=="Male") {
      
      stat_df<-teachers_dta %>%
        filter(m2saq3==1)
      
    } else if (unit=="Rural") {
      
      stat_df<-teachers_dta %>%
        filter(urban_rural=="Rural")
      
    } else if (unit=="Urban") {
      
      stat_df<-teachers_dta %>%
        filter(urban_rural=="Urban")
      
    }
    
    
    
    stat_df %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator))
      ) %>%
      filter(!is.na(school_weight)) %>%
      filter(!is.na(teacher_content_weight)) %>%
      filter(!is.infinite(school_weight)) %>%
      select(VALUE, one_of(strata), school_weight, teacher_content_weight, school_code, teachers_id ) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='value') %>%
      as_survey_design(
        id=c(school_code, teachers_id),
        strata=strata,
        weight=c(school_weight, teacher_content_weight)) %>%
      ungroup() %>%
      summarise(mean=survey_mean(value, na.rm=T, vartype=c('se', 'ci','var')),
                N=sum(!(is.na(value) | is.na(school_weight) | is.na(teacher_content_weight)))) %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything())
    
    
  } else if  (dataset=='teacher_pedagogy') {
    
    
    if (unit=="All") {
      
      stat_df<-teachers_dta
      
      
    } else if (unit=="Female") {
      
      stat_df<-teachers_dta %>%
        filter(m2saq3==2)
      
    } else if (unit=="Male") {
      
      stat_df<-teachers_dta %>%
        filter(m2saq3==1)
      
    } else if (unit=="Rural") {
      
      stat_df<-teachers_dta %>%
        filter(urban_rural=="Rural")
      
    } else if (unit=="Urban") {
      
      stat_df<-teachers_dta %>%
        filter(urban_rural=="Urban")
      
    }
    
    
    
    stat_df %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator))
      ) %>%
      filter(!is.na(school_weight)) %>%
      filter(!is.infinite(school_weight)) %>%
      filter(!is.na(teacher_pedagogy_weight)) %>%
      select(VALUE, one_of(strata), school_weight, teacher_pedagogy_weight, school_code, teachers_id ) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='value') %>%
      as_survey_design(
        id=c(school_code, teachers_id),
        strata=strata,
        weight=c(school_weight, teacher_pedagogy_weight)) %>%
      ungroup() %>%
      summarise(mean=survey_mean(value, na.rm=T, vartype=c('se', 'ci','var')),
                N=sum(!(is.na(value) | is.na(school_weight) | is.na(teacher_pedagogy_weight)))) %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything())
    
    
  } else if  (dataset=='fourth_grade') {
    
    
    if (unit=="All") {
      
      stat_df<-fourth_grade
      
      
    } else if (unit=="Female") {
      
      stat_df<-fourth_grade %>%
        filter(m8s1q3==2)
      
    } else if (unit=="Male") {
      
      stat_df<-fourth_grade %>%
        filter(m8s1q3==1)
      
    } else if (unit=="Rural") {
      
      stat_df<-fourth_grade %>%
        filter(urban_rural=="Rural")
      
    } else if (unit=="Urban") {
      
      stat_df<-fourth_grade %>%
        filter(urban_rural=="Urban")
      
    }
    
    
    
    stat_df %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator))
      ) %>%
      filter(!is.na(school_weight)) %>%
      filter(!is.na(g4_stud_weight)) %>%
      filter(!is.infinite(school_weight)) %>%
      select(VALUE, one_of(strata), school_weight, g4_stud_weight, school_code, fourth_grade_assessment__id ) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='value') %>%
      as_survey_design(
        id=c(school_code, fourth_grade_assessment__id),
        strata=strata,
        weight=c(school_weight, g4_stud_weight)) %>%
      ungroup() %>%
      summarise(mean=survey_mean(value, na.rm=T, vartype=c('se', 'ci','var')),
                N=sum(!(is.na(value) | is.na(school_weight) | is.na(g4_stud_weight)))) %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything())
    
    
  } else if  (dataset=='first_grade') {
    
    
    if (unit=="All") {
      
      stat_df<-first_grade
      
      
    } else if (unit=="Female") {
      
      stat_df<-first_grade %>%
        filter(m6s1q3==2)
      
    } else if (unit=="Male") {
      
      stat_df<-first_grade %>%
        filter(m6s1q3==1)
      
    } else if (unit=="Rural") {
      
      stat_df<-first_grade %>%
        filter(urban_rural=="Rural")
      
    } else if (unit=="Urban") {
      
      stat_df<-first_grade %>%
        filter(urban_rural=="Urban")
      
    }
    
    
    
    stat_df %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator))
      ) %>%
      filter(!is.na(school_weight)) %>%
      filter(!is.na(g1_stud_weight)) %>%
      filter(!is.infinite(school_weight)) %>%
      select(VALUE, one_of(strata), school_weight, g1_stud_weight, school_code, ecd_assessment__id ) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='value') %>%
      as_survey_design(
        id=c(school_code, ecd_assessment__id),
        strata=strata,
        weight=c(school_weight, g1_stud_weight)) %>%
      ungroup() %>%
      summarise(mean=survey_mean(value, na.rm=T, vartype=c('se', 'ci','var')),
                N=sum(!(is.na(value) | is.na(school_weight) | is.na(g1_stud_weight)))) %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything())
    
    
  } else if (dataset== 'public_officials') {
    
    if (unit=="All") {
      
      stat_df<-public_officials_dta
      
      
    } else if (unit=="central") {
      
      stat_df<-public_officials_dta %>%
        filter(govt_tier=="Ministry of Education (or equivalent)")
      
    } else if (unit=="regional") {
      
      stat_df<-public_officials_dta %>%
        filter(rural=='Regional office (or equivalent)')
      
    }
    else if (unit=="district") {
      
      stat_df<-public_officials_dta %>%
        filter(rural=='District office (or equivalent)')
      
    }
    
    stat_df %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator)),
        ipw=1
      ) %>%
      select(VALUE, ipw) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='value') %>%
      as_survey_design(
        weight=ipw) %>%
      ungroup() %>%
      summarise(mean=survey_mean(value, na.rm=T, vartype=c('se', 'ci','var')),
                N=sum(!is.na(value))) %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything())
    
  } else if (dataset== 'policy_survey') {
   
    stat_df <- expert_df %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator))      ) %>%
      select(VALUE) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='mean') %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything()) %>%
      mutate(mean_se=as.numeric(NA),
             mean_low=as.numeric(NA),
             mean_upp=as.numeric(NA),
             mean_var=as.numeric(NA),
             N=as.numeric(1)) %>%
      select(-indicators)
    
     
  } else if (dataset== 'finance') {
    
    stat_df <- finance_df_final %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator))      ) %>%
      select(VALUE) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='mean') %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything()) %>%
      mutate(mean_se=as.numeric(NA),
             mean_low=as.numeric(NA),
             mean_upp=as.numeric(NA),
             mean_var=as.numeric(NA),
             N=as.numeric(1)) %>%
      select(-indicators)
    
    
  } else if (dataset== 'learners') {
    
    stat_df <- defacto_dta_learners_final %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator))      ) %>%
      select(VALUE) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='mean') %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything()) %>%
      mutate(mean_se=as.numeric(NA),
             mean_low=as.numeric(NA),
             mean_upp=as.numeric(NA),
             mean_var=as.numeric(NA),
             N=as.numeric(1)) %>%
      select(-indicators)
    
    
  } else if (dataset== 'aggregate') {
    
    stat_df <- indicator_data %>%
      filter(Series %in% eval(parse(text=tag))) %>%
      select(Series, mean) %>%
      #pivot_wider
      pivot_wider(names_from = Series, values_from = mean) %>%
      #create column named indicator that evaluates expression in indicator argument
      mutate(
        VALUE=eval(parse(text=indicator))      ) %>%
      select(VALUE) %>%
      pivot_longer(cols='VALUE',
                   names_to = 'indicators',
                   values_to='mean') %>%
      as_tibble() %>%
      mutate(Series=name) %>%
      select(Series, everything()) %>%
      mutate(mean_se=as.numeric(NA),
             mean_low=as.numeric(NA),
             mean_upp=as.numeric(NA),
             mean_var=as.numeric(NA),
             N=as.numeric(1)) %>%
      select(-indicators)
    
  }
  
  
  
  
}


#######################################
# Proficiency on GEPD Assessment	(LERN)
#######################################

#api_final[grep('LERN', api_final$Series),1]

indicators <-   list(
  c("SE.PRM.LERN",'student_proficient', "fourth_grade", "LERN",  "All"),
  c("SE.PRM.LERN.1",'student_proficient', "fourth_grade", "LERN",  "All"),
  c("SE.PRM.LERN.1.F",'student_proficient', "fourth_grade", "LERN",  "Female"),
  c("SE.PRM.LERN.1.M",'student_proficient', "fourth_grade", "LERN",  "Male"),
  c("SE.PRM.LERN.1.R",'student_proficient', "fourth_grade", "LERN",  "Rural"),
  c("SE.PRM.LERN.1.U",'student_proficient', "fourth_grade", "LERN",  "Urban"),
  c("SE.PRM.LERN.2",'literacy_student_proficient', "fourth_grade", "LERN",  "All"),  
  c("SE.PRM.LERN.2.F",'literacy_student_proficient', "fourth_grade", "LERN",  "Female"),
  c("SE.PRM.LERN.2.M",'literacy_student_proficient', "fourth_grade", "LERN",  "Male"),
  c("SE.PRM.LERN.2.R",'literacy_student_proficient', "fourth_grade", "LERN",  "Rural"),
  c("SE.PRM.LERN.2.U",'literacy_student_proficient', "fourth_grade", "LERN",  "Urban"),
  c("SE.PRM.LERN.3",'math_student_proficient', "fourth_grade", "LERN",  "All"),
  c("SE.PRM.LERN.3.F",'math_student_proficient', "fourth_grade", "LERN",  "Female"),
  c("SE.PRM.LERN.3.M",'math_student_proficient', "fourth_grade", "LERN",  "Male"),
  c("SE.PRM.LERN.3.R",'math_student_proficient', "fourth_grade", "LERN",  "Rural"),
  c("SE.PRM.LERN.3.U",'math_student_proficient', "fourth_grade", "LERN",  "Urban"),
  
  #######################################
  # Teacher Effort		(EFFT)
  #######################################
  
  
  c("SE.PRM.EFFT"     ,"100-sch_absence_rate", "teacher_abs", "EFFT",  "All"),
  c("SE.PRM.EFFT.1"   ,"100-absence_rate", "teacher_abs", "EFFT",  "All"),
  c("SE.PRM.EFFT.1.F" ,"100-absence_rate", "teacher_abs", "EFFT",  "Female"),
  c("SE.PRM.EFFT.1.M" ,"100-absence_rate", "teacher_abs", "EFFT",  "Male"),
  c("SE.PRM.EFFT.1.R" ,"100-absence_rate", "teacher_abs", "EFFT",  "Rural"),
  c("SE.PRM.EFFT.1.U" ,"100-absence_rate", "teacher_abs", "EFFT",  "Urban"),
  c("SE.PRM.EFFT.2"   ,"100-sch_absence_rate", "teacher_abs", "EFFT",  "All"),  
  c("SE.PRM.EFFT.2.F" ,"100-sch_absence_rate", "teacher_abs", "EFFT",  "Female"),
  c("SE.PRM.EFFT.2.M" ,"100-sch_absence_rate", "teacher_abs", "EFFT",  "Male"),
  c("SE.PRM.EFFT.2.R" ,"100-sch_absence_rate", "teacher_abs", "EFFT",  "Rural"),
  c("SE.PRM.EFFT.2.U" ,"100-sch_absence_rate", "teacher_abs", "EFFT",  "Urban"),
  
  
  
  
  #######################################
  # 	Teacher Content Knowledge	(CONT)
  #######################################
  
  
  c("SE.PRM.CONT    ", "content_proficiency", "teacher_content", "CONT",  "All"),
  c("SE.PRM.CONT.1  ", "content_proficiency", "teacher_content", "CONT",  "All"),
  c("SE.PRM.CONT.1.F", "content_proficiency", "teacher_content", "CONT",  "Female"),
  c("SE.PRM.CONT.1.M", "content_proficiency", "teacher_content", "CONT",  "Male"),
  c("SE.PRM.CONT.1.R", "content_proficiency", "teacher_content", "CONT",  "Rural"),
  c("SE.PRM.CONT.1.U", "content_proficiency", "teacher_content", "CONT",  "Urban"),
  c("SE.PRM.CONT.2  ", "literacy_content_proficiency", "teacher_content", "CONT",  "All"),  
  c("SE.PRM.CONT.2.F", "literacy_content_proficiency", "teacher_content", "CONT",  "Female"),
  c("SE.PRM.CONT.2.M", "literacy_content_proficiency", "teacher_content", "CONT",  "Male"),
  c("SE.PRM.CONT.2.R", "literacy_content_proficiency", "teacher_content", "CONT",  "Rural"),
  c("SE.PRM.CONT.2.U", "literacy_content_proficiency", "teacher_content", "CONT",  "Urban"),
  c("SE.PRM.CONT.3  ", "math_content_proficiency", "teacher_content", "CONT",  "All"),
  c("SE.PRM.CONT.3.F", "math_content_proficiency", "teacher_content", "CONT",  "Female"),
  c("SE.PRM.CONT.3.M", "math_content_proficiency", "teacher_content", "CONT",  "Male"),
  c("SE.PRM.CONT.3.R", "math_content_proficiency", "teacher_content", "CONT",  "Rural"),
  c("SE.PRM.CONT.3.U", "math_content_proficiency", "teacher_content", "CONT",  "Urban"),
  
  
  #######################################
  # Teacher Pedagogical Skills	(PEDG)
  #######################################
  
  
  c("SE.PRM.PEDG     ","100*as.numeric(teach_score>=3)", "teacher_pedagogy", "PEDG",  "All"),
  c("SE.PRM.PEDG.1   ","100*as.numeric(teach_score>=3)", "teacher_pedagogy", "PEDG",  "All"),
  c("SE.PRM.PEDG.1.F", "100*as.numeric(teach_score>=3)", "teacher_pedagogy", "PEDG",  "Female"),
  c("SE.PRM.PEDG.1.M", "100*as.numeric(teach_score>=3)", "teacher_pedagogy", "PEDG",  "Male"),
  c("SE.PRM.PEDG.1.R ","100*as.numeric(teach_score>=3)", "teacher_pedagogy", "PEDG",  "Rural"),
  c("SE.PRM.PEDG.1.U ","100*as.numeric(teach_score>=3)", "teacher_pedagogy", "PEDG",  "Urban"),
  c("SE.PRM.PEDG.2   ","100*as.numeric(classroom_culture>=3)", "teacher_pedagogy", "PEDG",  "All"),
  c("SE.PRM.PEDG.2.F", "100*as.numeric(classroom_culture>=3)", "teacher_pedagogy", "PEDG",  "Female"),
  c("SE.PRM.PEDG.2.M", "100*as.numeric(classroom_culture>=3)", "teacher_pedagogy", "PEDG",  "Male"),
  c("SE.PRM.PEDG.2.R ","100*as.numeric(classroom_culture>=3)", "teacher_pedagogy", "PEDG",  "Rural"),
  c("SE.PRM.PEDG.2.U ","100*as.numeric(classroom_culture>=3)", "teacher_pedagogy", "PEDG",  "Urban"),
  c("SE.PRM.PEDG.3   ","100*as.numeric(instruction>=3)", "teacher_pedagogy", "PEDG",  "All"),
  c("SE.PRM.PEDG.3.F", "100*as.numeric(instruction>=3)", "teacher_pedagogy", "PEDG",  "Female"),
  c("SE.PRM.PEDG.3.M", "100*as.numeric(instruction>=3)", "teacher_pedagogy", "PEDG",  "Male"),
  c("SE.PRM.PEDG.3.R ","100*as.numeric(instruction>=3)", "teacher_pedagogy", "PEDG",  "Rural"),
  c("SE.PRM.PEDG.3.U ","100*as.numeric(instruction>=3)", "teacher_pedagogy", "PEDG",  "Urban"),
  c("SE.PRM.PEDG.4   ","100*as.numeric(socio_emotional_skills>=3)", "teacher_pedagogy", "PEDG",  "All"),
  c("SE.PRM.PEDG.4.F", "100*as.numeric(socio_emotional_skills>=3)", "teacher_pedagogy", "PEDG",  "Female"),
  c("SE.PRM.PEDG.4.M", "100*as.numeric(socio_emotional_skills>=3)", "teacher_pedagogy", "PEDG",  "Male"),
  c("SE.PRM.PEDG.4.R ","100*as.numeric(socio_emotional_skills>=3)", "teacher_pedagogy", "PEDG",  "Rural"),
  c("SE.PRM.PEDG.4.U ","100*as.numeric(socio_emotional_skills>=3)", "teacher_pedagogy", "PEDG",  "Urban"),


  #######################################
  # 	Basic Inputs	(INPT)
  #######################################
  
  
  #(De Facto) Average number of classroom inputs in classrooms	
  c("SE.PRM.INPT     ","inputs", "school", "INPT",  "All"),
  c("SE.PRM.INPT.1   ","inputs", "school", "INPT",  "All"),
  c("SE.PRM.INPT.1.R ","inputs", "school", "INPT",  "Rural"),
  c("SE.PRM.INPT.1.U ","inputs", "school", "INPT",  "Urban"),
  c("SE.PRM.INPT.3   ","33*textbooks+ 67*pens_etc", "school", "INPT",  "All") ,
  c("SE.PRM.INPT.3.R ","33*textbooks+ 67*pens_etc", "school", "INPT",  "Rural") ,
  c("SE.PRM.INPT.3.U ","33*textbooks + 67*pens_etc", "school", "INPT",  "Urban"),
  c("SE.PRM.INPT.2","100*blackboard_functional", "school", "INPT",  "All"),
  c("SE.PRM.INPT.2.R ","100*blackboard_functional", "school", "INPT",  "Rural"),
  c("SE.PRM.INPT.2.U ","100*blackboard_functional", "school", "INPT",  "Urban"),
  c("SE.PRM.INPT.4   ","100*share_desk", "school", "INPT",  "All"),
  c("SE.PRM.INPT.4.R ","100*share_desk", "school", "INPT",  "Rural"),
  c("SE.PRM.INPT.4.U ","100*share_desk", "school", "INPT",  "Urban"),
  c("SE.PRM.INPT.5   ","100*access_ict", "school", "INPT",  "All"),
  c("SE.PRM.INPT.5.R ","100*access_ict", "school", "INPT",  "Rural"),
  c("SE.PRM.INPT.5.U ","100*access_ict", "school", "INPT",  "Urban"),
  
  
  
  #######################################
  # 	Basic Infrastructure	(INFR)
  #######################################
  
  
  #(De Facto) Average number of infrastructure aspects present in schools	
  c("SE.PRM.INFR     ","infrastructure	", "school", "INFR",  "All"),
  c("SE.PRM.INFR.1   ","infrastructure	", "school", "INFR",  "All"),
  c("SE.PRM.INFR.1.R ","infrastructure	", "school", "INFR",  "Rural"),
  c("SE.PRM.INFR.1.U ","infrastructure	", "school", "INFR",  "Urban"),
  #(De Facto) Perc","nt of schools with drinking water	
  c("SE.PRM.INFR.2   ","100*drinking_water	", "school", "INFR",  "All"),
  c("SE.PRM.INFR.2.R ","100*drinking_water	", "school", "INFR",  "Rural"),
  c("SE.PRM.INFR.2.U ","100*drinking_water	", "school", "INFR",  "Urban"),
  #(De Facto) Perc","nt of schools with functioning toilets
  c("SE.PRM.INFR.3   ","100*functioning_toilet	", "school", "INFR",  "All"),
  c("SE.PRM.INFR.3.R ","100*functioning_toilet	", "school", "INFR",  "Rural"),
  c("SE.PRM.INFR.3.U ","100*functioning_toilet	", "school", "INFR",  "Urban"),
  #(De Facto) Perc","nt of schools with access to electricity	
  c("SE.PRM.INFR.4   ","100*class_electricity", "school", "INFR",  "All"),
  c("SE.PRM.INFR.4.R ","100*class_electricity", "school", "INFR",  "Rural"),
  c("SE.PRM.INFR.4.U ","100*class_electricity", "school", "INFR",  "Urban"),
  #(De Facto) Perc","nt of schools with access to internet	
  c("SE.PRM.INFR.5   ","100*internet", "school", "INFR",  "All"),
  c("SE.PRM.INFR.5.R ","100*internet", "school", "INFR",  "Rural"),
  c("SE.PRM.INFR.5.U ","100*internet", "school", "INFR",  "Urban"),
  #	(De Facto) Per","ent of schools accessible to children with special needs	
  c("SE.PRM.INFR.6   ","100*disability_accessibility", "school", "INFR",  "All"),
  c("SE.PRM.INFR.6.R ","100*disability_accessibility", "school", "INFR",  "Rural"),
  c("SE.PRM.INFR.6.U ","100*disability_accessibility", "school", "INFR",  "Urban"),
  
  
  #######################################
  # Learning Capacity	(LCAP)
  #######################################
  
  #api_final[grep('LERN', api_final$Series),1]
  
  
  c("SE.PRM.LCAP    ", "ecd_student_proficiency	", "first_grade", "LCAP",  "All"),
  c("SE.PRM.LCAP.R", "ecd_student_proficiency	", "first_grade", "LCAP",  "Rural"),
  c("SE.PRM.LCAP.U", "ecd_student_proficiency	", "first_grade", "LCAP",  "Urban"),  
  c("SE.PRM.LCAP.1  ", "ecd_student_knowledge	", "first_grade", "LCAP",  "All"),
  c("SE.PRM.LCAP.1.F", "ecd_student_knowledge	", "first_grade", "LCAP",  "Female"),
  c("SE.PRM.LCAP.1.M", "ecd_student_knowledge	", "first_grade", "LCAP",  "Male"),
  c("SE.PRM.LCAP.1.R", "ecd_student_knowledge	", "first_grade", "LCAP",  "Rural"),
  c("SE.PRM.LCAP.1.U", "ecd_student_knowledge	", "first_grade", "LCAP",  "Urban"),
  c("SE.PRM.LCAP.2  ", "ecd_math_student_knowledge", "first_grade", "LCAP",  "All"),  
  c("SE.PRM.LCAP.2.F", "ecd_math_student_knowledge", "first_grade", "LCAP",  "Female"),
  c("SE.PRM.LCAP.2.M", "ecd_math_student_knowledge", "first_grade", "LCAP",  "Male"),
  c("SE.PRM.LCAP.2.R", "ecd_math_student_knowledge", "first_grade", "LCAP",  "Rural"),
  c("SE.PRM.LCAP.2.U", "ecd_math_student_knowledge", "first_grade", "LCAP",  "Urban"),
  c("SE.PRM.LCAP.3  ", "ecd_literacy_student_knowledge", "first_grade", "LCAP",  "All"),
  c("SE.PRM.LCAP.3.F", "ecd_literacy_student_knowledge", "first_grade", "LCAP",  "Female"),
  c("SE.PRM.LCAP.3.M", "ecd_literacy_student_knowledge", "first_grade", "LCAP",  "Male"),
  c("SE.PRM.LCAP.3.R", "ecd_literacy_student_knowledge", "first_grade", "LCAP",  "Rural"),
  c("SE.PRM.LCAP.3.U", "ecd_literacy_student_knowledge", "first_grade", "LCAP",  "Urban"),
  c("SE.PRM.LCAP.4  ", "ecd_exec_student_knowledge", "first_grade", "LCAP",  "All"),
  c("SE.PRM.LCAP.4.F", "ecd_exec_student_knowledge", "first_grade", "LCAP",  "Female"),
  c("SE.PRM.LCAP.4.M", "ecd_exec_student_knowledge", "first_grade", "LCAP",  "Male"),
  c("SE.PRM.LCAP.4.R", "ecd_exec_student_knowledge", "first_grade", "LCAP",  "Rural"),
  c("SE.PRM.LCAP.4.U", "ecd_exec_student_knowledge", "first_grade", "LCAP",  "Urban"),
  c("SE.PRM.LCAP.5  ", "ecd_soc_student_knowledge", "first_grade", "LCAP",  "All"),
  c("SE.PRM.LCAP.5.F", "ecd_soc_student_knowledge", "first_grade", "LCAP",  "Female"),
  c("SE.PRM.LCAP.5.M", "ecd_soc_student_knowledge", "first_grade", "LCAP",  "Male"),
  c("SE.PRM.LCAP.5.R", "ecd_soc_student_knowledge", "first_grade", "LCAP",  "Rural"),
  c("SE.PRM.LCAP.5.U", "ecd_soc_student_knowledge", "first_grade", "LCAP",  "Urban"),
  
  
  #######################################
  # Student Attendance	(ATTD)
  #######################################
  
  
  c("SE.PRM.ATTD    ", "student_attendance	", "school", "ATTD",  "All"),
  c("SE.PRM.ATTD.1  ", "student_attendance	", "school", "ATTD",  "All"),
  c("SE.PRM.ATTD.1.F", "student_attendance_female	", "school", "ATTD",  "All"),
  c("SE.PRM.ATTD.1.M", "student_attendance_male	", "school", "ATTD",  "All"),
  c("SE.PRM.ATTD.1.R", "student_attendance	", "school", "ATTD",  "Rural"),
  c("SE.PRM.ATTD.1.U", "student_attendance	", "school", "ATTD",  "Urban"),
  
  
  #######################################
  # Operactional Management (OPMN)
  #######################################
  
  
  c("SE.PRM.OPMN", "operational_management	", "school", "OPMN",  "All"),
  #(De Facto) Average score for the presence and quality of core operational management functions	
  c("SE.PRM.OPMN.1  ", "operational_management	", "school", "OPMN",  "All"),
  c("SE.PRM.OPMN.1.F", "operational_management	", "school", "OPMN",  "Female"),
  c("SE.PRM.OPMN.1.M", "operational_management	", "school", "OPMN",  "Male"),
  c("SE.PRM.OPMN.1.R", "operational_management	", "school", "OPMN",  "Rural"),
  c("SE.PRM.OPMN.1.U", "operational_management	", "school", "OPMN",  "Urban"),
  #(De Facto) Average score for infrastructure repair/maintenance	
  c("SE.PRM.OPMN.2  ", "1+2*vignette_1", "school", "OPMN",  "All"),  
  c("SE.PRM.OPMN.2.F", "1+2*vignette_1", "school", "OPMN",  "Female"),
  c("SE.PRM.OPMN.2.M", "1+2*vignette_1", "school", "OPMN",  "Male"),
  c("SE.PRM.OPMN.2.R", "1+2*vignette_1", "school", "OPMN",  "Rural"),
  c("SE.PRM.OPMN.2.U", "1+2*vignette_1", "school", "OPMN",  "Urban"),
  #(De Facto) Ave,rage score for ensuring  availability of school inputs	
  c("SE.PRM.OPMN.3  ", "1+2*vignette_2", "school", "OPMN",  "All"),
  c("SE.PRM.OPMN.3.F", "1+2*vignette_2", "school", "OPMN",  "Female"),
  c("SE.PRM.OPMN.3.M", "1+2*vignette_2", "school", "OPMN",  "Male"),
  c("SE.PRM.OPMN.3.R", "1+2*vignette_2", "school", "OPMN",  "Rural"),
  c("SE.PRM.OPMN.3.U", "1+2*vignette_2", "school", "OPMN",  "Urban"),
  
  
  
  
  #######################################
  # Instructional Leadership	(ILDR)
  #######################################
  
  
  
  c("SE.PRM.ILDR     ","instructional_leadership		", "teacher_questionnaire", "ILDR",  "All"),
  #(De Facto) Aver,age score for the presence and quality of instructional leadership	
  c("SE.PRM.ILDR.1   ","instructional_leadership		", "teacher_questionnaire", "ILDR",  "All"),
  c("SE.PRM.ILDR.1.F ","instructional_leadership		", "teacher_questionnaire", "ILDR",  "Female"),
  c("SE.PRM.ILDR.1.M ","instructional_leadership		", "teacher_questionnaire", "ILDR",  "Male"),
  c("SE.PRM.ILDR.1.R ","instructional_leadership		", "teacher_questionnaire", "ILDR",  "Rural"),
  c("SE.PRM.ILDR.1.U ","instructional_leadership		", "teacher_questionnaire", "ILDR",  "Urban"),
  #(De Facto) Perc,ent of teachers reporting having had their class observed	
  c("SE.PRM.ILDR.2   ","100*classroom_observed", "teacher_questionnaire", "ILDR",  "All"),  
  c("SE.PRM.ILDR.2.F ","100*classroom_observed", "teacher_questionnaire", "ILDR",  "Female"),
  c("SE.PRM.ILDR.2.M ","100*classroom_observed", "teacher_questionnaire", "ILDR",  "Male"),
  c("SE.PRM.ILDR.2.R ","100*classroom_observed", "teacher_questionnaire", "ILDR",  "Rural"),
  c("SE.PRM.ILDR.2.U ","100*classroom_observed", "teacher_questionnaire", "ILDR",  "Urban"),
  #(De Facto) Perc,ent of teachers reporting that the classroom observation happened recently
  c("SE.PRM.ILDR.3   ","100*classroom_observed_recent", "teacher_questionnaire", "ILDR",  "All"),
  c("SE.PRM.ILDR.3.F ","100*classroom_observed_recent", "teacher_questionnaire", "ILDR",  "Female"),
  c("SE.PRM.ILDR.3.M ","100*classroom_observed_recent", "teacher_questionnaire", "ILDR",  "Male"),
  c("SE.PRM.ILDR.3.R ","100*classroom_observed_recent", "teacher_questionnaire", "ILDR",  "Rural"),
  c("SE.PRM.ILDR.3.U ","100*classroom_observed_recent", "teacher_questionnaire", "ILDR",  "Urban"),
  #(De Facto) Perc,ent of teachers reporting having discussed the results of the classroom observation	
  c("SE.PRM.ILDR.4   ","100*if_else(classroom_observed==1 & m3sdq19_ildr==1,1,0)", "teacher_questionnaire", "ILDR",  "All"),  
  c("SE.PRM.ILDR.4.F ","100*if_else(classroom_observed==1 & m3sdq19_ildr==1,1,0)", "teacher_questionnaire", "ILDR",  "Female"),
  c("SE.PRM.ILDR.4.M ","100*if_else(classroom_observed==1 & m3sdq19_ildr==1,1,0)", "teacher_questionnaire", "ILDR",  "Male"),
  c("SE.PRM.ILDR.4.R ","100*if_else(classroom_observed==1 & m3sdq19_ildr==1,1,0)", "teacher_questionnaire", "ILDR",  "Rural"),
  c("SE.PRM.ILDR.4.U ","100*if_else(classroom_observed==1 & m3sdq19_ildr==1,1,0)", "teacher_questionnaire", "ILDR",  "Urban"),
  #(De Facto) Perc,ent of teachers reporting that the discussion was over 30 minutes	
  c("SE.PRM.ILDR.5   ","100*if_else((classroom_observed==1 & m3sdq19_ildr==1 & m3sdq20_ildr==3),1,0)", "teacher_questionnaire", "ILDR",  "All"),  
  c("SE.PRM.ILDR.5.F ","100*if_else((classroom_observed==1 & m3sdq19_ildr==1 & m3sdq20_ildr==3),1,0)", "teacher_questionnaire", "ILDR",  "Female"),
  c("SE.PRM.ILDR.5.M ","100*if_else((classroom_observed==1 & m3sdq19_ildr==1 & m3sdq20_ildr==3),1,0)", "teacher_questionnaire", "ILDR",  "Male"),
  c("SE.PRM.ILDR.5.R ","100*if_else((classroom_observed==1 & m3sdq19_ildr==1 & m3sdq20_ildr==3),1,0)", "teacher_questionnaire", "ILDR",  "Rural"),
  c("SE.PRM.ILDR.5.U ","100*if_else((classroom_observed==1 & m3sdq19_ildr==1 & m3sdq20_ildr==3),1,0)", "teacher_questionnaire", "ILDR",  "Urban"),
  #(De Facto) Perc,ent of teachers reporting that they were provided with feedback in that discussion	
  c("SE.PRM.ILDR.6   ","100*if_else((classroom_observed==1 & m3sdq19_ildr==1 & m3sdq21_ildr==1),1,0)", "teacher_questionnaire", "ILDR",  "All"),  
  c("SE.PRM.ILDR.6.F ","100*if_else((classroom_observed==1 & m3sdq19_ildr==1 & m3sdq21_ildr==1),1,0)", "teacher_questionnaire", "ILDR",  "Female"),
  c("SE.PRM.ILDR.6.M ","100*if_else((classroom_observed==1 & m3sdq19_ildr==1 & m3sdq21_ildr==1),1,0)", "teacher_questionnaire", "ILDR",  "Male"),
  c("SE.PRM.ILDR.6.R ","100*if_else((classroom_observed==1 & m3sdq19_ildr==1 & m3sdq21_ildr==1),1,0)", "teacher_questionnaire", "ILDR",  "Rural"),
  c("SE.PRM.ILDR.6.U ","100*if_else((classroom_observed==1 & m3sdq19_ildr==1 & m3sdq21_ildr==1),1,0)", "teacher_questionnaire", "ILDR",  "Urban"),
  #(De Facto) Perc,ent of teachers reporting having lesson plans	
  c("SE.PRM.ILDR.7   ","100-100*lesson_plan", "teacher_questionnaire", "ILDR",  "All"),  
  c("SE.PRM.ILDR.7.F ","100-100*lesson_plan", "teacher_questionnaire", "ILDR",  "Female"),
  c("SE.PRM.ILDR.7.M ","100-100*lesson_plan", "teacher_questionnaire", "ILDR",  "Male"),
  c("SE.PRM.ILDR.7.R ","100-100*lesson_plan", "teacher_questionnaire", "ILDR",  "Rural"),
  c("SE.PRM.ILDR.7.U ","100-100*lesson_plan", "teacher_questionnaire", "ILDR",  "Urban"),
  #(De Facto) Perc,ent of teachers reporting that they had discussed their lesson plans with someone else (pricinpal, pedagogical coordinator, another teacher)	
  c("SE.PRM.ILDR.8   ","100*m3sdq24_ildr", "teacher_questionnaire", "ILDR",  "All"),  
  c("SE.PRM.ILDR.8.F ","100*m3sdq24_ildr", "teacher_questionnaire", "ILDR",  "Female"),
  c("SE.PRM.ILDR.8.M ","100*m3sdq24_ildr", "teacher_questionnaire", "ILDR",  "Male"),
  c("SE.PRM.ILDR.8.R ","100*m3sdq24_ildr", "teacher_questionnaire", "ILDR",  "Rural"),
  c("SE.PRM.ILDR.8.U ","100*m3sdq24_ildr", "teacher_questionnaire", "ILDR",  "Urban"),
  
  
  #######################################
  # Principal School Knowledge	(PKNW)
  #######################################
  
  c("SE.PRM.PKNW    ", "principal_knowledge_score		", "school", "PKNW",  "All"),
  #(De Facto) Ave,rage score for the extent to which principals are familiar with certain key aspects of the day-to-day workings of the school		
  c("SE.PRM.PKNW.1  ", "principal_knowledge_score		", "school", "PKNW",  "All"),
  c("SE.PRM.PKNW.1.F", "principal_knowledge_score		", "school", "PKNW",  "Female"),
  c("SE.PRM.PKNW.1.M", "principal_knowledge_score		", "school", "PKNW",  "Male"),
  c("SE.PRM.PKNW.1.R", "principal_knowledge_score		", "school", "PKNW",  "Rural"),
  c("SE.PRM.PKNW.1.U", "principal_knowledge_score		", "school", "PKNW",  "Urban"),
  #(De Facto) Per,cent of principals familiar with teachers' content knowledge	
  c("SE.PRM.PKNW.2  ", "100*rowMeans(select(., add_triple_digit_pknw,complete_sentence_pknw,multiply_double_digit_pknw), na.rm=TRUE )", "school", "PKNW",  "All"),  
  c("SE.PRM.PKNW.2.F", "100*rowMeans(select(., add_triple_digit_pknw,complete_sentence_pknw,multiply_double_digit_pknw), na.rm=TRUE )", "school", "PKNW",  "Female"),
  c("SE.PRM.PKNW.2.M", "100*rowMeans(select(., add_triple_digit_pknw,complete_sentence_pknw,multiply_double_digit_pknw), na.rm=TRUE )", "school", "PKNW",  "Male"),
  c("SE.PRM.PKNW.2.R", "100*rowMeans(select(., add_triple_digit_pknw,complete_sentence_pknw,multiply_double_digit_pknw), na.rm=TRUE )", "school", "PKNW",  "Rural"),
  c("SE.PRM.PKNW.2.U", "100*rowMeans(select(., add_triple_digit_pknw,complete_sentence_pknw,multiply_double_digit_pknw), na.rm=TRUE )", "school", "PKNW",  "Urban"),
  #(De Facto) Per,cent of principals familiar with teachers' experience	
  c("SE.PRM.PKNW.3  ", "100*experience_pknw", "school", "PKNW",  "All"),
  c("SE.PRM.PKNW.3.F", "100*experience_pknw", "school", "PKNW",  "Female"),
  c("SE.PRM.PKNW.3.M", "100*experience_pknw", "school", "PKNW",  "Male"),
  c("SE.PRM.PKNW.3.R", "100*experience_pknw", "school", "PKNW",  "Rural"),
  c("SE.PRM.PKNW.3.U", "100*experience_pknw", "school", "PKNW",  "Urban"),
  #(De Facto) Per,cent of principals familiar with availability of classroom inputs	
  c("SE.PRM.PKNW.4  ", "100*rowMeans(select(., textbooks_pknw,blackboard_pknw), na.rm=TRUE )", "school", "PKNW",  "All"),  
  c("SE.PRM.PKNW.4.F", "100*rowMeans(select(., textbooks_pknw,blackboard_pknw), na.rm=TRUE )", "school", "PKNW",  "Female"),
  c("SE.PRM.PKNW.4.M", "100*rowMeans(select(., textbooks_pknw,blackboard_pknw), na.rm=TRUE )", "school", "PKNW",  "Male"),
  c("SE.PRM.PKNW.4.R", "100*rowMeans(select(., textbooks_pknw,blackboard_pknw), na.rm=TRUE )", "school", "PKNW",  "Rural"),
  c("SE.PRM.PKNW.4.U", "100*rowMeans(select(., textbooks_pknw,blackboard_pknw), na.rm=TRUE )", "school", "PKNW",  "Urban"),
  
  #######################################
  # Principal Management Skills	(PMAN)
  #######################################
  
  c("SE.PRM.PMAN    ", "principal_management		", "school", "PMAN",  "All"),
  #(De Facto) Ave,rage score for the extent to which principals master two key managerial skills - problem-solving in the short-term, and goal-setting in the long term	
  c("SE.PRM.PMAN.1  ", "principal_management		", "school", "PMAN",  "All"),
  c("SE.PRM.PMAN.1.F", "principal_management		", "school", "PMAN",  "Female"),
  c("SE.PRM.PMAN.1.M", "principal_management		", "school", "PMAN",  "Male"),
  c("SE.PRM.PMAN.1.R", "principal_management		", "school", "PMAN",  "Rural"),
  c("SE.PRM.PMAN.1.U", "principal_management		", "school", "PMAN",  "Urban"),
  #(De Facto) Ave,rage score for the extent to which principals master problem-solving in the short-term	
  c("SE.PRM.PMAN.2  ", "goal_setting", "school", "PMAN",  "All"),  
  c("SE.PRM.PMAN.2.F", "goal_setting", "school", "PMAN",  "Female"),
  c("SE.PRM.PMAN.2.M", "goal_setting", "school", "PMAN",  "Male"),
  c("SE.PRM.PMAN.2.R", "goal_setting", "school", "PMAN",  "Rural"),
  c("SE.PRM.PMAN.2.U", "goal_setting", "school", "PMAN",  "Urban"),
  #(De Facto) Ave,rage score for the extent to which principals master goal-setting in the long term	
  c("SE.PRM.PMAN.3  ", "problem_solving", "school", "PMAN",  "All"),
  c("SE.PRM.PMAN.3.F", "problem_solving", "school", "PMAN",  "Female"),
  c("SE.PRM.PMAN.3.M", "problem_solving", "school", "PMAN",  "Male"),
  c("SE.PRM.PMAN.3.R", "problem_solving", "school", "PMAN",  "Rural"),
  c("SE.PRM.PMAN.3.U", "problem_solving", "school", "PMAN",  "Urban"),
  
  #######################################
  # Policy Lever (Teaching) - Attraction	(TATT)
  #######################################
  #api_final[grep('TATT', api_final$Series),1:2]
  
  c("SE.PRM.TATT ","teacher_attraction		", "teacher_questionnaire", "TATT",  "All"),        
  #(De Jure) Ave,rage starting public-school teacher salary as percent of GDP per capita	
  c("SE.PRM.TATT.1", "100*teacher_salary", "policy_survey", "NA","NA"),
  #(De Facto) Pe,rcent of teachers reporting being satisfied or very satisfied with their social status in the community	
  c("SE.PRM.TATT.2 ","100*teacher_satisfied_status		", "teacher_questionnaire", "TATT",  "All"),   
  #(De Facto) Pe,rcent of teachers reporting being satisfied or very satisfied with their job as teacher	
  c("SE.PRM.TATT.3 ","100*teacher_satisfied_job		", "teacher_questionnaire", "TATT",  "All"),  
  #(De Facto) Pe,rcent of teachers reporting having received financial bonuses in addition to their salaries	
  c("SE.PRM.TATT.4 ","100*teacher_bonus		", "teacher_questionnaire", "TATT",  "All"),    
  #(De Facto) Pe,rcent of teachers reporting that there are incentives (financial or otherwise) for teachers to teach certain subjects/grades and/or in certain areas	
  c("SE.PRM.TATT.5 ","100*if_else((teacher_bonus_hard_staff==1 | teacher_bonus_subj_shortages==1),1,0	)	", "teacher_questionnaire", "TATT",  "All"),
  #(De Facto) Pe,rcent of teachers that performance matters for promotions	
  c("SE.PRM.TATT.6 ", "100*better_teachers_promoted		", "teacher_questionnaire", "TATT",  "All"),  
  #(De Jure) Is ,there a well-established career path for teachers?	
  #SE.PRM.TATT.7,  as.numeric(NA)     ,
  #(De Facto) Pe,rcent of teachers that report salary delays in the past 12 months	
  c("SE.PRM.TATT.8 ", "100*m3seq6_tatt		", "teacher_questionnaire", "TATT",  "All"),  
  #(De Facto) Po,licy Lever (Teaching) - Attraction	
  c("SE.PRM.TATT.DJ", "teacher_attraction", "policy_survey", "NA","NA"),
  #(De Jure) Pol,icy Lever (Teaching) - Attraction	
  c("SE.PRM.TATT.DF", "teacher_attraction		", "teacher_questionnaire", "TATT",  "All"),
  
  
  #######################################
  # Policy Lever (Teaching) - Selection & Deployment	(TSDP)
  #######################################
  
  c("SE.PRM.TSDP  " ,"teacher_selection_deployment		", "teacher_questionnaire", "TSDP",  "All"),
  #Policy Lever (,Teaching) - Selection & Deployment                                 
  c("SE.PRM.TSDP.1" , "criteria_admittance", "policy_survey", "NA","NA"),
  #(De Jure) Requ,irements to enter into initial education programs                  
  c("SE.PRM.TSDP.2",  "as.numeric(NA)", "policy_survey", "NA","NA"),
  #(De Facto) Ave,rage quality of applicants accepted into initial education programs
  c("SE.PRM.TSDP.3", "criteria_become", "policy_survey", "NA","NA"),
  #(De Jure) Requ,irements to become a primary school teacher                        
  c("SE.PRM.TSDP.4  ","1+2*teacher_selection		", "teacher_questionnaire", "TSDP",  "All"),
  #(De Facto) Req,uirements to become a primary school teacher                       
  c("SE.PRM.TSDP.5" ,"criteria_transfer", "policy_survey", "NA","NA"),
  #(De Jure) Requ,irements to fulfill a transfer request                             
  c("SE.PRM.TSDP.6  ","1+2*teacher_deployment		", "teacher_questionnaire", "TSDP",  "All"),
  #(De Facto) Req,uirements to fulfill a transfer request                            
  c("SE.PRM.TSDP.7", "as.numeric(NA)", "policy_survey", "NA","NA"),
  #(De Jure) Sele,ctivity of teacher hiring process                                  
  c("SE.PRM.TSDP.DF ","teacher_selection_deployment		", "teacher_questionnaire", "TSDP",  "All"),
  #(De Facto) Pol,icy Lever (Teaching) - Selection & Deployment                      
  c("SE.PRM.TSDP.DJ", "teacher_selection_deployment", "policy_survey", "NA","NA"),
  #(De Jure) Poli,cy Lever (Teaching) - Selection & Deployment   
  
  #######################################
  # Policy Lever (Teaching) - Support	(TSUP)
  #######################################
  
  
  c("SE.PRM.TSUP ","teacher_support		", "teacher_questionnaire", "TSUP",  "All"),   
  #Policy Lever", (Teaching) - Support                                                                                        
  c("SE.PRM.TSUP.1"  ,"practicum", "policy_survey", "NA","NA") ,
  #(De Jure) Pr,acticum required as part of pre-service training                                                             
  c("SE.PRM.TSUP.2", "100-100*if_else(m3sdq6_tsup==2,0,1)			", "teacher_questionnaire", "TSUP",  "All"), 
  #(De Facto) P,ercent reporting they completed a practicum as part of pre-service training                                  
  c("SE.PRM.TSUP.3",  "100*m3sdq3_tsup		", "teacher_questionnaire", "TSUP",  "All"),
  #(De Facto) P",ercent of teachers reporting that they participated in an induction and/or mentorship program                
  c("SE.PRM.TSUP.4","prof_development", "policy_survey", "NA","NA"),
  #(De Jure) Pa",rticipation in professional development has professional implications for teachers                           
  c("SE.PRM.TSUP.5",  "100*m3sdq9_tsup			", "teacher_questionnaire", "TSUP",  "All"),
  #(De Facto) P",ercent of teachers reporting having attended in-service trainings in the past 12 months                      
  c("SE.PRM.TSUP.6",  "m3sdq10_tsup			", "teacher_questionnaire", "TSUP",  "All"),
  #(De Facto) A",verage length of the trainings attended                                                                      
  c("SE.PRM.TSUP.7",  "m3sdq11_tsup			", "teacher_questionnaire", "TSUP",  "All"),
  #(De Facto) A",verage span of time (in weeks) of those trainings                                                            
  c("SE.PRM.TSUP.8",  "100*(m3sdq13_tsup-1)/4			", "teacher_questionnaire", "TSUP",  "All"),
  #(De Facto) A",verage percent of time spent inside the classrooms during the trainings                                      
  c("SE.PRM.TSUP.9", "100*opportunities_teachers_share			", "teacher_questionnaire", "TSUP",  "All"), 
  #(De Facto) P",ercent of teachers that report having opportunities to come together with other teachers to discuss ways of ~
  c("SE.PRM.TSUP.DF","teacher_support		", "teacher_questionnaire", "TSUP",  "All"),  
  #(De Facto) P",olicy Lever (Teaching) - Support                                                                             
  c("SE.PRM.TSUP.DJ" ,"teacher_support", "policy_survey", "NA","NA"),
  #(De Jure) Po",licy Lever (Teaching) - Support  
  
  #######################################
  # Policy Lever (Teaching) - Evaluation	(TEVL)
  #######################################
  
  c("SE.PRM.TEVL  ","teaching_evaluation		", "teacher_questionnaire", "TEVL",  "All"),     #Policy Lever (Teaching) - Evaluation                                                                                     
  c("SE.PRM.TEVL.1", "evaluation_law", "policy_survey", "NA","NA"), #(De Jure) Legislation assigns responsibility of evaluating the performance of teachers to a public authority (national)
  c("SE.PRM.TEVL.2", "evaluation_law_school", "policy_survey", "NA","NA"), #(De Jure) Legislation assigns responsibility of evaluating the performance of teachers to the schools                    
  c("SE.PRM.TEVL.3 ","100*formally_evaluated		", "teacher_questionnaire", "TEVL",  "All"),   #(De Facto) Percent of teachers that report being evaluated in the past 12 months                                         
  c("SE.PRM.TEVL.4", "evaluation_criteria", "policy_survey", "NA","NA"), #(De Jure) The criteria to evaluate teachers is clear                                                                     
  c("SE.PRM.TEVL.5 ","rowSums(select(., m3sbq8_tmna__1,m3sbq8_tmna__2,m3sbq8_tmna__3, m3sbq8_tmna__4, m3sbq8_tmna__5,m3sbq8_tmna__6, m3sbq8_tmna__7, m3sbq8_tmna__8,m3sbq8_tmna__97) , na.rm=TRUE )", "teacher_questionnaire", "TEVL",  "All"),  #(De Facto) Number of criteria used to evaluate teachers                                                                  
  c("SE.PRM.TEVL.6 ","100*negative_consequences		", "teacher_questionnaire", "TEVL",  "All"),  #(De Facto) Percent of teachers that report there would be consequences after two negative evaluations                    
  c("SE.PRM.TEVL.7 ","100*positive_consequences		", "teacher_questionnaire", "TEVL",  "All"),  #(De Facto) Percent of teachers that report there would be consequences after two positive evaluations                    
  c("SE.PRM.TEVL.8", "negative_evaluations", "policy_survey", "NA","NA"), #(De Jure) There are clear consequences for teachers who receive two or more negative evaluations                         
  c("SE.PRM.TEVL.9", "positive_evaluations", "policy_survey", "NA","NA"), #(De Jure) There are clear consequences for teachers who receive two or more positive evaluations                         
  c("SE.PRM.TEVL.DF", "teaching_evaluation		", "teacher_questionnaire", "TEVL",  "All"),  #(De Facto) Policy Lever (Teaching) - Evaluation                                                                          
  c("SE.PRM.TEVL.DJ", "teaching_evaluation", "policy_survey", "NA","NA"), #(De Jure) Policy Lever (Teaching) - Evaluation 
  
  #######################################
  # Policy Lever (Teaching) - Monitoring & Accountability 	(TMNA)
  #######################################
  
  c("SE.PRM.TMNA   ","teacher_monitoring		", "teacher_questionnaire", "TMNA",  "All"),    #Policy Lever (Teaching) - Monitoring & Accountability                                                       
  c("SE.PRM.TMNA.1"  , "absence_collected", "policy_survey", "NA","NA"), #(De Jure) Information on teacher presence/absenteeism is being collected on a regular basis                 
  c("SE.PRM.TMNA.2"  , 'attendance_rewarded', "policy_survey", "NA","NA"), #(De Jure) Teachers receive monetary compensation for being present                                          
  c("SE.PRM.TMNA.3 ","100*attendance_rewarded		", "teacher_questionnaire", "TMNA",  "All"),   #(De Facto) Teacher report receiving monetary compensation (aside from salary) for being present             
  c("SE.PRM.TMNA.4 ","100*miss_class_admin		", "teacher_questionnaire", "TMNA",  "All"),   #(De Facto) Percent of teachers that report having been absent because of administrative processes           
  c("SE.PRM.TMNA.5 ","100*attendence_sanctions		", "teacher_questionnaire", "TMNA",  "All"),  #(De Facto) Percent of teachers that report that there would be consequences for being absent 40% of the time
  c("SE.PRM.TMNA.DF", "teacher_monitoring		", "teacher_questionnaire", "TMNA",  "All"),  #(De Facto) Policy Lever (Teaching) - Monitoring & Accountability                                            
  c("SE.PRM.TMNA.DJ" ,"teacher_monitoring", "policy_survey", "NA","NA"),

  #######################################
  # Policy Lever (Teaching) - Intrinsic Motivation 	(TINM)
  #######################################
  
  c("SE.PRM.TINM   ","intrinsic_motivation		", "teacher_questionnaire", "TINM",  "All"),    #Policy Lever (Teaching) - Intrinsic Motivation                                                                           
  c("SE.PRM.TINM.1 ","SE_PRM_TINM_1		", "teacher_questionnaire", "TINM",  "All"),  #(De Facto) Percent of teachers that agree or strongly agrees with It is acceptable for a teacher to be absent if the ~
  c("SE.PRM.TINM.10", "SE_PRM_TINM_10		", "teacher_questionnaire", "TINM",  "All"), #(De Facto) Percent of teachers that agree or strongly agrees with \"Students can change even their basic intelligence l~
  c("SE.PRM.TINM.11", "100*motivation_teaching		", "teacher_questionnaire", "TINM",  "All"), #(De Facto) Percent of teachers who state that intrinsic motivation was the main reason to become teachers                
  c("SE.PRM.TINM.12", "m3sdq2_tmna		", "teacher_questionnaire", "TMNA",  "All"), #(De Facto) New teachers are required to undergo a probationary period                                                    
  c("SE.PRM.TINM.13" , "probationary_period", "policy_survey", "NA","NA"), #(De Jure) New teachers are required to undergo a probationary period                                                     
  c("SE.PRM.TINM.2 ","SE_PRM_TINM_2		", "teacher_questionnaire", "TINM",  "All"),  #(De Facto) Percent of teachers that agree or strongly agrees with It is acceptable for a teacher to be absent if stud~
  c("SE.PRM.TINM.3 ","SE_PRM_TINM_3		", "teacher_questionnaire", "TINM",  "All"),  #(De Facto) Percent of teachers that agree or strongly agrees with It is acceptable for a teacher to be absent if the ~
  c("SE.PRM.TINM.4 ","SE_PRM_TINM_4		", "teacher_questionnaire", "TINM",  "All"),  #(De Facto) Percent of teachers that agree or strongly agrees with Students deserve more attention if they attend scho~
  c("SE.PRM.TINM.5 ","SE_PRM_TINM_5		", "teacher_questionnaire", "TINM",  "All"),  #(De Facto) Percent of teachers that agree or strongly agrees with Students deserve more attention if they come to sch~
  c("SE.PRM.TINM.6 ","SE_PRM_TINM_6		", "teacher_questionnaire", "TINM",  "All"),  #(De Facto) Percent of teachers that agree or strongly agrees with Students deserve more attention if they are motivat~
  c("SE.PRM.TINM.7 ","SE_PRM_TINM_7		", "teacher_questionnaire", "TINM",  "All"),  #(De Facto) Percent of teachers that agree or strongly agrees with Students have a certain amount of intelligence and ~
  c("SE.PRM.TINM.8 ","SE_PRM_TINM_8		", "teacher_questionnaire", "TINM",  "All"),  #(De Facto) Percent of teachers that agree or strongly agrees with To be honest, students can't really change how inte~
  c("SE.PRM.TINM.9 ","SE_PRM_TINM_9		", "teacher_questionnaire", "TINM",  "All"),  #(De Facto) Percent of teachers that agree or strongly agrees with Students can always substantially change how intell~
  c("SE.PRM.TINM.DF", "intrinsic_motivation		", "teacher_questionnaire", "TINM",  "All"), #(De Facto) Policy Lever (Teaching) - Intrinsic Motivation                                                                
  c("SE.PRM.TINM.DJ" , "intrinsic_motivation", "policy_survey", "NA","NA"), #(De Jure) Policy Lever (Teaching) - Intrinsic Motivation   
  
  #######################################
  # Policy Lever (Inputs & Infrastructure) - Standards 	(ISTD)
  #######################################
  
  c("SE.PRM.ISTD    "," standards_monitoring		", "school", "ISTD",  "All"), #Policy Lever (Inputs & Infrastructure) - Standards                                                                       
  c("SE.PRM.ISTD.1"  ,"textbook_policy", "policy_survey", "NA","NA"), #(De Jure) Is there a policy in place to require that students have access to the prescribed textbooks?                   
  c("SE.PRM.ISTD.10 "," 100*m1scq14_imon__4		", "school", "ISTD",  "All"),#(De Facto) Do you know if there is a policy in place to require that schools have access to drinking water?              
  c("SE.PRM.ISTD.11" ,"toilet_policy", "policy_survey", "NA","NA"), #(De Jure) Is there a policy in place to require that schools have functioning toilets?                                   
  c("SE.PRM.ISTD.12 "," 100*m1scq14_imon__1		", "school", "ISTD",  "All"),#(De Facto) Do you know if there is a policy in place to require that schools have functioning toilets?                   
  c("SE.PRM.ISTD.13" ,"disability_policy", "policy_survey", "NA","NA"), #(De Jure) Is there a policy in place to require that schools are accessible to children with special needs?              
  c("SE.PRM.ISTD.14 "," 100*m1scq14_imon__3		", "school", "ISTD",  "All"),#(De Facto) Do you know if there is there a policy in place to require that schools are accessible to children with speci~
  c("SE.PRM.ISTD.2  "," 100*m1scq13_imon__2		", "school", "ISTD",  "All"),#(De Facto) Do you know if there is a policy in place to require that students have access to the prescribed textbooks?   
  c("SE.PRM.ISTD.3"  ,"connectivity_program", "policy_survey", "NA","NA"), #(De Jure) Is there a national connectivity program?                                                                      
  c("SE.PRM.ISTD.4"  ,  "as.numeric(NA)", "policy_survey", "NA","NA"),#(De Facto) Do you know if there is a national connectivity program?                                                      
  c("SE.PRM.ISTD.5"  ,"materials_policy", "policy_survey", "NA","NA"), #(De Jure) Is there a policy in place to require that students have access to PCs, laptops, tablets, and/or other computi~
  c("SE.PRM.ISTD.6  "," 100*m1scq13_imon__5		", "school", "ISTD",  "All"),#(De Facto) Do you know if there is a policy in place to require that students have access to PCs, laptops, tablets, and/~
  c("SE.PRM.ISTD.7"  ,"electricity_policy", "policy_survey", "NA","NA"), #(De Jure) Is there a policy in place to require that schools have access to electricity?                                 
  c("SE.PRM.ISTD.8  "," 100*m1scq14_imon__2		", "school", "ISTD",  "All"),#(De Facto) Do you know if there is a policy in place to require that schools have access to electricity?                 
  c("SE.PRM.ISTD.9"  ,"water_policy", "policy_survey", "NA","NA"), #(De Jure) Is there a policy in place to require that schools have access to drinking water?                              
  c("SE.PRM.ISTD.DF "," standards_monitoring		", "school", "ISTD",  "All"),#(De Facto) Policy Lever (Inputs & Infrastructure) - Standards                                                            
  c("SE.PRM.ISTD.DJ" ,"inputs_standards", "policy_survey", "NA","NA"), #(De Jure) Policy Lever (Inputs & Infrastructure) - Standards    
  
  #######################################
  # Policy Lever (Inputs & Infrastructure) - Monitoring 	(IMON)
  #######################################
  
  
  c("SE.PRM.IMON    "," sch_monitoring		", "school", "IMON",  "All"),    #Policy Lever (Inputs & Infrastructure) - Monitoring                                                                      
  c("SE.PRM.IMON.1  "," 100*m1scq1_imon		", "school", "IMON",  "All"),  #(De Facto) Percent of schools that report there is someone monitoring that basic inputs are available to students        
  c("SE.PRM.IMON.10" ,"as.numeric(NA)", "policy_survey", "NA","NA"), #(De Jure) Number of basic infrastructure features clearly articulated as needing to be monitored                         
  c("SE.PRM.IMON.2  "," 100*parents_involved		", "school", "IMON",  "All"),  #(De Facto) Percent of schools that report that parents or community members are involved in the monitoring of availabili~
  c("SE.PRM.IMON.3  "," 100*m1scq5_imon		", "school", "IMON",  "All"),  #(De Facto) Percent of schools that report that there is an inventory to monitor availability of basic inputs             
  c("SE.PRM.IMON.4  "," 100*m1scq7_imon		", "school", "IMON",  "All"),  #(De Facto) Percent of schools that report there is someone monitoring that basic infrastructure is available             
  c("SE.PRM.IMON.5  "," 100*bin_var(m1scq10_imon,1)		", "school", "IMON",  "All"),  #(De Facto) Percent of schools that report that parents or community members are involved in the monitoring of availabili~
  c("SE.PRM.IMON.6  "," 100*m1scq11_imon		", "school", "IMON",  "All"),  #(De Facto) Percent of schools that report that there is an inventory to monitor availability of basic infrastructure     
  c("SE.PRM.IMON.7"  ,"as.numeric(NA)", "policy_survey", "NA","NA"), #(De Jure) Is the responsibility of monitoring basic inputs clearly articulated in the policies?                          
  c("SE.PRM.IMON.8"  ,"as.numeric(NA)", "policy_survey", "NA","NA"), #(De Jure) Number of basic inputs clearly articulated as needing to be monitored                                          
  c("SE.PRM.IMON.9"  ,"as.numeric(NA)", "policy_survey", "NA","NA"), #(De Jure) Is the responsibility of monitoring basic infrastructure clearly articulated in the policies?                  
  c("SE.PRM.IMON.DF ", " sch_monitoring		", "school", "IMON",  "All"), #(De Facto) Policy Lever (Inputs & Infrastructure) - Monitoring                                                           
  c("SE.PRM.IMON.DJ" ,"as.numeric(NA)", "policy_survey", "NA","NA"), #(De Jure) Policy Lever (Inputs & Infrastructure) - Monitoring  
  
  
    #######################################
  # Policy Lever (Learners) - Nutrition Programs 	(LNTN)
  #######################################

  c("SE.PRM.LNTN.1", "iodization", "policy_survey", "NA", "NA"), # (De Jure) Does a national policy to encourage salt iodization exist?
  c("SE.PRM.LNTN.2", "100*as.numeric(`Percentage of households with salt testing positive for any iodide among households`)", "learners", "NA", "NA"), # (De Facto) Percent of households with salt testing positive for any iodide among households
  c("SE.PRM.LNTN.3", "iron_fortification", "policy_survey", "NA", "NA"), # (De Jure) Does a national policy exist to encourage iron fortification of staples like wheat, maize, or rice?
  c("SE.PRM.LNTN.4", "100*as.numeric(`Percentage of children age 6–23 months who had at least the minimum dietary diversity and the minimum meal frequency during the previous day`)", "learners", "NA", "NA"), # (De Facto) Percent of children age 6-23 months who had at least the minimum dietary diversity and the minimum meal frequ~
  c("SE.PRM.LNTN.5", "breastfeeding", "policy_survey", "NA", "NA"), # (De Jure) Does a national policy exist to encourage breastfeeding?
  c("SE.PRM.LNTN.6", "100*as.numeric(`Percentage of children born in the five (three) years preceding the survey who were ever breastfed`)", "learners", "NA", "NA"), # (De Facto) Percent of children born in the five (three) years preceding the survey who were ever breastfed
  c("SE.PRM.LNTN.7", "school_feeding", "policy_survey", "NA", "NA"), # (De Jure) Is there a publicly funded school feeding program?
  c("SE.PRM.LNTN.8", "100*m1saq9_lnut", "school", "school_dta_anon", "All"), # (De Facto) Percent of schools reporting having publicly funded school feeding program
  c("SE.PRM.LNTN.DF", "4*rowMeans(across(c('SE.PRM.LNTN.2', 'SE.PRM.LNTN.4', 'SE.PRM.LNTN.6', 'SE.PRM.LNTN.8')),na.rm = TRUE)/100+1", "aggregate", 'c("SE.PRM.LNTN.2", "SE.PRM.LNTN.4", "SE.PRM.LNTN.6", "SE.PRM.LNTN.8")', "NA"), # (De Facto) Policy Lever (Learners) - Nutrition Programs
  c("SE.PRM.LNTN.DJ", "nutrition_programs", "policy_survey", "NA", "NA"), # (De Jure) Policy Lever (Learners) - Nutrition Programs
  c("SE.PRM.LNTN", "SE.PRM.LNTN.DF", "aggregate", 'c("SE.PRM.LNTN.DF")', "NA"), # Policy Lever (Learners) - Nutrition Programs

  #######################################
  # Policy Lever (Learners) - Health 	(LHTH)
  #######################################

  c("SE.PRM.LHTH.1", "immunization", "policy_survey", "NA", "NA"), # (De Jure) Are young children required to receive a complete course of childhood immunizations?
  c("SE.PRM.LHTH.2", " 100*as.numeric(defacto_dta_learners_final[,5])", "policy_survey", "NA", "NA"), # (De Facto) Percent of children who at age 24-35 months had received all vaccinations recommended in the national immuniz~
  c("SE.PRM.LHTH.3", "healthcare_young_children", "policy_survey", "NA", "NA"), # (De Jure) Is there a policy that assures access to healthcare for young children? Either by offering these services free~
  c("SE.PRM.LHTH.4", "100*as.numeric(`MICS/Other - Percentage of children under 5 covered by health insurance`)", "learners", "NA", "NA"), # (De Facto) Percent of  children under 5 covered by health insurance
  c("SE.PRM.LHTH.5", "deworming", "policy_survey", "NA", "NA"), # (De Jure) Are deworming pills funded and distributed by the government?
  c("SE.PRM.LHTH.6", "100*as.numeric(`MICS/Other - Percentage of children age 6-59 months who received deworming medication.`)", "learners", "NA", "NA"), # (De Facto) Percent of children age 6-59 months who received deworming medication
  c("SE.PRM.LHTH.7", "antenatal_skilled_delivery", "policy_survey", "NA", "NA"), # (De Jure) Is there a policy that guarantees pregnant women free antenatal visits and skilled delivery?
  c("SE.PRM.LHTH.8", "100*as.numeric(`MICS/DHS - Percentage of women age 15-49 years with a live birth in the last 2 years whose most recent live birth was delivered in a health facility`)", "learners", "NA", "NA"), # (De Facto) Percent of women age 15-49 years with a live birth in the last 2 years whose most recent live birth was deliv~
  c("SE.PRM.LHTH.DF", "4*rowMeans(across(c('SE.PRM.LHTH.2', 'SE.PRM.LHTH.4', 'SE.PRM.LHTH.6', 'SE.PRM.LHTH.8')),na.rm = TRUE)/100+1", "aggregate", 'c("SE.PRM.LHTH.2", "SE.PRM.LHTH.4", "SE.PRM.LHTH.6", "SE.PRM.LHTH.8")', "NA"), # (De Facto) Policy Lever (Learners) - Health
  c("SE.PRM.LHTH.DJ", "health_programs", "policy_survey", "NA", "NA"), # (De Jure) Policy Lever (Learners) - Health
  c("SE.PRM.LHTH", "SE.PRM.LHTH.DF", "aggregate", 'c("SE.PRM.LHTH.DF")', "NA"), # Policy Lever (Learners) - Health


  #######################################
  # Policy Lever (Learners) - Center-Based Care 	(LCBC)
  #######################################

  c("SE.PRM.LCBC.1", "pre_primary_free_some", "policy_survey", "NA", "NA"), # (De Jure) Is there a policy that guarantees free education for some or all grades and ages included in pre-primary educat~
  c("SE.PRM.LCBC.2", "100*(as.numeric(`Percentage of children age 36-59 months who are attending ECE`))", "learners", "NA", "NA"), # (De Facto) Percent of children age 36-59 months who are attending an early childhood education programme
  c("SE.PRM.LCBC.3", "developmental_standards", "policy_survey", "NA", "NA"), # (De Jure) Are there developmental standards established for early childhood care and education?
  c("SE.PRM.LCBC.4", "ece_qualifications", "policy_survey", "NA", "NA"), # (De Jure) According to laws and regulations, are there requirement to become an early childhood educator, pre-primary tea~
  c("SE.PRM.LCBC.5", "ece_in_service", "policy_survey", "NA", "NA"), # (De Jure) According to policy, are ECCE professionals working at public or private centers required to complete in-servic~

  c("SE.PRM.LCBC.DF", "4*(SE.PRM.LCBC.2)/100+1", "aggregate", 'c("SE.PRM.LCBC.2")', "NA"), # (De Facto) Policy Lever (Learners) - Center-Based Care
  c("SE.PRM.LCBC.DJ", "ece_programs", "policy_survey", "NA", "NA"), # (De Jure) Policy Lever (Learners) - Center-Based Care

  c("SE.PRM.LCBC", "SE.PRM.LCBC.DF", "aggregate", 'c("SE.PRM.LCBC.DF")', "NA"), # Policy Lever (Learners) - Center-Based Care

  #######################################
  # Policy Lever (Learners) - Caregiver Capacity - Financial Capacity 	(LFCP)
  #######################################

  c("SE.PRM.LFCP.1", "anti_poverty", "policy_survey", "NA", "NA"), # (De Jure) Are anti poverty interventions that focus on ECD publicly supported?
  c("SE.PRM.LFCP.2", "as.numeric(NA)", "policy_survey", "NA", "NA"), # (De Jure) Are cash transfers conditional on ECD services/enrollment publicly supported?
  c("SE.PRM.LFCP.3", "as.numeric(NA)", "policy_survey", "NA", "NA"), # (De Jure) Are cash transfers focused partially on ECD publicly supported?
  c("SE.PRM.LFCP.4", "100*as.numeric(`Coverage of social protection programs (Best data source to be identified)`)", "learners", "NA", "NA"), # (De Facto) Coverage of social protection programs

  c("SE.PRM.LFCP.DF", "4*SE.PRM.LFCP.4/100 +1", "aggregate", 'c("SE.PRM.LFCP.4")', "NA"), # (De Facto) Policy Lever (Learners) - Caregiver Capacity - Financial Capacity
  c("SE.PRM.LFCP.DJ", "financial_capacity", "policy_survey", "NA", "NA"), # (De Jure) Policy Lever (Learners) - Caregiver Capacity - Financial Capacity

  c("SE.PRM.LFCP", "SE.PRM.LFCP.DF", "aggregate", 'c("SE.PRM.LFCP.DF")', "NA"), # Policy Lever (Learners) - Caregiver Capacity - Financial Capacity


  #######################################
  # Policy Lever (Learners) - Caregiver Capacity - Skills Capacity 	(LSKC)
  #######################################

  c("SE.PRM.LSKC.1", "good_parent_sharing", "policy_survey", "NA", "NA"), # (De Jure) Does the government offer programs that aim to share good parenting practices with caregivers?
  c("SE.PRM.LSKC.2", "promote_ece_stimulation", "policy_survey", "NA", "NA"), # (De Jure) Are any of the following publicly-supported delivery channels used to reach families in order to promote early ~
  c("SE.PRM.LSKC.3", "100*as.numeric(`Percentage of children under age 5 who have three or more children books`)", "learners", "NA", "NA"), # (De Facto) Percent of children under age 5 who have three or more children's books
  c("SE.PRM.LSKC.4", "100*as.numeric(`Percentage of children age 24-59 months engaged in four or more activities to provide early stimulation and responsive care in the last 3 days with any adult in the household`)", "learners", "NA", "NA"), # (De Facto) Percent of children age 24-59 months engaged in four or more activities to provide early stimulation and respo~

  c("SE.PRM.LSKC.DF", "4*rowMeans(across(c('SE.PRM.LSKC.3','SE.PRM.LSKC.4')),na.rm = TRUE)/100+1", "aggregate", 'c("SE.PRM.LSKC.3","SE.PRM.LSKC.4")', "NA"), # (De Facto) Policy Lever (Learners) - Caregiver Capacity - Skills Capacity
  c("SE.PRM.LSKC.DJ", "caregiver_skills", "policy_survey", "NA", "NA"),
  # (De Jure) Policy Lever (Learners) - Caregiver Capacity - Skills Capacity
  c("SE.PRM.LSKC", "SE.PRM.LSKC.DF", "aggregate", 'c("SE.PRM.LSKC.DF")', "NA"), # Policy Lever (Learners) - Caregiver Capacity - Skills Capacity

  #######################################
  # Policy Lever (School Management) - Clarity of Functions 	(SCFN)
  #######################################
  
  c("SE.PRM.SCFN    ","sch_management_clarity		", "school", "SCFN",  "All"),  #Policy Lever (School Management) - Clarity of Functions                                                                  
  c("SE.PRM.SCFN.1  ","100*infrastructure_scfn		", "school", "SCFN",  "All"),  #(De Facto) Do you know if the policies governing schools assign responsibility for the implementation of the maintenance~
c("SE.PRM.SCFN.10" ,"student_scfn", "policy_survey", "NA","NA"), #(De Jure) Do the policies governing schools assign the responsibility of student learning assessments?                   
  c("SE.PRM.SCFN.11 ","100*principal_hiring_scfn		", "school", "SCFN",  "All"), #(De Facto) Do you know if the policies governing schools assign responsibility for the implementation of principal hirin~
c("SE.PRM.SCFN.12" ,"principal_hiring_scfn", "policy_survey", "NA","NA"),#(De Jure) Do the policies governing schools assign the responsibility of principal hiring and assignment?                
  c("SE.PRM.SCFN.13 ","100*principal_supervision_scfn		", "school", "SCFN",  "All"),#(De Facto) Do you know if the policies governing schools assign responsibility for the implementation of principal super~
c("SE.PRM.SCFN.14" ,"principal_supervision_scfn", "policy_survey", "NA","NA"), #(De Jure) Do the policies governing schools assign the responsibility of principal supervision and training?             
c("SE.PRM.SCFN.2"  ,"infrastructure_scfn", "policy_survey", "NA","NA"), #(De Jure) Do the policies governing schools assign the responsibility of maintenance and expansion of school infrastruct~
  c("SE.PRM.SCFN.3  ","100*materials_scfn		", "school", "SCFN",  "All"), #(De Facto) Do you know if the policies governing schools assign responsibility for the implementation of the procurement~
c("SE.PRM.SCFN.4"  ,"materials_scfn", "poIlicy_survey", "NA","NA"),#(De Jure) Do the policies governing schools assign the responsibility of procurement of materials?                       
  c("SE.PRM.SCFN.5  ","100*hiring_scfn		", "school", "SCFN",  "All"),#(De Facto) Do you know if the policies governing schools assign responsibility for the implementation of teacher hiring ~
c("SE.PRM.SCFN.6"  ,"hiring_scfn", "policy_survey", "NA","NA"), #(De Jure) Do the policies governing schools assign the responsibility of teacher hiring and assignment?                  
  c("SE.PRM.SCFN.7  ","100*supervision_scfn		", "school", "SCFN",  "All"),#(De Facto) Do you know if the policies governing schools assign responsibility for the implementation of teacher supervi~
c("SE.PRM.SCFN.8"  ,"supervision_scfn", "policy_survey", "NA","NA"), #(De Jure) Do the policies governing schools assign the responsibility of teacher supervision, training, and coaching?    
  c("SE.PRM.SCFN.9  ","100*student_scfn		", "school", "SCFN",  "All"),#(De Facto) Do you know if the policies governing schools assign responsibility for the implementation of student learnin~
  c("SE.PRM.SCFN.DF ","sch_management_clarity		", "school", "SCFN",  "All"),#(De Facto) Policy Lever (School Management) - Clarity of Functions                                                       
c("SE.PRM.SCFN.DJ" ,"sch_management_clarity", "policy_survey", "NA","NA"),#(De Jure) Policy Lever (School Management) - Clarity of Functions    
  
  #######################################
  # Policy Lever (School Management) - Attraction 	(SATT)
  #######################################
  
  c("SE.PRM.SATT   ","sch_management_attraction		", "school", "SATT",  "All"),  #Policy Lever (School Management) - Attraction                                                                             
c("SE.PRM.SATT.1"  ,"professionalized", "policy_survey", "NA","NA"), #(De Jure) Do the national policies governing the education system portray the position of principal or head teacher as pr~
  c("SE.PRM.SATT.2 ","100*principal_salary		", "school", "SATT",  "All"),  #(De Facto) Average principal salary as percent of GDP per capita                                                          
  c("SE.PRM.SATT.3 ", "100*(principal_satisfaction>3)		", "school", "SATT",  "All"),#(De Facto) Percent of principals reporting being satisfied or very satisfied with their social status in the community    
  c("SE.PRM.SATT.DF", "sch_management_attraction		", "school", "SATT",  "All"), #(De Facto) Policy Lever (School Management) - Attraction                                                                  
c("SE.PRM.SATT.DJ" ,"sch_management_attraction", "policy_survey", "NA","NA"),#(De Jure) Policy Lever (School Management) - Attraction  
  
  #######################################
  # Policy Lever (School Management) - Selection & Deployment 	(SSLD)
  #######################################
  
  c("SE.PRM.SSLD    "," sch_selection_deployment		", "school", "SSLD",  "All"),#Policy Lever (School Management) - Selection & Deployment                                                                
c("SE.PRM.SSLD.1"  ,"principal_rubric", "policy_survey", "NA","NA"),#(De Jure) Is there a systematic approach/rubric for the selection of principals?                                         
  c("SE.PRM.SSLD.10 ", " 100*m7sgq2_ssld==1		", "school", "SSLD",  "All"), #(De Facto) Percent of principals that report that the most important factor considered when selecting a principal is yea~
  c("SE.PRM.SSLD.11 "," 100*m7sgq2_ssld==2		", "school", "SSLD",  "All"),#(De Facto) Percent of principals that report that the most important factor considered when selecting a principal is qua~
  c("SE.PRM.SSLD.12 "," 100*m7sgq2_ssld==3		", "school", "SSLD",  "All"),#(De Facto) Percent of principals that report that the most important factor considered when selecting a principal is dem~
  c("SE.PRM.SSLD.13 "," 100*m7sgq2_ssld==4		", "school", "SSLD",  "All"),#(De Facto) Percent of principals that report that the most important factor considered when selecting a principal is hav~
  c("SE.PRM.SSLD.14 "," 100*m7sgq2_ssld==6		", "school", "SSLD",  "All"),#(De Facto) Percent of principals that report that the most important factor considered when selecting a principal is pol~
  c("SE.PRM.SSLD.15 "," 100*m7sgq2_ssld==7		", "school", "SSLD",  "All"),#(De Facto) Percent of principals that report that the most important factor considered when selecting a principal is eth~
  c("SE.PRM.SSLD.16 "," 100*m7sgq2_ssld==8		", "school", "SSLD",  "All"),#(De Facto) Percent of principals that report that the most important factor considered when selecting a principal is kno~
c("SE.PRM.SSLD.2"  ,"principal_factors", "policy_survey", "NA","NA"),#(De Jure) How are the principals selected? Based on the requirements, is the selection system meritocratic?              
  c("SE.PRM.SSLD.3  "," 100*m7sgq1_ssld__1		", "school", "SSLD",  "All"), #(De Facto) Percent of principals that report that the factors considered when selecting a principal include years of exp~
  c("SE.PRM.SSLD.4  "," 100*m7sgq1_ssld__2		", "school", "SSLD",  "All"),#(De Facto)  Percent of principals that report that the factors considered when selecting a principal include quality of ~
  c("SE.PRM.SSLD.5  "," 100*m7sgq1_ssld__3		", "school", "SSLD",  "All"), #(De Facto) Percent of principals that report that the factors considered when selecting a principal include demonstrated~
  c("SE.PRM.SSLD.6  "," 100*m7sgq1_ssld__4		", "school", "SSLD",  "All"),#(De Facto) Percent of principals that report that the factors considered when selecting a principal include good relatio~
  c("SE.PRM.SSLD.7  "," 100*m7sgq1_ssld__6		", "school", "SSLD",  "All"),#(De Facto) Percent of principals that report that the factors considered when selecting a principal include political af~
  c("SE.PRM.SSLD.8  "," 100*m7sgq1_ssld__7		", "school", "SSLD",  "All"),#(De Facto) Percent of principals that report that the factors considered when selecting a principal include ethnic group 
  c("SE.PRM.SSLD.9  "," 100*m7sgq1_ssld__8		", "school", "SSLD",  "All"), #(De Facto) Percent of principals that report that the factors considered when selecting a principal include knowledge of~
  c("SE.PRM.SSLD.DF "," sch_selection_deployment		", "school", "SSLD",  "All"), #(De Facto) Policy Lever (School Management) - Selection & Deployment                                                     
c("SE.PRM.SSLD.DJ" ,"sch_selection_deployment", "policy_survey", "NA","NA"), #(De Jure) Policy Lever (School Management) - Selection & Deployment  
  
  #######################################
  # Policy Lever (School Management) - Support 	(SSUP)
  #######################################
  
  c("SE.PRM.SSUP    "," sch_support		", "school", "SSUP",  "All"), #Policy Lever (School Management) - Support                                                                        
c("SE.PRM.SSUP.1"  ,"principal_training_required", "policy_survey", "NA","NA"),#(De Jure) Are principals required to have training on how to manage a school?                                     
  c("SE.PRM.SSUP.10 "," 100*m7sgq5_ssup		", "school", "SSUP",  "All"),#(De Facto) Percent of principals that report having used the skills they gained at the last training they attended
  c("SE.PRM.SSUP.11 "," m7sgq7_ssup		", "school", "SSUP",  "All"),#(De Facto) Average number of trainings that principals report having been offered to them in the past year        
c("SE.PRM.SSUP.2"  ,"principal_training_type1", "policy_survey", "NA","NA"),#(De Jure) Are principals required to have management training for new principals?                                 
c("SE.PRM.SSUP.3"  ,"principal_training_type2", "policy_survey", "NA","NA"),#(De Jure) Are principals required to have in-service training?                                                    
c("SE.PRM.SSUP.4"  ,"principal_training_type3", "policy_survey", "NA","NA"),#(De Jure) Are principals required to have mentoring/coaching by experienced principals?                           
c("SE.PRM.SSUP.5"  ,"principal_training_frequency", "policy_survey", "NA","NA"),#(De Jure) How many times per year do principals have trainings?                                                   
  c("SE.PRM.SSUP.6  "," 100*m7sgq3_ssup		", "school", "SSUP",  "All"), #(De Facto) Percent of principals that report ever having received formal training                                 
  c("SE.PRM.SSUP.7  "," 100*m7sgq4_ssup__1		", "school", "SSUP",  "All"),#(De Facto) Percent of principals that report having received management training for new principals               
  c("SE.PRM.SSUP.8  "," 100*m7sgq4_ssup__2		", "school", "SSUP",  "All"), #(De Facto) Percent of principals that report having received in-service training                                  
  c("SE.PRM.SSUP.9  "," 100*m7sgq4_ssup__3		", "school", "SSUP",  "All"),#(De Facto) Percent of principals that report having received mentoring/coaching by experienced principals         
  c("SE.PRM.SSUP.DF ",  " sch_support		", "school", "SSUP",  "All"),  #(De Facto) Policy Lever (School Management) - Support                                                             
c("SE.PRM.SSUP.DJ" ,"sch_support", "policy_survey", "NA","NA"),#(De Jure) Policy Lever (School Management) - Support 
  
  #######################################
  # Policy Lever (School Management) - Evaluation 	(SEVL)
  #######################################
  
  c("SE.PRM.SEVL   "," principal_evaluation		", "school", "SEVL",  "All"), #Policy Lever (School Management) - Evaluation                                                          
c("SE.PRM.SEVL.1"  ,"principal_monitor_law", "policy_survey", "NA","NA"),#(De Jure) Is there a policy that specifies the need to monitor principal or head teacher performance?  
c("SE.PRM.SEVL.2"  ,"principal_monitor_criteria", "policy_survey", "NA","NA"),#(De Jure) Is the criteria to evaluate principals clear and includes multiple factors?                  
  c("SE.PRM.SEVL.3 "," 100*m7sgq8_sevl		", "school", "SEVL",  "All"), #(De Facto) Percent of principals that report having been evaluated  during the last school year        
  c("SE.PRM.SEVL.4 "," 100*principal_eval_tot>1		", "school", "SEVL",  "All"), #(De Facto) Percent of principals that report having been evaluated on multiple factors                 
  c("SE.PRM.SEVL.5 "," 100*principal_negative_consequences	", "school", "SEVL",  "All"), #(De Facto) Percent of principals that report there would be consequences after two negative evaluations
  c("SE.PRM.SEVL.6 "," 100*principal_positive_consequences	", "school", "SEVL",  "All"),#(De Facto) Percent of principals that report there would be consequences after two positive evaluations
  c("SE.PRM.SEVL.DF","  principal_evaluation		", "school", "SEVL",  "All"), #(De Facto) Policy Lever (School Management) - Evaluation                                               
c("SE.PRM.SEVL.DJ" ,"principal_evaluation", "policy_survey", "NA","NA"), #(De Jure) Policy Lever (School Management) - Evaluation     
  
  #######################################
  # Politics & Bureaucratic Capacity - Quality of Bureaucracy 	(BQBR)
  #######################################
  
  c("SE.PRM.BQBR  ", " quality_bureaucracy"		, "public_officials", "BQBR",  "All"),#Politics & Bureaucratic Capacity - Quality of Bureaucracy                                                                  
  c("SE.PRM.BQBR.1", " quality_bureaucracy"		, "public_officials", "BQBR",  "All"),#Average score for Quality of Bureaucracy; where a score of 1 indicates low effectiveness and 5 indicates high effectiveness
  c("SE.PRM.BQBR.2", " knowledge_skills"		, "public_officials", "BQBR",  "All"),#(Quality of Bureaucracy) average score for knowledge and skills                                                            
  c("SE.PRM.BQBR.3", " work_environment"		, "public_officials", "BQBR",  "All"),#(Quality of Bureaucracy) average score for work environment                                                                
  c("SE.PRM.BQBR.4", " merit"		, "public_officials", "BQBR",  "All"),#(Quality of Bureaucracy) average score for merit                                                                           
  c("SE.PRM.BQBR.5"," motivation_attitudes"		, "public_officials", "BQBR",  "All"),#Quality of Bureaucracy) average score for motivation and attitudes      
  
  #######################################
  # Politics & Bureaucratic Capacity - Impartial Decision-Making 	(BIMP)
  #######################################
  
  c("SE.PRM.BIMP  "," impartial_decision_making"		, "public_officials", "BIMP",  "All"), #Politics & Bureaucratic Capacity - Impartial Decision-Making                                                               
  c("SE.PRM.BIMP.1"," impartial_decision_making"		, "public_officials", "BIMP",  "All"), #Average score for Impartial Decision-Making; where a score of 1 indicates low effectiveness and 5 indicates high effective~
  c("SE.PRM.BIMP.2"," pol_personnel_management"		, "public_officials", "BIMP",  "All"), #(Impartial Decision-Making) average score for politicized personnel management                                             
  c("SE.PRM.BIMP.3"," pol_policy_making"		, "public_officials", "BIMP",  "All"), #(Impartial Decision-Making) average score for politicized policy-making                                                    
  c("SE.PRM.BIMP.4"," pol_policy_implementation"		, "public_officials", "BIMP",  "All"), #(Impartial Decision-Making) average score for politicized policy implementation                                            
  c("SE.PRM.BIMP.5"," employee_unions_as_facilitators"		, "public_officials", "BIMP",  "All"), #(Impartial Decision-Making) average score for employee unions as facilitators 
  
  #######################################
  # Politics & Bureaucratic Capacity - Mandates & Accountability 	(BMAC)
  #######################################
  
  c("SE.PRM.BMAC   "," mandates_accountability"		, "public_officials", "BMAC",  "All"),#Politics & Bureaucratic Capacity - Mandates & Accountability                                                               
  c("SE.PRM.BMAC.1 "," mandates_accountability"		, "public_officials", "BMAC",  "All"),#Average score for Mandates & Accountability; where a score of 1 indicates low effectiveness and 5 indicates high effective~
  c("SE.PRM.BMAC.2 "," coherence"		, "public_officials", "BMAC",  "All"),#(Mandates & Accountability) Average score for coherence                                                                    
  c("SE.PRM.BMAC.3 "," transparency"		, "public_officials", "BMAC",  "All"),#(Mandates & Accountability) Average score for transparency                                                                 
  c("SE.PRM.BMAC.4 "," accountability"		, "public_officials", "BMAC",  "All"),#(Mandates & Accountability) Average score for accountability of public officials    
  
  #######################################
  # Politics & Bureaucratic Capacity - National Learning Goals 	(BNLG)
  #######################################
  
  c("SE.PRM.BNLG  ", " national_learning_goals"		, "public_officials", "BNLG",  "All"),#Politics & Bureaucratic Capacity - National Learning Goals                                                                 
  c("SE.PRM.BNLG.1", " national_learning_goals"		, "public_officials", "BNLG",  "All"),#Average score for National Learning Goals; where a score of 1 indicates low effectiveness and 5 indicates high effectivene~
  c("SE.PRM.BNLG.2", " targeting"		, "public_officials", "BNLG",  "All"),#(National Learning Goals) Average score for targeting                                                                      
  c("SE.PRM.BNLG.3", " monitoring"		, "public_officials", "BNLG",  "All"),#(National Learning Goals) Average score for monitoring                                                                     
  c("SE.PRM.BNLG.4", " incentives"		, "public_officials", "BNLG",  "All"),#(National Learning Goals) Average score for incentives                                                                     
  c("SE.PRM.BNLG.5", " community_engagement"		, "public_officials", "BNLG",  "All"),#(National Learning Goals) Average score for community engagement   
  
  #######################################
  # Politics & Bureaucratic Capacity - Financing 	(BFIN)
  #######################################

c("SE.PRM.BFIN.6" , "4*as.numeric(`Does the country spend 4-5%  of GDP or 15-20% of public expenditures on education spending?`)+1", "finance", "NA","NA"), #(Financing) - Adequacy expressed by the per child spending
c("SE.PRM.BFIN.3" ,"4*as.numeric(`Efficiency by the relationship between financing and outcomes; where 0 is the lowest possible efficiency and 1 is the highest`)+1", "finance", "NA","NA"),#(Financing) Efficiency - Expressed by the score from the Public Expenditure and Financial Accountability (PEFA) assessment~
c("SE.PRM.BFIN.4" ,"4*as.numeric(`Efficiency by the score from the Public Expenditure and Financial Accountability (PEFA) assessment; where 0 is the lowest possible efficiency and 1 is the highest`)+1", "finance", "NA","NA"),#(Financing) Efficiency - Expressed by the relationship between financing and outcomes; where 0 is the lowest possible effi~
c("SE.PRM.BFIN.5" ,"as.numeric(NA)", "finance", "NA","NA"),#(Financing) - Equity
c("SE.PRM.BFIN.2" , "as.numeric(`Government expenditure per school age person, primary (% of GDP per capita)`)", "finance", "NA","NA"), #(Financing) - Adequacy expressed by the per child spending

c("SE.PRM.BFIN"   , "as.numeric(0.5*SE.PRM.BFIN.2+0.5*(SE.PRM.BFIN.3+SE.PRM.BFIN.4)/2)", "aggregate", 'c("SE.PRM.BFIN.2", "SE.PRM.BFIN.3", "SE.PRM.BFIN.4")',"NA"), #Politics & Bureaucratic Capacity - Financing
c("SE.PRM.BFIN.1" , "as.numeric(0.5*SE.PRM.BFIN.2+0.5*(SE.PRM.BFIN.3+SE.PRM.BFIN.4)/2)", "aggregate", 'c("SE.PRM.BFIN.2", "SE.PRM.BFIN.3", "SE.PRM.BFIN.4")',"NA")#Financing score; where a score of 1 indicates low effectiveness and 5 indicates high effectiveness in terms of adequacy, e~
      
  
  
)

#apply the function to indicators list
#loop through the elements in indicators
#combine results in a dataframe

#initialize empty dataframe
indicator_data <- data.frame()

for (i in 1:length(indicators)) {
  
  #get indicator name
  name <- indicators[[i]][1]
  
  #get indicator code
  indicator <- indicators[[i]][2]
  
  #get dataset
  dataset <- indicators[[i]][3]
  
  #get tag
  tag <- indicators[[i]][4]
  
  #get unit
  unit <- indicators[[i]][5]
  
  #get indicator data
  indicator_data <- rbind(indicator_data, indicator_stats(name, indicator, dataset, tag, unit))
  
}



#join metadata

indicator_data <- left_join(GEPD_template, indicator_data ) %>%
  rename(
    `Mean`=mean,
    `Standard Error`=mean_se,
    `Lower Bound`=mean_low,
    `Upper Bound`=mean_upp,
    `Variance`=mean_var
    
  )

#save as csv
write_excel_csv(indicator_data, here('04_GEPD_Indicators',paste0(country,"_GEPD_Indicators_", software,".csv")))


#write to an xlsx named GEPD_indicators.xlsx
#save one tab with all endicators in this list
main_indicators <-
  c(
    "SE.PRM.LERN"
    ,"SE.PRM.EFFT"
    ,"SE.PRM.CONT"
    ,"SE.PRM.PEDG"
    ,"SE.PRM.INPT"
    ,"SE.PRM.INFR"
    ,"SE.PRM.LCAP"
    ,"SE.PRM.ATTD"
    ,"SE.PRM.OPMN"
    ,"SE.PRM.ILDR"
    ,"SE.PRM.PKNW"
    ,"SE.PRM.PMAN"
    ,"SE.PRM.TATT"
    ,"SE.PRM.TSDP"
    ,"SE.PRM.TSUP"
    ,"SE.PRM.TEVL"
    ,"SE.PRM.TMNA"
    ,"SE.PRM.TINM"
    ,"SE.PRM.ISTD"
    ,"SE.PRM.IMON"
    ,"SE.PRM.LNTN"
    ,"SE.PRM.LHTH"
    ,"SE.PRM.LCBC"
    ,"SE.PRM.LFCP"
    ,"SE.PRM.LSKC"
    ,"SE.PRM.SCFN"
    ,"SE.PRM.SATT"
    ,"SE.PRM.SSLD"
    ,"SE.PRM.SSUP"
    ,"SE.PRM.SEVL"
    ,"SE.PRM.BQBR"
    ,"SE.PRM.BIMP"
    ,"SE.PRM.BMAC"
    ,"SE.PRM.BNLG"
    ,"SE.PRM.BFIN"
    
  )

main_indicator_labels <- c(
  "Proficiency on GEPD Assessment"
  ,"Teacher Presence"
  ,"Teacher Content Knowledge"
  ,"Teacher Pedagogical Skills"
  ,"Basic Inputs"
  ,"Basic Infrastructure"
  ,"Student Readiness"
  ,"Student Attendance"
  ,"Operational Management"
  ,"Instructional Leadership"
  ,"Principal School Knowledge"
  ,"Principal Management Skills"
  ,"(Teaching) - Attraction"
  ,"(Teaching) - Selection & Deployment"
  ,"(Teaching) - Support"
  ,"(Teaching) - Evaluation"
  ,"(Teaching) - Monitoring & Accountability"
  ,"(Teaching) - Intrinsic Motivation"
  ,"(Inputs & Infrastructure) - Standards"
  ,"(Inputs & Infrastructure) - Monitoring"
  ,"(Learners) - Nutrition Programs"
  ,"(Learners) - Health"
  ,"(Learners) - Center-Based Care"
  ,"(Learners) - Caregiver Capacity – Financial Capacity"
  ,"(Learners) - Caregiver Capacity – Skills Capacity"
  ,"(School Management) - Clarity of Functions"
  ,"(School Management) - Attraction"
  ,"(School Management) - Selection & Deployment"
  ,"(School Management) - Support"
  ,"(School Management) - Evaluation"
  ,"Politics & Bureaucratic Capacity - Characteristics of Bureaucracy"
  ,"Politics & Bureaucratic Capacity - Impartial Decision-Making"
  ,"Politics & Bureaucratic Capacity - Mandates & Accountability"
  ,"Politics & Bureaucratic Capacity - National Learning Goals"
  ,"Politics & Bureaucratic Capacity - Financing"
  
)

#save a tab to the excel with just the indicators in main_indicators
main_indicator_data <- indicator_data %>%
  filter(Series %in% main_indicators) %>%
  #arrange by main indicators
  mutate(Series = factor(Series, levels = main_indicators)) %>%
  arrange(Series) %>%
  #round mean standard error, lower bound, upper bound, and variance to 1 decimal places
  mutate(across(c(Mean, `Standard Error`, `Lower Bound`, `Upper Bound`, Variance), ~round(., 1))) %>%
  select(Series,	`Indicator Name`,	Mean,	`Standard Error`,	`Lower Bound`,	`Upper Bound`,	`Variance`,	`N`, everything())


#list of tabs 
list_of_tabs <- list(
  "Main Indicators" = main_indicator_data
)

#add tab with main urban/rural breakdowns
urban_rural_data <- indicator_data %>%
  filter(Series %in% c(paste0(main_indicators, ".1.R"), paste0(main_indicators, ".1.U"), 
                       'SE.PRM.EFFT.2.R', 'SE.PRM.EFFT.2.U',
                       'SE.PRM.LCAP.R', 'SE.PRM.LCAP.U'
                       )) %>%
  filter(!(Series %in% c("SE.PRM.EFFT.1.R", "SE.PRM.EFFT.1.U")) ) %>% #manual fix to pick the right teacher absence indicator.
  filter(!(Series %in% c("SE.PRM.LCAP.1.R", "SE.PRM.LCAP.1.U")) ) %>% #manual fix to pick the right ecd  indicator.
  #round mean standard error, lower bound, upper bound, and variance to 1 decimal places
  mutate(across(c(Mean, `Standard Error`, `Lower Bound`, `Upper Bound`, Variance), ~round(., 1))) %>%
  select(Series,	`Indicator Name`,	Mean,	`Standard Error`,	`Lower Bound`,	`Upper Bound`,	`Variance`,	`N`, everything())

#add to list of tabs
list_of_tabs[["Urban Rural Breakdown"]] <- urban_rural_data

#now loop through the main indicators and save each one as a separate tab in the excel with all the subindicaors as well
for (i in 1:length(main_indicators)) {
  
  #get indicator name
  name <- main_indicators[i]
  
  #get indicator label
  label <- main_indicator_labels[i]
  
  #get indicator data
  sub_data <- indicator_data %>%
    filter(grepl(name, Series)) %>%
    #round mean standard error, lower bound, upper bound, and variance to 1 decimal places
    mutate(across(c(Mean, `Standard Error`, `Lower Bound`, `Upper Bound`, Variance), ~round(., 1))) %>%
    select(Series,	`Indicator Name`,	Mean,	`Standard Error`,	`Lower Bound`,	`Upper Bound`,	`Variance`,	`N`, everything())
  
  #create dataframe that is named after name
  assign(name, sub_data)
  
  #add sub_data to list
  list_of_tabs[[label]] <- sub_data
  
}

write_xlsx(list_of_tabs, here('04_GEPD_Indicators',paste0(country,"_GEPD_Indicators_", software,".xlsx")))



