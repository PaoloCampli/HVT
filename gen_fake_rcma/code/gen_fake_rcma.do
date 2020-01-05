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



use "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/gen_fake_rcma/input/mkt_access_byorigin1955.dta", clear
 
forvalues year = 1935/1954{
replace year = `year'
save "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/gen_fake_rcma/output/mkt_access_byorigin`year'.dta", replace
}


use "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/gen_fake_rcma/input/mkt_access_byorigin2010.dta", clear


forvalues year = 2011/2020{
replace year = `year'
save "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/gen_fake_rcma/output/mkt_access_byorigin`year'.dta", replace
}
