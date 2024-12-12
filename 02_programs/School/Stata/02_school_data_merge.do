* Last updated by Mohammed ELdesouky on December 12 2024

clear all

*set the paths
gl data_dir ${clone}/01_GEPD_raw_data/
gl processed_dir ${clone}/03_GEPD_processed_data/


*save some useful locals
local preamble_info_individual school_code 
local preamble_info_school school_code 
local not "school_code"
local not1 "interview__id"

***************
***************
* Append files from various questionnaires
***************
***************
/*
gl dir_v7 "${data_dir}\\School\\School Survey - Version 7 - without 10 Revisited Schools\\"
gl dir_v8 "${data_dir}\\School\\School Survey - Version 8 - without 10 Revisited Schools\\"

* get the list of files
local files_v7: dir "${dir_v7}" files "*.dta"

di `files_v7'
* loop through the files and append into a single file saved in dir_saved
gl dir_saved "${data_dir}\\School\\"

foreach file of local files_v7 {
	di "`file'"
	use "${dir_v7}`file'", clear
	append using "${dir_v8}`file'", force
	save "${dir_saved}`file'", replace
}
*/

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

use "${data_dir}\\School\\EPDashboard2.dta" 

********
*read in the school weights
********

frame create weights
frame change weights
import delimited "${data_dir}\\Sampling\\${weights_file_name}"

* rename school code
rename ${school_code_name} school_code 

* Comment_Mo (if needed): adjust variables in the sample file. Confirm correct sample file.
clonevar schoollevel = school_type
clonevar location =  csl_area
clonevar  urban_rural = location

keep school_code ${strata} ${other_info} strata_prob ipw urban_rural schoollevel location


destring school_code, replace force
destring ipw, replace force
duplicates drop school_code, force


*[Mo comment, no missing school_code]
drop if missing(school_code)

******
* Merge the weights
*******
frame change school

*dropping test enteries 
*count if school_code_preload=="##N/A##"
*drop if school_code_preload=="##N/A##"

gen school_code=school_code_preload
destring school_code, force replace
format school_code  %12.0f
destring m1s0q2_emis, force replace 

replace school_code =  m1s0q2_emis if school_info_correct == 0 & m1s0q2_emis !=.
replace school_name_preload = m1s0q2_name if school_info_correct == 0 

count if missing(school_code)  // 0 missings

frlink m:1 school_code, frame(weights)
frget ${strata} ${other_info} urban_rural strata_prob ipw strata schoollevel location, from(weights)


*create weight variable that is standardized
gen school_weight=1/strata_prob // school level weight
count if missing(school_weight) // Mo-there should be no missings, if so, run the follwoing and contact the surveying firm
br if missing(school_weight) 


*fourth grade student level weight
egen g4_stud_count = mean(m4scq4_inpt), by(school_code)


*create collapsed school file as a temp
frame copy school school_collapse_temp
frame change school_collapse_temp

order school_code
sort school_code

* collapse to school level
ds, has(type numeric)
local numvars "`r(varlist)'"
local numvars : list numvars - not

ds, has(type string)
local stringvars "`r(varlist)'"
local stringvars : list stringvars- not

 foreach v of var * {
	local l`v' : variable label `v'
       if `"`l`v''"' == "" {
 	local l`v' "`v'"
 	}
 }

collapse (max) `numvars' (firstnm) `stringvars', by(school_code)

 foreach v of var * {
	label var `v' `"`l`v''"'
 }
 
 
******
* TEACH data - create the teacher-level file inlcuding TEACH vars: ()
*******
clonevar school_code_org = school_code 

isid interview__key
isid school_code 

preserve

keep interview__key school_code *

tempfile key
save `key', replace
 
restore


use `key', clear 

isid school_code
isid interview__key


