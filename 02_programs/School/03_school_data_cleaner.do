*Clean data files for GEPD school indicators
*Written by Kanika Verma

clear all

*Country name and year of survey
local country "PER"
local country_name  "Peru"
local year  "2019"
local preamble_info_individual hashed_school_code hashed_school_district hashed_school_province interview__id questionnaire_selected__id interview__key rural ipw STRATUM province
local preamble_info_school hashed_school_code hashed_school_district hashed_school_province interview__id interview__key rural ipw STRATUM province
local not hashed_school_code
local not1 interview__id

*Set working directory on your computer here
gl wrk_dir "/Users/kanikaverma/Desktop/WB internship/Data anonymized/GEPD_anonymized_data/Data/`country'/`country'_`year'_GEPD/`country'_`year'_GEPD_v01_M/Data/School/data"
cd "/Users/kanikaverma/Desktop/WB internship/Data anonymized/GEPD_anonymized_data/Data/`country'/`country'_`year'_GEPD/`country'_`year'_GEPD_v01_M/Data/School/data"

********************************************
* Create indicators and necessary variables
********************************************

************
*School data
************
cap frame create school
frame change school
*Load the school data
use "${wrk_dir}/school_dta_anon.dta"

************
*Teacher absence
************
cap frame create teacher_absence
frame change teacher_absence
*Load the teacher_absence data
use "${wrk_dir}/teacher_roster_anon.dta"

frlink m:1 interview__id, frame(school)
frget hashed_school_code hashed_school_province hashed_school_district rural STRATUM ipw province, from(school)

*Creating unique teacher gender file to get teacher gender variable
frame copy teacher_absence teacher_gender
frame change teacher_gender
keep questionnaire_selected__id hashed_school_code m2saq3
duplicates drop
keep if !missing(hashed_school_code)

************
*Teacher questionnaire
************
cap frame create teacher_questionnaire
frame change teacher_questionnaire
*Load the teacher_questionnaire data
use "${wrk_dir}/teacher_questionnaire_anon.dta"
*Link this file with teacher_gender to get teacher gender

************
*Teacher knowledge
************
cap frame create teacher_assessment
frame change teacher_assessment
*Load the teacher_assessment data
use "${wrk_dir}/teacher_assessment_dta_anon.dta"

drop literacy_content_knowledge cloze grammar read_passage math_content_knowledge arithmetic_number_relations geometry interpret_data

************
*4th grade assessment
************
cap frame create learning
frame change learning
*Load the 4th grade assessment data
use "${wrk_dir}/assess_4th_grade_anon_anon.dta"


************
*ECD assessment
************
cap frame create ecd
frame change ecd
*Load the ecd data
use "${wrk_dir}/ecd_dta_anon.dta"

set type double

*********************************************************
* Data is clean and ready to produce indicators
*********************************************************

*********************************************************
* Teacher Absence 
*********************************************************
* School survey. Percent of teachers absent. Teacher is coded absent if they are: 
* - not in school 
* - in school but absent from the class 
* - Loading teacher_absence dataset
frame change teacher_absence
*Error: File has missing school codes, and unique codes do not match with R files

*Generate school absence variable
gen school_absence_rate = (m2sbq6_efft==6 | teacher_available==2) if !missing(m2sbq6_efft)
replace school_absence_rate = 100*school_absence_rate
*generate absence variables
gen absence_rate = 100 if m2sbq6_efft==6 | m2sbq6_efft==5 |  teacher_available==2 
replace absence_rate = 0 if (m2sbq6_efft==1 | m2sbq6_efft==3 | m2sbq6_efft==2 | m2sbq6_efft==4) & teacher_available!=2

*generate principal absence_rate
gen principal_absence = 100 if m2sbq3_efft==8
replace principal_absence = 0 if m2sbq3_efft!=8 & !missing(m2sbq3_efft)

*Fix absence rates, where in some cases the principal is the only one they could assess for absence (1 room schools type of situation?)
replace absence_rate = principal_absence if missing(absence_rate)
replace school_absence_rate = principal_absence if missing(school_absence_rate)
*Generating teacher presence rate- whether in school or classroom
gen presence_rate = 100-absence_rate

frame put *, into(final_teacher_absence)
frame change final_teacher_absence
*Create data copies for female and male teacher absence rate calculations
frame copy final_teacher_absence sub_final_tabsence_male
frame copy final_teacher_absence sub_final_tabsence_female

frame change final_teacher_absence
*Error: This file has missing school codes

ds, has(type numeric)
local numvars_efft "`r(varlist)'"
ds, has(type string)
local stringvars_efft "`r(varlist)'"
local stringvars_efft : list stringvars_efft- not

collapse (mean) `numvars_efft' (firstnm) `stringvars_efft', by(hashed_school_code)
export excel using "final_indicator_EFFT", sheet("EFFT") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean absence_rate

frame change sub_final_tabsence_male
rename absence_rate absence_rate_male
collapse (mean) `numvars_efft' (first) `stringvars_efft' if m2saq3==1 , by(hashed_school_code)
export excel using "final_indicator_EFFT_M", sheet("EFFT") cell(A1) firstrow(variables) replace
svyset [pw=ipw]
svy: mean absence_rate_male

frame change sub_final_tabsence_female
rename absence_rate absence_rate_female
collapse (mean) `numvars_efft' (first) `stringvars_efft' if m2saq3==2, by(hashed_school_code)
export excel using "final_indicator_EFFT_F", sheet("EFFT") cell(A1) firstrow(variables) replace
svyset [pw=ipw]
svy: mean absence_rate_female

*********************************************
***** Student Attendance ***********
*********************************************

*Percent of 4th grade students who are present during an unannounced visit.
frame copy school student_attendance
frame change student_attendance

gen student_attendance=m4scq4_inpt/m4scq12_inpt
*fix an issue where sometimes enumerators will get these two questions mixed up.
replace student_attendance=m4scq12_inpt/m4scq4_inpt if m4scq4_inpt>m4scq12_inpt & !missing(student_attendance)
replace student_attendance=1 if student_attendance>1 & !missing(student_attendance)
replace student_attendance=100*student_attendance
keep hashed_school_code hashed_school_district hashed_school_province interview__id interview__key rural ipw STRATUM  m4scq4_inpt m4scq12_inpt m4scq4n_girls m4scq13_girls student_attendance

frame put *, into(final_student_attendance)
frame change final_student_attendance

*Create data copies for female and male teacher absence rate calculations
frame copy final_student_attendance sub_final_stattd_male
frame copy final_student_attendance sub_final_stattd_female
frame change final_student_attendance

ds
local vars_attd "`r(varlist)'"
local vars_attd : list vars_attd- not

collapse (firstnm) `vars_attd', by(hashed_school_code)
export excel using "final_indicator_ATTD", sheet("ATTD") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean student_attendance

*Boys attendance
frame change sub_final_stattd_male

frame copy sub_final_stattd_male sub_final_stattd_male_10
frame change sub_final_stattd_male_10

gen boys_num_attending = (m4scq4_inpt-m4scq4n_girls)
gen boys_on_list = (m4scq12_inpt-m4scq13_girls)
gen student_attendance_male = boys_num_attending/boys_on_list
*fix an issue where sometimes enumerators will get these two questions mixed up.
replace student_attendance_male=0 if student_attendance_male<0  & !missing(student_attendance_male)
replace student_attendance_male=1 if (student_attendance_male>1 & !missing(student_attendance_male)) | (boys_on_list==0 & boys_num_attending>boys_on_list)
replace student_attendance_male=100*student_attendance_male

ds
local vars_attd_m "`r(varlist)'"
local vars_attd_m : list vars_attd_m- not

collapse (firstnm) `vars_attd_m' , by(hashed_school_code)
export excel using "final_indicator_ATTD_M", sheet("ATTD_M") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean student_attendance_male

*Girls attendance
frame change sub_final_stattd_female
gen student_attendance_female = m4scq4n_girls/m4scq13_girls
*fix an issue where sometimes enumerators will get these two questions mixed up.
replace student_attendance_female=1 if student_attendance_female>1 & !missing(student_attendance_female)
replace student_attendance_female=100*student_attendance_female

ds
local vars_attd_f "`r(varlist)'"
local vars_attd_f : list vars_attd_f- not

collapse (firstnm) `vars_attd_f' , by(hashed_school_code)
export excel using "final_indicator_ATTD_F", sheet("ATTD_F") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean student_attendance_female


**********************************************************
* Teacher Content Knowledge
**********************************************************
*School survey. Fraction correct on teacher assessment. In the future, we will align with SDG criteria for minimum proficiency.

frame change teacher_assessment
rename g4_teacher_number questionnaire_selected__id
*this file has 3 missing values of hashed_school_code

*recode assessment variables to be 1 if student got it correct and zero otherwise
de m5s1q* m5s2q* m5s1q* m5s2q*, varlist
*Replacing values is enumerators have entered values other than 01,00 and 99- eg:2. Also replacing "No response" code 99 to 0- this is treated as incorrect answer- No such values have been detected in the file currently, this can be removed to increase speed of code
foreach var in `r(varlist)' {
replace `var'=1 if `var'==2 & !missing(`var')
replace `var'=0 if `var'==99 & !missing(`var')
}

*create indicator for % correct on teacher assessment

****Literacy****
*calculate # of literacy items correct
*Assessment consists of 4 parts- identifying correct letter, cloze, grammar and reading comprehension
*For whole assessment
egen literacy_content_knowledge=rowmean(m5s1q*)
*For separate parts of assessment- Correct the letter has been dropped
egen cloze=rowmean(m5s1q2*)
egen grammar=rowmean(m5s1q1*)
egen read_passage=rowmean(m5s1q4*)

****Math****
*calculate # of math items correct
*Assessment consists of 3 parts- arithmetic checks, geometry and data interpretation
*For whole assessment
egen math_content_knowledge=rowmean(m5s2q*)
*For separate parts of assessment
egen arithmetic_number_relations=rowmean(*_number)
egen geometry=rowmean(*_geometric)
egen interpret_data=rowmean(*_data)

*calculate % correct for literacy, math, and total
gen content_knowledge=(math_content_knowledge+literacy_content_knowledge)/2 if !missing(literacy_content_knowledge) & !missing(math_content_knowledge)
replace content_knowledge=math_content_knowledge if missing(literacy_content_knowledge)
replace content_knowledge=literacy_content_knowledge if missing(math_content_knowledge)
gen content_proficiency=(content_knowledge>=.80) if !missing(content_knowledge)

foreach var in content_proficiency content_knowledge literacy_content_knowledge cloze grammar read_passage math_content_knowledge arithmetic_number_relations geometry interpret_data {
	replace `var' = `var'*100
}

frame put *, into(final_teacher_assessment)
frame change final_teacher_assessment
egen m5_teach_count = count(hashed_school_code), by(hashed_school_code)
bysort hashed_school_code: egen m5_teach_count_math=count(hashed_school_code) if typetest==1

*Saving a version of the teacher assessment file at teacher level for linking with gender
frame copy final_teacher_assessment main_teacher_assessment
frame change main_teacher_assessment
*Linking files to get teacher gender variable
frlink m:1 hashed_school_code questionnaire_selected__id, frame(teacher_gender)
*Error: both teacher_gender and teacher asssessment files have missing hashed_school_code- creating errors in matching unique combinations of values of hashed_school_code and questionnaire_selected__id- 12 rows have missing gender values in main_teacher_assessment file
frget m2saq3, from(teacher_gender)
*Creating copies for gender analysis
*Error:Missing gender values means answers will not be accurate
frame copy main_teacher_assessment sub_final_tassess_male
frame copy main_teacher_assessment sub_final_tassess_female

