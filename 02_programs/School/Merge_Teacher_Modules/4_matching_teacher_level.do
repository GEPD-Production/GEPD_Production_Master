

* Purpose: Match EPDashboard main file with TEACHERS data to bring in the TEACH Variables:
* Date: 2/5/2024

/*
use "C:\Users\wb549384\WBG\HEDGE Files - GEPD-Confidential\General\Country_Data\GEPD_Production-Sindh\01_GEPD_raw_data\School\EPDashboard2.dta", clear

br interview__key m4saq1 m4saq1_number 
*/

clear all
set more off
*macro drop _all
cap log close
program drop _all
matrix drop _all
*set trace on
*set tracedepth 1

global date = c(current_date)
global username = c(username)

*global clone "C:\Users\Hersheena\OneDrive\Desktop\Professional\WBG_GEPD_2023\GEPD Production Balochistan"

/*Our goal is to clean all variables in all modules before matching teacher names across modules */ 

* Enter the country we are looking at here: PAK_Balochistan

********
*read in the raw school file
********
*set the paths
gl data_dir ${clone}/01_GEPD_raw_data/
gl processed_dir ${clone}/03_GEPD_processed_data/

global strata district location // Strata for sampling

* GEPD_Punjab_sample_200_2023-10-31.csv

* Execution parameters
global weights_file_name "GEPD_Punjab_weights_200_2023-10-31.csv" // Name of the file with the sampling
global school_code_name "csl_emis_code" // Name of the school code variable in the weights file
global other_info tehsil  schoollevel // other info needed in sampling frame (shift)
*-------------------------------------------------------------------------------

*save some useful locals
local preamble_info_individual school_code 
local preamble_info_school school_code 
local not school_code
local not1 interview__id


frame create school
frame change school

use "${data_dir}\\School\\EPDashboard2.dta" 



********
*read in the school weights
********

frame create weights
frame change weights
import delimited "${data_dir}/Sampling/${weights_file_name}"

* rename school code
rename ${school_code_name} school_code 

* clonevar tehsil = taluka
clonevar location =  csl_area
clonevar schoollevel = csl_level

keep school_code ${strata} ${other_info} strata_prob ipw 

gen strata=" "
foreach var in $strata {
	replace strata=strata + `var' + " - "
}

gen urban_rural=location

destring school_code, replace force
destring ipw, replace force
duplicates drop school_code, force





******
* Merge the weights
*******
frame change school

* school_name_preload	school_code_preload	school_info_correct	m1s0q2_name	m1s0q2_emis

replace school_emis_preload = m1s0q2_emis if school_info_correct ==0
replace school_name_preload = m1s0q2_name if school_info_correct ==0

gen school_code = school_emis_preload
gen school_name = school_name_preload

replace school_code = m1s0q2_emis if school_info_correct ==0
replace school_name = m1s0q2_name if school_info_correct ==0

destring school_code, generate(school_code_ar) force

replace school_code = school_code_preload if school_code_ar ==. 


destring school_code, replace
drop school_code_ar

format school_code  %12.0f

/*
destring m1s0q2_emis, replace
format m1s0q2_emis %12.0f

*fix missing cases
replace school_code = m1s0q2_emis if school_info_correct==0

*/

/*
gen str_len = strlen(school_code)

br str_len school_code
*/





drop if missing(school_code)

frlink m:1 school_code, frame(weights)
frget ${strata} ${other_info} urban_rural strata_prob ipw strata, from(weights)



*create weight variable that is standardized
gen school_weight=strata_prob // school level weight

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

clonevar school_code_org = school_code 

isid interview__key
isid school_code 

********************************************************************************
preserve

keep interview__key school_code *

tempfile key
save `key', replace
 
restore


use `key', clear 

isid school_code
isid interview__key

replace m4saq1_number=15 if m4saq1_number==10474363 // fix an issue with code


rename  m4saq1_number TEACHERS__id 


 
 keep  TEACHERS__id school_code  s1_0_1_1 s1_0_1_2 s1_0_2_1 s1_0_2_2 s1_0_3_1 s1_0_3_2 s1_a1 s1_a1_1 s1_a1_2 s1_a1_3 s1_a1_4a s1_a1_4b s1_a2 s1_a2_1 s1_a2_2 s1_a2_3 s1_b3 s1_b3_1 s1_b3_2 s1_b3_3 s1_b3_4 s1_b4 s1_b4_1 s1_b4_2 s1_b4_3 s1_b5 s1_b5_1 s1_b5_2 s1_b6 s1_b6_1 s1_b6_2 s1_b6_3 s1_c7 s1_c7_1 s1_c7_2 s1_c7_3 s1_c8 s1_c8_1 s1_c8_2 s1_c8_3 s1_c9 s1_c9_1 s1_c9_2 s1_c9_3 s2_0_1_1 s2_0_1_2 s2_0_2_1 s2_0_2_2 s2_0_3_1 s2_0_3_2 s2_a1 s2_a1_1 s2_a1_2 s2_a1_3 s2_a1_4a s2_a1_4b s2_a2 s2_a2_1 s2_a2_2 s2_a2_3 s2_b3 s2_b3_1 s2_b3_2 s2_b3_3 s2_b3_4 s2_b4 s2_b4_1 s2_b4_2 s2_b4_3 s2_b5 s2_b5_1 s2_b5_2 s2_b6 s2_b6_1 s2_b6_2 s2_b6_3 s2_c7 s2_c7_1 s2_c7_2 s2_c7_3 s2_c8 s2_c8_1 s2_c8_2 s2_c8_3 s2_c9 s2_c9_1 s2_c9_2 s2_c9_3

 
count
 
tempfile teach1
save `teach1', replace 

********************************************************************************

use "${clone}/01_GEPD_raw_data/School/TEACHERS.dta", replace
isid interview__key TEACHERS__id


frlink m:1 interview__key, frame(school)
frget school_code , from(school)

duplicates drop school_code TEACHERS__id, force

merge 1:1 school_code TEACHERS__id using `teach1'

* Comment_AR: Discuss merge results with Brian. 
tab _merge 

br if _merge==2
drop _merge 

* Comment_AR I have to drop school_code because if I don't follow-up code breaks.
drop school_code
drop school




********************************************************************************
save "${clone}/01_GEPD_raw_data/School/Punjab_teacher_level_test.dta", replace
********************************************************************************