rename  m4saq1_number TEACHERS__id 

 keep  TEACHERS__id school_code  s1_0_1_1 s1_0_1_2 s1_0_2_1 s1_0_2_2 s1_0_3_1 s1_0_3_2 s1_a1 s1_a1_1 s1_a1_2 s1_a1_3 s1_a1_4a s1_a1_4b s1_a2 s1_a2_1 s1_a2_2 s1_a2_3 s1_b3 s1_b3_1 s1_b3_2 s1_b3_3 s1_b3_4 s1_b4 s1_b4_1 s1_b4_2 s1_b4_3 s1_b5 s1_b5_1 s1_b5_2 s1_b6 s1_b6_1 s1_b6_2 s1_b6_3 s1_c7 s1_c7_1 s1_c7_2 s1_c7_3 s1_c8 s1_c8_1 s1_c8_2 s1_c8_3 s1_c9 s1_c9_1 s1_c9_2 s1_c9_3 s2_0_1_1 s2_0_1_2 s2_0_2_1 s2_0_2_2 s2_0_3_1 s2_0_3_2 s2_a1 s2_a1_1 s2_a1_2 s2_a1_3 s2_a1_4a s2_a1_4b s2_a2 s2_a2_1 s2_a2_2 s2_a2_3 s2_b3 s2_b3_1 s2_b3_2 s2_b3_3 s2_b3_4 s2_b4 s2_b4_1 s2_b4_2 s2_b4_3 s2_b5 s2_b5_1 s2_b5_2 s2_b6 s2_b6_1 s2_b6_2 s2_b6_3 s2_c7 s2_c7_1 s2_c7_2 s2_c7_3 s2_c8 s2_c8_1 s2_c8_2 s2_c8_3 s2_c9 s2_c9_1 s2_c9_2 s2_c9_3 m4saq1 interview__key  interview__id interview__status

 
count

* Note Mo: Should be no missings, if so contact the firm
unique interview__key TEACHERS__id
count if missing(TEACHERS__id)

tempfile teach1
save `teach1', replace 

*Merging Teach data (unique on the school level) with Teachers' roster file 
use "${clone}/01_GEPD_raw_data/School/TEACHERS.dta", replace
unique interview__key TEACHERS__id

frlink m:1 interview__key, frame(school)
frget school_code , from(school)

count if missing(school_code) //Mo: should be no missings-- if not so, run the following line and get in touch with the firm
list school_code interview__id interview__key TEACHERS__id if missing(school_code)

isid school_code TEACHERS__id // shall be unique

merge 1:1 school_code TEACHERS__id using `teach1'  //all teachers from TEACH data must be merged

drop _merge 

unique school_code //must match number of schools in school-level collapsed file
save "${clone}/01_GEPD_raw_data/School/${country}_teacher_level_test.dta", replace


* Note Mo: [only applies if some of teachers modules are collected manually on seperate forms] in some occassions assessmnet and questionnaire data can be collected in a seperate file manually and it has to be brought in to the teacher_level_test

/*
*IMPORT TEACHER assessment manual FILE:
frame create ases_m
frame change ases_m
use"${data_dir}\\School\\teacher_assessment_manual.dta" 
rename *_manual* **
gen TEACHERS__id=m5sb_tnum

unique interview__key TEACHERS__id // must be unique 

frlink m:1 interview__key, frame(school) // importing school_codes
frget school_code , from(school)

unique school_code TEACHERS__id //if not unique,  corrections to teachers code shall be made 

drop interview__key interview__id teacher_assessment__id teach_content_gender school

tempfile ases_m
save `ases_m', replace 


*IMPORT TEACHER qestionnaire manual FILE:
frame create quest_m
frame change quest_m
use"${data_dir}\\School\\questionnaire_roster_manual.dta" 
rename *_manual* **
gen TEACHERS__id=m3sb_tnumber

unique interview__key TEACHERS__id // must be unique 

frlink m:1 interview__key, frame(school) // importing school_codes
frget school_code , from(school)

unique school_code TEACHERS__id // if not unique,  corrections to teachers code shall be made 

drop interview__key interview__id questionnaire_roster__id school // dropping some varibales to avoid conflict when merging to TEACHERS data

tempfile quest_m
save `quest_m', replace 


*IMPORT TEACHER ROSTER FILE:
use "${clone}/01_GEPD_raw_data/School/${country}_teacher_level_test.dta", replace

*merging assessment manual data
merge 1:m school_code TEACHERS__id using `ases_m', update
unique school_code
unique school_code TEACHERS__id

drop _merge


*merging questionnaire manual data
merge 1:m school_code TEACHERS__id using `quest_m', update
unique school_code
unique school_code TEACHERS__id

drop _merge

save "${clone}/01_GEPD_raw_data/School/${country}_teacher_level_test.dta", replace

*/