frame change final_teacher_assessment

ds, has(type numeric)
local numvars_cont "`r(varlist)'"
ds, has(type string)
local stringvars_cont "`r(varlist)'"
local stringvars_cont : list stringvars_cont- not

collapse (mean) `numvars_cont' (firstnm) `stringvars_cont', by(hashed_school_code)
*Saving copy of result for future indicators use
frame copy final_teacher_assessment master_teacher_assessment
frame change final_teacher_assessment
export excel using "final_indicator_CONT", sheet("CONT") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
foreach var in content_proficiency  {
svy: mean `var'
}

*For male teachers
frame change sub_final_tassess_male
collapse content_proficiency content_knowledge literacy_content_knowledge math_content_knowledge ipw (first) province if m2saq3 == 1, by(hashed_school_code)
export excel using "final_indicator_CONT_M", sheet("CONT_M") cell(A1) firstrow(variables) replace
svyset [pw=ipw]
foreach var in content_proficiency  {
svy: mean `var'
}

*For female teachers
frame change sub_final_tassess_female
collapse content_proficiency content_knowledge literacy_content_knowledge math_content_knowledge ipw (first) province if m2saq3 == 2, by(hashed_school_code)
export excel using "final_indicator_CONT_F", sheet("CONT_F") cell(A1) firstrow(variables) replace
svyset [pw=ipw]
foreach var in content_proficiency  {
svy: mean `var'
}


************
*4th grade assessment
************

*Proficiency in math > 82%
*Proficiency in literacy > 92%
*Overall proficiency >86.6%
*Scoring questions m8saq2 and m8saq3, in which students identify letters/words that enumerator calls out is tricky, because enumerators would not always follow instructions to say out loud the same letters/words. In order to account for this, will assume if 80% of the class has a the exact same response, then this is the letter/word called out. If there is a deviation from what 80% of the class says, then it is wrong.
frame copy learning grade4
frame change grade4
de m8saq* m8sbq* m8saq* m8sbq*, varlist
*There are no incorrect values of variables- but just as a check, replacing any possible "No response" value of 99 with 0
foreach var in `r(varlist)' {
replace `var'=0 if `var'==99 & !missing(`var')
}
*create indicator for % correct on 4th grade assessment

****Literacy****
*calculate # of literacy items correct
egen literacy_student_knowledge_new=rowmean(m8saq*)
replace literacy_student_knowledge_new = 100*literacy_student_knowledge_new
****Math****
*calculate # of math items correct
egen math_student_knowledge_new=rowmean(m8sbq*)
replace math_student_knowledge_new = 100*math_student_knowledge_new

*calculate % correct for literacy, math, and total
gen student_knowledge_new=(math_student_knowledge_new+literacy_student_knowledge_new)/2
gen student_proficient=100*(student_knowledge_new>=86.6) if !missing(student_knowledge_new)
gen literacy_student_proficient= 100*(literacy_student_knowledge_new>=92) if !missing(literacy_student_knowledge_new)
gen math_student_proficient= 100*(math_student_knowledge_new>=82) if !missing(math_student_knowledge_new)

frame put *, into(final_4gradestudent_assessment)
*Creating copies with datasets for male and female student analysis
frame copy final_4gradestudent_assessment sub_final_4gradestudent_male
frame copy final_4gradestudent_assessment sub_final_4gradestudent_female

frame change final_4gradestudent_assessment

collapse student_proficient student_knowledge_new literacy_student_proficient literacy_student_knowledge_new math_student_proficient math_student_knowledge_new ipw (first) province, by(hashed_school_code)
export excel using "final_indicator_LERN", sheet("LERN") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
foreach var in student_proficient {
svy: mean `var'
}
*For male students
frame change sub_final_4gradestudent_male
collapse student_proficient student_knowledge_new literacy_student_proficient literacy_student_knowledge_new math_student_proficient math_student_knowledge_new ipw (first) province if student_male ==1, by(hashed_school_code)
export excel using "final_indicator_LERN_M", sheet("LERN_M") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
foreach var in student_proficient {
svy: mean `var'
}

*For female teachers
frame change sub_final_4gradestudent_female
collapse student_proficient student_knowledge_new literacy_student_proficient literacy_student_knowledge_new math_student_proficient math_student_knowledge_new ipw (first) province if student_male ==0, by(hashed_school_code)
export excel using "final_indicator_LERN_F", sheet("LERN_F") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
foreach var in student_proficient  {
svy: mean `var'
}

*******************
*ECD assessment
*******************
frame copy ecd ecd_assess
frame change ecd_assess
*create indicator for % correct on ECD assessment
*There are no wrong values in the dataset- all variables are already set in [0,1] range

****Literacy****
*calculate # of literacy items correct
egen ecd_lit_student_knowledge_new=rowmean(*vocabn *comprehension *letters *words *sentence *nm_writing *_print)

****Math****
*calculate # of math items correct
egen ecd_math_student_knowledge_new=rowmean(*counting *produce_set *number_ident *number_compare *simple_add)

****Executive Functioning****
*calculate # of executive functioning items correct
egen ecd_exec_student_knowledge_new=rowmean(*backward_digit *head_shoulders)

****Socio-Emotional****
*calculate # of socio emotional items correct
egen ecd_soc_student_knowledge_new=rowmean(*perspective *conflict_resol)

*calculate % correct for literacy, math, exec functioning, socio emotional and total
gen ecd_student_knowledge_new=(ecd_lit_student_knowledge_new+ecd_math_student_knowledge_new+ecd_exec_student_knowledge_new+ecd_soc_student_knowledge_new)/4
gen ecd_student_proficiency_new=(ecd_student_knowledge_new>=.80) if !missing(ecd_student_knowledge_new)
gen ecd_math_student_proficiency_new=(ecd_math_student_knowledge_new>=.80) if !missing(ecd_math_student_knowledge_new)
gen ecd_lit_student_proficiency_new=(ecd_lit_student_knowledge_new>=.80) if !missing(ecd_lit_student_knowledge_new)
gen ecd_exec_student_proficiency_new=(ecd_exec_student_knowledge_new>=.80) if !missing(ecd_exec_student_knowledge_new)
gen ecd_soc_student_proficiency_new=(ecd_soc_student_knowledge_new>=.80) if !missing(ecd_soc_student_knowledge_new)

foreach var in ecd_lit_student_knowledge_new ecd_math_student_knowledge_new ecd_soc_student_knowledge_new ecd_exec_student_knowledge_new ecd_student_knowledge_new ecd_student_proficiency_new ecd_math_student_proficiency_new ecd_lit_student_proficiency_new ecd_exec_student_proficiency_new ecd_soc_student_proficiency_new  {
replace `var' = `var'*100
}
                                  
frame put *, into(final_ecdstudent_assessment)
*Creating copies with datasets for male and female student analysis
frame copy final_ecdstudent_assessment sub_final_ecdstudent_male
frame copy final_ecdstudent_assessment sub_final_ecdstudent_female

frame change final_ecdstudent_assessment

ds, has(type numeric)
local numvars_lcap "`r(varlist)'"
ds, has(type string)
local stringvars_lcap "`r(varlist)'"
local stringvars_lcap : list stringvars_lcap- not

collapse (mean) `numvars_lcap' (firstnm) `stringvars_lcap', by(hashed_school_code)
export excel using "final_indicator_LCAP", sheet("LCAP") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean ecd_student_proficiency_new

*For male students
frame change sub_final_ecdstudent_male
collapse ecd_student_proficiency_new ecd_lit_student_proficiency_new ecd_math_student_proficiency_new ecd_exec_student_proficiency_new ecd_soc_student_proficiency_new ipw (first) province if m6s1q3 ==1, by(hashed_school_code)
export excel using "final_indicator_LCAP_M", sheet("LCAP_M") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean ecd_student_proficiency_new


*For female students
frame change sub_final_ecdstudent_female
collapse ecd_student_proficiency_new ecd_lit_student_proficiency_new ecd_math_student_proficiency_new ecd_exec_student_proficiency_new ecd_soc_student_proficiency_new ipw (first) province if m6s1q3 ==2, by(hashed_school_code)
export excel using "final_indicator_LCAP_F", sheet("LCAP_F") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean ecd_student_proficiency_new


*********************************************
***** School Inputs ********
*********************************************

* School survey. Total score starts at 1 and points added are the sum of whether a school has: 
*   - Functional blackboard 
* - Pens, pencils, textbooks, exercise books 
* - Fraction of students in class with a desk 
* - Used ICT in class and have access to ICT in the school

frame copy school school_inputs
frame change school_inputs

gen blackboard_functional= 1 if m4scq10_inpt==1 & m4scq9_inpt==1 & m4scq8_inpt==1
replace blackboard_functional = 0 if (m4scq10_inpt==0 | m4scq9_inpt==0 | m4scq8_inpt==0)

gen share_textbook=(m4scq5_inpt)/(m4scq4_inpt)
gen share_pencil=(m4scq6_inpt)/(m4scq4_inpt)
gen share_exbook=(m4scq7_inpt)/(m4scq4_inpt)
gen pens_etc = (share_pencil>=0.9 & share_exbook>=0.9) if !missing(share_pencil) & !missing(share_exbook)
gen textbooks = (share_textbook>=0.9) if !missing(share_textbook)
gen share_desk = 1-(m4scq11_inpt/m4scq4_inpt)
gen used_ict_num =0 if m1sbq12_inpt==0
replace used_ict_num = m1sbq14_inpt if m1sbq12_inpt>=1 & !missing(m1sbq12_inpt)

gen access_ict = 0 if m1sbq12_inpt==0 | m1sbq13_inpt==0
replace access_ict =1 if m1sbq12_inpt>=1 & m1sbq13_inpt==1 & !missing(m1sbq12_inpt)
replace access_ict = 0.5 if m1sbq12_inpt>=1 & m1sbq13_inpt==0 & !missing(m1sbq12_inpt)

frame put *, into(main_school_inputs)
frame change main_school_inputs
frame copy teacher_questionnaire school_teacher_ques_INPT
frame change school_teacher_ques_INPT
collapse (mean) m3sbq4_inpt, by(hashed_school_code)
rename m3sbq4_inpt used_ict_pct

frame change main_school_inputs
frlink m:1 hashed_school_code, frame(school_teacher_ques_INPT)
frget used_ict_pct, from(school_teacher_ques_INPT)
*Error: Missing values of hashed_school_code in school frame- hence used_ict_pct will be missing for some rows in new frame (13 rows)
gen used_ict=(used_ict_pct>=0.5 & used_ict_num>=3) if !missing(used_ict_num) & !missing(used_ict_pct)
ds hashed_school_code, not
collapse (firstnm) `r(varlist)', by(hashed_school_code)
gen inputs = textbooks+blackboard_functional + pens_etc + share_desk +  0.5*used_ict + 0.5*access_ict

frame put *, into(final_school_inputs)
frame change final_school_inputs
frame copy final_school_inputs master_school_inputs
frame change final_school_inputs
*Create lists of variables to be selected for export
local inpt_out share_textbook share_pencil share_exbook used_ict_num used_ict_pct blackboard_functional textbooks pens_etc share_desk used_ict access_ict inputs
local inpt_list *_inpt 
frame change final_school_inputs
keep `preamble_info_school' `inpt_list' `inpt_out' 
export excel using "final_indicator_INPT", sheet("INPT") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean inputs


*********************************************
***** School Infrastructure ********
*********************************************

*School survey. Total score starts at 1 and points added are the sum of whether a school has: 
*Access to adequate drinking water 
*Functional toilets.  Extra points available if are separate for boys/girls, private, useable, and have hand washing facilities 
*Electricity  in the classroom 
*Internet
*School is accessible for those with disabilities (road access, a school ramp for wheelchairs, an entrance wide enough for wheelchairs, ramps to classrooms where needed, accessible toilets, and disability screening for seeing, hearing, and learning disabilities with partial credit for having 1 or 2 or the 3).)

frame copy school school_infr
frame change school_infr

de *_infr m4scq10_inpt m4scq8_inpt m1sbq15_inpt, varlist
*Replacing values if enumerators have entered value 99- "No response" code to 0- this is treated as incorrect answer
foreach var in `r(varlist)' {
replace `var'=0 if `var'==99 & !missing(`var')
}
*Drinking water
gen drinking_water = (m1sbq9_infr==1 | m1sbq9_infr==2 | m1sbq9_infr==5 | m1sbq9_infr==6) if !missing(m1sbq9_infr)

