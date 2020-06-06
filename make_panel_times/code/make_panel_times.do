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


*cd /Users/paolocampli/hw


use "../input/link/times_byorigin1955.dta", clear

forvalues year = 1935(2)1953{
	replace year = `year'
	tempfile times_byorigin`year'
	save `times_byorigin`year''
}


* Build panel
use "../input/link/times_byorigin1955.dta", clear


forvalues year = 1935(2)1953 {
	append using `times_byorigin`year''
}


forvalues year = 1957(2)2015 {
	append using "../input/link/times_byorigin`year'.dta"
}


rename (gdenr_o year) (gdenr jahr)
order 	gdenr jahr
sort  	gdenr jahr


**** Some data analysis
gen flag_times_year = 0
sort gdenr jahr
bys gdenr: replace flag_times_year = 1 if time_to_40[_n] > 1.01*time_to_40[_n-1]
bys gdenr: egen flag_times_issue = max(flag_times_year)

gen flag2 = 0
sort gdenr jahr
bys gdenr: replace flag2 = 1 if time_to_40[_N] > time_to_40[1]
drop if flag2 > 0
drop flag2


save "../output/make_panel_times.dta", replace