***************
***************
* Teacher File
***************
***************

frame create teachers
frame change teachers
********
* Addtional Cleaning may be required here to link the various modules
* We are assuming the teacher level modules (Teacher roster, Questionnaire, Pedagogy, and Content Knowledge have already been linked here)
********
use "${data_dir}\\School\\Punjab_teacher_level_test.dta"

* Rename all variables to lower case:
ren *, lower 

clonevar teachers_id = teachers__id

fre  m2saq3

* Comment: Commented out as gender variable is already correctly formatted. 
* recode m2saq3 1=2 0=1


foreach var in $other_info $strata school_code school  {
	cap drop `var'
}


frlink m:1 interview__key, frame(school)
frget school_code ${strata} $other_info urban_rural strata school_weight numEligible numEligible4th schoollevel, from(school)

*get number of 4th grade teachers for weights
egen g4_teacher_count=sum(m3saq2__4), by(school_code)
egen g1_teacher_count=sum(m3saq2__1), by(school_code)

order school_code
sort school_code

*weights
*teacher absense weights
*get number of teachers checked for absense
egen teacher_abs_count=count(m2sbq6_efft), by(school_code)
gen teacher_abs_weight=numEligible/teacher_abs_count
replace teacher_abs_weight=1 if missing(teacher_abs_weight) //fix issues where no g1 teachers listed. Can happen in very small schools

*teacher questionnaire weights
*get number of teachers checked for absense
egen teacher_quest_count=count(m3s0q1), by(school_code)
gen teacher_questionnaire_weight=numEligible4th/teacher_quest_count
replace teacher_questionnaire_weight=1 if missing(teacher_questionnaire_weight) //fix issues where no g1 teachers listed. Can happen in very small schools

*teacher content knowledge weights
*get number of teachers checked for absense
egen teacher_content_count=count(m3s0q1), by(school_code)
gen teacher_content_weight=numEligible4th/teacher_content_count
replace teacher_content_weight=1 if missing(teacher_content_weight) //fix issues where no g1 teachers listed. Can happen in very small schools

*teacher pedagogy weights
gen teacher_pedagogy_weight=numEligible4th/1 // one teacher selected
replace teacher_pedagogy_weight=1 if missing(teacher_pedagogy_weight) //fix issues where no g1 teachers listed. Can happen in very small schools

count if missing(school_weight)
drop if missing(school_weight)  //nothing to drop


save "${processed_dir}\\School\\Confidential\\Merged\\teachers.dta" , replace

********************************************************************************


********
* Add some useful info back onto school frame for weighting
********

*collapse to school level
frame copy teachers teachers_school
frame change teachers_school

collapse g1_teacher_count g4_teacher_count, by(school_code)

frame change school
frlink m:1 school_code, frame(teachers_school)

frget g1_teacher_count g4_teacher_count, from(teachers_school)



***************
***************
* 1st Grade File
***************
***************

frame create first_grade
frame change first_grade
use "${data_dir}\\School\\ecd_assessment.dta" 


frlink m:1 interview__key interview__id, frame(school)
frget school_code ${strata} $other_info urban_rural strata school_weight m6_class_count g1_teacher_count schoollevel, from(school)


order school_code
sort school_code

*weights
gen g1_class_weight=g1_teacher_count/1, // weight is the number of 1st grade streams divided by number selected (1)
replace g1_class_weight=1 if g1_class_weight<1 //fix issues where no g1 teachers listed. Can happen in very small schools

bysort school_code: gen g1_assess_count=_N
gen g1_stud_weight_temp=m6_class_count/g1_assess_count // 3 students selected from the class

gen g1_stud_weight=g1_class_weight*g1_stud_weight_temp

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
frget school_code ${strata}  $other_info urban_rural strata school_weight m4scq4_inpt g4_teacher_count g4_stud_count schoollevel, from(school)

order school_code
sort school_code

*weights
gen g4_class_weight=g4_teacher_count/1, // weight is the number of 4tg grade streams divided by number selected (1)
replace g4_class_weight=1 if g4_class_weight<1 //fix issues where no g4 teachers listed. Can happen in very small schools

bysort school_code: gen g4_assess_count=_N

gen g4_stud_weight_temp=g4_stud_count/g4_assess_count // max of 25 students selected from the class

gen g4_stud_weight=g4_class_weight*g4_stud_weight_temp

unique school_code fourth_grade_assessment__id // shall be unique - otherwise additional cleaning is required 

save "${processed_dir}\\School\\Confidential\\Merged\\fourth_grade_assessment.dta" , replace

***************
***************
* Collapse school data file to be unique at school_code level
***************
***************

frame change school

*******
* collapse to school level
*******

*drop some unneeded info
drop enumerators*

order school_code
sort school_code

* Adjust value label names that are too long 
la copy fillout_teacher_questionnaire fillout_teacher_q
la val fillout_teacher_questionnaire fillout_teacher_q
la drop fillout_teacher_questionnaire
clonevar fillout_teacher_q = fillout_teacher_questionnaire
la val fillout_teacher_q fillout_teacher_q
drop fillout_teacher_questionnaire


la copy fillout_teacher_content fillout_teacher_con
la val fillout_teacher_content fillout_teacher_con
la drop fillout_teacher_content
clonevar fillout_teacher_con = fillout_teacher_content
la val fillout_teacher_con fillout_teacher_con
drop fillout_teacher_content


* collapse to school level
ds, has(type numeric)
local numvars "`r(varlist)'"
local numvars : list numvars - not

ds, has(type string)
local stringvars "`r(varlist)'"
local stringvars : list stringvars- not

* Store variable labels:
 foreach v of var * {
	local l`v' : variable label `v'
       if `"`l`v''"' == "" {
 	local l`v' "`v'"
 	}
 }
 
 * Store value labels: 