*Functioning toilet
gen toilet_exists = 0 if m1sbq1_infr==7
replace toilet_exists = 1 if m1sbq1_infr!=7 & !missing(m1sbq1_infr)
gen toilet_separate = (m1sbq2_infr==1 | m1sbq2_infr==3) if !missing(m1sbq2_infr)
gen toilet_private = m1sbq4_infr
gen toilet_usable = m1sbq5_infr
gen toilet_handwashing = m1sbq7_infr
gen toilet_soap = m1sbq8_infr
*if toilet exist, separate for boys/girls, clean, private, useable,  handwashing available
gen functioning_toilet = 1 if toilet_exists==1 & toilet_usable==1 & toilet_separate==1  & toilet_private==1  & toilet_handwashing==1
replace functioning_toilet = 0 if toilet_exists==0 | toilet_usable==0 | toilet_separate==0  | toilet_private==0  | toilet_handwashing==0

*Visbility
gen visibility = 1 if m4scq10_inpt==1 & m4scq8_inpt==1
replace visibility = 0 if m4scq10_inpt==0 & m4scq8_inpt==1

*Electricity
gen class_electricity = (m1sbq11_infr==1) if !missing(m1sbq11_infr)

*Accessibility for people with disabilities
frame put *, into(main_school_infr)
frame change main_school_infr
ds hashed_school_code, not
collapse (firstnm) `r(varlist)', by(hashed_school_code)
gen disab_road_access = 1 if m1s0q2_infr==1
replace disab_road_access = 0 if m1s0q2_infr!=1 & !missing(m1s0q2_infr)

*Error: check
gen disab_school_ramp = 1 if m1s0q3_infr == 0
replace disab_school_ramp = 1 if m1s0q4_infr==1 & m1s0q3_infr==1
replace disab_school_ramp = 0 if m1s0q4_infr==0 & m1s0q3_infr==1

gen disab_school_entr = 1 if m1s0q5_infr==1
replace disab_class_entr = 0 if m1s0q5_infr!=1 & !missing(m1s0q5_infr)

*Error: Wrong code here- correction made but check
gen disab_class_ramp =1 if m4scq1_infr==0
replace disab_class_ramp = 1 if m4scq2_infr==1 & m4scq1_infr==1
replace disab_class_ramp = 0 if m4scq2_infr==0 & m4scq1_infr==1

gen disab_class_entr = 1 if m4scq3_infr==1
replace disab_class_entr = 0 if m4scq3_infr!=1 & !missing(m4scq3_infr)
egen disab_screening = rowmean(m1sbq17_infr__1 m1sbq17_infr__2 m1sbq17_infr__3)
gen coed_toilet = 0 if m1sbq1_infr==7
replace coed_toilet = m1sbq6_infr if m1sbq1_infr!=7 & !missing(m1sbq1_infr)
gen disability_accessibility = (disab_road_access+disab_school_ramp+disab_school_entr+disab_class_ramp+disab_class_entr+coed_toilet+disab_screening)/7
                          
*Wrong code here- correction made but check
gen internet = 1 if m1sbq15_inpt==2
replace internet = .5 if m1sbq15_inpt==1
replace internet = 0 if m1sbq15_inpt==0 | missing(m1sbq15_inpt)

frame put *, into(school_infr_final)
frame change school_infr_final
gen infrastructure = drinking_water+ functioning_toilet+ internet + class_electricity+ disability_accessibility

*Create variables lists to retain
local infr_list m1sbq9_infr m1sbq1_infr m1sbq2_infr m1sbq4_infr m1sbq5_infr m1sbq7_infr m1sbq8_infr m4scq10_inpt m4scq8_inpt m4scq10_inpt m4scq8_inpt m1sbq11_infr m1sbq11_infr m1s0q2_infr m1s0q3_infr m1s0q4_infr m1s0q5_infr m4scq1_infr m4scq2_infr m4scq2_infr m4scq3_infr m1sbq17_infr__1 m1sbq17_infr__2 m1sbq17_infr__3 m1sbq1_infr m1sbq6_infr m1sbq1_infr m1sbq15_inpt
local infr_out drinking_water toilet_exists toilet_separate toilet_private toilet_usable toilet_handwashing toilet_soap functioning_toilet visibility class_electricity disab_road_access disab_school_ramp disab_school_entr disab_class_ramp disab_class_entr disab_screening coed_toilet disability_accessibility internet

keep `preamble_info_school' `infr_list' `infr_out' 
export excel using "final_indicator_INFR", sheet("INFR") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean drinking_water functioning_toilet internet class_electricity disability_accessibility infrastructure

*********************************************
**********School Operational Management *********
*********************************************

*Princials/head teachers are given two vignettes:
*One on solving the problem of a hypothetical leaky roof 
*One on solving a problem of inadequate numbers of textbooks.  
*Each vignette is worth 2 points.  
*
*The indicator will measure two things: presence of functions and quality of functions. In each vignette: 
*0.5 points are awarded for someone specific having the responsibility to fix 
*0.5 point is awarded if the school can fully fund the repair, 0.25 points is awarded if the school must get partial help from the community, and 0 points are awarded if the full cost must be born by the community 
*1 point is awarded if the problem is fully resolved in a timely manner, with partial credit given if problem can only be partly resolved

frame copy school school_opmn
frame change school_opmn
ds hashed_school_code, not
collapse (firstnm) `r(varlist)', by(hashed_school_code)
gen vignette_1_resp = cond(m7sbq1_opmn==0 & (m7sbq4_opmn==4 | m7sbq4_opmn==98),0,0.5,.)
replace vignette_1_resp=. if missing(m7sbq1_opmn) & missing(m7sbq1_opmn)
replace vignette_1_resp = 0.5 if !m7sbq1_opmn==0 & (m7sbq4_opmn==4 | m7sbq4_opmn==98)
gen vignette_1_finance= 0.5 if m7sbq2_opmn==1
replace vignette_1_finance = 0.25 if (m7sbq2_opmn==2 | m7sbq2_opmn==97)
replace vignette_1_finance = 0 if m7sbq2_opmn==3
replace vignette_1_finance = 0.5 if m7sbq1_opmn==0 & !(m7sbq4_opmn==4 | m7sbq4_opmn==98)

gen vignette_1_address = 0 if m7sbq3_opmn==1 & m7sbq1_opmn==1
replace vignette_1_address = 0.5 if (m7sbq3_opmn==2 | m7sbq3_opmn==97) & m7sbq1_opmn==1
replace vignette_1_address = 1 if m7sbq3_opmn==3 & m7sbq1_opmn==1
replace vignette_1_address = 0 if m7sbq5_opmn==1 & m7sbq1_opmn!=1 & !missing(m7sbq1_opmn)
replace vignette_1_address = 0.5 if m7sbq5_opmn==2 & m7sbq1_opmn!=1 & !missing(m7sbq1_opmn)
replace vignette_1_address = 1 if m7sbq5_opmn==3 & m7sbq1_opmn!=1 & !missing(m7sbq1_opmn)

*Give total score for this vignette
gen vignette_1 = vignette_1_resp + vignette_1_finance + vignette_1_address
*  // no one responsible that is known
gen vignette_2_resp = 0 if m7scq1_opmn==98
replace vignette_2_resp = 0.5 if m7scq1_opmn!=98 &!missing(m7scq1_opmn)
* //parents are forced to buy textbooks 
gen vignette_2_finance = 0 if m7scq1_opmn==1
replace vignette_2_finance = 0.5 if m7scq1_opmn!=1 & !missing(m7scq1_opmn)
*Give partial credit based on how quickly it will be solved <1 month, 1-3, 3-6, 6-12, >1 yr
gen vignette_2_address = 1 if m7scq2_opmn==1
replace vignette_2_address = .75 if m7scq2_opmn==2
replace vignette_2_address = .5 if m7scq2_opmn==3
replace vignette_2_address = .25 if m7scq2_opmn==4
replace vignette_2_address = 0 if m7scq2_opmn==5 | m7scq2_opmn==98
*Sum all components for overall score
gen vignette_2= vignette_2_resp + vignette_2_finance + vignette_2_address
gen operational_management=1+vignette_1+vignette_2

frame put *, into(school_operational_management)
frame change school_operational_management

*Create local variable list to export
local opmn_input m7sbq1_opmn m7sbq4_opmn m7sbq2_opmn m7sbq3_opmn m7scq1_opmn m7scq2_opmn
local opmn_outpt vignette_1_resp vignette_1_finance vignette_1_address vignette_1 vignette_2_resp vignette_2_finance vignette_2_address vignette_2 operational_management

keep `preamble_info_school' `opmn_input' `opmn_outpt'
export excel using "final_indicator_OPMN", sheet("OPMN") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean operational_management

*********************************************
**********School Instructional Leadership *********
*********************************************

*School survey. Total score starts at 1 and points added are the sum of whether a teacher has: 
*  - Had a classroom observation in past year 
* - Had a discussion based on that observation that lasted longer than 10 min 
* - Received actionable feedback from that observation 
* - Teacher had a lesson plan and discussed it with another person

frame copy teacher_questionnaire school_instruc
frame change school_instruc

gen classroom_observed = 1 if m3sdq15_ildr ==1
replace classroom_observed = 0 if m3sdq15_ildr!=1 & !missing(m3sdq15_ildr)
*Set recent to mean under 12 months
gen classroom_observed_recent = 1 if classroom_observed==1 & m3sdq16_ildr<=12
replace classroom_observed_recent = 0 if !(classroom_observed==1 & m3sdq16_ildr<=12)
replace classroom_observed_recent=. if missing(classroom_observed) & missing(classroom_observed)
gen discussion_30_min = 1 if m3sdq20_ildr==1
replace discussion_30_min = 0 if m3sdq20_ildr!=1 & !missing(m3sdq20_ildr)
*Make sure there was discussion and lasted more than 30 min
gen discussed_observation = 1 if classroom_observed==1 & m3sdq19_ildr==1 & m3sdq20_ildr==3
replace discussed_observation = 0 if !(classroom_observed==1 & m3sdq19_ildr==1 & m3sdq20_ildr==3)
gen feedback_observation = 1 if (m3sdq21_ildr==1 & (m3sdq22_ildr__1==1 | m3sdq22_ildr__2==1 | m3sdq22_ildr__3==1 | m3sdq22_ildr__4==1 | m3sdq22_ildr__5==1))
replace feedback_observation = 0 if !(m3sdq21_ildr==1 & (m3sdq22_ildr__1==1 | m3sdq22_ildr__2==1 | m3sdq22_ildr__3==1 | m3sdq22_ildr__4==1 | m3sdq22_ildr__5==1))
replace feedback_observation=. if missing(m3sdq21_ildr) & missing(m3sdq22_ildr__1)

