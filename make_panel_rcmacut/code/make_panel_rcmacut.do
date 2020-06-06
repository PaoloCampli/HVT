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
use "../input/link/mkt_access_byorigin1955_cut.dta", clear

forvalues year = 1935(2)1953{
	replace year = `year'
	tempfile mkt_access_byorigin`year'_cut
	save `mkt_access_byorigin`year'_cut'
}




* Build panel
use "../input/link/mkt_access_byorigin1955_cut.dta", clear


forvalues year = 1935(2)1953 {

	append using `mkt_access_byorigin`year'_cut'
}


forvalues year = 1957(2)2015 {

	append using "../input/link/mkt_access_byorigin`year'_cut.dta"
}



rename (gdenr_o year) (gdenr jahr)
order 	gdenr jahr
sort  	gdenr jahr



**** Some data analysis
gen flag_rcma_year = 0
sort gdenr jahr
bys gdenr: replace flag_rcma_year = 1 if rcma[_n] < 0.99*rcma[_n-1] 
bys gdenr: replace flag_rcma_year = 0 if _n == 1
bys gdenr: egen flag_rcma_issue = max(flag_rcma_year)

gen flag2 = 0
sort gdenr jahr
bys gdenr: replace flag2 = 1 if rcma[_N] < 1.05*rcma[1]
drop if flag2 > 0
drop flag2



save "../output/make_panel_rcmacut.dta", replace
