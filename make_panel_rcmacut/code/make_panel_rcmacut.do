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
use "make_panel_rcmacut/input/link/mkt_access_byorigin1955_cut.dta", clear

forvalues year = 1935(2)1953{
	replace year = `year'
	tempfile mkt_access_byorigin`year'_cut
	save `mkt_access_byorigin`year'_cut'
}




* Build panel
use "make_panel_rcmacut/input/link/mkt_access_byorigin1955_cut.dta", clear


forvalues year = 1935(2)1953 {

	append using `mkt_access_byorigin`year'_cut'
}


forvalues year = 1957(2)2015 {

	append using "make_panel_rcmacut/input/link/mkt_access_byorigin`year'_cut.dta"
}



rename (gdenr_o year) (gdenr jahr)
order 	gdenr jahr
sort  	gdenr jahr


*merge 1:1 gdenr jahr using make_panel_rcma/input/clean_tax_bases.dta
*keep if _merge == 3
*drop _merge


save "make_panel_rcmacut/output/make_panel_rcmacut.dta", replace