gen lesson_plan = 1 if m3sdq23_ildr==1
replace lesson_plan = 0 if m3sdq23_ildr!=1 & !missing(m3sdq23_ildr)
gen lesson_plan_w_feedback = 1 if m3sdq23_ildr==1 & m3sdq24_ildr==1
replace lesson_plan_w_feedback = 0 if !(m3sdq23_ildr==1 & m3sdq24_ildr==1)
replace lesson_plan_w_feedback =. if missing(m3sdq23_ildr) & missing(m3sdq24_ildr)

replace feedback_observation = feedback_observation if m3sdq15_ildr==1 & m3sdq19_ildr==1
replace feedback_observation = 0 if !(m3sdq15_ildr==1 & m3sdq19_ildr==1)
replace feedback_observation=. if missing(m3sdq15_ildr) & missing(m3sdq19_ildr)

gen instructional_leadership = 1+0.5*classroom_observed + 0.5*classroom_observed_recent + discussed_observation + feedback_observation + lesson_plan_w_feedback
replace instructional_leadership= (1.5 + lesson_plan_w_feedback) if classroom_observed!=1 & !missing(classroom_observed)

frame put *, into (final_school_instruc_leader)
frame change final_school_instruc_leader
ds, has(type numeric)
local numvars_ildr "`r(varlist)'"
ds, has(type string)
local stringvars_ildr "`r(varlist)'"
local stringvars_ildr : list stringvars_ildr- not1

collapse (mean) `numvars_ildr' (firstnm) `stringvars_ildr', by(interview__id)
ds hashed_school_code, not
collapse (firstnm) `r(varlist)', by(hashed_school_code)
export excel using "final_indicator_ILDR", sheet("ILDR") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean instructional_leadership

*********************************************
***** School Principal School Knowledge ***********
*********************************************
* The aim of this indicator is to measure the extent to which principals have the knowledge about their own schools that is necessary for them to be effective managers. A score from 1 to 5 capturing the extent to which the principal is familiar with certain key aspects of the day-to-day workings of the school (in schools that have principals). Principal receives points in the following way: 
*   - 5 points. Principal gets all 90-100% of questions within accuracy bounds (defined below). 
* - 4 points. Principal gets 80-90% of question within accuracy bounds. 
* - 3 points. Principal gets 70-80% of question within accuracy bounds. 
* - 2 points. Principal gets 60-70% of question within accuracy bounds. 
* - 1 points. Principal gets under 60% of question within accuracy bounds. 
* 
* Accuracy bounds for each question. 
* Within 1 teacher/student for each of the following: 
*   - Out of these XX teachers, how many do you think would be able to correctly add triple digit numbers (i.e. 343+215+127)? 
*   - Out of these XX teachers, how many do you think would be able to correctly to multiply double digit numbers (i.e. 37 x 13)? 
*   - Out of these XX teachers, how many do you think would be able to complete sentences with the correct world (i.e. The accident _____ (see, saw, had seen, was seen) by three people)? 
*   - Any of these XX teachers have less than 3 years of experience? 
*   - Out of these XX teachers, which ones have less than 3 years of experience as a teacher? 
* Within 3 teacher/student for each of the following: 
*   - In the selected 4th grade classroom, how many of the pupils have the relevant textbooks? 
*   Must identify whether or not blackboard was working in a selected 4th grade classroom.

frame copy master_teacher_assessment pknw_actual_cont_temp
frame change pknw_actual_cont_temp
keep hashed_school_code m5_teach_count m5_teach_count_math m5s2q1c_number m5s2q1e_number m5s1q1f_grammer
replace hashed_school_code = ".a" if missing(hashed_school_code)
frame put *,into(pknw_actual_cont)

frame copy teacher_questionnaire pknw_actual_exper_temp
frame change pknw_actual_exper_temp
keep hashed_school_code m3sb_tnumber m3saq5 m3saq6
gen experience=2019-m3saq5
keep if experience<3
egen teacher_count_experience_less3 = count(hashed_school_code), by(hashed_school_code)
collapse (first) teacher_count_experience_less3, by(hashed_school_code)
replace hashed_school_code = ".a" if missing(hashed_school_code)
frame put *,into(pknw_actual_exper)

frame copy master_school_inputs pknw_actual_school_inpts
frame change pknw_actual_school_inpts
keep hashed_school_code blackboard_functional m4scq5_inpt m4scq4_inpt
replace hashed_school_code = ".a" if missing(hashed_school_code)
	
frlink 1:1 hashed_school_code, frame(pknw_actual_cont)
frget * , from(pknw_actual_cont)
frlink 1:1 hashed_school_code, frame(pknw_actual_exper)
frget * , from(pknw_actual_exper)

replace teacher_count_experience_less3 = 0 if missing(teacher_count_experience_less3)
gen m5s2q1c_number_new = m5s2q1c_number*m5_teach_count
gen m5s2q1e_number_new=m5s2q1e_number*m5_teach_count,
gen m5s1q1f_grammer_new=m5s1q1f_grammer*m5_teach_count
frame put *, into(pknw_actual_combined)
frame change pknw_actual_combined

frame copy school school_data_pknw_f
frame change school_data_pknw_f
collapse (firstnm) m7sfq5_pknw (firstnm) m7sfq6_pknw (firstnm) m7sfq7_pknw (firstnm) m7sfq9_pknw_filter (firstnm) m7sfq10_pknw (firstnm) m7sfq11_pknw (firstnm) m7_teach_count_pknw ipw (first) province, by(hashed_school_code)
replace hashed_school_code =".a" if missing(hashed_school_code)
frlink 1:1 hashed_school_code, frame(pknw_actual_combined)
frget *, from(pknw_actual_combined)

gen add_triple_digit_pknw = 1 if ((1-abs(m7sfq5_pknw-m5s2q1c_number_new)/m7_teach_count_pknw>= 0.8) | (m7sfq5_pknw-m5s2q1c_number_new <= 1)) & !missing(m7sfq5_pknw) & !missing(m5s2q1c_number_new) & !missing(m7_teach_count_pknw)
replace add_triple_digit_pknw = 0 if !((1-abs(m7sfq5_pknw-m5s2q1c_number_new)/m7_teach_count_pknw>= 0.8) | (m7sfq5_pknw-m5s2q1c_number_new <= 1)) & !missing(m7sfq5_pknw) & !missing(m5s2q1c_number_new) & !missing(m7_teach_count_pknw)
gen multiply_double_digit_pknw = 1 if ((1-abs(m7sfq6_pknw-m5s2q1e_number_new)/m7_teach_count_pknw>= 0.8) | (m7sfq6_pknw-m5s2q1e_number_new <= 1)) & !missing(m7sfq6_pknw) & !missing(m5s2q1e_number_new) & !missing(m7_teach_count_pknw)
replace multiply_double_digit_pknw = 0 if !((1-abs(m7sfq6_pknw-m5s2q1e_number_new)/m7_teach_count_pknw>= 0.8) | (m7sfq6_pknw-m5s2q1e_number_new <= 1)) & !missing(m7sfq6_pknw) & !missing(m5s2q1e_number_new) & !missing(m7_teach_count_pknw)
gen complete_sentence_pknw = 1 if ((1-abs(m7sfq7_pknw-m5s1q1f_grammer_new)/m7_teach_count_pknw>= 0.8) | (m7sfq7_pknw-m5s1q1f_grammer_new <= 1)) & !missing(m7sfq7_pknw) & !missing(m5s1q1f_grammer_new) & !missing(m7_teach_count_pknw)
replace complete_sentence_pknw = 0 if !((1-abs(m7sfq7_pknw-m5s1q1f_grammer_new)/m7_teach_count_pknw>= 0.8) | (m7sfq7_pknw-m5s1q1f_grammer_new <= 1)) & !missing(m7sfq7_pknw) & !missing(m5s1q1f_grammer_new) & !missing(m7_teach_count_pknw)
gen experience_pknw = 1 if ((1-abs(m7sfq9_pknw_filter-teacher_count_experience_less3)/m7_teach_count_pknw>= 0.8) | (m7sfq9_pknw_filter-teacher_count_experience_less3 <= 1)) & !missing(m7sfq9_pknw_filter) & !missing(teacher_count_experience_less3) & !missing(m7_teach_count_pknw)
replace experience_pknw = 0 if !((1-abs(m7sfq9_pknw_filter-teacher_count_experience_less3)/m7_teach_count_pknw>= 0.8) | (m7sfq9_pknw_filter-teacher_count_experience_less3 <= 1)) & !missing(m7sfq9_pknw_filter) & !missing(teacher_count_experience_less3) & !missing(m7_teach_count_pknw)
gen textbooks_pknw = 1 if ((1-abs(m7sfq10_pknw-m4scq5_inpt)/m4scq4_inpt>= 0.8) | (m7sfq10_pknw-m4scq5_inpt <= 3)) & !missing(m7sfq10_pknw) & !missing(m4scq5_inpt) & !missing(m4scq4_inpt)
replace textbooks_pknw = 0 if !((1-abs(m7sfq10_pknw-m4scq5_inpt)/m4scq4_inpt>= 0.8) | (m7sfq10_pknw-m4scq5_inpt <= 3)) & !missing(m7sfq10_pknw) & !missing(m4scq5_inpt) & !missing(m4scq4_inpt)
gen blackboard_pknw = 1 if m7sfq11_pknw==blackboard_functional & !missing(m7sfq11_pknw) & !missing(blackboard_functional)
replace blackboard_pknw = 0 if m7sfq11_pknw!=blackboard_functional & !missing(m7sfq11_pknw) & !missing(blackboard_functional)
egen principal_knowledge_avg = rowmean(add_triple_digit_pknw multiply_double_digit_pknw complete_sentence_pknw experience_pknw textbooks_pknw blackboard_pknw)

gen principal_knowledge_score = 5 if principal_knowledge_avg>0.9 & !missing(principal_knowledge_avg)
replace principal_knowledge_score = 4 if principal_knowledge_avg>0.8 & principal_knowledge_avg<=0.9
replace principal_knowledge_score = 3 if principal_knowledge_avg>0.7 & principal_knowledge_avg<=0.8
replace principal_knowledge_score = 2 if principal_knowledge_avg>0.6 & principal_knowledge_avg<=0.7
replace principal_knowledge_score = 1 if principal_knowledge_avg<=0.6 & !missing(principal_knowledge_avg)

frame put *, into(final_principal_know)
frame change final_principal_know
export excel using "final_indicator_PKNW", sheet("PKNW") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean principal_knowledge_score

********************************************
***** School Principal Management Skills ***********
*********************************************


* Score of 1-5 based on sum of following: 
* goal setting:
*   - 1 Point. School Goals Exists 
* - 1 Point. School goals are clear to school director, teachers, students, parents, and other members of community (partial credit available) 
* - 1 Point. Specific goals related to improving student achievement ( improving test scores, improving pass rates, reducing drop out, reducing absenteeism, improving pedagogy, more resources for infrastructure, more resources for inputs) 
* - 1 Point. School has defined system to measure goals (partial credit available)
* problem solving:
* - 1.33 point on proactive (partial credit for just notifying a superior) on absence issue
* - 0.33 for each group principal would contact to gather info on absence
* - 1.33 point for working with local authorities, 0.5 points for organizing remedial classes, 0.25 for just informing parents
*Create variables for whether school goals exists, are clear, are relevant to learning, and are measured in an appropriate way.

frame copy school school_data_PMAN
frame change school_data_PMAN
*For goals
gen school_goals_exist = 1 if m7sdq1_pman==1
replace school_goals_exist= 0 if m7sdq1_pman!=1 & !missing(m7sdq1_pman)
egen school_goals_clear = rowmean(m7sdq3_pman__1 m7sdq3_pman__2 m7sdq3_pman__3 m7sdq3_pman__4 m7sdq3_pman__5) if m7sdq1_pman==1
replace school_goals_clear = 0 if m7sdq1_pman!=1 & !missing(m7sdq1_pman)
egen school_goals_relevant_total = rowmean(m7sdq4_pman__1 m7sdq4_pman__2 m7sdq4_pman__3 m7sdq4_pman__4 m7sdq4_pman__5 m7sdq4_pman__6 m7sdq4_pman__7 m7sdq4_pman__8 m7sdq4_pman__97)
gen school_goals_relevant = 1 if school_goals_relevant_total>0 & !missing(school_goals_relevant_total) & m7sdq1_pman==1
replace school_goals_relevant = 0 if school_goals_relevant_total==0 & m7sdq1_pman==1
replace school_goals_relevant = 0 if m7sdq1_pman!=1 &!missing(m7sdq1_pman)
gen school_goals_measured = 0 if m7sdq5_pman ==1 & m7sdq1_pman==1
replace school_goals_measured =0.5 if (m7sdq5_pman==2 | m7sdq5_pman==97) & m7sdq1_pman==1
replace school_goals_measured =1 if m7sdq5_pman ==3 & m7sdq1_pman==1
replace school_goals_measured =0 if m7sdq1_pman!=1 & !missing(m7sdq1_pman)

gen goal_setting =1+school_goals_exist+school_goals_clear+school_goals_relevant+school_goals_measured

*Now for problem solving
gen problem_solving_proactive = 1 if m7seq1_pman ==4
replace problem_solving_proactive = 0.5 if (m7seq1_pman==2 | m7seq1_pman==3)
replace problem_solving_proactive = 0 if (m7seq1_pman==1 | m7seq1_pman==98)
replace problem_solving_proactive = 0 if ((!inlist(m7seq1_pman,1,2,3,4,98)) | missing(m7seq1_pman))

gen problem_solving_info_collect = (m7seq2_pman__1+m7seq2_pman__2 + m7seq2_pman__3 + m7seq2_pman__4)/4
*Error: Corrected but check
gen problem_solving_stomach = 1 if m7seq3_pman==4 
replace problem_solving_stomach = 0.5 if m7seq3_pman==3
replace problem_solving_stomach = 0.25 if (m7seq3_pman==1 | m7seq3_pman==2 | m7seq3_pman==98)
replace problem_solving_stomach = 0 if ((!inlist(m7seq3_pman,1,2,3,4,98)) | missing(m7seq3_pman))

gen problem_solving=1+(4/3)*problem_solving_proactive+(4/3)*problem_solving_info_collect+(4/3)*problem_solving_stomach
gen principal_management = (goal_setting+problem_solving)/2

local pman_out school_goals_exist school_goals_exist school_goals_clear school_goals_relevant_total school_goals_relevant school_goals_measured problem_solving_proactive problem_solving_info_collect problem_solving_stomach goal_setting problem_solving principal_management
local pman_inpt m7sdq1_pman m7sdq3_pman__1 m7sdq3_pman__2 m7sdq3_pman__3 m7sdq3_pman__4 m7sdq3_pman__5 m7sdq4_pman__1 m7sdq4_pman__2 m7sdq4_pman__3 m7sdq4_pman__4 m7sdq4_pman__5 m7sdq4_pman__6 m7sdq4_pman__7 m7sdq4_pman__8 m7sdq4_pman__97 m7sdq5_pman m7seq1_pman m7seq2_pman__1 m7seq2_pman__2 m7seq2_pman__3 m7seq2_pman__4 m7seq3_pman
keep `preamble_info_school' `pman_inpt' `pman_out'

frame put *, into(final_principal_management)
frame change final_principal_management

ds hashed_school_code, not
collapse (firstnm) `r(varlist)', by(hashed_school_code)

