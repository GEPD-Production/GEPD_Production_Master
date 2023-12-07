clear all

*set the paths
gl data_dir ${clone}/01_GEPD_raw_data/
gl processed_dir ${clone}/03_GEPD_processed_data/


***************
***************
* School File
***************
***************

********
*read in the raw school file
********
frame create school
frame change school

use "${data_dir}\\School\\EPDash.dta" 

********
*read in the school weights
********

frame create weights
frame change weights
import delimited "${data_dir}\\Sampling\\${weights_file_name}"

* rename school code
rename school_code ${school_code_name}

keep school_code ${strata} urban_rural public strata_prob ipw
destring school_code, replace force
destring ipw, replace force
duplicates drop school_code, force



******
* Merge the weights
*******
frame change school

gen school_code = school_emis_preload
destring school_code, replace force

frlink m:1 school_code, frame(weights)
frget ${strata} urban_rural public strata_prob ipw, from(weights)

*******
* collapse to school level
*******

*drop some unneeded info
drop enumerators*

order school_code
sort school_code
save "${processed_dir}\\School\\Confidential\\Merged\\school.dta" , replace


***************
***************
* Teacher File
***************
***************

frame create teachers
frame change teachers
use "${data_dir}\\School\\questionnaire_roster.dta" 


frlink m:1 interview__key interview__id, frame(school)
frget school_code ${strata} urban_rural public strata_prob ipw, from(school)

order school_code
sort school_code

********
* Addtional Cleaning will likely be required here
********

save "${processed_dir}\\School\\Confidential\\Merged\\teachers.dta" , replace


***************
***************
* 1st Grade File
***************
***************

frame create first_grade
frame change first_grade
use "${data_dir}\\School\\ecd_assessment.dta" 


frlink m:1 interview__key interview__id, frame(school)
frget school_code ${strata} urban_rural public strata_prob ipw, from(school)

order school_code
sort school_code

save "${processed_dir}\\School\\Confidential\\Merged\\first_grade_assessment.dta" , replace

***************
***************
* 4th Grade File
***************
***************

frame create fourth_grade
frame change fourth_grade
use "${data_dir}\\School\\fourth_grade_assessment.dta" 


frlink m:1 interview__key interview__id, frame(school)
frget school_code ${strata} urban_rural public strata_prob ipw, from(school)

order school_code
sort school_code

save "${processed_dir}\\School\\Confidential\\Merged\\fourth_grade_assessment.dta" , replace