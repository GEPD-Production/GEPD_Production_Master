*==============================================================================*
*! GEPD Production (GEPD) - PUBLIC VERSION
*! Project information at: https://www.educationpolicydashboard.org/
*! GEPD Team, World Bank Group [educationdashboard@worldbank.org]

*! TASK: Run all programs to clean the GEPD public officials data
*==============================================================================*

*-------------------------------------------------------------------------------
* Setup for this task
*-------------------------------------------------------------------------------
* Check that project profile was loaded, otherwise stops code
cap assert ${GEPD_profile_is_loaded} == 1
if _rc != 0 {
  noi disp as error "Please execute the profile_GEPD initialization do in the root of this project and try again."
  exit
}



*-------------------------------------------------------------------------------
* Subroutines for this task
*-------------------------------------------------------------------------------
* Import rawdata from .dta files and clean
do "${clone}/02_programs/Public_Officials/Stata/02_public_officials_data_cleaner.do"

* Anonymize  data
* do "${clone}/02_programs/Public_Officials/Stata/03_public_officials_data_anonymizer.do"

*-----------------------------------------------------------------------------
