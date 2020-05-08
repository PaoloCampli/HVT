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


local ln_time40 	"ln_time_to_40 		d_ln_1_time_to_40-d_ln_20_time_to_40"
local time40 		"time_to_40 		d1_time_to_40-d20_time_to_40"

local ln_time80 	"ln_time_to_80 		d_ln_1_time_to_80-d_ln_20_time_to_80"
local time80 		"time_to_80 		d1_time_to_80-d20_time_to_80"

local log_pop_vars 	"ln_stpf_norm_under_p50 ln_stpf_norm_p50_p75 ln_stpf_norm_p75_p90 ln_stpf_norm_p90"
local pop_vars 		"stpf_norm_under_p50 stpf_norm_p50_p75 stpf_norm_p75_p90 stpf_norm_p90"


local no_agglo		"zentren == 0 & agglomeration == 0"
local dist_bands 	"in_zugang_p_5 in_zugang_p_10 in_zugang_p_15 in_zugang_p_20 in_zugang_p_30 1"

local std_sample	"zentren == 0 & agglomeration == 0  & in_zugang_p_30 ==1"




*** std_sample
foreach var in `log_pop_vars' log_tax90 {

	if `var' == log_tax90 			local fe_tax "i.jahr##i.kannr"
	reghdfe `var' 	`ln_time40'		if `std_sample' ///
	, a(gdenr##c.jahr jahr `fe_tax') cluster(gdenr)
	estimates store reg_`var'

	}
	esttab reg_* using "../output/ind_reg_std_sample_tt40.tex" ///
	, keep(ln_time_to_40) nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore



*** excluding municip at highway entry (where firms would prob be located)
foreach var in `log_pop_vars' {
	reghdfe `var' 		`ln_time40'		if `std_sample' & in_zugang_p_0 == 0 ///
	, a(gdenr##c.jahr jahr) cluster(gdenr)
	estimates store reg_`var'
	}
	reghdfe log_tax90 	`ln_time40'		if `std_sample' & in_zugang_p_0 == 0 ///
	, a(gdenr##c.jahr i.jahr##i.kannr) cluster(gdenr)
	estimates store reg_tax

	esttab reg_* using "../output/ind_reg_std_sample_noaccess_tt40.tex" ///
	, keep(ln_time_to_40) nonumbers p mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore


*** firms
merge 1:1 gdenr jahr using "../../firms_count/output/firms_count.dta"
reghdfe nb_firms	`ln_time40'		if `std_sample', a(gdenr##c.jahr jahr) cluster(gdenr)
	estimates store reg_firms
	esttab reg_firms using "../output/ind_reg_noagglo_firms.tex", keep(ln_time_to_40) ///
		nonumbers p mtitles("Number of firms") replace
	cap estfe . reg_*, restore


	reghdfe nb_firms	`ln_time40'	, a(gdenr##c.jahr jahr) cluster(gdenr)
		estimates store reg_firms
		esttab reg_firms using "../output/ind_reg_std_sample_firms_tt40.tex", keep(ln_time_to_40) ///
			nonumbers p mtitles("Number of firms") replace
		cap estfe . reg_*, restore



*Logs agglo
foreach dist in `dist_bands' {
	foreach var in `log_pop_vars' log_tax90 {
		if `var' == ln_stpf_norm_under_p50	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p50_p75	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p75_p90	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p90	 	 local fe_pop "jahr"
		if `var' == log_tax90 				 local fe_tax "i.jahr##i.kannr"

		reghdfe `var' 	`ln_time40'		if zentren == 0 & `dist'==1, a(gdenr##c.jahr `fe_pop' `fe_tax') cluster(gdenr)
	estimates store reg_`var'
	}
	esttab reg_* using "../output/ind_reg_agglo_`dist'.tex", keep(ln_time_to_40) ///
		nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore
}


eststo clear


*No logs agglo
foreach dist in `dist_bands' {
	foreach var in `pop_vars' tr_v0k_p90 {
		if `var' == stpf_norm_under_p50	 local fe_pop "jahr"
		if `var' == stpf_norm_p50_p75	 local fe_pop "jahr"
		if `var' == stpf_norm_p75_p90	 local fe_pop "jahr"
		if `var' == stpf_norm_p90	 	 local fe_pop "jahr"
		if `var' == tr_v0k_p90 			 local fe_tax "i.jahr##i.kannr"

		reghdfe `var' 	`time40'	if zentren == 0 & `dist'==1, a(gdenr##c.jahr `fe_pop' `fe_tax') cluster(gdenr)
	estimates store reg_`var'
	}
	esttab reg_* using "../output/ind_reg_agglo_nolog`dist'.tex", keep(time_to_40) ///
		nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore
}