export excel using "final_indicator_PMAN", sheet("PMAN") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean principal_management

*********************************************
***** Teacher Teaching Attraction ***********
*********************************************

* In the school survey, a number of De Facto questions on teacher attraction are asked. 0.8 points is awarded for each of the following: 
*   - 0.8 Points. Teacher satisfied with job 
* - 0.8 Points. Teacher satisfied with status in community 
* - 0.8 Points. Would better teachers be promoted faster? 
*   - 0.8 Points. Do teachers receive bonuses? 
*   - 0.8 Points. One minus the fraction of months in past year with a salary delay.


*create function to clean teacher attitudes questions.  Need to reverse the order for scoring for some questions.  
*Should have thought about this, when programming in Survey Solutions and scale 1-5.

frame copy teacher_questionnaire teacher_questionnaire_TATT
frame change teacher_questionnaire_TATT

gen teacher_satisfied_job = . if m3seq1_tatt==99
replace teacher_satisfied_job= 5 if m3seq1_tatt==1
replace teacher_satisfied_job= 3.67 if m3seq1_tatt==2
replace teacher_satisfied_job= 2.33 if m3seq1_tatt==3
replace teacher_satisfied_job= 1 if m3seq1_tatt==4
replace teacher_satisfied_job= teacher_satisfied_job/5

gen teacher_satisfied_status = . if m3seq2_tatt==99
replace teacher_satisfied_status= 5 if m3seq2_tatt==1
replace teacher_satisfied_status= 3.67 if m3seq2_tatt==2
replace teacher_satisfied_status= 2.33 if m3seq2_tatt==3
replace teacher_satisfied_status= 1 if m3seq2_tatt==4
replace teacher_satisfied_status= teacher_satisfied_status/5

gen better_teachers_promoted = 1 if m3seq3_tatt==1
replace better_teachers_promoted = 0 if m3seq3_tatt!=1 & !missing(m3seq3_tatt)

gen teacher_bonus = 1 if m3seq4_tatt==1
replace teacher_bonus = 0 if m3seq4_tatt!=1 & !missing(m3seq4_tatt)

gen teacher_bonus_attend =1 if m3seq5_tatt__1==1 & m3seq4_tatt==1 
replace teacher_bonus_attend =0 if m3seq5_tatt__1!=1 & !missing(m3seq5_tatt__1) & m3seq4_tatt==1 
replace teacher_bonus_attend =0 if m3seq4_tatt!=1 & !missing(m3seq4_tatt)

gen teacher_bonus_student_perform =1 if m3seq5_tatt__2==1 & m3seq4_tatt==1 
replace teacher_bonus_student_perform =0 if m3seq5_tatt__2!=1 & !missing(m3seq5_tatt__2) & m3seq4_tatt==1 
replace teacher_bonus_student_perform =0 if m3seq4_tatt!=1 & !missing(m3seq4_tatt)

gen teacher_bonus_extra_duty =1 if m3seq5_tatt__3==1 & m3seq4_tatt==1 
replace teacher_bonus_extra_duty =0 if m3seq5_tatt__3!=1 & !missing(m3seq5_tatt__3) & m3seq4_tatt==1 
replace teacher_bonus_extra_duty =0 if m3seq4_tatt!=1 & !missing(m3seq4_tatt)

gen teacher_bonus_hard_staff =1 if m3seq5_tatt__4==1 & m3seq4_tatt==1 
replace teacher_bonus_hard_staff =0 if m3seq5_tatt__4!=1 & !missing(m3seq5_tatt__4) & m3seq4_tatt==1 
replace teacher_bonus_hard_staff =0 if m3seq4_tatt!=1 & !missing(m3seq4_tatt)

gen teacher_bonus_subj_shortages =1 if m3seq5_tatt__5==1 & m3seq4_tatt==1 
replace teacher_bonus_subj_shortages =0 if m3seq5_tatt__5!=1 & !missing(m3seq5_tatt__5) & m3seq4_tatt==1 
replace teacher_bonus_subj_shortages =0 if m3seq4_tatt!=1 & !missing(m3seq4_tatt)

gen teacher_bonus_add_qualif =1 if m3seq5_tatt__6==1 & m3seq4_tatt==1 
replace teacher_bonus_add_qualif =0 if m3seq5_tatt__6!=1 & !missing(m3seq5_tatt__6) & m3seq4_tatt==1 
replace teacher_bonus_add_qualif =0 if m3seq4_tatt!=1 & !missing(m3seq4_tatt)

gen teacher_bonus_school_perform =1 if m3seq5_tatt__7==1 & m3seq4_tatt==1 
replace teacher_bonus_school_perform =0 if m3seq5_tatt__7!=1 & !missing(m3seq5_tatt__7) & m3seq4_tatt==1 
replace teacher_bonus_school_perform =0 if m3seq4_tatt!=1 & !missing(m3seq4_tatt)

*Error- m3seq5_other_tatt absent in teacher_questionnaire
*gen teacher_bonus_other = m3seq5_other_tatt if m3seq5_tatt__97==1 & m3seq4_tatt==1 
*replace teacher_bonus_other =. if m3seq5_tatt__97!=1 & !missing(m3seq5_tatt__97) & m3seq4_tatt==1 
*replace teacher_bonus_other =. if m3seq4_tatt!=1 & !missing(m3seq4_tatt)

gen salary_delays = m3seq7_tatt if m3seq6_tatt==1
replace salary_delays = 0 if m3seq6_tatt!=1 & !missing(m3seq6_tatt)
replace salary_delays = 12 if salary_delays>12 & !missing(salary_delays)
gen teacher_attraction=(1+(0.8*teacher_satisfied_job)+(.8*teacher_satisfied_status)+(.8*better_teachers_promoted)+(.8*teacher_bonus)+(.8*(1-salary_delays/12)))

frame put * , into(final_teacher_TATT)
frame change final_teacher_TATT

ds, has(type numeric)
local numvars_tatt "`r(varlist)'"
ds, has(type string)
local stringvars_tatt "`r(varlist)'"
local stringvars_tatt : list stringvars_tatt- not1

collapse (mean) `numvars_tatt' (firstnm) `stringvars_tatt', by(interview__id)

