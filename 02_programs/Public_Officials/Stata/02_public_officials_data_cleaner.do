clear all

*set the paths
gl data_dir ${clone}/01_GEPD_raw_data/
gl processed_dir ${clone}/03_GEPD_processed_data/
gl save_dir "${processed_dir}\\Public_Officials\\Confidential\\"


********************************************
* Create indicators and necessary variables
********************************************

************
*Load public officials cleaned data file
************
cap frame create public
frame change public
*Load the school data
use "${data_dir}/Public_Officials/public_officials.dta"



**********
* Read in School indicators
**********

*absence
frame create teachers
frame change teachers

use "${processed_dir}/School/Confidential/Cleaned/teachers_Stata.dta"

svyset school_code, strata(strata) singleunit(scaled) weight(school_weight)   || teachers_id, weight(teacher_abs_weight)
svy: mean absence_rate
gl teacher_absence =  _b[absence_rate]

*class size
frame create school
frame change school

use "${processed_dir}/School/Confidential/Cleaned/school_Stata.dta"

svyset school_code, strata(strata) singleunit(scaled) weight(school_weight)  
svy: mean m4scq4_inpt
gl class_size = _b[m4scq4_inpt]

***********
* Clean up Idiosyncratic Variables
***********
frame change public

*create new copies of the indicators to score_temp
ds NLG* ACM* QB* IDM* ORG*
*Cleaning some data in major variables
foreach var in `r(varlist)' {

	gen scored_`var'=`var'
}

*reverse code some indicaotrs so 5 is best and 1 is worst
local intrinsic_motiv_q_rev scored_QB2q2 scored_QB4q4a scored_QB4q4b scored_QB4q4c scored_QB4q4d scored_QB4q4e scored_QB4q4f scored_QB4q4g scored_IDM1q1 scored_IDM1q2

