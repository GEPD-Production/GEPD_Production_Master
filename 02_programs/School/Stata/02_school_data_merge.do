clear all

*set the paths
gl data_dir ${clone}/01_GEPD_raw_data/
gl processed_dir ${clone}/03_GEPD_processed_data/


*save some useful locals
local preamble_info_individual school_code 
local preamble_info_school school_code 
local not school_code
local not1 interview__id

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

* Comment_AR: adjust variables in the sample file. Confirm correct sample file from Brian.

clonevar location =  csl_area
clonevar schoollevel = csl_level

clonevar  urban_rural = location



keep school_code ${strata} ${other_info} strata_prob ipw urban_rural


destring school_code, replace force
destring ipw, replace force
duplicates drop school_code, force


* Comment_AR: Drop one missing school_code : Confirm correct sample file.

drop if school_code == .
******
* Merge the weights
*******
frame change school

gen school_code=school_code_preload
destring school_code, force replace

drop if missing(school_code)

frlink m:1 school_code, frame(weights)
frget ${strata} ${other_info} urban_rural strata_prob ipw strata, from(weights)


*create weight variable that is standardized
gen school_weight=1/strata_prob // school level weight

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
* See Merge_Teacher_Modules code folder for help in this task if needed
********

* use "${data_dir}\\School\\TEACHERS.dta"

use "${data_dir}\\School\\Punjab_teacher_level_test.dta"

* Rename all variables to lower case:
ren *, lower 

clonevar teachers_id = teachers__id

fre  m2saq3

* Comment_AR: Commented out as gender variable is already correctly formatted. 
* recode m2saq3 1=2 0=1


foreach var in $other_info {
	cap drop `var'
}
cap drop $strata

frlink m:1 interview__key, frame(school)
frget school_code ${strata} $other_info urban_rural strata school_weight numEligible numEligible4th, from(school)

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

drop if missing(school_weight)



********************************************************************************
* Comment_AR: TEACH Run:
do "${clone}/02_programs/School/Stata/teach_chk.do"



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
frget school_code ${strata} $other_info urban_rural strata school_weight m6_class_count g1_teacher_count, from(school)


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
frget school_code ${strata}  $other_info urban_rural strata school_weight m4scq4_inpt g4_teacher_count g4_stud_count, from(school)

order school_code
sort school_code

*weights
gen g4_class_weight=g4_teacher_count/1, // weight is the number of 4tg grade streams divided by number selected (1)
replace g4_class_weight=1 if g4_class_weight<1 //fix issues where no g4 teachers listed. Can happen in very small schools

bysort school_code: gen g4_assess_count=_N

gen g4_stud_weight_temp=g4_stud_count/g4_assess_count // max of 25 students selected from the class

gen g4_stud_weight=g4_class_weight*g4_stud_weight_temp


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

* collapse to school level
ds, has(type numeric)
local numvars "`r(varlist)'"
local numvars : list numvars - not

ds, has(type string)
local stringvars "`r(varlist)'"
local stringvars : list stringvars- not

collapse (mean) `numvars' (firstnm) `stringvars', by(school_code)


save "${processed_dir}\\School\\Confidential\\Merged\\school.dta" , replace