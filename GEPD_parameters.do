*-------------------------------------------------------------------------------
* Please configure the following parameters before executing this task
*-------------------------------------------------------------------------------

* Set a number of key parameters for the GEPD country implementation
global master_seed  17893   // Ensures reproducibility

global country "BGD"
global country_name  "Bangladeshb"
global year  "2024"
global strata strata // Strata for sampling

* Execution parameters
global weights_file_name "GEPD_BGD_weights_2024-04-18.csv" // Name of the file with the sampling
global school_code_name "school_code" // Name of the school code variable in the weights file
global other_info division district upazila geographic_location // Other info needed in sampling frame
*-------------------------------------------------------------------------------

