
*
* 21/1/2019
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


*cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks"

use "adjust_id/output/merge_towns_adjid_bfsplz_commuting1950clean.dta"


sort gdenr

forvalues i=1(1)5{
merge m:m gdenr using "update_gdenr/input/gemeinde_merge.dta"
drop if _merge == 2
qui: replace gdenr = gdenr_new if gdenr_new != .
drop gdenr_new _merge
sort gdenr
}

gen idO = id
order id idO

compress

save "update_gdenr/output/merge_towns_adj_update_bfsplz_commuting1950clean.dta", replace