ds hashed_school_code, not
collapse (firstnm) `r(varlist)', by(hashed_school_code)

export excel using "final_indicator_TATT", sheet("TATT") cell(A1) firstrow(variables) replace

svyset [pw=ipw]
svy: mean teacher_attraction

*********************************************
***** Teacher Teaching Selection and Deployment ***********
*********************************************

* School Survey. The De Facto portion of the Teacher Selection and Deployment Indicator considers two issues: how teachers are selected into the profession and how teachers are assigned to positions (transferred) once in the profession. Research shows that degrees and years of experience explanin little variation in teacher quality, so more points are assigned for systems that also base hiring on content knowledge or pedagogical skill. 2 points are available for the way teachers are selected and 2 points are available for deployment. 
* 
* Selection 
* - 0 Points. None of the below 
* - 1 point. Teachers selected based on completion of coursework, educational qualifications, graduating from tertiary program (including specialized programs), selected based on experience 
* - 2 points. Teacher recruited based on passing written content knowledge test, passed interview stage assessment, passed an assessment conducted by supervisor based on practical experience, conduct during mockup class. 
* 
* Deployment 
* - 0 Points. None of the below 
* - 1 point. Teachers deployed based on years of experience or job title hierarchy 
* - 2 points. Teacher deployed based on performance assessed by school authority, colleagues, or external evaluator, results of interview.

frame copy teacher_questionnaire teacher_questionnaire_TSDP
frame change teacher_questionnaire_TSDP

gen teacher_selection = 2 if (m3sdq1_tsdp__5==1 | m3sdq1_tsdp__6==1 | m3sdq1_tsdp__8==1 | m3sdq1_tsdp__9==1)
replace teacher_selection = 1 if (m3sdq1_tsdp__1==1 | m3sdq1_tsdp__2==1 | m3sdq1_tsdp__3==1 | m3sdq1_tsdp__4==1 | m3sdq1_tsdp__7==1)
replace teacher_selection = 0 if (m3sdq1_tsdp__1==0 & m3sdq1_tsdp__2==0 & m3sdq1_tsdp__3==0 & m3sdq1_tsdp__4==0 & m3sdq1_tsdp__5==0 & m3sdq1_tsdp__6==0 & m3sdq1_tsdp__7==0 & m3sdq1_tsdp__8==0 & m3sdq1_tsdp__9==0)

gen teacher_deployment = 2 if (m3seq8_tsdp__3==1 | m3seq8_tsdp__4==1 | m3seq8_tsdp__5==1)
gen teacher_deployment = 1 if (m3seq8_tsdp__1==1 | m3seq8_tsdp__2==1 | m3seq8_tsdp__97==1)
gen teacher_deployment = 0 if ((m3seq8_tsdp__1==0 & m3seq8_tsdp__2==0 & m3seq8_tsdp__3==0 & m3seq8_tsdp__4==0 & m3seq8_tsdp__5==0) | ( m3seq8_tsdp__99==1))

gen teacher_selection_deployment=1+teacher_selection+teacher_deployment

frame put * , into(teacher_questionnaire_TSDP_final)
frame change teacher_questionnaire_TSDP_final

ds, has(type numeric)
local numvars_sd "`r(varlist)'"
ds, has(type string)
local stringvars_sd "`r(varlist)'"

collapse (mean) numvars_sd (first) stringvars_sd, by(interview__id)
ds hashed_school_code, not
collapse (firstnm) `r(varlist)', by(hashed_school_code)

svyset [pw=ipw]
svy: mean teacher_selection_deployment

*********************************************
***** Teacher Teaching Support ***********
*********************************************


* School survey. Our teaching support indicator asks teachers about participation and the experience with several types of formal/informal training: 
*   
*   Pre-Service (Induction) Training: 
*   - 0.5 Points. Had a pre-service training 
* - 0.5 Points. Teacher reported receiving usable skills from training 
* 
* Teacher practicum (teach a class with supervision) 
* - 0.5 Points. Teacher participated in a practicum 
* - 0.5 Points. Practicum lasted more than 3 months and teacher spent more than one hour per day teaching to students. 
* 
* In-Service Training: 
*   - 0.5 Points. Had an in-service training 
* - 0.25 Points. In-service training lasted more than 2 total days 
* - 0.125 Points. More than 25% of the in-service training was done in the classroom. 
* - 0.125 Points. More than 50% of the in-service training was done in the classroom. 
* 
* Opportunities for teachers to come together to share ways of improving teaching: 
*   - 1 Point if such opportunities exist.

*Add in question on teach opportunities so share ways of teaching

frame copy teacher_questionnaire teacher_questionnaire_ILDR
frame change teacher_questionnaire_ILDR
keep interview__id m3sdq14_ildr
gen opportunities_teachers_share = 1 if m3sdq14_ildr==1
replace opportunities_teachers_share = 0 if m3sdq14_ildr!=1 & !missing(m3sdq14_ildr)
duplicates drop

frame copy teacher_questionnaire teacher_questionnaire_TSUP
frame change teacher_questionnaire_TSUP

gen pre_training_exists = 1 if m3sdq3_tsup==1
replace pre_training_exists = 0 if m3sdq3_tsup!=1 & !missing(m3sdq3_tsup)
replace pre_training_exists = pre_training_exists/2

gen pre_training_useful =1 if m3sdq4_tsup==1 & m3sdq3_tsup==1 
replace pre_training_useful =0 if m3sdq4_tsup!=1 & !missing(m3sdq4_tsup) & m3sdq3_tsup==1 
replace pre_training_useful =0 if m3sdq3_tsup!=1 & !missing(m3sdq3_tsup)
replace pre_training_useful = pre_training_useful/2

gen pre_training_practicum =1 if m3sdq6_tsup==1 & m3sdq3_tsup==1 
replace pre_training_practicum =0 if m3sdq6_tsup!=1 & !missing(m3sdq6_tsup) & m3sdq3_tsup==1 
replace pre_training_practicum =0 if m3sdq3_tsup!=1 & !missing(m3sdq3_tsup)
replace pre_training_practicum = pre_training_practicum/2

gen pre_training_practicum_lngth = 0.5 if (m3sdq6_tsup==1 & m3sdq7_tsup>=3 & m3sdq8_tsup>=1 & !missing(m3sdq7_tsup) & !missing(m3sdq8_tsup))
gen pre_training_practicum_lngth = 0 if (m3sdq6_tsup==1 & (m3sdq7_tsup<3 | m3sdq8_tsup<1)) & & !missing(m3sdq7_tsup) & !missing(m3sdq8_tsup)
gen pre_training_practicum_lngth = 0 if m3sdq6_tsup==2
gen pre_training_practicum_lngth = 0 if m3sdq3_tsup==0
replace pre_training_practicum_lngth = 0 if missing(pre_training_practicum_lngth)

gen in_service_exists = 1 if m3sdq9_tsup==1
replace in_service_exists = 0 if m3sdq9_tsup!=1 & !missing(m3sdq9_tsup)

gen in_servce_lngth = 1 if m3sdq9_tsup==1 & m3sdq10_tsup>2 & !missing(m3sdq10_tsup)
gen in_servce_lngth = 0 if m3sdq9_tsup==1 & m3sdq10_tsup<=2 & !missing(m3sdq10_tsup)
gen in_servce_lngth = 0 if m3sdq6_tsup==2
gen in_servce_lngth = 0 if m3sdq3_tsup==0
replace in_servce_lngth = 0 if missing(in_servce_lngth)

gen in_service_classroom = 1 if m3sdq9_tsup==1 & m3sdq13_tsup>=3 & !missing(m3sdq13_tsup)
gen in_service_classroom = 0.5 if (m3sdq9_tsup==1 & m3sdq13_tsup==2)
gen in_service_classroom = 0 if (m3sdq9_tsup==1 & m3sdq13_tsup==1)
gen in_service_classroom = 0 if m3sdq9_tsup==0
replace in_service_classroom = 0 if missing(in_service_classroom)

frlink m:1 interview__id m3sdq14_ildr frame(teacher_questionnaire_ILDR)
frget opportunities_teachers_share from(teacher_questionnaire_ILDR)

gen pre_service=pre_training_exists+pre_training_useful
gen practicum=pre_training_practicum+pre_training_practicum_lngth,
gen in_service=0.5*in_service_exists+0.25*in_servce_lngth+0.25*in_service_classroom
gen teacher_support=1+pre_service+practicum+in_service+opportunities_teachers_share
* mutate(teacher_support=if_else(teacher_support>5,5,teacher_support)) #need to fix

frame put * , into(teacher_questionnaire_TSUP_final)
frame change teacher_questionnaire_TSUP_final

ds, has(type numeric)
local numvars_ts "`r(varlist)'"
ds, has(type string)
local stringvars_ts "`r(varlist)'"

collapse (mean) numvars_ts (first) stringvars_ts, by(interview__id)
ds hashed_school_code, not
collapse (firstnm) `r(varlist)', by(hashed_school_code)

svyset [pw=ipw]
svy: mean teacher_support

*********************************************
***** Teacher Teaching Evaluation ***********
*********************************************

* School survey. This policy lever measures whether there is a teacher evaluation system in place, and if so, the types of decisions that are made based on the evaluation results. Score is the sum of the following: 
*   - 1 Point. Was teacher formally evaluated in past school year? 
*   - 1 Point total. 0.2 points for each of the following: Evaluation included evaluation of attendance, knowledge of subject matter, pedagogical skills in the classroom, students' academic achievement, students' socio-emotional development 
* - 1 Point. Consequences exist if teacher receives 2 or more negative evaluations 
* - 1 Point. Rewards exist if teacher receives 2 or more positive evaluations

frame copy teacher_questionnaire teacher_questionnaire_TEVL
frame change teacher_questionnaire_TEVL

*list of teacher evaluation questions
local tevl m3sbq7_tmna__1 m3sbq7_tmna__2 m3sbq7_tmna__3 m3sbq7_tmna__4 m3sbq7_tmna__5 m3sbq7_tmna__6 m3sbq7_tmna__97 m3sbq8_tmna__2 m3sbq8_tmna__3 m3sbq8_tmna__4 m3sbq8_tmna__5 m3sbq8_tmna__6 m3sbq8_tmna__7 m3sbq8_tmna__8 m3sbq8_tmna__97 m3sbq8_tmna__98 m3sbq9_tmna__1 m3sbq9_tmna__2 m3sbq9_tmna__3 m3sbq9_tmna__4 m3sbq9_tmna__7 m3sbq9_tmna__97 m3sbq9_tmna__98 m3bq10_tmna__1 m3bq10_tmna__2 m3bq10_tmna__3 m3bq10_tmna__4 m3bq10_tmna__7 m3bq10_tmna__97 m3bq10_tmna__98

local preamble_info_teacher interview__id questionnaire_roster__id teacher_number available teacher_position teacher_grd1 teacher_grd2 teacher_grd3 teacher_grd4 teacher_grd5 teacher_language teacher_math teacher_both_subj teacher_education teacher_year_began teacher_age

keep hashed_school_code `preamble_info_teacher' `tevl' m3sbq6_tmna m3sbq8_tmna__1

gen formally_evaluated = 1 if m3sbq6_tmna==1
replace formally_evaluated = 0 if m3sbq6_tmna!=1 & !missing(m3sbq6_tmna)

gen evaluation_content =(m3sbq8_tmna__1+m3sbq8_tmna__2+ m3sbq8_tmna__3 + m3sbq8_tmna__5 + m3sbq8_tmna__6)/5 if m3sbq6_tmna==1
replace teacher_bonus_subj_shortages =0 if m3sbq6_tmna!=1 & !missing(m3sbq6_tmna)

gen negative_consequences = 1 if (m3sbq9_tmna__1==1 | m3sbq9_tmna__2==1 | m3sbq9_tmna__3==1 | m3sbq9_tmna__4==1 | m3sbq9_tmna__97==1)
replace negative_consequences = . if (missing(m3sbq9_tmna__1) & missing(m3sbq9_tmna__2) & missing(m3sbq9_tmna__3) & missing(m3sbq9_tmna__4) & missing(m3sbq9_tmna__97))

gen positive_consequences = 1 if (m3bq10_tmna__1==1 | m3bq10_tmna__2==1 | m3bq10_tmna__3==1 | m3bq10_tmna__4==1 | m3bq10_tmna__97==1)
replace negative_consequences = . if missing(m3bq10_tmna__1) & missing(m3bq10_tmna__2) & missing(m3bq10_tmna__3) & missing(m3bq10_tmna__4) & missing(m3bq10_tmna__97)
gen teaching_evaluation=1+formally_evaluated+evaluation_content+negative_consequences+positive_consequences

frame put *, into(teacher_questionnaire_TEVL_final)
frame change teacher_questionnaire_TEVL_final

ds, has(type numeric)
local numvars_ts "`r(varlist)'"
ds, has(type string)
local stringvars_ts "`r(varlist)'"