label dir 
return list


local list_of_valuelables = r(names)  // specify labels you want to keep
* local list_of_valuelables =  "m7saq7 m7saq10 teacher_obs_gender"

// save the label values in labels.do file to be executed after the collapse:
label save using "${clone}/02_programs/School/Stata/labels.do", replace
// note the names of the label values for each variable that has a label value attached to it: need the variable name - value label correspodence
   local list_of_vars_w_valuelables
 * foreach var of varlist m7saq10 teacher_obs_gender m7saq7 {
   
   foreach var of varlist * {
   
   local templocal : value label `var'
   if ("`templocal'" != "") {
      local varlabel_`var' : value label `var'
      di "`var': `varlabel_`var''"
      local list_of_vars_w_valuelables "`list_of_vars_w_valuelables' `var'"
   }
}
di "`list_of_vars_w_valuelables'"

fre fillout_teacher_con m1s0q3_infr m1scq13_imon__4 m1scq12_imon__2 m1scq12_imon__1 m1scq7_imon m1scq6_imon__2 m1scq6_imon__1 m1scq4_imon__3 m1sbq10_infr m1sbq8_infr m1sbq5_infr m1s0q3_infr m1s0q2_infr m1sbq3_infr

********************************************************************************
*drop labels and then reattach
label drop _all
collapse (mean) `numvars' (firstnm) `stringvars', by(school_code)

* Redefine var labels:  
  foreach v of var * {
	label var `v' `"`l`v''"'
 }
 
// Run labels.do to redefine the label values in collapsed file
do "${clone}/02_programs/School/Stata/labels.do"
// reattach the label values
foreach var of local list_of_vars_w_valuelables {
   cap label values `var' `varlabel_`var''
}



save "${processed_dir}\\School\\Confidential\\Merged\\school.dta" , replace