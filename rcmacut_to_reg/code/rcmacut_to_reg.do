* 29/1/2019
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
use "../input/make_panel_rcmacut.dta", clear


drop if jahr < 1947
drop if jahr > 2015
drop if mod(jahr,2) == 0
bys gdenr (jahr): gen periode = _n
xtset gdenr periode



merge 1:1 gdenr jahr using "../input/clean_tax_bases.dta", keep(1 3) nogen

merge 1:1 gdenr jahr using "../input/new_tax_data.dta", keep(1 3) nogen

xtset gdenr periode


gen log_rcma = log(rcma)
order log_rcma, a(rcma)


foreach var of varlist rcma-log_rcma {
	bysort gdenr: gen `var'_inc = D.`var'
}
order rcma_inc log_rcma_inc, a(log_rcma)


foreach v of varlist rcma_inc-log_rcma_inc {
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



foreach v of varlist top01_rcma_inc-top25_log_rcma_inc {
	bys gdenr: egen in_`v' = total(`v')

}
foreach v of varlist top01_rcma_inc-top25_log_rcma_inc {
	bys gdenr: gen sum_`v' = sum(`v')

}


* gen lags x_{t-k}
forvalues t = 1/20 {
gen l`t'_rcma = l`t'.rcma
replace l`t'_rcma = 0 if l`t'_rcma == .
}

* gen leads x_{t+k}
forvalues t = 1/20 {
gen f`t'_rcma = f`t'.rcma
replace f`t'_rcma = 0 if f`t'_rcma == .
}

* gen log of rcma, leads and lags
foreach var of varlist rcma l1_rcma-l20_rcma f1_rcma-f20_rcma {
qui: g ln_`var' = ln(`var')
}

* gen x_{t-k} - x_t
forvalues t = 1/20 {
gen d`t'_rcma = l`t'_rcma - rcma
replace d`t'_rcma = 0 if d`t'_rcma == .
}

* gen log(x_{t-k}) - log(x_t)
forvalues t = 1/20 {
gen d_ln_`t'_rcma = ln_l`t'_rcma - ln_rcma
replace d_ln_`t'_rcma = 0 if d_ln_`t'_rcma == .
}


*=========================

* Modify variables to avoid log(0):
* mlags
forvalues t = 1/20 {
gen ml`t'_rcma = l`t'_rcma
replace ml`t'_rcma = 0.1 if ml`t'_rcma < 0.1
}

* logs of mlags
foreach var of varlist ml1_rcma-ml20_rcma {
qui: g ln_`var' = ln(`var')
}

* diff of mlogs:
forvalues t = 1/20 {
gen d_mln_`t'_rcma = ln_ml`t'_rcma - ln_rcma
replace d_ln_`t'_rcma = 0 if d_ln_`t'_rcma == .
}




foreach tax of varlist tr_v0k_p50-tr_v0k_p99 {
	gen log_`tax' = log(`tax')
}
rename (log_tr_v0k_p50-log_tr_v0k_p99) (log_tax50 log_tax75 log_tax90 log_tax95 log_tax99)



xtset gdenr periode
sort gdenr jahr

save "../output/rcmacut_to_reg.dta", replace
