*-------------------------------------------------------------------------------
* Please configure the following parameters before executing this task
*-------------------------------------------------------------------------------

* Set a number of key parameters for the GEPD country implementation
global master_seed  17893   // Ensures reproducibility

global country "PAK"
global country_name  "Pakistan - Punjab"
global year  "2023"
global strata strata // Strata for sampling

* Execution parameters
global weights_file_name "GEPD_Punjab_weights_200_2023-10-31.csv" // Name of the file with the sampling
global school_code_name "csl_emis_code" // Name of the school code variable in the weights file
global csl_tehsil csl_district csl_area saber_sampled // Other info needed in sampling frame
*-------------------------------------------------------------------------------

