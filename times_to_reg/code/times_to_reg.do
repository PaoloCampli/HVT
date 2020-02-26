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
use "times_to_reg/input/make_panel_times.dta", clear


drop if jahr < 1947
drop if jahr > 2015
drop if mod(jahr,2) == 0
bys gdenr (jahr): gen periode = _n
xtset gdenr periode




merge 1:1 gdenr jahr using "times_to_reg/input/clean_tax_bases.dta", keep(1 3) nogen

merge 1:1 gdenr jahr using "times_to_reg/input/new_tax_data.dta", keep(1 3) nogen



/*
* Smoothed times
foreach var in time_to_40 time_to_80 {
	gen smooth_`var' = (`var' + L.`var')/2
}

rename (smooth_time_to_40 smooth_time_to_80) (tt40_sm tt80_sm)
label var tt40_sm "2 years m.a. time_to_40"
label var tt80_sm "2 years m.a. time_to_80"


order time_to_40 time_to_80 tt40_sm tt80_sm, a(jahr)
*/


* from tt40_sumstat
*{
foreach var of varlist time_to_40-time_to_80 {
	gen log_`var' = log(`var')
}

order log_time_to_40 log_time_to_80, a(time_to_80)


foreach var of varlist time_to_40-log_time_to_80 {
	bysort gdenr: gen `var'_red = - D.`var'
}


rename 	(time_to_40_red time_to_80_red log_time_to_40_red log_time_to_80_red) ///
		(tt40_red tt80_red log_tt40_red log_tt80_red)

order tt40_red tt80_red log_tt40_red log_tt80_red, a(log_time_to_80)



foreach v of varlist tt40_red-log_tt80_red {
	gen top01_`v' = 0
	gen top05_`v' = 0
	gen top10_`v' = 0
	gen top25_`v' = 0
	qui: sum `v' if jahr > 1955 & agglo == 0, d
	replace top01_`v' = inrange(`v', r(p99), r(max)+1)
	replace top05_`v' = inrange(`v', r(p95), r(max)+1)
	replace top10_`v' = inrange(`v', r(p90), r(max)+1)
	replace top25_`v' = inrange(`v', r(p75), r(max)+1)
}





* The 2/3 prefactor obtains normalized var after all even years dropped
foreach v of varlist top01_tt40_red-top25_tt80_red {
	gen smooth3_`v' = 2/3*(F.`v' + `v' + L.`v')
}
foreach v of varlist top01_tt40_red-top25_tt80_red {
	gen smooth2_`v' = (F.`v' + `v')
}


foreach v of varlist top01_tt40_red-top25_tt80_red {
	bys gdenr: egen in_`v' = total(`v')

}
foreach v of varlist top01_tt40_red-top25_tt80_red {
	bys gdenr: gen sum_`v' = sum(`v')

}
*}



*****************
** Lags and Leads

* gen lags x_{t-k}
foreach type of varlist time_to_40-time_to_80 {
forvalues t = 1/20 {
gen l`t'_`type' = l`t'.`type'
replace l`t'_`type' = 0 if l`t'_`type' == .
}
}

* gen leads x_{t+k}
foreach type of varlist time_to_40-time_to_80 {
forvalues t = 1/20 {
gen f`t'_`type' = f`t'.`type'
replace f`t'_`type' = 0 if f`t'_`type' == .
}
}

*gen log of times
foreach var of varlist time_to_40-time_to_80 {
qui: g ln_`var' = ln(`var')
}

