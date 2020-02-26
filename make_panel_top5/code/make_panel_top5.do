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


* Fake backwards
*cd /Users/paolocampli/hw
use "make_panel_top5/input/link/times_top5_1955.dta", clear

forvalues year = 1935(2)1953{
	replace year = `year'
	tempfile times_top5_`year'
	save `times_top5_`year''
}




* Build panel
use "make_panel_top5/input/link/times_top5_1955.dta", clear


forvalues year = 1935(2)1953 {

	append using `times_top5_`year''
}


forvalues year = 1957(2)2015 {

	append using "make_panel_top5/input/link/times_top5_`year'.dta"
}



rename (gdenr_o year) (gdenr jahr)
order 	gdenr jahr
sort  	gdenr jahr



**** Some data analysis
gen flag_times_year = 0
sort gdenr jahr
bys gdenr: replace flag_times_year = 1 if w_tttop5[_n] > w_tttop5[_n-1]
bys gdenr: egen flag_times_issue = max(flag_times_year)

gen flag2 = 0
sort gdenr jahr
bys gdenr: replace flag2 = 1 if w_tttop5[_N] > w_tttop5[1]
drop if flag2 > 0
drop flag2



save "make_panel_top5/output/make_panel_top5.dta", replace
