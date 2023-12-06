/*******************************************************************************
Purpose: Merging all teacher modules (roster, pedagogy, asssessment, and questionnaire)
for Tchad

Last modified on: 
By: 
    
*******************************************************************************/

clear all
set more off
macro drop _all
cap log close
program drop _all
matrix drop _all
*set trace on
*set tracedepth 1

* Install packages
ssc install matchit
ssc install freqindex

global date = c(current_date)
global username = c(username)

** File paths
* If you have one drive installed on your local machine, use this base
*global base "C:/Users/${username}/WBG/HEDGE Files - HEDGE Documents/GEPD-Confidential/General/LEGO_Teacher_Paper"

* set up all globals
global base "C:\Users\Hersheena\OneDrive\Desktop\Professional\WBG_GEPD_2023\LEGO_Teacher_Paper"
global data "$base\5_output_data\1_clean_input_data"
global temp "$base\4_temp_data"
global final "$base\5_output_data"
global code "$base\1_code\2_merging_modules"
global log "$base\2_log"

/*Our goal is to have a teacher level file that combines modules 1(roster), 
4 (questionnaire), 5 (assessment) and 7 (pedagogy/classroom observation).
The final data should be unique at the teacher_id - school_code level.
*/ 

* Enter the 3 letter corresponding to the country here. E.g Tchad - TCD
global country TCD

