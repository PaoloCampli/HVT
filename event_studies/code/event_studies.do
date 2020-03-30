* Paolo Campli, USI
*--------------------------------------------------

*--------------------------------------------------
* Program Setup
*--------------------------------------------------
version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
* --------------------------------------------------

use "../input/merge_connectivity_measures.dta"

local sample "zentren == 0 & agglomeration == 0 & in_zugang_p_30 == 1"
local dep_vars "log_w_tttop5	ln_stpf_norm_p90	log_tax90"


do event_study_intensity_program zugang_p_10 -10 10 `sample' `dep_vars'
