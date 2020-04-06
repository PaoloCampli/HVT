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

use "../input/merge_connectivity_measures.dta", clear

xtset gdenr periode

* drop very few municip which only appear later
bys gdenr: egen start = min(jahr)
drop if start > 1950
drop start







*** old event definition based on hw access to check that it reduces to old design
gen event_zugang_p_10 = D.zugang_p_10

*** weighted event zugang_p_10
gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
bys gdenr: gen time_window = inrange(jahr, first_access - 2, first_access + 10)
bys gdenr: egen w_event_zugang_p_10 = total(log_w_tttop5_red*time_window)
bys gdenr: replace w_event_zugang_p_10 = w_event_zugang_p_10*event_zugang_p_10

drop access_year first_access time_window
***___________


*** event definitions top5
foreach v of varlist top05_log_w_tttop5_red top10_log_w_tttop5_red  {
	gen event_`v' = `v'
}
*** imputing missing
foreach v of varlist top05_log_w_tttop5_red top10_log_w_tttop5_red  zugang_p_10 {
	replace event_`v' = . if jahr > 2015					// no hw data post 2015
	replace event_`v' = 0 if jahr < 1955 & event_`v' == .	// no hw  at all pre 1955
}
*** weighted events top5
foreach v of varlist event_top05_log_w_tttop5_red event_top10_log_w_tttop5_red  {
	gen w_`v' = `v'*log_w_tttop5_red
}
***____________



*** event definitions rcma
foreach v of varlist top05_log_rcma_inc top10_log_rcma_inc {
	gen event_`v' = `v'
}
*** imputing missing
foreach v of varlist top05_log_rcma_inc top10_log_rcma_inc zugang_p_10 {
	replace event_`v' = . if jahr > 2015					// no hw data post 2015
	replace event_`v' = 0 if jahr < 1955 & event_`v' == .	// no hw  at all pre 1955
}
*** weighted events rcma
foreach v of varlist event_top05_log_rcma_inc event_top10_log_rcma_inc {
	gen w_`v' = `v'*log_rcma_inc
}
***____________



*** event definitions times
foreach v of varlist top05_log_tt40_red top10_log_tt40_red {
	gen event_`v' = `v'
}
*** imputing missing
foreach v of varlist top05_log_tt40_red top10_log_tt40_red zugang_p_10 {
	replace event_`v' = . if jahr > 2015					// no hw data post 2015
	replace event_`v' = 0 if jahr < 1955 & event_`v' == .	// no hw  at all pre 1955
}
*** weighted events times
foreach v of varlist event_top05_log_tt40_red event_top10_log_tt40_red {
	gen w_`v' = `v'*log_tt40_red
}
***____________





*** sample definition
local sample ""zentren == 0 & agglomeration == 0 & in_zugang_p_30 == 1""

*** dep vars for regressions
local dep_vars ""ln_stpf_norm_p90 	log_tax90""

*** events over which we loop
local events "event_zugang_p_10	event_top10_log_w_tttop5_red	event_top10_log_rcma_inc"



*** run the program
foreach event in `events' {
	do event_study_intensity_program `event' -10 10 `sample' `dep_vars'
	drop treat_year-balanced_sample 
}
