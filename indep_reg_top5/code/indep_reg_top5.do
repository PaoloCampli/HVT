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


local ln_w_tttop5 	"ln_w_tttop5 		d_ln_1_w_tttop5 - d_ln_10_w_tttop5"
local w_tttop5 		"w_tttop5 			d1_w_tttop5 - d10_w_tttop5"

local log_pop_vars 	"ln_stpf_norm_under_p50 ln_stpf_norm_p50_p75 ln_stpf_norm_p75_p90 ln_stpf_norm_p90"
local pop_vars 		"stpf_norm_under_p50 stpf_norm_p50_p75 stpf_norm_p75_p90 stpf_norm_p90"


local no_agglo		"zentren == 0 & agglomeration == 0 & in_zugang_p_30 ==1"
local dist_bands 	"in_zugang_p_5 in_zugang_p_10 in_zugang_p_15 in_zugang_p_20 in_zugang_p_30 1"

local std_sample	"zentren == 0 & agglomeration == 0 "



* 4 income classes log
reghdfe ln_stpf_norm_under_p50 	`ln_w_tttop5' 	if `std_sample', a(gdenr##c.jahr  jahr) cl(gdenr)
estimates store reg_b50

reghdfe ln_stpf_norm_p50_p75 	`ln_w_tttop5' 	if `std_sample', a(gdenr##c.jahr  jahr) cl(gdenr)
estimates store reg_50_75

reghdfe ln_stpf_norm_p75_p90 	`ln_w_tttop5' 	if `std_sample', a(gdenr##c.jahr  jahr) cl(gdenr)
estimates store reg_75_90

reghdfe ln_stpf_norm_p90 		`ln_w_tttop5' 	if `std_sample', a(gdenr##c.jahr  jahr) cl(gdenr)
estimates store reg_t10

reghdfe log_tax90 				`ln_w_tttop5' 	if `std_sample', a(gdenr##c.jahr i.jahr##i.kannr jahr) 	cl(gdenr)
estimates store reg_tax

estfe . reg_*
return list
esttab reg_* using "../output/ind_reg_std_sample_ln_w_tttop5.tex" ///
	, se keep(ln_w_tttop5) nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
estfe . reg_*, restore





local ln_w_tttop5 	"ln_w_tttop5 		d_ln_1_w_tttop5 - d_ln_10_w_tttop5"
local std_sample	"zentren == 0 & agglomeration == 0 "
local years			"jahr >= 1959 & jahr <= 1981"

gen stpf_norm_under_p75 = stpf_norm_under_p50 + stpf_norm_p50_p75
gen ln_stpf_norm_under_p75 = log(stpf_norm_under_p75)

* 2 inc classes 1960-1980
reghdfe ln_stpf_norm_under_p75	`ln_w_tttop5' 	if `std_sample' & `years', a(gdenr##c.jahr  jahr) cl(gdenr)
reghdfe ln_stpf_norm_p75		`ln_w_tttop5' 	if `std_sample' & `years', a(gdenr##c.jahr  jahr) cl(gdenr)
reghdfe log_tax90 				`ln_w_tttop5' 	if `std_sample' & `years', a(gdenr##c.jahr i.jahr##i.kannr jahr) cl(gdenr)






