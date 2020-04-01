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


use "../input/times_to_reg.dta"

merge 1:1 gdenr jahr using "../input/rcmacut_to_reg.dta"
keep if _merge == 3
drop _merge 

merge 1:1 gdenr jahr using "../input/top5times_to_reg.dta"
keep if _merge == 3
drop _merge 

save "../output/merge_connectivity_measures.dta", replace