* gen log of lags
foreach type of varlist time_to_40-time_to_80 {
forvalues t = 1/20 {
qui: g ln_l`t'_`type' = ln(l`t'_`type')
}
}

* gen log of leads
foreach type of varlist time_to_40-time_to_80 {
forvalues t = 1/20 {
qui: g ln_f`t'_`type' = ln(f`t'_`type')
}
}


* gen x_{t-k} - x_t
foreach type of varlist time_to_40-time_to_80 {
forvalues t = 1/20 {
gen d`t'_`type' = l`t'_`type' - `type'
replace d`t'_`type' = 0 if d`t'_`type' == .
}
}



* gen log(x_{t-k}) - log(x_t)
foreach type of varlist time_to_40-time_to_80 {
forvalues t = 1/20 {
gen d_ln_`t'_`type' = ln_l`t'_`type' - ln_`type'
replace d_ln_`t'_`type' = 0 if d_ln_`t'_`type' == .
}
}

* gen log(x_{t+k}) - log(x_t)
foreach type of varlist time_to_40-time_to_80 {
forvalues t = 1/20 {
gen d_ln_f`t'_`type' = ln_f`t'_`type' - ln_`type'
replace d_ln_f`t'_`type' = 0 if d_ln_f`t'_`type' == .
}
}




foreach tax of varlist tr_v0k_p50-tr_v0k_p99 {
	gen log_`tax' = log(`tax')
}
rename (log_tr_v0k_p50-log_tr_v0k_p99) (log_tax50 log_tax75 log_tax90 log_tax95 log_tax99)
rename (tr_v0k_p50 tr_v0k_p75 tr_v0k_p90 tr_v0k_p95 tr_v0k_p99) (tax50 tax75 tax90 tax95 tax99)


gen obs = 	log_tax90 != . & ln_stpf_norm_under_p50 != . & ln_stpf_norm_p50_p75 != . ///
			& ln_stpf_norm_p75_p90 != . & ln_stpf_norm_p90 != .

order 	gdenr jahr time_to_40 time_to_80 gdename bezname kanton zugang_p_10  ///
		in_zugang_p_10 ln_stpf_norm_p90 log_tax90




save "times_to_reg/output/times_to_reg.dta", replace




* ============================================
/*
asdf

cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/"

use "make_panel_times/output/make_panel_times_2010.dta", clear

xtset gdenr jahr

**********************************************************
* Transform lags to compute long-term effects as in DMcK *
**********************************************************
sort gdenr jahr
/* data for long-term effect as in Davidson and MacKinnon */
/* replace missing values due to lags by 0 */
/*
foreach t of numlist 1/20{
g L`t'_rcma = L`t'.rcma
replace L`t'_rcma = 0 if L`t'_rcma == .
g l`t'_rcma = L`t'_rcma-rcma //x_t - x_t-j
drop L`t'_rcma
}
*/


cap noisily{
***** Two income classes b90-t10 *****
*sort gdenr periode
gen stpf_norm_under_p90 = stpf_norm_under_p50 + stpf_norm_p50_p75 + stpf_norm_p75_p90
gen ln_stpf_norm_under_p90 = log(stpf_norm_under_p90)

***** Two income classes b75-t25 *****
*sort gdenr periode
gen stpf_norm_under_p75 = 	stpf_norm_under_p50 + stpf_norm_p50_p75
gen stpf_norm_p75 		= 	stpf_norm_p75_p90 + stpf_norm_p90

gen ln_stpf_norm_under_p75 = log(stpf_norm_under_p75)
gen ln_stpf_norm_p75 	   = log(stpf_norm_p75)

***** Two income classes b50-t50 *****
*sort gdenr periode
gen stpf_norm_p50 		= 	stpf_norm_p50_p75 + stpf_norm_p75_p90 + stpf_norm_p90
gen ln_stpf_norm_p50 	   = log(stpf_norm_p50)
}


* gen lags x_{t-k}
foreach type of varlist time_to_20-time_to_80 {
forvalues t = 1/10 {
gen l`t'_`type' = l`t'.`type'
replace l`t'_`type' = 0 if l`t'_`type' == .
}
}

* gen leads x_{t+k}
foreach type of varlist time_to_20-time_to_80 {
forvalues t = 1/10 {
gen f`t'_`type' = f`t'.`type'
replace f`t'_`type' = 0 if f`t'_`type' == .
}
}

*gen log of times
foreach var of varlist time_to_20-time_to_80 {
qui: g ln_`var' = ln(`var')
}

* gen log of lags
foreach type of varlist time_to_20-time_to_80 {
forvalues t = 1/10 {
qui: g ln_l`t'_`type' = ln(l`t'_`type')
}
}

* gen log of leads
foreach type of varlist time_to_20-time_to_80 {
forvalues t = 1/10 {
qui: g ln_f`t'_`type' = ln(f`t'_`type')
}
}


* gen x_{t-k} - x_t
foreach type of varlist time_to_20-time_to_80 {
forvalues t = 1/10 {
gen d`t'_`type' = l`t'_`type' - `type'
replace d`t'_`type' = 0 if d`t'_`type' == .
}
}

* gen log(x_{t-k}) - log(x_t)
foreach type of varlist time_to_20-time_to_80 {
forvalues t = 1/10 {
gen d_ln_`t'_`type' = ln_l`t'_`type' - ln_`type'
replace d_ln_`t'_`type' = 0 if d_ln_`t'_`type' == .
}
}


*=========================
/*
* Modify variables to avoid log(0):
* mlags
forvalues t = 1/10 {
gen ml`t'_rcma = l`t'_rcma
replace ml`t'_rcma = 0.1 if ml`t'_rcma < 0.1
}

* logs of mlags
foreach var of varlist ml1_rcma-ml10_rcma {
qui: g ln_`var' = ln(`var')
}

* diff of mlogs:
forvalues t = 1/10 {
gen d_mln_`t'_rcma = ln_ml`t'_rcma - ln_rcma
replace d_ln_`t'_rcma = 0 if d_ln_`t'_rcma == .
}
*/

merge 1:1 gdenr jahr using "make_panel_rcma/input/clean_tax_bases.dta"
keep if _merge == 3
drop _merge

merge 1:1 gdenr jahr using "new_tax_data/input/new_tax_data.dta"

foreach tax of varlist tr_v0k_p50-tr_v0k_p99 {
	gen log_`tax' = log(`tax')
}
rename (log_tr_v0k_p50-log_tr_v0k_p99) (log_tax50 log_tax75 log_tax90 log_tax95 log_tax99)


* event study interpretation depends on us using a municip fixed effect

keep if _merge == 3
drop _merge

xtset gdenr periode

sort gdenr jahr


save "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/times_to_reg/output/times_to_reg_2010.dta", replace
