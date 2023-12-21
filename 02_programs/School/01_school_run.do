*==============================================================================*
*! GEPD Production (GEPD) - PUBLIC VERSION
*! Project information at: https://www.educationpolicydashboard.org/
*! GEPD Team, World Bank Group [educationdashboard@worldbank.org]

*! TASK: Run all programs to clean the GEPD school data
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
* Please configure the following parameters before executing this task
*-------------------------------------------------------------------------------
* Execution parameters
global master_seed  17893   // Ensures reproducibility
global weights_file_name "GEPD_JOR_weights_2023-10-26.csv" // Name of the file with the sampling
global school_code_name "school_code" // Name of the school code variable in the weights file
gl other_info supervisory_authority school_status governorate_eng directoratecode directorate ministrydirectorate areaclassification // other info needed in sampling frame
*-------------------------------------------------------------------------------


*-------------------------------------------------------------------------------
* Subroutines for this task
*-------------------------------------------------------------------------------
* Import rawdata from .dta files and merge together into four files: school, first grade, fourth grade, teachers
do "${clone}/02_programs/School/02_school_data_merge.do"

* Clean school data
do "${clone}/02_programs/School/03_school_data_cleaner.do"

* Anonymize school data
do "${clone}/02_programs/School/04_school_data_anonymizer.do"

*-----------------------------------------------------------------------------