collapse (mean) numvars_ts (first) stringvars_ts, by(interview__id)
ds hashed_school_code, not
collapse (firstnm) `r(varlist)', by(hashed_school_code)

svyset [pw=ipw]
svy: mean teaching_evaluation

*********************************************
***** Teacher  Monitoring and Accountability ***********
*********************************************

* School Survey. This policy lever measures the extent to which teacher presence is being monitored, whether attendance is rewarded, and whether there are consequences for chronic absence. Score is the sum of the following: 
*   - 1 Point. Teachers evaluated by some authority on basis of absence. 
* - 1 Point. Good attendance is rewarded. 
* - 1 Point. There are consequences for chronic absence (more than 30% absence). 
* - 1 Point. One minus the fraction of teachers that had to miss class because of any of the following: collect paycheck, school administrative procedure, errands or request of the school district office, other administrative tasks.

frame copy teacher_questionnaire_TATT teacher_questionnaire_TMNA2
frame change teacher_questionnaire_TMNA2
keep interview__id hashed_school_code questionnaire_roster__id teacher_number m3seq4_tatt m3seq5_tatt__1 m3sbq1_tatt__1 m3sbq1_tatt__2 m3sbq1_tatt__3 m3sbq1_tatt__97
save teacher_questionnaire_TMNA2

frame copy teacher_questionnaire_TATT teacher_questionnaire_TMNA
frame change teacher_questionnaire_TMNA
ds `tevl', not
keep `r(varlist)'

merge m:m hashed_school_code interview__id questionnaire_roster__id teacher_number using teacher_questionnaire_TMNA2

gen attendance_evaluated = 1 if m3sbq6_tmna==1 & m3sbq8_tmna__1==1
replace attendance_evaluated = 0 if m3sbq6_tmna==1 & m3sbq8_tmna__1!=1
replace attendance_evaluated = 0 if m3sbq6_tmna!=1

gen attendance_rewarded = 1 if m3seq4_tatt==1 & m3seq5_tatt__1==1
replace attendance_rewarded = 0 if m3seq4_tatt==1 & m3seq5_tatt__1!=1
replace attendance_rewarded = 0 if m3seq4_tatt!=1

gen attendence_sanctions = 1 if (m3sbq2_tmna__1==1 | m3sbq2_tmna__2==1 | m3sbq2_tmna__3==1 | m3sbq2_tmna__4==1 | m3sbq2_tmna__97==1)
replace negative_consequences = . if missing(m3sbq2_tmna__1) & missing(m3sbq2_tmna__2) & missing(m3sbq2_tmna__3) & missing(m3sbq2_tmna__4) & missing(m3sbq2_tmna__97)
replace negative_consequences = 0 if !(m3sbq2_tmna__1==1 | m3sbq2_tmna__2==1 | m3sbq2_tmna__3==1 | m3sbq2_tmna__4==1 | m3sbq2_tmna__97==1) & !(missing(m3sbq2_tmna__1) & missing(m3sbq2_tmna__2) & missing(m3sbq2_tmna__3) & missing(m3sbq2_tmna__4) & missing(m3sbq2_tmna__97))

gen miss_class_admin = 1 if (m3sbq1_tatt__1==1 | m3sbq1_tatt__2==1 | m3sbq1_tatt__3==1 | m3sbq1_tatt__97==1)
replace miss_class_admin=0 if (m3sbq1_tatt__1==0 & m3sbq1_tatt__2==0 & m3sbq1_tatt__3==0 & m3sbq1_tatt__97==0)
*Error: Variable m3sbq1_tatt__97 is missing in file teacher_questionnaire
*replace miss_class_admin= 0 if regexm(m3sbq1_tatt__97, "salud")

gen teacher_monitoring=1+attendance_evaluated + 1*attendance_rewarded + 1*attendence_sanctions + (1-miss_class_admin)

put *, into(teacher_questionnaire_TMNA_final)
frame change teacher_questionnaire_TMNA_final

ds, has(type numeric)
local numvars_tmna "`r(varlist)'"
ds, has(type string)
local stringvars_tmna "`r(varlist)'"

collapse (mean) numvars_tmna (first) stringvars_tmna, by(interview__id)
ds hashed_school_code, not
collapse (firstnm) `r(varlist)', by(hashed_school_code)

svyset [pw=ipw]
svy: mean teacher_monitoring

*********************************************
***** Teacher  Intrinsic Motivation ***********
*********************************************

* 
* School Survey. This lever measures whether teachers are intrinsically motivated to teach. The question(s) aim to address this 
* phenomenon by measuring the level of intrinsic motivation among teachers as well as teacher values that may be relevant for 
* ensuring that the teacher is motivated to focus on all children and not just some. Average score (1 (worst) - 5 (best)) on items 
* given to teachers on intrinsic motivation.

local intrinsic_motiv_q_rev m3scq1_tinm m3scq2_tinm m3scq3_tinm m3scq4_tinm m3scq5_tinm m3scq6_tinm m3scq7_tinm m3scq10_tinm
local intrinsic_motiv_q m3scq11_tinm m3scq14_tinm
local intrinsic_motiv_q_all m3scq1_tinm m3scq2_tinm m3scq3_tinm m3scq4_tinm m3scq5_tinm m3scq6_tinm m3scq7_tinm m3scq10_tinm m3scq11_tinm m3scq14_tinm

frame copy teacher_questionnaire_TMNA teacher_questionnaire_TINM2
frame change teacher_questionnaire_TINM2
keep hashed_school_code `preamble_info_teacher' m3sdq2_tmna
save teacher_questionnaire_TINM2

frame copy teacher_questionnaire teacher_questionnaire_TINM
frame change teacher_questionnaire_TINM

merge m:m hashed_school_code interview__id questionnaire_roster__id teacher_number using teacher_questionnaire_TINM2
*(De Facto) Percent of teachers that agree or strongly agrees with It is acceptable for a teacher to be absent if the ~
gen SE_PRM_TINM_1 = 100 if m3scq1_tinm>=4 & !missing(m3scq1_tinm)
replace SE_PRM_TINM_1 = 0 if m3scq1_tinm<4 & !missing(m3scq1_tinm)
*(De Facto) Percent of teachers that agree or strongly agrees with It is acceptable for a teacher to be absent if stud~
gen SE_PRM_TINM_2 = 100 if m3scq2_tinm>=4 & !missing(m3scq2_tinm) 
replace SE_PRM_TINM_2 = 0 if m3scq2_tinm<4 & !missing(m3scq2_tinm) 
*(De Facto) Percent of teachers that agree or strongly agrees with It is acceptable for a teacher to be absent if the ~
gen SE_PRM_TINM_3 = 100 if m3scq3_tinm>=4 & !missing(m3scq3_tinm) 
replace SE_PRM_TINM_3 = 0 if m3scq3_tinm<4 & !missing(m3scq3_tinm) 
*(De Facto) Percent of teachers that agree or strongly agrees with Students deserve more attention if they attend scho~
gen SE_PRM_TINM_4 = 100 if m3scq4_tinm>=4 & !missing(m3scq4_tinm) 
replace SE_PRM_TINM_4 = 0 if m3scq4_tinm<4 & !missing(m3scq4_tinm)
*(De Facto) Percent of teachers that agree or strongly agrees with Students deserve more attention if they come to sch~
gen SE_PRM_TINM_5 = 100 if m3scq5_tinm>=4 & !missing(m3scq5_tinm) 
replace SE_PRM_TINM_5 = 0 if m3scq5_tinm<4 & !missing(m3scq5_tinm)
*(De Facto) Percent of teachers that agree or strongly agrees with Students deserve more attention if they are motivat~
gen SE_PRM_TINM_6 = 100 if m3scq6_tinm>=4 & !missing(m3scq6_tinm) 
replace SE_PRM_TINM_6 = 0 if m3scq6_tinm<4 & !missing(m3scq6_tinm)
*(De Facto) Percent of teachers that agree or strongly agrees with Students have a certain amount of intelligence and ~
gen SE_PRM_TINM_7 = 100 if m3scq7_tinm>=4 & !missing(m3scq7_tinm) 
replace SE_PRM_TINM_7 = 0 if m3scq7_tinm<4 & !missing(m3scq7_tinm)
*(De Facto) Percent of teachers that agree or strongly agrees with To be honest, students can't really change how inte~
gen SE_PRM_TINM_8 = 100 if m3scq10_tinm>=4 & !missing(m3scq10_tinm) 
replace SE_PRM_TINM_8 = 0 if m3scq10_tinm<4 & !missing(m3scq10_tinm)
*(De Facto) Percent of teachers that agree or strongly agrees with Students can always substantially change how intell~
gen SE_PRM_TINM_9 = 100 if m3scq11_tinm>=4 & !missing(m3scq11_tinm) 
replace SE_PRM_TINM_9 = 0 if m3scq11_tinm<4 & !missing(m3scq11_tinm)
*(De Facto) Percent of teachers that agree or strongly agrees with \"Students can change even their basic intelligence l~
gen SE_PRM_TINM_10 = 100 if m3scq14_tinm>=4 & !missing(m3scq14_tinm) 
replace SE_PRM_TINM_10 = 0 if m3scq14_tinm<4 & !missing(m3scq14_tinm)

foreach var in `r(intrinsic_motiv_q)' {
replace `var' = . if `var'==99
replace `var' = 5 if `var'==4
replace `var' = 3.67 if `var'==3
replace `var' = 2.33 if `var'==2
replace `var' = 1 if `var'==1
}

foreach var in `r(intrinsic_motiv_q_rev)' {
replace `var' = . if `var'==99
replace `var' = 5 if `var'==1
replace `var' = 3.67 if `var'==2
replace `var' = 2.33 if `var'==3
replace `var' = 1 if `var'==4
}

gen acceptable_absent = (m3scq1_tinm+ m3scq2_tinm + m3scq3_tinm)/3
gen students_deserve_attention = (m3scq4_tinm+ m3scq5_tinm + m3scq6_tinm )/3
gen growth_mindset=(m3scq7_tinm + m3scq10_tinm + m3scq11_tinm + m3scq14_tinm)/4
gen motivation_teaching = 0 if m3scq15_tinm__3>=1 & !missing(m3scq15_tinm__3)
replace motivation_teaching= 1 if ((m3scq15_tinm__3!=1 & !missing(m3scq15_tinm__3)) & (m3scq15_tinm__1>=1 & !missing(m3scq15_tinm__1) | m3scq15_tinm__2>=1 & !missing(m3scq15_tinm__2)| m3scq15_tinm__4>=1 & !missing(m3scq15_tinm__1) & m3scq15_tinm__5>=1 & !missing(m3scq15_tinm__1)))
gen motivation_teaching_1 = 1 if m3sdq2_tmna==1
replace motivation_teaching_1 = 0 if m3sdq2_tmna!=1 & !missing(m3sdq2_tmna)
gen intrinsic_motivation=1+0.8*(0.2*acceptable_absent + 0.2*students_deserve_attention + 0.2*growth_mindset + motivation_teaching+motivation_teaching_1)

put *, into(teacher_questionnaire_TINM_final)
frame change teacher_questionnaire_TINM_final

ds, has(type numeric)
local numvars_tinm "`r(varlist)'"
ds, has(type string)
local stringvars_tinm "`r(varlist)'"

collapse (mean) numvars_tinm (first) stringvars_tinm, by(hashed_school_code)

svyset [pw=ipw]
svy: mean intrinsic_motivation

*********************************************
***** School  Inputs and Infrastructure Standards ***********
*********************************************
*   - 1 Point. Are there standards in place to monitor blackboard and chalk, pens and pencils, basic classroom furniture, computers, textbooks, exercise books, toilets, electricity, drinking water, accessibility for those with disabilities? (partial credit available)

frame copy school school_data_ISTD
frame change school_data_ISTD

