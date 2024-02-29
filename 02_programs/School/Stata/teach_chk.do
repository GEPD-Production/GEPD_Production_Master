* Comment_AR: Setting up this file to plug in TEACH code in the revamped WF. 


********************************************************************************

*Balcohistan:

* use "C:\Users\wb549384\WBG\HEDGE Files - GEPD-Confidential\General\Country_Data\GEPD_Production-Balochistan\01_GEPD_raw_data\School\Balochistan_teacher_level.dta", clear 

* Commment_AR: Adjust variable names in code for it run. 

/*
** grouping teach variables and storing them into globals 

gl low_medium_high s_0_1_2 s_0_2_2 s_0_3_2 s_a2_1 s_a2_2 s_a2_3 s_b3_1 s_b3_2 s_b3_3 s_b3_4 s_b5_1 s_b5_2 s_b6_1 ///
  s_b6_2 s_b6_3 s_c7_1 s_c7_2 s_c7_3 s_c8_1 s_c8_2 s_c8_3 s_c9_1 s_c9_2 s_c9_3
  
gl low_medium_high_na s_a1_1 s_a1_2 s_a1_3 s_a1_4a s_a1_4b s_b4_1 s_b4_2 s_b4_3  

gl yes_no s_0_1_1 s_0_2_1 s_0_3_1	

gl overall s_a1 s_a2 s_b3 s_b4 s_b5 s_b6 s_c7 s_c8 s_c9
*/


gl low_medium_high s1_0_1_2 s1_0_2_2 s1_0_3_2 s1_a2_1 s1_a2_2 s1_a2_3 s1_b3_1 s1_b3_2 s1_b3_3 s1_b3_4 s1_b5_1 s1_b5_2 s1_b6_1 s1_b6_2 s1_b6_3 s1_c7_1 s1_c7_2 s1_c7_3  s1_c8_1 s1_c8_2 s1_c8_3 s1_c9_1 s1_c9_2 s1_c9_3

  
gl low_medium_high_na s1_a1_1 s1_a1_2 s1_a1_3 s1_a1_4a s1_a1_4b s1_b4_2 s1_b4_3


gl yes_no s1_0_1_1 s1_0_2_1 s1_0_3_1

gl overall s1_a1 s1_a2 s1_b3 s1_b4 s1_b5 s1_b6 s1_c7 s1_c8 s1_c9


** Verfying that the teach vars have observations
**# Bookmark #1

foreach var in $overall $yes_no $low_medium_high $low_medium_high_na {
sum `var'
}


** encoding the string responses into numeric -- Read below to understnad how the loop works 
	/*
	a- we define value lables to be used for encoding
	b- the loop first execute a test to confirm the varibales are coded as string:
		- if it is string (rc==0), the loop will execute and encode them into factor/numerical and labled vars
		- if it is numeric(rc==7), the loop will stop executing with an error -- already encoded into factor (do nothing more).

	*/

foreach var of global overall {
capture confirm string varibale `v'
if (_rc == 7) continue 
	*these aggregate vars must be numeric -- if they are, the loop would do nothing

	destring `var', replace
		tab `var'
}



/*

* Comment_AR: This part of the code is breaking: typemismatch

*  gl low_medium_high s1_0_1_2 s1_0_2_2 s1_0_3_2 s1_a2_1 s1_a2_2 s1_a2_3 s1_b3_1 s1_b3_2 s1_b3_3 s1_b3_4 s1_b5_1 s1_b5_2 s1_b6_1 s1_b6_2 s1_b6_3 s1_c7_1 s1_c7_2 s1_c7_3  s1_c8_1 s1_c8_2 s1_c8_3 s1_c9_1 s1_c9_2 s1_c9_3
 
 
label define low_medium_high_lbl 1 "NA" 2 "L" 3 "M" 4 "H"
foreach var of global low_medium_high_ar {
capture confirm string varibale `v'
if (_rc == 7) continue 
	tab `var', m
	
	replace `var'= upper(`var')							  //Making all upper
	replace `var'= subinstr(`var', " ", "", .)			  //Trimming spaces
	replace `var'= substr(`var' , 1, 1) if `var' !="NA"	  //for L,M,H; extract only first letters

	replace `var' ="1" if (`var'=="NA" | `var'=="")
	replace `var' ="2" if `var'=="L"
	replace `var' ="3" if `var'=="M"
	replace `var' ="4" if `var'=="H"

	destring `var', replace
		label val `var' low_medium_high_lbl
		
		tab `var'
}



foreach var of global low_medium_high_na {
capture confirm string varibale `v'
if (_rc == 7) continue 
	tab `var', m
	
	replace `var'= upper(`var')							  //Making all upper
	replace `var'= subinstr(`var', " ", "", .)			  //Trimming spaces
	replace `var'= substr(`var' , 1, 1) if `var' !="NA"	  //for L,M,H; we extract only first letters

	replace `var' ="1" if (`var'=="NA" | `var'=="")
	replace `var' ="2" if `var'=="L"
	replace `var' ="3" if `var'=="M"
	replace `var' ="4" if `var'=="H"

	destring `var', replace
		label val `var' low_medium_high_lbl
		
		tab `var'
}





label define yes_no_lbl 0 "N" 1 "Y"
foreach var of global yes_no {
capture confirm string varibale `v'
if (_rc == 7) continue 
	tab `var', m
	
	replace `var'= upper(`var')								//Making all upper
	replace `var'= subinstr(`var', " ", "", .)				//Trimming spaces
	replace `var'= substr(`var' , 1, 1) if `var' !="NA"	    //for Yes, No; we extract only first letters

	replace `var' =""  if `var'=="NA"
	replace `var' ="0" if `var'=="N"
	replace `var' ="1" if `var'=="Y"

	destring `var', replace
		label val `var' yes_no_lbl
		
		tab `var'
}

*/