foreach cty in $country {

/* Step 1: Start with roster data */
use "$data/`cty'/`cty'_teacher_absence.dta", clear

* Dataset should be unique at teacher-id - school_code level
*isid teachers_id school_code
* There are 6 obs with missing school code, no school level vars at all. Impute the 
* same school code for all 6 obs
sum school_code
replace school_code=999999 if missing(school_code)
replace m2saq2=lower(m2saq2)
 
/* Create a unique teacher ID that combines the number assigned to the teacher and the 
school code
*/
format school_code %12.0g
tostring school_code, g(str_school_code)
tostring teachers_id, g(str_teach_id)
egen unique_teach_id=concat(str_teach_id str_school_code), punct(.)
drop str_school_code str_teach_id
isid unique_teach_id
la var unique_teach_id "Unique teacher ID combining school code and teacher number"

* There are 2064 teachers in the `cty' roster.

/* Step 2: Merge in modules key with roster */
/* Master is roster and is unique at teachers_id school code level
   Using is the modules key data - not unique at teachers id and hashed_school_code
   Merge 1:m on teachers_id and hashed_school_code
*/

* Merge modules key and roster
merge 1:1 teachers_id hashed_school_code using "$data/`cty'/`cty'_teacher_modules_key.dta"
drop _merge
isid teachers_id school_code													//Only variable v1 is different. Safe to dedup

/* Step 4: Merge in pedagogy data */
preserve
use "$data/`cty'/`cty'_teacher_pedagogy.dta", clear

count if missing(m4saq1_number)
* replace missing with 9999, we will replace back to missing after the merge
replace m4saq1_number=9999 if missing(m4saq1_number)

* There are 6 obs with missing m4saq1_number
* Drop them here and we will add them as extra rows within the same school code
duplicates tag m4saq1_number m4saq1 hashed_school_code, g(test)
drop if test==1
*isid m4saq1_number school_code
count
di "There are `r(N)' teachers in the `cty' pedagogy data"
*468

* There are two variables containing teacher names: one for grade 2 and one for grade 4
* flag for obs in pedagogy data
gen in_pedagogy=1

* Save a temp file
save "$temp/`cty'/`cty'_teacher_pedagogy.dta", replace

restore

*Now save a copy with those dropped obs above
preserve
use "$data/`cty'/`cty'_teacher_pedagogy.dta", clear

count if missing(m4saq1_number)
* There are 6 obs with missing m4saq1_number
* Drop them here and we will add them as extra rows within the same school code
duplicates tag m4saq1_number m4saq1 hashed_school_code, g(test)
keep if test==1

* There are two variables containing teacher names: one for grade 2 and one for grade 4
* flag for obs in pedagogy data
gen in_pedagogy=1

* Save a temp file
save "$temp/`cty'/`cty'_teacher.dta", replace

restore

/* Merge pedagogy data
Master is not unique at teachers_id and school_code
Using is not unique at m4saq1_number and school_code
We want to merge pedagogy on the m4saq1_number and school_code from the modules key
*/

* Note that there are a lot of missing values for m4saq1_number in the master data
count if missing(m4saq1_number)
* replace missing with 9999, we will replace back to missing after the merge
replace m4saq1_number=9999 if missing(m4saq1_number)

merge m:1 m4saq1_number m4saq1 school_code using "$temp/`cty'/`cty'_teacher_pedagogy.dta"
*443 out of 462!

* There are some names from pedagogy that repeat themselves and look like duplicates
duplicates tag m4saq1, g(name_dup)
replace flag_dup_teacher_name=1 if name_dup!=0
* replace back missing m4saq1_number
replace m4saq1_number=. if m4saq1_number==9999

* there are 24 observations from pedagogy only: one is a missing teacher name and one seems to map to 
* teacher_id instead of m4saq1_number
preserve
keep if _merge==2
drop _merge teachers_id
gen m4_id=m4saq1_number
rename m4_id teachers_id
drop if missing(teachers_id)
isid teachers_id school_code
save "$temp/`cty'/`cty'_pedagogy_temp.dta", replace
restore

* merge on teachers_id and school code
drop if _merge==2 & !missing(teachers_id)
drop _merge
merge m:1 teachers_id school_code using "$temp/`cty'/`cty'_pedagogy_temp.dta", update
*Now we have 459 matches out of 462

* Now merge the ones that were dropped on teacher id - name school and grades
drop _merge
merge m:1 grade m4saq1_number m4saq1 school_code using "$temp/`cty'/`cty'_teacher.dta"
drop _merge
erase "$temp/`cty'/`cty'_teacher.dta"

/* Step 4: Merge in m3(questionnaire) data */

* prep data for merge
preserve
use "$data/`cty'/`cty'_teacher_questionnaire.dta", clear

replace school_code=999999 if missing(school_code)

* Teacher name is m3sb_troster and teacher id is m3sb_tnumber
count if missing(m3sb_tnumber) 				//0 missing obs

isid m3sb_tnumber m3sb_troster school_code
duplicates tag m3sb_tnumber school_code, g(flag_m3_dup_teach_id)
replace flag_m3_dup_teach_id=1 if flag_m3_dup_teach_id!=0
la var flag_m3_dup_teach_id "Flag m3: same teacher id, different teacher name"
** There are 44 duplicates where the same teacher id was assigned to two different teachers in the same school

* flag for obs in questionnaire data
gen in_questionnaire=1

* Save a temp file
save "$temp/`cty'/`cty'_teacher_questionnaire.dta", replace
restore

* Same as in pedadogy, we want to keep the obs with missing ID(m3sb_tnumber) in the master data
count if missing(m3sb_tnumber)
* replace missing with 9999, we will replace back to missing after the merge
replace m3sb_tnumber=9999 if missing(m3sb_tnumber)

/* Master is not unique at teacher id and school code
Using is unique at teacher name - teacher id - school code level
Do a m:1 merge on those vars
*/
merge m:1 m3sb_troster m3sb_tnumber school_code using "$temp/`cty'/`cty'_teacher_questionnaire.dta"
*1050 out of 1100 matches!

* replace back missing m3sbt_number
replace m3sb_tnumber=. if m3sb_tnumber==9999

/* there are 52 observations from questionnaire only. A quick check shows that the m3sb_tnumber is missing from modules key
while these teachers had m3sb_tnumber in questionnaire data. Save a temp data with observations with _merge==2
and merge on teachers_id - school_code instead
*/
preserve
keep if _merge==2
drop _merge teachers_id
gen m3_id=m3sb_tnumber
rename m3_id teachers_id
drop if missing(teachers_id)
isid teachers_id school_code
save "$temp/`cty'/`cty'_questionnaire_temp.dta", replace
restore

* merge on teachers_id and school code
drop if _merge==2 & !missing(m3sb_tnumber)
drop _merge
merge m:1 teachers_id school_code using "$temp/`cty'/`cty'_questionnaire_temp.dta", update

/* Step 6: Merge in m5(assessment) data */
* prep data for merge
preserve
use "$data/`cty'/`cty'_teacher_assessment.dta", clear

replace school_code=999999 if missing(school_code)

rename m5sb_tnum m5sb_tnumber
* Teacher name is m5sb_troster and teacher id is m5sb_tnumber
count if missing(m5sb_tnumber) 				//0 missing obs

** There are 26 duplicates where the same teacher id was assigned to two different teachers in the same school
duplicates tag m5sb_tnumber school_code, g(flag_m5_dup_teach_id)
replace flag_m5_dup_teach_id=1 if flag_m5_dup_teach_id!=0
la var flag_m5_dup_teach_id "Flag m5: same teacher id, different teacher name"

* For now, drop obs with missing id. We want to keep all duplicates in master data.
replace m5sb_tnumber=9999 if missing(m5sb_tnumber)

* flag for obs in assessment data
gen in_assessment=1

* Save a temp file
save "$temp/`cty'/`cty'_teacher_assessment.dta", replace
restore

* Same as in pedadogy, we want to keep the obs with missing ID(m5sb_tnumber) in the master data
count if missing(m5sb_tnumber)
* replace missing with 9999, we will replace back to missing after the merge
replace m5sb_tnumber=9999 if missing(m5sb_tnumber)

/* Master is not unique at teacher id and school code
Using is unique at teacher name - teacher id - school code level
Do a m:1 merge on those vars
*/

drop _merge
merge m:1 m5sb_troster m5sb_tnumber school_code using "$temp/`cty'/`cty'_teacher_assessment.dta"
*1033 matches

* replace back missing m4saq1_number
replace m5sb_tnumber=. if m5sb_tnumber==9999

/* there are 50 observations from assessment only. A quick check shows that the 
m5sb_tnumber is missing from modules key while these teachers had m5sb_tnumber 
in assessment data.Save a temp data with observations 
with _merge==2 and merge on teachers_id - school_code instead
*/
preserve
keep if _merge==2
drop _merge teachers_id
gen m5_id=m5sb_tnumber
rename m5_id teachers_id
drop if m5sb_troster=="DJOUNOUMBI BASIL" & school_code==999999

isid teachers_id school_code

save "$temp/`cty'/`cty'_assessment_temp.dta", replace
restore

* merge on teachers_id and school code
drop if m5sb_troster=="DJOUNOUMBI BASIL" & school_code==999999 & _merge==2
drop if _merge==2
drop _merge
merge m:1 teachers_id school_code using "$temp/`cty'/`cty'_assessment_temp.dta", update


* Check on duplicates
duplicates tag teachers_id school_code, g(tag_dup_final)
tab tag_dup_final

/* There are 5 duplicated teacher id - school code combos because the same teachers
taught frade 2 and grade 4 in the same school. So we have a grade 2 obs and a grade 4 obs.
*/

* drop temp/unecessary vars 
drop _merge tag_dup_final tag

* label variables 
do "$code/zz_label_all_variables.do"

order unique_teach_id
sort school_code teachers_id

* Save final data
save "$final/`cty'/`cty'_teacher_level.dta", replace

}
