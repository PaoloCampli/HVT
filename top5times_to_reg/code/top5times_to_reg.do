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
use "../input/make_panel_top5.dta", clear


drop if jahr < 1947
drop if jahr > 2015
drop if mod(jahr,2) == 0
bys gdenr (jahr): gen periode = _n
sort gdenr periode




merge m:1 gdenr jahr using "../input/clean_tax_bases.dta", keep(1 3) nogen

merge 1:1 gdenr jahr using "../input/new_tax_data.dta", keep(1 3) nogen



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
sort gdenr periode
xtset gdenr periode


* from tt40_sumstat
*{
foreach var of varlist w_tttop5 {
	gen log_`var' = log(`var')
}

order log_w_tttop5, a(w_tttop5)


foreach var of varlist w_tttop5-log_w_tttop5 {
	bysort gdenr: gen `var'_red = - D.`var'
}


order w_tttop5_red log_w_tttop5_red, a(log_w_tttop5)



foreach v of varlist w_tttop5_red-log_w_tttop5_red {
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

/*
* The 2/3 prefactor obtains normalized var after all even years dropped
foreach v of varlist top01_tt40_red-top25_tt80_red {
	gen smooth3_`v' = 2/3*(F.`v' + `v' + L.`v')
}
foreach v of varlist top01_tt40_red-top25_tt80_red {
	gen smooth2_`v' = (F.`v' + `v')
}
*/


foreach v of varlist top01_w_tttop5_red-top25_log_w_tttop5_red {
	bys gdenr: egen in_`v' = total(`v')

}
foreach v of varlist top01_w_tttop5_red-top25_log_w_tttop5_red {
	bys gdenr: gen sum_`v' = sum(`v')

}
*}



*****************
** Lags and Leads

* gen lags x_{t-k}
foreach type of varlist w_tttop5 {
forvalues t = 1/20 {
gen l`t'_`type' = l`t'.`type'
replace l`t'_`type' = 0 if l`t'_`type' == .
}
}

* gen leads x_{t+k}
foreach type of varlist w_tttop5 {
forvalues t = 1/20 {
gen f`t'_`type' = f`t'.`type'
replace f`t'_`type' = 0 if f`t'_`type' == .
}
}

*gen log of times
foreach var of varlist w_tttop5 {
qui: g ln_`var' = ln(`var')
}

* gen log of lags
foreach type of varlist w_tttop5 {
forvalues t = 1/20 {
qui: g ln_l`t'_`type' = ln(l`t'_`type')
}
}

* gen log of leads
foreach type of varlist w_tttop5 {
forvalues t = 1/20 {
qui: g ln_f`t'_`type' = ln(f`t'_`type')
}
}


* gen x_{t-k} - x_t
foreach type of varlist w_tttop5 {
forvalues t = 1/20 {
gen d`t'_`type' = l`t'_`type' - `type'
replace d`t'_`type' = 0 if d`t'_`type' == .
}
}



* gen log(x_{t-k}) - log(x_t)
foreach type of varlist w_tttop5 {
forvalues t = 1/20 {
gen d_ln_`t'_`type' = ln_l`t'_`type' - ln_`type'
replace d_ln_`t'_`type' = 0 if d_ln_`t'_`type' == .
}
}

* gen log(x_{t+k}) - log(x_t)
foreach type of varlist w_tttop5 {
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

order 	gdenr jahr w_tttop5 gdename bezname kanton zugang_p_10  ///
		in_zugang_p_10 ln_stpf_norm_p90 log_tax90




save "../output/top5times_to_reg.dta", replace