** create sub-indicators from TEACH and calculating Teach score

*  a- first, create an average score var of the sub-componenets  
*  b- second, we creat an indicator varibale "counter", to know on how many of the sub componenets the
*		teacher scored above 3. -- these varibales will be used to calculate the proficiency scores. 

egen classroom_culture = rowmean(s1_a1 s1_a2)
	foreach var of varlist s1_a1 s1_a2 {
	
	gen     `var'_pro =.
	replace `var'_pro =1 if (`var' >=3 & `var'<=5)
	replace `var'_pro =0 if (`var' <3)
	
		tab `var'_pro
		}
		egen cc_counter= rowtotal(s1_a1_pro s1_a2_pro), m
			tab cc_counter
	
	
	
egen instruction = rowmean(s1_b3 s1_b4 s1_b5 s1_b6)
	foreach var of varlist s1_b3 s1_b4 s1_b5 s1_b6 {
	
	gen     `var'_pro =.
	replace `var'_pro =1 if (`var' >=3 & `var'<=5)
	replace `var'_pro =0 if (`var' <3)
	
		tab `var'_pro
		}
		egen i_counter= rowtotal(s1_b3_pro s1_b4_pro s1_b5_pro s1_b6_pro), m
			tab i_counter

egen socio_emotional_skills = rowmean(s1_c7 s1_c8 s1_c9)
	foreach var of varlist s1_c7 s1_c8 s1_c9 {
	
	gen     `var'_pro =.
	replace `var'_pro =1 if (`var' >=3 & `var'<=5)
	replace `var'_pro =0 if (`var' <3)
	
		tab `var'_pro
		}
		egen se_counter= rowtotal(s1_c7_pro s1_c8_pro s1_c9_pro), m
			tab se_counter

			
			
egen teach_score=rowmean(classroom_culture instruction socio_emotional_skills)
	foreach var of varlist classroom_culture instruction socio_emotional_skills {
	
	gen     `var'_pro =.
	replace `var'_pro =1 if (`var' >=3 & `var'<=5)
	replace `var'_pro =0 if (`var' <3)
	
		tab `var'_pro
		}
		egen tch_counter= rowtotal(classroom_culture_pro instruction_pro socio_emotional_skills_pro), m
			tab tch_counter
		

** estimate teach proficiency: 
*			(100% if all teach score components>=3;) 
*					teacher scoring 3 or more on each of the subcomponents
*			(50% if at least one teach score compenents >=3;) if a teacher is proficient on 
*					at least one of the components and the overall teach_score is <3. 
*			(0% if all teach score components <3;) 
*					teacher scoring below 3 on all of the subcomponents



*-- First component proficiency (classroom culture)
gen classroom_culture_prof=.
	replace classroom_culture_prof=1*100    if (classroom_culture >=3 & classroom_culture<=5)
	replace classroom_culture_prof=0	    if (classroom_culture <3)
	replace classroom_culture_prof=0.5*100  if cc_counter==1

*-- Second component proficiency  (instruction)
gen instruction_prof=.
	replace instruction_prof=1*100  	  if (instruction >=3 & instruction<=5)
	replace instruction_prof=0	     	  if (instruction <3)
	replace instruction_prof=0.5*100      if (i_counter==2 | i_counter==3)

*-- Thired component proficiency (socio-emotional)
gen socio_emotional_skills_prof=.
	replace socio_emotional_skills_prof=1*100  	if (socio_emotional_skills >=3 & socio_emotional_skills<=5)
	replace socio_emotional_skills_prof=0	   	if (socio_emotional_skills <3)
	replace socio_emotional_skills_prof=0.5*100 if se_counter==2

*--Overall teach proficiency
gen teach_prof=. 
	replace teach_prof=1*100    if (teach_score >=3 & teach_score <=5)
	replace teach_prof=0	    if teach_score <3
	replace teach_prof=0.5*100  if tch_counter==2

	

drop s1_a1_pro s1_a2_pro s1_b3_pro s1_b4_pro s1_b5_pro s1_b6_pro ///
s1_c7_pro s1_c8_pro s1_c9_pro classroom_culture_pro instruction_pro ///
socio_emotional_skills_pro cc_counter i_counter se_counter tch_counter

********************************************************************************
