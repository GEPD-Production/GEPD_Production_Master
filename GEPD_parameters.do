*-------------------------------------------------------------------------------
* Please configure the following parameters before executing this task
*-------------------------------------------------------------------------------

* Set a number of key parameters for the GEPD country implementation
global master_seed  17893   // Ensures reproducibility

global country "NGA"
global country_name  "Nigeria - Edo State"
global year  "2023"
global strata lga  urban_rural // Strata for sampling

* Execution parameters
global weights_file_name "GEPD_Edo_weights_2023-06-20" // Name of the file with the sampling
global school_code_name "ubecschoolcode" // Name of the school code variable in the weights file
global other_info senatorialdistrict classification schooltype // other info needed in sampling frame
*-------------------------------------------------------------------------------
