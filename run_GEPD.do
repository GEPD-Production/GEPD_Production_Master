*==============================================================================*
*! GEPD Production (GEPD) - PUBLIC VERSION
*! Project information at: https://www.educationpolicydashboard.org/
*! GEPD Team, World Bank Group [educationdashboard@worldbank.org]

*! MASTER RUN: Executes all tasks sequentially
*==============================================================================*

* Check that project profile was loaded, otherwise stops code
cap assert ${GEPD_profile_is_loaded} == 1
if _rc {
  noi disp as error "Please execute the profile initialization do in the root of this project and try again."
  exit 601
}

*-------------------------------------------------------------------------------
* Set some parameters for the project
*-------------------------------------------------------------------------------
do "${clone}/GEPD_parameters.do"


*-------------------------------------------------------------------------------
* Run all tasks in this project
*-------------------------------------------------------------------------------
* TASK: calculates GEPD School Indicators by combining multiple data sources
do "${clone}/02_programs/School/Stata/01_school_run.do"

* TASK: calculates GEPD Public Officials Indicators by combining multiple data sources
do "${clone}/02_programs/Public_Officials/Stata/01_public_officials_run.do"
*-------------------------------------------------------------------------------
