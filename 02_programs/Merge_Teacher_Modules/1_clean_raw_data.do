/*******************************************************************************
Purpose: Cleaning all variables in raw data 

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

global date = c(current_date)
global username = c(username)

** File paths

* set up all globals
global base "C:\Users\Hersheena\OneDrive\Desktop\Professional\WBG_GEPD_2023\LEGO_Teacher_Paper"
global data "$base\3_input_data"
global temp "$base\4_temp_data"
global final "$base\5_output_data\1_clean_input_data"
global code "$base\1_code\1_cleaning"
global log "$base\2_log"

/*Our goal is to clean all variables in all modules before our fuzzy match*/ 
* The following countries use the same variables
*Enter the 3 letter abbreviation of the country's data you want to clean here
*For example, Tchad is TCD

global countries TCD
																//to identify countries in the global above.e.g 1 if NER and 2 is RWA
foreach cty_f in $countries {
* Datasets for PAK_ICT and PAK_KP are saved as PAK

* Now, we start cleaning our datasets
/* Step 1: Start with roster data */
use "$data/`cty'/`cty'_teacher_absence.dta", clear

* Dataset should be unique at teacher-id - school_code level
*isid teachers_id school_code													//6 obs with missing school code in Tchad
replace m2saq2=lower(m2saq2)

* Run do file with all value labels
do "$code/z_value_labels.do"
 
* Sex - Recode sex variable as 1 for female and 0 for male
recode m2saq3 2=1 1=0
tab m2saq3
* label values
label define sex 0 "Male" 1 "Female", modify
label val m2saq3 sex 

* Contract status
tab m2saq5
tab m2saq5_other

* Full time status
* Recode part time to 0
recode m2saq6 2=0
label val m2saq6 fulltime

* Destring urban rural variable and recode
cap rename rural urban_rural 
*if urban_rural is string
cap replace urban_rural ="1" if urban_rural =="Rural"
cap replace urban_rural ="0" if urban_rural =="Urban"
cap destring urban_rural, replace

* if urban_rural if numeric
cap recode urban_rural 2=0
la val urban_rural rural

* Save file
save "$final/`cty'/`cty'_teacher_absence.dta", replace
 
/* Step 2: Clean pedagogy data */
use "$data/`cty'/`cty'_teacher_pedagogy.dta", clear
count
* Data should be unique at m4saq1_number school_code level

*Gender
if `i'==3|`i'==5 {
	di "No gender variable found"
	}
else{	
	tab m7saq10
	tab m7saq10, nol
	recode m7saq10 2=1 1=0
	la val m7saq10 sex
}
* Destring urban rural variable and recode
cap rename rural urban_rural 
*if urban_rural is string
cap replace urban_rural ="1" if urban_rural =="Rural"
cap replace urban_rural ="0" if urban_rural =="Urban"
cap destring urban_rural, replace

* if urban_rural if numeric
cap recode urban_rural 2=0
la val urban_rural rural

* Label variables 
cap la var m4scq4_inpt "How many pupils are in the room?" 
cap la var m4scq4n_girls "How many of them are boys?"
cap la var m4scq5_inpt "How many total pupils have the textbook for class?"
cap la var m4scq6_inpt "How many pupils have pencil/pen?" 
cap la var m4scq7_inpt "How many pupils have an exercise book?"
cap la var m4scq11_inpt "How many pupils were not sitting on desks?"
cap la var m4scq12_inpt "How many students in class as per class list?"

* Save file
save "$final/`cty'/`cty'_teacher_pedagogy.dta", replace

/* Step 3: m3(questionnaire) data */

use "$data/`cty'/`cty'_teacher_questionnaire.dta", clear
* Teacher name is m3sb_troster and teacher id is m3sb_tnumber
* Data should be unique at m3sb_tnumber-school_code level

*Gender
	tab m7saq10
	tab m7saq10, nol
	recode m7saq10 2=1 1=0
	la val m7saq10 sex


*Age - differnt countries have different outliers
	if `cty'=="NER" {																	//NER
		* Has an outlier of 1994.
		sum m3saq6,d	
		winsor m3saq6, g( m3saq6_w) p(0.001)
		drop m3saq6
		rename m3saq6_w m3saq6
	}
	if `cty'=="JOR_2023" {																	//Jordan 2023
		* Has 3 outliers of 247,3140,4015 and 4
		sum m3saq6,d	
		winsor m3saq6, g( m3saq6_w) p(0.001)
		drop m3saq6
		rename m3saq6_w m3saq6
		
		winsor m3saq6, g( m3saq6_w) p(0.003) highonly
		drop m3saq6
		rename m3saq6_w m3saq6
	}
	if `cty'=="TCD" {																	//Tchad
		* Has 2 outliers: 1987 and 1991
		sum m3saq6,d	
		winsor m3saq6, g( m3saq6_w) h(2) highonly
		drop m3saq6
		rename m3saq6_w m3saq6
	
	}
	else {
		sum m3saq6
	}
	
* Destring urban rural variable and recode
cap rename rural urban_rural 
*if urban_rural is string
cap replace urban_rural ="1" if urban_rural =="Rural"
cap replace urban_rural ="0" if urban_rural =="Urban"
cap destring urban_rural, replace

* if urban_rural if numeric
cap recode urban_rural 2=0
la val urban_rural rural

* Save file
save "$final/`cty'/`cty'_teacher_questionnaire.dta", replace

/* Step 4: Merge in m5(assessment) data */
use "$data/`cty'/`cty'_teacher_assessment.dta", clear

* Data should be unique at m5sb_tnumber - school_code

*Gender
	tab m7saq10
	tab m7saq10, nol
	recode m7saq10 2=1 1=0
	la val m7saq10 sex

* Destring urban rural variable and recode
cap rename rural urban_rural 
*if urban_rural is string
cap replace urban_rural ="1" if urban_rural =="Rural"
cap replace urban_rural ="0" if urban_rural =="Urban"
cap destring urban_rural, replace

* if urban_rural if numeric
cap recode urban_rural 2=0
la val urban_rural rural

* Save file
save "$final/`cty'/`cty'_teacher_assessment.dta", replace

}

