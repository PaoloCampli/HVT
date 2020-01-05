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

cd /Users/paolocampli/hw

use dta_to_times_fixed_sample/output/times_byorigin1955.dta, clear


forvalues year = 1935/1954{
replace year = `year'
save "gen_fake_times/output/times_byorigin`year'.dta", replace
}


use dta_to_times_fixed_sample/output/times_byorigin2015.dta, clear


forvalues year = 2016/2020{
replace year = `year'
save "gen_fake_times/output/times_byorigin`year'.dta", replace
}