foreach var in `intrinsic_motiv_q_rev' {
gen score_temp=.
replace score_temp = 1 if `var'==4
replace score_temp = 2.33 if `var'==3
replace score_temp = 3.67 if `var'==2
replace score_temp = 5 if `var'==1
replace score_temp = . if `var'==99
replace `var'=score_temp
drop score_temp
}

de scored_NLG* scored_ACM* scored_QB* scored_IDM* scored_ORG*, varlist
*Cleaning some data in major variables
foreach var in `r(varlist)' {
	capture confirm numeric variable `var'
	if !_rc {
		replace `var'=. if `var'==900 & !missing(`var')
        replace `var'=. if `var'==998 & !missing(`var')
	}
}

* Scale variables
* QB1q2
gen scored_temp=.
replace scored_temp = 5 if abs(QB1q2-$class_size)/$class_size<=0.1 // between 0-10% of actual value gets 5 points
replace scored_temp = 4 if abs(QB1q2-$class_size)/$class_size>0.1 & abs(QB1q2-$class_size)/$class_size<=0.2 // between 10-20% of actual value gets 4 points
replace scored_temp = 3 if abs(QB1q2-$class_size)/$class_size>0.2 & abs(QB1q2-$class_size)/$class_size<=0.3 // between 20-30% of actual value gets 3 points
replace scored_temp = 2 if abs(QB1q2-$class_size)/$class_size>0.3 & abs(QB1q2-$class_size)/$class_size<=0.4 // between 30-40% of actual value gets 2 points
replace scored_temp = 1 if abs(QB1q2-$class_size)/$class_size>0.4 & abs(QB1q2-$class_size)/$class_size<=1 // between 40-10% of actual value gets 1 points
replace scored_QB1q2=scored_temp
drop scored_temp

* QB1q1
gen scored_temp=.
replace scored_temp = 5 if abs(QB1q1-$teacher_absence)/$teacher_absence <=0.1 // between 0-10% of actual value gets 5 points
replace scored_temp = 4 if abs(QB1q1-$teacher_absence)/$teacher_absence >0.1 & abs(QB1q1-$teacher_absence)/$teacher_absence <=0.2 // between 10-20% of actual value gets 4 points
replace scored_temp = 3 if abs(QB1q1-$teacher_absence)/$teacher_absence >0.2 & abs(QB1q1-$teacher_absence)/$teacher_absence <=0.3 // between 20-30% of actual value gets 3 points
replace scored_temp = 2 if abs(QB1q1-$teacher_absence)/$teacher_absence >0.3 & abs(QB1q1-$teacher_absence)/$teacher_absence <=0.4 // between 30-40% of actual value gets 2 points
replace scored_temp = 1 if abs(QB1q1-$teacher_absence)/$teacher_absence >0.4 & abs(QB1q1-$teacher_absence)/$teacher_absence <=1 // between 40-10% of actual value gets 1 points
replace scored_QB1q1=scored_temp
drop scored_temp

* QB4q2
gen scored_temp=1  
replace scored_temp=1 if QB4q2<=90   // QB4q2>=80 ~ 1,
replace scored_temp=2 if QB4q2>=90 & QB4q2<100 
replace scored_temp=3 if QB4q2>=100 & QB4q2<110
replace scored_temp=4 if QB4q2>=110 & QB4q2<120
replace scored_temp=5 if QB4q2>=120
replace scored_QB4q2=scored_temp
drop scored_temp


* IDM1q3
gen scored_temp=1
replace scored_temp=2 if IDM1q3>15 & IDM1q3<=20
replace scored_temp=3 if IDM1q3>10 & IDM1q3<=15
replace scored_temp=4 if IDM1q3>5 & IDM1q3<=10
replace scored_temp=5 if IDM1q3>=0 & IDM1q3<=5
replace scored_IDM1q3=scored_temp
drop scored_temp



* IDM3q1
gen scored_temp=1
replace scored_temp=2 if IDM3q1>15 & IDM3q1<=20
replace scored_temp=3 if IDM3q1>10 & IDM3q1<=15
replace scored_temp=4 if IDM3q1>5 & IDM3q1<=10
replace scored_temp=5 if IDM3q1>=0 & IDM3q1<=5
replace scored_IDM3q1=scored_temp
drop scored_temp



* IDM3q2
gen scored_temp=1
replace scored_temp=2 if IDM3q2>15 & IDM3q2<=20
replace scored_temp=3 if IDM3q2>10 & IDM3q2<=15
replace scored_temp=4 if IDM3q2>5 & IDM3q2<=10
replace scored_temp=5 if IDM3q2>=0 & IDM3q2<=5
replace scored_IDM3q2=scored_temp
drop scored_temp



* IDM3q3
gen scored_temp=1
replace scored_temp=2 if IDM3q3>15 & IDM3q3<=20
replace scored_temp=3 if IDM3q3>10 & IDM3q3<=15
replace scored_temp=4 if IDM3q3>5 & IDM3q3<=10
replace scored_temp=5 if IDM3q3>=0 & IDM3q3<=5
replace scored_IDM3q3=scored_temp
drop scored_temp



*************************
* National Learning Goals
*************************
frame change public

ds scored_NLG*
gen nlg_length= wordcount("`r(varlist)'")
*calculate item scores
egen national_learning_goals = rowmean(scored_NLG*)
egen targeting=rowmean(scored_NLG1*)
egen monitoring=rowmean(scored_NLG2*)
egen incentives=rowmean(scored_NLG3*)
egen community_engagement=rowmean(scored_NLG4*)


********
* Mandates and Accountability
********
ds scored_ACM*
gen acm_length= wordcount("`r(varlist)'")

*calculate item scores
egen mandates_accountability = rowmean(scored_ACM*)
egen coherence=rowmean(scored_ACM2*)
egen transparency=rowmean(scored_ACM3*)
egen accountability=rowmean(scored_ACM4*)


********
* Quality of Bureaucracy
********
ds scored_QB*
gen qb_length= wordcount("`r(varlist)'")

*calculate item scores

egen quality_bureaucracy=rowmean(scored_QB*)
egen knowledge_skills=rowmean(scored_QB1*)
egen work_environment=rowmean(scored_QB2*)
egen merit=rowmean(scored_QB3*)
egen motivation_attitudes=rowmean(scored_QB4*)


********
* Impartial Decision Making
********
ds IDM*
gen idm_length= wordcount("`r(varlist)'")

*calculate item scores

egen impartial_decision_making=rowmean(scored_IDM*)
egen pol_personnel_management=rowmean(scored_IDM1*)
egen pol_policy_making=rowmean(scored_IDM2*)
egen pol_policy_implementation=rowmean(scored_IDM3*)
egen employee_unions_as_facilitators=rowmean(scored_IDM4*)

********
* Stats 
********

mean national_learning_goals targeting monitoring incentives community_engagement mandates_accountability coherence transparency accountability quality_bureaucracy knowledge_skills work_environment merit motivation_attitudes impartial_decision_making pol_personnel_management pol_policy_making pol_policy_implementation employee_unions_as_facilitators


*Clean office variable:

clonevar tier_govt_ar = m1s0q2_name

replace tier_govt_ar = m1s0q2_name_incorrect if info_correct ==0 
fre info_correct

fre tier_govt_ar


gen office_clean = "Secretariat (or equivalent)" if  tier_govt_ar ==1
replace office_clean = "District office (or equivalent)" if  tier_govt_ar == 3
replace office_clean = "Directorate office (or equivalent)" if  tier_govt_ar == 2

fre office_clean
fre tier_govt_ar




*********
* Save
*********

save "$save_dir/public_officials.dta", replace