egen standards_monitoring_input = rowmean(m1scq13_imon__*)
egen standards_monitoring_infrastructure = rowmean(m1scq14_imon__*)
gen standards_monitoring=(standards_monitoring_input*6+standards_monitoring_infrastructure*4)/2
collapse (firstnm) _all, by(hashed_school_code)

svyset [pw=ipw]
svy: mean standards_monitoring

*********************************************
***** School  Inputs and Infrastructure Monitoring ***********
*********************************************

* School Survey. This lever measures the extent to which there is a monitoring system in place to ensure that the inputs that must be available at the schools are in fact available at the schools. This set of questions will include three aspects: 
* - 1 Point. Are all input items (functioning blackboard, chalk, pens, pencils, textbooks, exercise books in 4th grade classrooms, basic classroom furniture, and at least one computer in the schools) being monitored? (partial credit available) 
* - 1 Point. Are all infrastructure items (functioning toilets, electricity, drinking water, and accessibility for people with disabilities) being monitored? (partial credit available) 
* - 1 Point. Is the community involved in the monitoring?

frame copy school school_data_IMON
frame change school_data_IMON
replace m1scq3_imon = 1 if m1scq3_imon==1
replace m1scq3_imon = 0 if m1scq3_imon!=1 & !missing(m1scq3_imon)
replace m1scq5_imon = 0 if m1scq5_imon==0
replace m1scq5_imon = 1 if m1scq5_imon==1
replace m1scq5_imon = 0.5 if m1scq5_imon==2
replace m1scq5_imon = 0 if missing(m1scq5_imon)

egen monitoring_inputs_temp = rowmean(m1scq4_imon__*)
gen monitoring_inputs = monitoring_inputs_temp if m1scq1_imon==1
replace monitoring_inputs = 0 if m1scq1_imon!=1 & !missing(m1scq1_imon)

egen monitoring_infrastructure_temp = rowmean(m1scq9_imon__*)
gen monitoring_infrastructure = monitoring_infrastructure_temp if m1scq7_imon==1
replace monitoring_infrastructure = 0 if m1scq7_imon!=1 & !missing(m1scq7_imon)

gen parents_involved = 1 if m1scq3_imon==1
replace parents_involved = 0 if m1scq3_imon!=1 & !missing(m1scq3_imon)
replace parents_involved = 0 if missing(m1scq3_imon)

gen sch_monitoring=1+1.5*monitoring_inputs+1.5*monitoring_infrastructure+parents_involved

collapse (firstnm) _all, by(hashed_school_code)
svyset [pw=ipw]
svy: mean sch_monitoring

*********************************************
***** School School Management Clarity of Functions  ***********
*********************************************


frame copy school school_data_SCFN
frame change school_data_SCFN
gen infrastructure_scfn = !(m7sfq15a_pknw__0==1 | m7sfq15a_pknw__98==1)
gen materials_scfn = !(m7sfq15b_pknw__0==1 | m7sfq15b_pknw__98==1)
gen hiring_scfn = !(m7sfq15c_pknw__0==1 | m7sfq15c_pknw__98==1)
gen supervision_scfn = !(m7sfq15d_pknw__0==1 | m7sfq15d_pknw__98==1)
gen student_scfn = !(m7sfq15e_pknw__0==1 | m7sfq15e_pknw__98==1)
gen principal_hiring_scfn = !(m7sfq15f_pknw__0==1 | m7sfq15f_pknw__98==1)
gen principal_supervision_scfn = !(m7sfq15g_pknw__0==1 | m7sfq15g_pknw__98==1)
gen sch_management_clarity=1+(infrastructure_scfn+materials_scfn)/2+ (hiring_scfn + supervision_scfn)/2 + student_scfn +(principal_hiring_scfn+ principal_supervision_scfn)/2

collapse (firstnm) _all, by(hashed_school_code)
svyset [pw=ipw]
svy: mean sch_management_clarity

*********************************************
***** School School Management Attraction  ***********
*********************************************

* This policy lever measures whether the right candidates are being attracted to the profession of school principals. The questions will aim to capture the provision of benefits to attract and maintain the best people to serve as principals. 
* 
* Scoring: 
*   -score is between 1-5 based on how satisfied the principal is with status in community. We will also add in component based on Principal salaries.
* For salary, based GDP per capita from 2018 World Bank  https://data.worldbank.org/indicator/NY.GDP.PCAP.CD?locations=JO.  


frame copy school school_data_SATT
frame change school_data_SATT

gen principal_satisfaction = . if m7shq1_satt==99
replace principal_satisfaction = 5 if m7shq1_satt==1
replace principal_satisfaction = 3.67 if m7shq1_satt==2
replace principal_satisfaction = 2.33 if m7shq1_satt==3
replace principal_satisfaction = 1 if m7shq1_satt==4
gen principal_salary=12*m7shq2_satt/22813.06	

gen principal_salary_score = 1 if principal_salary >=0 & principal_salary<=0.5 & !missing(principal_salary)
replace principal_salary_score = 2 if principal_salary >=0.5 & principal_salary<=0.75 & !missing(principal_salary)
replace principal_salary_score = 3 if principal_salary >=0.75 & principal_salary<=1 & !missing(principal_salary)
replace principal_salary_score = 4 if principal_salary >=1 & principal_salary<=1.5 & !missing(principal_salary)
replace principal_salary_score = 5 if principal_salary >=1.5 & principal_salary<=5 & !missing(principal_salary)
gen sch_management_attraction=(principal_satisfaction+principal_salary_score)/2

collapse (firstnm) _all, by(hashed_school_code)
svyset [pw=ipw]
svy: mean sch_management_attraction

*********************************************
***** School School Management Selection and Deployment  ***********
*********************************************


* This policy lever measures whether the right candidates being selected. These questions will probe what the recruitment process is like to 
* ensure that these individuals are getting the positions. The question would ultimately be based on: 1) there is a standard approach for selecting principals,
* 2) that approach relies on professional/academic requirements, and 3) those requirements are common in practice. 
* 
* Scoring: 
*   - 1 (lowest score) Most important factor is political affiliations or ethnic group. 
* - 2 Political affiliations or ethnic group is a consideration, but other factors considered as well. 
* - 3 Most important factor is years of experience, good relationship with owner/education department, and does not factor in quality teaching, demonstrated management qualities, or knowledge of local community. 
* - 4 Quality teaching, demonstrated management qualities, or knowledge of local community is a consideration in hiring, but not the most important factor 
* - 5 Quality teaching, demonstrated management qualities, or knowledge of local community is the most important factor in hiring. 

frame copy school school_data_SSLD
frame change school_data_SSLD
gen sch_selection_deployment = 5 if m7sgq2_ssld==2 | m7sgq2_ssld==3 | m7sgq2_ssld==8
replace sch_selection_deployment = 1 if m7sgq2_ssld==6 | m7sgq2_ssld==7
replace sch_selection_deployment = 4 if !(m7sgq2_ssld==6 | m7sgq2_ssld==7 | missing(m7sgq2_ssld)) & (m7sgq1_ssld__2==1 | m7sgq1_ssld__3==1 | m7sgq1_ssld__8==1)
replace sch_selection_deployment = 3 if (!(m7sgq2_ssld==6 | m7sgq2_ssld==7 |missing(m7sgq2_ssld)) & (m7sgq1_ssld__1==1 | m7sgq1_ssld__4==1 | m7sgq1_ssld__5==1 | m7sgq1_ssld__97==1))
replace sch_selection_deployment = 2 if m7sgq1_ssld__6==1 | m7sgq1_ssld__7==1

collapse (firstnm) _all, by(hashed_school_code)
svyset [pw=ipw]
svy: mean sch_selection_deployment

*********************************************
***** School School Management Support  ***********
*********************************************


* This policy lever measures the extent to which principals receive training and/or exposure to other professional opportunities that could help them be better school leaders. 
* The questions aim to figure out if such programs are provided, and if they are, their level of quality. 
* 
* Scoring (sum of components below): 
*   - 1 Point. Principal has received formal training on managing school. 
* - 1/3 Point. Had management training for new principals. 
* - 1/3 Point. Had management in-service training. 
* - 1/3 Point. Had mentoring/coaching by experienced principals. 
* - 1 Point. Have used skills gained at training. 
* - 1 Point. Principals offered training at least once per year

frame copy school school_data_SSUP
frame change school_data_SSUP
gen prinicipal_trained = 1 if m7sgq3_ssup==1
replace prinicipal_trained = 0 if m7sgq3_ssup!=1 & !missing(m7sgq3_ssup)
egen principal_training_temp = rowmean(m7sgq4_ssup__*)
gen principal_training = principal_training_temp if m7sgq3_ssup==1
replace principal_training = 0 if m7sgq3_ssup!=1 & !missing(m7sgq3_ssup)
gen principal_used_skills = 1 if m7sgq5_ssup ==1 & m7sgq3_ssup==1
replace principal_used_skills = 0 if m7sgq5_ssup!=1 & !missing(m7sgq5_ssup) & m7sgq3_ssup==1
gen principal_offered = (m7sgq7_ssup==2 | m7sgq7_ssup==3 | m7sgq7_ssup==4 | m7sgq7_ssup==5)
gen sch_support=1+prinicipal_trained+principal_training+principal_used_skills+principal_offered

collapse (firstnm) _all, by(hashed_school_code)
svyset [pw=ipw]
svy: mean sch_support

*********************************************
***** School School Management Evaluation  ***********
*********************************************

* School Survey. This policy lever measures the extent to which principal performance is being monitored and enforced via accountability measures. 
* The idea is that the indicator will be based on: 1) there is a legislation outlining the need to monitor, 2) principals are being evaluated, 3) 
* principals are being evaluated on multiple things, and 4) there the accountability mechanisms in place.

frme copy school school_data_SEVL
frame change school_data_SEVL
gen principal_formally_evaluated =1 if m7sgq8_sevl==1
replace principal_formally_evaluated= 0 if m7sgq8_sevl!=1 & !missing(m7sgq8_sevl)
ds m7sgq10_sevl__*
local varlist `r(varlist)'
local SEVL: list varlist - m7sgq10_sevl__98
egen principal_eval_tot = rowtotal(`SEVL')
gen principal_evaluation_multiple= 0 if m7sgq8_sevl==1
gen principal_evaluation_multiple = 1 if m7sgq8_sevl==1 & principal_eval_tot>=5 & !missing(principal_eval_tot)
replace principal_evaluation_multiple = 0.666667 if m7sgq8_sevl==1 & principal_eval_tot>1 & principal_eval_tot<5 & !missing(principal_eval_tot)
replace principal_evaluation_multiple = 0.3333333 if m7sgq8_sevl==1 & principal_eval_tot==1
replace principal_evaluation_multiple = 0 if m7sgq8_sevl!=1 & !missing(m7sgq8_sevl)
gen principal_negative_consequences = 1 if m7sgq11_sevl__1==1 | m7sgq11_sevl__2==1 | m7sgq11_sevl__3==1 | m7sgq11_sevl__4==1 | m7sgq11_sevl__97==1
gen principal_positive_consequences = 1 if m7sgq12_sevl__1==1 | m7sgq12_sevl__2==1 | m7sgq12_sevl__3==1 | m7sgq12_sevl__4==1 | m7sgq12_sevl__97==1
gen principal_evaluation=1+principal_formally_evaluated+principal_evaluation_multiple+principal_negative_consequences+principal_positive_consequences

collapse (firstnm) _all, by(hashed_school_code)
svyset [pw=ipw]
svy: mean principal_evaluation

****************************************************************************END**************************************************************************************************







