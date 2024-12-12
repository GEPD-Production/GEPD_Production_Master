*Last updated by Mohammed Eldesouky on December 11, 2024 to: 

** a- Correct a calculation issue on "QB4q2"
** b- Add the summary and descriptive stats automation at the bottom of the script


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

*Appending public 46 officials from V5 
 append using "${data_dir}/Public_Officials/public_officials_v5.dta"

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
gen scored_temp=.  
replace scored_temp=1 if QB4q2<90   // QB4q2>=80 ~ 1,
replace scored_temp=2 if QB4q2>=90 & QB4q2<100 
replace scored_temp=3 if QB4q2>=100 & QB4q2<110
replace scored_temp=4 if QB4q2>=110 & QB4q2<120
replace scored_temp=5 if QB4q2>=120 & QB4q2!= 900 & QB4q2!=998 & QB4q2!=. & QB4q2!=.a

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

stop {*! "[Some key parameters below must be checked or modified by the user before run]"

*-------------------------------------------
* Comments Mo
* Summarry and discribtives stats automation


/*Defining the data files' names
*----------------------------
* In-Processed
gl po_p		 			"public_officials.dta"*/

*Defining the ID variables for dataset 
*----------------------------
* In processed
gl po_IDs_p				 "interview__key"

*****************************
*loading datasets
*****************************

// Po _processes_ data
frame copy public po_p
frame change po_p	

*****************************
*Running the checks
*****************************
// defining the results matrices to store results 

matrix overview_01 = J(1, 4, .z)
matrix rownames overview_01 = "Numbers"
matrix colname overview_01 = "No_observations" "Interviewed_officials" "Consented" "Consented_recorded" 
matlist overview_01


matrix overview_02 = J(6, 4, .z)
matrix rownames overview_02 = "MoE_Federal" "Province_office" "District_office" "Sub_district" "Total(N)" "Percent(%)"
matrix colname overview_02 = "Female" "Male" "Total(N)" "Percent(%)"
matlist overview_02


matrix occup_cat = J(5, 6, .z)
matrix rownames occup_cat = "Professional_service(%)" "Sub-professional(%)" "Administrative(%)" "Other(%)" "Total(N)"
matrix colname occup_cat = "MoE_Federal" "Province_office" "District_office" "Sub_district" "Total(N)" "Percent(%)"
matlist occup_cat


matrix edu_lvl = J(6, 6, .z)
matrix rownames edu_lvl = "Secondary_school(%)" "Post-high-school_diploma(%)" "Undergraduate(%)" "Master(%)" "PhD(%)" "Other(%)"
matrix colname edu_lvl = "MoE_Federal" "Province_office" "District_office" "Sub_district" "Total(N)" "Percent(%)"
matlist edu_lvl


matrix cotrct_typ = J(4, 6, .z)
matrix rownames cotrct_typ = "Permanent(%)" "Short-term_Temporary(%)" "Don't-know(%)" "Refused_answer(%)" 
matrix colname cotrct_typ = "MoE_Federal" "Province_office" "District_office" "Sub_district" "Total(N)" "Percent(%)"
matlist cotrct_typ



// Filling in the overview [Matrix "1"]-----------------------------*

capture unique  $po_IDs_p 
matrix overview_01[1, 1] = r(unique)
matrix overview_01[1, 2] = r(N)
count if m1s2q2==1
matrix overview_01[1, 3] = r(N)
clear results
cap count if recording_consent==1
matrix overview_01[1, 4] = r(N)

matlist overview_01

// Filling in the overview [Matrix "2"]-----------------------------*

tab DEM1q15, gen(sex)
tab tier_govt_ar, gen(tier)

cap sum sex1
matrix overview_02[5, 2] = r(sum)
matrix overview_02[6, 2] = round(100*r(mean))
cap sum sex2
matrix overview_02[5, 1] = r(sum)
matrix overview_02[6, 1] = round(100*r(mean))
matrix overview_02[5, 3] = r(N)
matrix overview_02[6, 3] = 100*r(sum_w)/r(N)

cap sum sex2 if tier_govt_ar==1
matrix overview_02[1, 1] = r(sum)
cap sum sex1 if tier_govt_ar==1
matrix overview_02[1, 2] = r(sum)
matrix overview_02[1, 3] = r(N)

cap sum sex2 if tier_govt_ar==2
matrix overview_02[2, 1] = r(sum)
cap sum sex1 if tier_govt_ar==2
matrix overview_02[2, 2] = r(sum)
matrix overview_02[2, 3] = r(N)

cap sum sex2 if tier_govt_ar==3
matrix overview_02[3, 1] = r(sum)
cap sum sex1 if tier_govt_ar==3
matrix overview_02[3, 2] = r(sum)
matrix overview_02[3, 3] = r(N)

cap sum sex2 if tier_govt_ar==4
matrix overview_02[4, 1] = r(sum)
cap sum sex1 if tier_govt_ar==4
matrix overview_02[4, 2] = r(sum)
matrix overview_02[4, 3] = r(N)

cap sum tier1
matrix overview_02[1, 4] = round(100*r(mean))
cap sum tier2
matrix overview_02[2, 4] = round(100*r(mean))
cap sum tier3
matrix overview_02[3, 4] = round(100*r(mean))
cap sum tier4
matrix overview_02[4, 4] = round(100*r(mean))
matrix overview_02[5, 4] = 100*r(sum_w)/r(N)


matlist overview_02

// Filling in the occupational category [Matrix "3"]-----------------------------*

tab DEM1q1, gen(occup_cat)
replace occup_cat4= occup_cat5 if occup_cat4!=1

cap sum occup_cat1
matrix occup_cat[1, 5] = r(sum)
matrix occup_cat[1, 6] = round(100*r(mean))
cap sum occup_cat2
matrix occup_cat[2, 5] = r(sum)
matrix occup_cat[2, 6] = round(100*r(mean))
cap sum occup_cat3
matrix occup_cat[3, 5] = r(sum)
matrix occup_cat[3, 6] = round(100*r(mean))
cap sum occup_cat4
matrix occup_cat[4, 5] = r(sum)
matrix occup_cat[4, 6] = round(100*r(mean))
matrix occup_cat[5, 5] = r(N)
matrix occup_cat[5, 6] = 100*r(sum_w)/r(N)

cap sum occup_cat1 if tier_govt_ar==1
matrix occup_cat[1, 1] = round(100*r(mean))
cap sum occup_cat2 if tier_govt_ar==1
matrix occup_cat[2, 1] = round(100*r(mean))
cap sum occup_cat3 if tier_govt_ar==1
matrix occup_cat[3, 1] = round(100*r(mean))
cap sum occup_cat4 if tier_govt_ar==1
matrix occup_cat[4, 1] = round(100*r(mean))
cap sum tier1
matrix occup_cat[5, 1] = r(sum)

cap sum occup_cat1 if tier_govt_ar==2
matrix occup_cat[1, 2] = round(100*r(mean))
cap sum occup_cat2 if tier_govt_ar==2
matrix occup_cat[2, 2] = round(100*r(mean))
cap sum occup_cat3 if tier_govt_ar==2
matrix occup_cat[3, 2] = round(100*r(mean))
cap sum occup_cat4 if tier_govt_ar==2
matrix occup_cat[4, 2] = round(100*r(mean))
cap sum tier2
matrix occup_cat[5, 2] = r(sum)

cap sum occup_cat1 if tier_govt_ar==3
matrix occup_cat[1, 3] = round(100*r(mean))
cap sum occup_cat2 if tier_govt_ar==3
matrix occup_cat[2, 3] = round(100*r(mean))
cap sum occup_cat3 if tier_govt_ar==3
matrix occup_cat[3, 3] = round(100*r(mean))
cap sum occup_cat4 if tier_govt_ar==3
matrix occup_cat[4, 3] = round(100*r(mean))
cap sum tier3
matrix occup_cat[5, 3] = r(sum)

cap sum occup_cat1 if tier_govt_ar==4
matrix occup_cat[1, 4] = round(100*r(mean))
cap sum occup_cat2 if tier_govt_ar==4
matrix occup_cat[2, 4] = round(100*r(mean))
cap sum occup_cat3 if tier_govt_ar==4
matrix occup_cat[3, 4] = round(100*r(mean))
cap sum occup_cat4 if tier_govt_ar==4
matrix occup_cat[4, 4] = round(100*r(mean))
cap sum tier4
matrix occup_cat[5, 4] = r(sum)

matlist occup_cat

// Filling in the educational level [Matrix "4"]-----------------------------*

tab DEM1q11, gen(edu_lvl) 
rename edu_lvl1 edu_lvl5
rename edu_lvl2 edu_lvl6
rename edu_lvl3 edu_lvl7

cap sum edu_lvl3
matrix edu_lvl[1, 5] = r(sum)
matrix edu_lvl[1, 6] = round(100*r(mean))
	clear results
cap sum edu_lvl4
matrix edu_lvl[2, 5] = r(sum)
matrix edu_lvl[2, 6] = round(100*r(mean))
	clear results
cap sum edu_lvl5
matrix edu_lvl[3, 5] = r(sum)
matrix edu_lvl[3, 6] = round(100*r(mean))
	clear results
cap sum edu_lvl6
matrix edu_lvl[4, 5] = r(sum)
matrix edu_lvl[4, 6] = round(100*r(mean))
	clear results
cap sum edu_lvl7
matrix edu_lvl[5, 5] = r(sum)
matrix edu_lvl[5, 6] = round(100*r(mean))
	clear results
cap sum edu_lvl8
matrix edu_lvl[6, 5] = r(sum)
matrix edu_lvl[6, 6] = round(100*r(mean))
	clear results

cap sum edu_lvl3 if tier_govt_ar==1
matrix edu_lvl[1, 1] = round(100*r(mean))
	clear results
cap sum edu_lvl4 if tier_govt_ar==1
matrix edu_lvl[2, 1] = round(100*r(mean))
	clear results
cap sum edu_lvl5 if tier_govt_ar==1
matrix edu_lvl[3, 1] = round(100*r(mean))
	clear results
cap sum edu_lvl6 if tier_govt_ar==1
matrix edu_lvl[4, 1] = round(100*r(mean))
	clear results
cap sum edu_lvl7 if tier_govt_ar==1
matrix edu_lvl[5, 1] = round(100*r(mean))
	clear results
cap sum edu_lvl8 if tier_govt_ar==1
matrix edu_lvl[6, 1] = round(100*r(mean))
	clear results

cap sum edu_lvl3 if tier_govt_ar==2
matrix edu_lvl[1, 2] = round(100*r(mean))
	clear results
cap sum edu_lvl4 if tier_govt_ar==2
matrix edu_lvl[2, 2] = round(100*r(mean))
	clear results
cap sum edu_lvl5 if tier_govt_ar==2
matrix edu_lvl[3, 2] = round(100*r(mean))
	clear results
cap sum edu_lvl6 if tier_govt_ar==2
matrix edu_lvl[4, 2] = round(100*r(mean))
	clear results
cap sum edu_lvl7 if tier_govt_ar==2
matrix edu_lvl[5, 2] = round(100*r(mean))
	clear results
cap sum edu_lvl8 if tier_govt_ar==2
matrix edu_lvl[6, 2] = round(100*r(mean))
	clear results

cap sum edu_lvl3 if tier_govt_ar==3
matrix edu_lvl[1, 3] = round(100*r(mean))
	clear results
cap sum edu_lvl4 if tier_govt_ar==3
matrix edu_lvl[2, 3] = round(100*r(mean))
	clear results
cap sum edu_lvl5 if tier_govt_ar==3
matrix edu_lvl[3, 3] = round(100*r(mean))
	clear results
cap sum edu_lvl6 if tier_govt_ar==3
matrix edu_lvl[4, 3] = round(100*r(mean))
	clear results
cap sum edu_lvl7 if tier_govt_ar==3
matrix edu_lvl[5, 3] = round(100*r(mean))
	clear results
cap sum edu_lvl8 if tier_govt_ar==3
matrix edu_lvl[6, 3] = round(100*r(mean))
	clear results
	
cap sum edu_lvl3 if tier_govt_ar==4
matrix edu_lvl[1, 4] = round(100*r(mean))
	clear results
cap sum edu_lvl4 if tier_govt_ar==4
matrix edu_lvl[2, 4] = round(100*r(mean))
	clear results
cap sum edu_lvl5 if tier_govt_ar==4
matrix edu_lvl[3, 4] = round(100*r(mean))
	clear results
cap sum edu_lvl6 if tier_govt_ar==4
matrix edu_lvl[4, 4] = round(100*r(mean))
	clear results
cap sum edu_lvl7 if tier_govt_ar==4
matrix edu_lvl[5, 4] = round(100*r(mean))
	clear results
cap sum edu_lvl8 if tier_govt_ar==4
matrix edu_lvl[6, 4] = round(100*r(mean))
	clear results


matlist edu_lvl


// Filling in the contract type [Matrix "5"]-----------------------------*

tab DEM1q11n, gen(cotrct_typ) 

cap sum cotrct_typ1
matrix cotrct_typ[1, 5] = r(sum)
matrix cotrct_typ[1, 6] = round(100*r(mean))
	clear results
cap sum cotrct_typ2
matrix cotrct_typ[2, 5] = r(sum)
matrix cotrct_typ[2, 6] = round(100*r(mean))
	clear results
cap sum cotrct_typ3
matrix cotrct_typ[3, 5] = r(sum)
matrix cotrct_typ[3, 6] = round(100*r(mean))
	clear results
cap sum cotrct_typ4
matrix cotrct_typ[4, 5] = r(sum)
matrix cotrct_typ[4, 6] = round(100*r(mean))
	clear results


cap sum cotrct_typ1 if tier_govt_ar==1
matrix cotrct_typ[1, 1] = round(100*r(mean))
	clear results
cap sum cotrct_typ2 if tier_govt_ar==1
matrix cotrct_typ[2, 1] = round(100*r(mean))
	clear results
cap sum cotrct_typ3 if tier_govt_ar==1
matrix cotrct_typ[3, 1] = round(100*r(mean))
	clear results
cap sum cotrct_typ4 if tier_govt_ar==1
matrix cotrct_typ[4, 1] = round(100*r(mean))
	clear results

cap sum cotrct_typ1 if tier_govt_ar==2
matrix cotrct_typ[1, 2] = round(100*r(mean))
	clear results
cap sum cotrct_typ2 if tier_govt_ar==2
matrix cotrct_typ[2, 2] = round(100*r(mean))
	clear results
cap sum cotrct_typ3 if tier_govt_ar==2
matrix cotrct_typ[3, 2] = round(100*r(mean))
	clear results
cap sum cotrct_typ4 if tier_govt_ar==2
matrix cotrct_typ[4, 2] = round(100*r(mean))
	clear results

cap sum cotrct_typ1 if tier_govt_ar==3
matrix cotrct_typ[1, 3] = round(100*r(mean))
	clear results
cap sum cotrct_typ2 if tier_govt_ar==3
matrix cotrct_typ[2, 3] = round(100*r(mean))
	clear results
cap sum cotrct_typ3 if tier_govt_ar==3
matrix cotrct_typ[3, 3] = round(100*r(mean))
	clear results
cap sum cotrct_typ4 if tier_govt_ar==3
matrix cotrct_typ[4, 3] = round(100*r(mean))
	clear results
	
cap sum cotrct_typ1 if tier_govt_ar==4
matrix cotrct_typ[1, 4] = round(100*r(mean))
	clear results
cap sum cotrct_typ2 if tier_govt_ar==4
matrix cotrct_typ[2, 4] = round(100*r(mean))
	clear results
cap sum cotrct_typ3 if tier_govt_ar==4
matrix cotrct_typ[3, 4] = round(100*r(mean))
	clear results
cap sum cotrct_typ4 if tier_govt_ar==4
matrix cotrct_typ[4, 4] = round(100*r(mean))
	clear results

matlist cotrct_typ


*****************************
*Graphing some data
*****************************

*location 
graph hbar (count), name(gh1) nodraw  ///
over(location, sort(1) descending label(angle(forty_five) labsize(tiny))) blabel(bar) ///
title(`"From where do public officials come from?"', span size(*.7) linegap(1.5) margin(medium)) ///
caption("{it:Figure 1.} Frequency count of public officials by {bf:location} variable", size (small) margin(large)) ///
ylabel(, labsize(small) notick) ///
bar(1, fcolor(teal%76) lcolor(mint))

graph bar (count) if tier_govt_ar==1 , name(gh2_1) nodraw ///
over(location, sort(1) descending label(angle(forty_five) labsize(vsmall))) blabel(bar) ///
title(`"From where do {bf:MoE} public officials come from?"', span size(*.7) linegap(1.5) margin(medium)) ///
ylabel(, labsize(vsmall) notick) ///
bar(1, fcolor(teal%76) lcolor(mint))

graph bar (count) if tier_govt_ar==2 , name(gh2_2) nodraw ///
over(location, sort(1) descending label(angle(forty_five) labsize(vsmall))) blabel(bar) ///
title(`"From where do {bf:Province} public officials come from?"', span size(*.7) linegap(1.5) margin(medium)) ///
ylabel(, labsize(vsmall) notick) ///
bar(1, fcolor(teal%76) lcolor(mint))

graph bar (count) if tier_govt_ar==3 , name(gh2_3) nodraw ///
over(location, sort(1) descending label(angle(forty_five) labsize(vsmall))) blabel(bar) ///
title(`"From where do {bf:District} public officials come from?"', span size(*.7) linegap(1.5) margin(medium)) ///
ylabel(, labsize(vsmall) notick) ///
bar(1, fcolor(teal%76) lcolor(mint))

graph bar (count) if tier_govt_ar==4 , name(gh2_4) nodraw ///
over(location, sort(1) descending label(angle(forty_five) labsize(vsmall))) blabel(bar) ///
title(`"From where do {bf:Sub-district} public officials come from?"', span size(*.7) linegap(1.5) margin(medium)) ///
caption("{it:Figure 2.} Frequency count of public officials by {bf:location} variable", size (small) margin(small)) ///
ylabel(, labsize(vsmall) notick) ///
bar(1, fcolor(teal%76) lcolor(mint))

graph combine gh2_1 gh2_2 gh2_3 gh2_4, col(1) ysize(12) xsize(11) name(gh2) nodraw 

*Age
sum DEM1q6, d
gl mean1 =round(r(mean), .01)
gl median1 =round(r(p50), .01)
graph hbox DEM1q6, name(gh3) nodraw ///
title(`"Age distribution of public officials"', span size(*.7) linegap(1.5) margin(medium)) ///
caption("{it:Figure 3.} distribution of public officials on the Age variable" ///
"{&bullet} {bf:Extreme outliers indicate data entry errors}" ///
"{&bullet} {bf:Dashed line represents mean value =$mean1}" ///
"{&bullet} {bf:Median =$median1}", size(small) margin(large) span) ///
asyvars bar(1, fcolor(blue) blcolor(blue) bfcolor(blue)) ///
marker(1, mcolor(blue) msymbol(o)) ///
yline( $mean1, lcolor(black) lwidth(thin)) ///
ylabel(, labsize(small) notick)


gen age=DEM1q6
replace age=. if DEM1q6<=0 | DEM1q6>100
sum age, d
gl mean2 =round(r(mean), .01)
gl median2 =round(r(p50), .01)
graph hbox age, name(gh4) nodraw ///
title(`"Age distribution of public officials, excluding irrational outliers"', span size(*.7) linegap(1.5) margin(medium)) ///
caption("{it:Figure 4.} distribution of public officials on the Age variable" ///
"{&bullet} {bf:Extreme outliers {it: <=0 & >100} were dropped}" ///
"{&bullet} {bf:Dashed line represents mean value =$mean2}" ///
"{&bullet} {bf:Median =$median2}", size(small) margin(large) span) ///
asyvars bar(1, fcolor(blue) blcolor(blue) bfcolor(blue)) ///
marker(1, mcolor(blue) msymbol(o)) ///
yline( $mean2, lcolor(black) lwidth(mediumthick)) ///
ylabel(, labsize(small) notick)


sum age if DEM1q15==1, d
gl mean_m =round(r(mean), .01)
gl median_m =round(r(p50), .01)
sum age if DEM1q15==2, d
gl mean_f =round(r(mean), .01)
gl median_f =round(r(p50), .01)

graph hbox age, name(gh5) nodraw ///
over(DEM1q15, relabel(1 "Male" 2 "Female")) ///
title(`"Age distribution of public officials, excluding irrational outliers"' ///
"{bf:Male/Female}", span size(*.7) linegap(1.5) margin(medium)) ///
caption("{it:Figure 5.} distribution of public officials on the Age variable" ///
"{&bullet} {bf:Extreme outliers {it: <=0 & >100} were dropped}" ///
"{&bullet} {bf:Dashed line represents mean value {&bullet}{Male=$mean_m} {&bullet}{Female=$mean_f}}" ///
"{&bullet} {bf:Median {&bullet}{Male= $median_m} {&bullet}{Female= $median_f}}", size(small) margin(large) span) ///
asyvars bar(1, fcolor(blue) blcolor(blue) bfcolor(blue)) ///
marker(1, mcolor(blue) msymbol(o)) ///
bar(2, fcolor(pink) blcolor(pink) bfcolor(pink)) ///
marker(2, mcolor(pink) msymbol(o)) ///
yline( $mean_m, lcolor(blue) lwidth(mediumthick)) ///
yline( $mean_f, lcolor(pink) lwidth(mediumthick)) ///
ylabel(, labsize(small) notick)


sum age if tier_govt_ar==1, d
gl mean_moe =round(r(mean), .01)
gl median_moe =round(r(p50), .01)
sum age if tier_govt_ar==2, d
gl mean_prv =round(r(mean), .01)
gl median_prv =round(r(p50), .01)
sum age if tier_govt_ar==3, d
gl mean_dist =round(r(mean), .01)
gl median_dist =round(r(p50), .01)
sum age if tier_govt_ar==4, d
gl mean_subdist =round(r(mean), .01)
gl median_subdist =round(r(p50), .01)

graph hbox age, name(gh6) nodraw ///
over(tier_govt_ar, relabel(1 "MoE" 2 "Province" 3 "District" 4 "Sub-district")) ///
title(`"Age distribution of public officials, excluding irrational outliers"' ///
"{bf:Government Tier}", span size(*.7) linegap(1.5) margin(medium)) ///
caption("{it:Figure 6.} distribution of public officials on the Age variable" ///
"{&bullet} {bf:Extreme outliers {it: <=0 & >100} were dropped}" ///
"{&bullet} {bf:Dashed line represents mean value {&bullet}{MoE=$mean_moe} {&bullet}{Prov=$mean_prv} {&bullet}{Dist=$mean_dist}} {&bullet}{Dist=$mean_subdist}}" ///
"{&bullet} {bf:Median {&bullet}{MoE= $median_moe} {&bullet}{Prov= $median_prv} {&bullet}{Dist= $median_dist} {&bullet}{Dist= $median_subdist}}", size(small) margin(large) span) ///
asyvars bar(1, fcolor(red) blcolor(red) bfcolor(red)) ///
marker(1, mcolor(red) msymbol(o)) ///
bar(2, fcolor(blue) blcolor(blue) bfcolor(blue)) ///
marker(2, mcolor(blue) msymbol(o)) ///
bar(3, fcolor(green) blcolor(green) bfcolor(green)) ///
marker(3, mcolor(green) msymbol(o)) ///
bar(4, fcolor(orange) blcolor(orange) bfcolor(orange)) ///
marker(3, mcolor(orange) msymbol(o)) ///
yline( $mean_moe, lcolor(red) lwidth(mediumthick)) ///
yline( $mean_prv, lcolor(blue) lwidth(mediumthick)) ///
yline( $mean_dist, lcolor(green) lwidth(mediumthick)) ///
yline( $mean_subdist, lcolor(orange) lwidth(mediumthick)) ///
ylabel(, labsize(small) notick)


* Occupational catgory 
graph hbar (count), name(gh7) nodraw ///
over(DEM1q1, sort(1) descending label(angle(forty_five) labsize(small))) blabel(bar) ///
title(`"What type of occupations do public officials represent?"', span size(*.7) linegap(1.5) margin(medium)) ///
caption("{it:Figure 1.} Frequency count of public officials by {bf:Occupational Category} variable", size (small) margin(large)) ///
ylabel(, labsize(small) notick) ///
bar(1, fcolor(teal%76) lcolor(mint))

* Years held in currentt position
sum DEM1q7 if tier_govt_ar==1, d
gl mean_moe2 =round(r(mean), .01)
gl median_moe2 =round(r(p50), .01)
sum DEM1q7 if tier_govt_ar==2, d
gl mean_prv2 =round(r(mean), .01)
gl median_prv2 =round(r(p50), .01)
sum DEM1q7 if tier_govt_ar==3, d
gl mean_dist2 =round(r(mean), .01)
gl median_dist2 =round(r(p50), .01)
sum DEM1q7 if tier_govt_ar==4, d
gl mean_subdist2 =round(r(mean), .01)
gl median_subdist2 =round(r(p50), .01)

graph hbox DEM1q7, name(gh8) nodraw ///
over(tier_govt_ar, relabel(1 "MoE" 2 "Province" 3 "District" 4 "Sub-district")) ///
title(`"Distribution of number of years that public officials spent in current position"' ///
"{bf:Government Tier}", span size(*.7) linegap(1.5) margin(medium)) ///
caption("{it:Figure 6.} distribution of public officials on {bf: Years in current position} variable" ///
"{&bullet} {bf:Dashed line represents mean value {&bullet}{MoE=$mean_moe2} {&bullet}{Prov=$mean_prv2} {&bullet}{Dist=$mean_dist2} {&bullet}{Dist=$mean_subdist2}}" ///
"{&bullet} {bf:Median {&bullet}{MoE= $median_moe2} {&bullet}{Prov= $median_prv2} {&bullet}{Dist= $median_dist2} {&bullet}{Dist= $median_subdist2}}", size(small) margin(large) span) ///
asyvars bar(1, fcolor(red) blcolor(red) bfcolor(red)) ///
marker(1, mcolor(red) msymbol(o)) ///
bar(2, fcolor(blue) blcolor(blue) bfcolor(blue)) ///
marker(2, mcolor(blue) msymbol(o)) ///
bar(3, fcolor(green) blcolor(green) bfcolor(green)) ///
marker(3, mcolor(green) msymbol(o)) ///
bar(4, fcolor(orange) blcolor(orange) bfcolor(orange)) ///
marker(4, mcolor(orange) msymbol(o)) ///
yline( $mean_moe2, lcolor(red) lwidth(mediumthick)) ///
yline( $mean_prv2, lcolor(blue) lwidth(mediumthick)) ///
yline( $mean_dist2, lcolor(green) lwidth(mediumthick)) ///
yline( $mean_subdist2, lcolor(orange) lwidth(mediumthick)) ///
ylabel(, labsize(small) notick)


* Educational level 
graph hbar (count), name(gh9) nodraw ///
over(DEM1q11, sort(1) descending label(angle(forty_five) labsize(small))) blabel(bar) ///
title(`"Level of education of public officials?"', span size(*.7) linegap(1.5) margin(medium)) ///
caption("{it:Figure 1.} Frequency count of public officials by {bf:Higest qualification} variable", size (small) margin(large)) ///
ylabel(, labsize(small) notick) ///
bar(1, fcolor(teal%76) lcolor(mint))


* salary distribution
sum  DEM1q14n if tier_govt_ar==1, d
gl mean_moe3 =round(r(mean), 1)
gl median_moe3 =round(r(p50), 1)
sum  DEM1q14n if tier_govt_ar==2, d
gl mean_prv3 =round(r(mean), 1)
gl median_prv3 =round(r(p50), 1)
sum  DEM1q14n if tier_govt_ar==3, d
gl mean_dist3 =round(r(mean), 1)
gl median_dist3 =round(r(p50), 1)
sum  DEM1q14n if tier_govt_ar==4, d
gl mean_subdist3 =round(r(mean), 1)
gl median_subdist3 =round(r(p50), 1)

graph hbox  DEM1q14n, name(gh10) nodraw ///
over(tier_govt_ar, relabel(1 "MoE" 2 "Province" 3 "District" 4 "Sub-district")) ///
title(`"Distribution of public officials' reported salaries"' ///
"{bf:Government Tier}", span size(*.7) linegap(1.5) margin(medium)) ///
caption("{it:Figure 6.} distribution of public officials on {bf: Salary} variable" ///
"{&bullet} {bf:Dashed line represents mean value {&bullet}{MoE=$mean_moe3} {&bullet}{Prov=$mean_prv3} {&bullet}{Dist=$mean_dist3} {&bullet}{Dist=$mean_subdist3}}" ///
"{&bullet} {bf:Median {&bullet}{MoE= $median_moe3} {&bullet}{Prov= $median_prv3} {&bullet}{Dist= $median_dist3} {&bullet}{Dist= $median_subdist3}}", size(small) margin(large) span) ///
asyvars bar(1, fcolor(red) blcolor(red) bfcolor(red)) ///
marker(1, mcolor(red) msymbol(o)) ///
bar(2, fcolor(blue) blcolor(blue) bfcolor(blue)) ///
marker(2, mcolor(blue) msymbol(o)) ///
bar(3, fcolor(green) blcolor(green) bfcolor(green)) ///
marker(3, mcolor(green) msymbol(o)) ///
bar(3, fcolor(orange) blcolor(orange) bfcolor(orange)) ///
marker(3, mcolor(orange) msymbol(o)) ///
yline( $mean_moe3, lcolor(red) lwidth(mediumthick)) ///
yline( $mean_prv3, lcolor(blue) lwidth(mediumthick)) ///
yline( $mean_dist3, lcolor(green) lwidth(mediumthick)) ///
yline( $mean_subdist3, lcolor(orange) lwidth(mediumthick)) ///
ylabel(, labsize(small) notick)


* Contract type

graph hbar (count), name(gh11) nodraw ///
over(DEM1q11n, sort(1) descending label(angle(forty_five) labsize(small))) blabel(bar) ///
title(`"Contract type of public officials?"', span size(*.7) linegap(1.5) margin(medium)) ///
caption("{it:Figure 1.} Frequency count of public officials by {bf: Contract type} variable", size (small) margin(large)) ///
ylabel(, labsize(small) notick) ///
bar(1, fcolor(teal%76) lcolor(mint))


*****************************
*Displaying the matrices and grpahs, and output them in an xlsx file
*****************************
matlist overview_01, border(rows) nodotz
matlist overview_02, border(rows)  nodotz
matlist occup_cat, border(rows)  nodotz
matlist edu_lvl, border(rows)  nodotz
matlist cotrct_typ, border(rows)  nodotz


*Setting up the export xlsx file  
gl font Calibri
gl color_r "055 086 035"
gl color_p "131 060 012"
gl font_size 12

**--- Set workbook for export
        putexcel set "${save_dir}/PO_summary-report.xlsx",  sheet("Document overview") replace
**--- Set the sheet for export
        putexcel sheetset, gridoff hpagebreak(1) header("text", margin(15)) footer("text", margin(15)) 
	
	
gl title "Summary Report for Public Officials data"
gl date "`c(current_date)'"
gl work_location "${save_dir}"
gl text1_1 "This report provides a set of summary tables and graphs on a selection of key variables from the Public Officials cleaned/processed data."


putexcel B4:O4 = "$title", merge vcenter left bold underline font($font, 16, darkblue) 
putexcel B6:D6 = "Date of the report:", merge vcenter left bold  font($font, $font_size, darkblue) 
putexcel E6:H6 = "$date", merge vcenter left font($font, $font_size) 
putexcel B7:D7 = "Work location:", merge vcenter left bold font($font, $font_size, darkblue) 
putexcel E7:R7 = "$work_location", merge vcenter left font($font, $font_size) 
putexcel B9:N9 = "$text1_1", merge vcenter left font($font, $font_size)

**--- Populating the 2nd sheet (PO_Overview)
        putexcel set "${save_dir}/PO_summary-report.xlsx",  sheet(PO_Overview) modify
        putexcel sheetset, gridoff hpagebreak(1) header("text", margin(15)) footer("text", margin(15)) 

gl title_id "Table (1): Overview on the Numbers of Public Officials"
putexcel B4:O4 = "$title_id", merge vcenter left bold underline font($font, 16, darkblue) 
putexcel B5 = matrix(overview_01), names 

gl title_id02 "Table (2): Closer Look Into the Numbers"
putexcel B10:O10 = "$title_id02", merge vcenter left bold underline font($font, 16, darkblue) 
putexcel B11 = matrix(overview_02), names 

mata
b = xl()
b.load_book("${save_dir}/PO_summary-report.xlsx")
b.set_sheet("PO_Overview")
b.set_column_width(2,2,33) //make title column widest
b.set_column_width(3,6,30) //make othe columns less wide

b.close_book()
end

putexcel B6:B6, vcenter right bold underline font($font, $font_size, darkblue) border(right, medium, darkblue)  overwritefmt
putexcel C5:F5, top bold font($font, $font_size, darkblue) hcenter  overwritefmt
putexcel C6:F6, font($font, $font_size, "$color_r") left border(all, dashed, darkblue)  overwritefmt

putexcel B12:B16, vcenter right bold underline font($font, $font_size, darkblue) border(right, medium, darkblue)  overwritefmt
putexcel C11:F11, top bold font($font, $font_size, darkblue) hcenter  overwritefmt
putexcel C12:F16, font($font, $font_size, "$color_r") left border(all, dashed, darkblue)  overwritefmt


graph di gh1
graph export "$save_dir/gh1.png", replace
putexcel B19= picture($save_dir/gh1.png)


graph di gh2
graph export "$save_dir/gh2.png", replace
putexcel B44= picture($save_dir/gh2.png)



**--- Populating the 3rd sheet (PO_age)
        putexcel set "${save_dir}/PO_summary-report.xlsx",  sheet(PO_age) modify
        putexcel sheetset, gridoff hpagebreak(1) header("text", margin(15)) footer("text", margin(15)) 

graph di gh3
graph export "$save_dir/gh3.png", replace
putexcel B5= picture($save_dir/gh3.png)

graph di gh4
graph export "$save_dir/gh5.png", replace
putexcel B32= picture($save_dir/gh5.png)

graph di gh5
graph export "$save_dir/gh5.png", replace
putexcel B59= picture($save_dir/gh5.png)

graph di gh6
graph export "$save_dir/gh6.png", replace
putexcel B86= picture($save_dir/gh6.png)


**--- Populating the 4th sheet (PO_Occupational-Category)
        putexcel set "${save_dir}/PO_summary-report.xlsx",  sheet(PO_Occupational-Category) modify
        putexcel sheetset, gridoff hpagebreak(1) header("text", margin(15)) footer("text", margin(15)) 
		
		
gl title_id "Table (3): Occupational category of Public Officials; by government tier (%)"
putexcel B32:O32 = "$title_id", merge vcenter left bold underline font($font, 16, darkblue) 
putexcel B33 = matrix(occup_cat), names 


mata
b = xl()
b.load_book("${save_dir}/PO_summary-report.xlsx")
b.set_sheet("PO_Occupational-Category")
b.set_column_width(2,2,33) //make title column widest
b.set_column_width(3,7,30) //make othe columns less wide

b.close_book()
end

graph di gh7
graph export "$save_dir/gh7.png", replace
putexcel B5= picture($save_dir/gh7.png)

putexcel B34:B39, vcenter right bold underline font($font, $font_size, darkblue) border(right, medium, darkblue)  overwritefmt
putexcel C33:G33, top bold font($font, $font_size, darkblue) hcenter  overwritefmt
putexcel C34:G39, font($font, $font_size, "$color_r") left border(all, dashed, darkblue)  overwritefmt

**--- Populating the 5th sheet (PO_Occupation-yrs)
        putexcel set "${save_dir}/PO_summary-report.xlsx",  sheet(PO_Occupation-yrs) modify
        putexcel sheetset, gridoff hpagebreak(1) header("text", margin(15)) footer("text", margin(15)) 

graph di gh8
graph export "$save_dir/gh8.png", replace
putexcel B5= picture($save_dir/gh8.png)


**--- Populating the 6th sheet (PO_Education)
        putexcel set "${save_dir}/PO_summary-report.xlsx",  sheet(PO_Education) modify
        putexcel sheetset, gridoff hpagebreak(1) header("text", margin(15)) footer("text", margin(15)) 
		
		
gl title_id "Table (4): Educational level of Public Officials; by government tier (%)"
putexcel B32:O32 = "$title_id", merge vcenter left bold underline font($font, 16, darkblue) 
putexcel B33 = matrix(edu_lvl), names 


mata
b = xl()
b.load_book("${save_dir}/PO_summary-report.xlsx")
b.set_sheet("PO_Education")
b.set_column_width(2,2,33) //make title column widest
b.set_column_width(3,7,30) //make othe columns less wide

b.close_book()
end

graph di gh9
graph export "$save_dir/gh9.png", replace
putexcel B5= picture($save_dir/gh9.png)

putexcel B34:B40, vcenter right bold underline font($font, $font_size, darkblue) border(right, medium, darkblue)  overwritefmt
putexcel C33:G33, top bold font($font, $font_size, darkblue) hcenter  overwritefmt
putexcel C34:G40, font($font, $font_size, "$color_r") left border(all, dashed, darkblue)  overwritefmt


**--- Populating the 7th sheet (PO_salaries)
        putexcel set "${save_dir}/PO_summary-report.xlsx",  sheet(PO_salaries) modify
        putexcel sheetset, gridoff hpagebreak(1) header("text", margin(15)) footer("text", margin(15)) 

graph di gh10
graph export "${save_dir}/gh10.png", replace
putexcel B5= picture($save_dir/gh10.png)

**--- Populating the 8th sheet (PO_contract)
        putexcel set "${save_dir}/PO_summary-report.xlsx",  sheet(PO_contract) modify
        putexcel sheetset, gridoff hpagebreak(1) header("text", margin(15)) footer("text", margin(15)) 
		
		
gl title_id "Table (5): Contract type of Public Officials; by government tier (%)"
putexcel B32:O32 = "$title_id", merge vcenter left bold underline font($font, 16, darkblue) 
putexcel B33 = matrix(cotrct_typ), names 


mata
b = xl()
b.load_book("${save_dir}/PO_summary-report.xlsx")
b.set_sheet("PO_contract")
b.set_column_width(2,2,33) //make title column widest
b.set_column_width(3,7,30) //make othe columns less wide

b.close_book()
end

graph di gh11
graph export "$save_dir/gh11.png", replace
putexcel B5= picture($save_dir/gh11.png)

putexcel B34:B38, vcenter right bold underline font($font, $font_size, darkblue) border(right, medium, darkblue)  overwritefmt
putexcel C33:G33, top bold font($font, $font_size, darkblue) hcenter  overwritefmt
putexcel C34:G38, font($font, $font_size, "$color_r") left border(all, dashed, darkblue)  overwritefmt
}
