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



use "../input/merge_connectivity_measures.dta", clear


local log_rcma		"ln_rcma 	d_ln_1_rcma-d_ln_10_rcma"
local rcma			"rcma 		d1_rcma-d20_rcma"


local log_pop_vars 	"ln_stpf_norm_under_p50 ln_stpf_norm_p50_p75 ln_stpf_norm_p75_p90 ln_stpf_norm_p90"
local pop_vars 		"stpf_norm_under_p50 stpf_norm_p50_p75 stpf_norm_p75_p90 stpf_norm_p90"


local std_sample	"zentren == 0 & agglomeration == 0  & in_zugang_p_30 ==1"
local dist_bands 	"in_zugang_p_5 in_zugang_p_10 in_zugang_p_15 in_zugang_p_20 in_zugang_p_30"



* std_sample
foreach var in `log_pop_vars' {
		reghdfe `var' 		`log_rcma'		if `std_sample' & in_zugang_p_30 ==1 ///
		, a(gdenr##c.jahr jahr) cluster(gdenr)
		estimates store reg_`var'
	}
		reghdfe log_tax90 	`log_rcma'		if `std_sample' & in_zugang_p_30 ==1 ///
		, a(gdenr##c.jahr i.jahr##i.kannr) cluster(gdenr)
		estimates store reg_tax

	esttab reg_* using "../output/ind_reg_std_sample_ln_rmca.tex", keep(ln_rcma) ///
		nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore





* distance_bands
foreach dist in `dist_bands' {
	foreach var in `log_pop_vars' log_tax90 {
		if `var' == ln_stpf_norm_under_p50	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p50_p75	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p75_p90	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p90	 	 local fe_pop "jahr"
		if `var' == log_tax90 				 local fe_tax "i.jahr##i.kannr"

		reghdfe `var' 	`log_rcma'		if `no_agglo' & `dist'==1 ///
		, a(gdenr##c.jahr `fe_pop' `fe_tax') cluster(gdenr)
	estimates store reg_`var'
	}
	esttab reg_* using "../output/ind_reg_std_sample_ln_rmca_`dist'.tex", keep(ln_rcma) ///
		nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore
}


eststo clear



*No logs
foreach dist in `dist_bands' {
	foreach var in `pop_vars' tr_v0k_p90 {
		if `var' == stpf_norm_under_p50	 local fe_pop "jahr"
		if `var' == stpf_norm_p50_p75	 local fe_pop "jahr"
		if `var' == stpf_norm_p75_p90	 local fe_pop "jahr"
		if `var' == stpf_norm_p90	 	 local fe_pop "jahr"
		if `var' == tr_v0k_p90 			 local fe_tax "i.jahr##i.kannr"

		reghdfe `var' 	`rcma'	if `no_agglo' & `dist'==1 ///
		, a(gdenr##c.jahr `fe_pop' `fe_tax') cluster(gdenr)
	estimates store reg_`var'
	}
	esttab reg_* using "../output/ind_reg_std_sample_rcma_`dist'.tex", keep(rcma) ///
		nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore
}


eststo clear















