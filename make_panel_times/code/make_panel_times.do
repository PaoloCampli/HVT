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


cd /Users/paolocampli/hw


use "gen_fake_times/output/times_byorigin1935.dta", clear

 
forvalues year = 1936(1)1954 {
 
	append using "gen_fake_times/output/times_byorigin`year'.dta"
 
}

 
forvalues year = 1955(1)2015 {
 
	append using "dta_to_times_fixed_sample/output/times_byorigin`year'.dta"
 
}


forvalues year = 2016(1)2020 {
 
	append using "gen_fake_times/output/times_byorigin`year'.dta"
 
}
 
rename (gdenr_o year) (gdenr jahr)
 
*merge 1:1 gdenr jahr using "clean_tax_bases/output/clean_tax_bases.dta"

*keep if _merge == 3

order gdenr jahr

sort gdenr jahr

*drop _merge


save "/Users/paolocampli/hw/make_panel_times/output/make_panel_times.dta", replace




* =====================================================
asdf




cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/"


use "gen_fake_times/output/times_byorigin1935.dta", clear

 
forvalues year = 1936(1)1954 {
 
	append using "gen_fake_times/output/times_byorigin`year'.dta"
 
}

 
forvalues year = 1955(1)2010 {
 
	append using "dta_to_times_fixed_sample/output/times_byorigin`year'_2010.dta"
 
}


forvalues year = 2011(1)2020 {
 
	append using "gen_fake_times/output/times_byorigin`year'.dta"
 
}
 
rename (gdenr_o year) (gdenr jahr)
 
merge 1:1 gdenr jahr using "make_panel_rcma/input/clean_tax_bases.dta"

*keep if _merge == 3

order gdenr jahr

sort gdenr jahr

drop _merge


save "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/make_panel_times/output/make_panel_times_2010.dta", replace
