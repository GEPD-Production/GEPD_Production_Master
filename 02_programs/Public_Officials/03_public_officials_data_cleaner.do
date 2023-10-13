clear all

*Country name and year of survey
local country "PER"
local country_name  "Peru"
local year  "2019"

*Set working directory on your computer here
*gl wrk_dir "/Users/kanikaverma/Desktop/WB internship/Data anonymized/GEPD_anonymized_data/Data/`country'/`country'_`year'_GEPD/`country'_`year'_GEPD_v01_M/Data/Public_Officials/data"
*gl wrk_dir may not work
cd "/Users/kanikaverma/Desktop/WB internship/Data anonymized/GEPD_anonymized_data/Data/`country'/`country'_`year'_GEPD/`country'_`year'_GEPD_v01_M/Data/Public_Officials/data"


********************************************
* Create indicators and necessary variables
********************************************

************
*Load public officials cleaned data file
************
cap frame create public
frame change public
*Load the school data
use "${wrk_dir}/public_officials_dta_anon"


de NLG* ACM* QB* IDM* ORG*, varlist
*Cleaning some data in major variables
foreach var in `r(varlist)' {
	capture confirm numeric variable `var'
	if !_rc {
		replace `var'=. if `var'==900 & !missing(`var')
        replace `var'=. if `var'==998 & !missing(`var')
	}
}

*************************
* National Learning Goals
*************************
ds NLG*
gen nlg_length= wordcount("`r(varlist)'")
*calculate item scores
egen national_learning_goals_temp = rowtotal(NLG*)
gen national_learning_goals = national_learning_goals_temp/(nlg_length)
egen targeting=rowmean(NLG1*)
egen monitoring=rowmean(NLG2*)
egen incentives=rowmean(NLG3*)
egen community_engagement=rowmean(NLG4*)


********
* Mandates and Accountability
********
ds ACM*
gen acm_length= wordcount("`r(varlist)'")

*calculate item scores
egen mandates_accountability_temp = rowtotal(ACM*)
gen mandates_accountability=mandates_accountability_temp/(acm_length)
egen coherence=rowmean(ACM2*)
egen transparency=rowmean(ACM3*)
egen accountability=rowmean(ACM4*)


********
* Quality of Bureaucracy
********
ds QB*
gen qb_length= wordcount("`r(varlist)'")

*calculate item scores

egen quality_bureaucracy_temp=rowtotal(QB*)
gen quality_bureaucracy=quality_bureaucracy_temp/(qb_length)
egen knowledge_skills=rowmean(QB1*)
egen work_environment=rowmean(QB2*)
egen merit=rowmean(QB3*)
egen motivation_attitudes=rowmean(QB4*)


********
* Impartial Decision Making
********
ds IDM*
gen idm_length= wordcount("`r(varlist)'")

*calculate item scores

egen impartial_decision_making_temp=rowtotal(IDM*)
gen impartial_decision_making=impartial_decision_making_temp/(idm_length)
egen pol_personnel_management=rowmean(IDM1*)
egen pol_policy_making=rowmean(IDM2*)
egen pol_policy_implementation=rowmean(IDM3*)
egen employee_unions_as_facilitators=rowmean(IDM4*)

*filter out the director of HR, who isn't specifically asked about indicator questions
keep if director_hr==0

*Preserving copy of main data file with all columns
frame copy public final_public_officials
frame change public

*List of Bureaucracy indicators
*Variables region_code district_code district province location lat lon missing in main file
local keep_info hashed_position hashed_office_id govt_tier interview__id
local bureau_ind_nlg national_learning_goals targeting monitoring incentives community_engagement
local bureau_ind_acm mandates_accountability coherence transparency accountability
local bureau_ind_qb quality_bureaucracy knowledge_skills work_environment merit motivation_attitudes
local bureau_ind_idm impartial_decision_making pol_personnel_management pol_policy_making pol_policy_implementation employee_unions_as_facilitators

keep `keep_info' DEM* NLG* ACM* QB* IDM* ORG* ENUM* motivation_relative_start `bureau_ind_nlg' `bureau_ind_acm' `bureau_ind_qb' `bureau_ind_idm'

frame put *, into(public_officials_office_level)
frame change public_officials_office_level
export excel using "public_officials_office_all.xlsx", sheet("Public_officials_data") cell(A1) firstrow(variables) replace

frame change public
collapse `bureau_ind_nlg' `bureau_ind_acm' `bureau_ind_qb' `bureau_ind_idm'
export excel using "public_officials_office_varsummary.xlsx", sheet("Public_officials_results") cell(A1) firstrow(variables) replace

