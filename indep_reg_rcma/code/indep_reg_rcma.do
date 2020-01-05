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

clear matrix
set memory 1g
set matsize 11000
set maxvar 20000

*use "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/indep_reg_1/input/rcma_to_reg.dta", replace

cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/"
use "rcmacut_to_reg/output/rcmacut_to_reg.dta", clear


local log_rcma		"ln_rcma 	d_ln_1_rcma-d_ln_10_rcma"
local rcma			"rcma 		d1_rcma-d20_rcma"


local log_pop_vars 	"ln_stpf_norm_under_p50 ln_stpf_norm_p50_p75 ln_stpf_norm_p75_p90 ln_stpf_norm_p90"
local pop_vars 		"stpf_norm_under_p50 stpf_norm_p50_p75 stpf_norm_p75_p90 stpf_norm_p90"


local no_agglo		"zentren == 0 & agglomeration == 0"
local dist_bands 	"in_zugang_p_5 in_zugang_p_10 in_zugang_p_15 in_zugang_p_20 in_zugang_p_30 1"



*try
foreach var in `log_pop_vars' {	
		reghdfe `var' 		`log_rcma'		if `no_agglo' & in_zugang_p_30 ==1, a(gdenr##c.jahr jahr) cluster(gdenr)
		estimates store reg_`var'		
	}
		reghdfe log_tax90 	`log_rcma'		if `no_agglo' & in_zugang_p_30 ==1, a(gdenr##c.jahr i.jahr##i.kannr) cluster(gdenr)
		estimates store reg_tax
	
	esttab reg_* using "indep_reg_1/output/ind_reg_try.tex", keep(ln_rcma) ///
		nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore	
	
	
	


*Logs
foreach dist in `dist_bands' {
	foreach var in `log_pop_vars' log_tax90 {
		if `var' == ln_stpf_norm_under_p50	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p50_p75	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p75_p90	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p90	 	 local fe_pop "jahr"
		if `var' == log_tax90 				 local fe_tax "i.jahr##i.kannr"
		
		reghdfe `var' 	`log_rcma'		if `no_agglo' & `dist'==1, a(gdenr##c.jahr `fe_pop' `fe_tax') cluster(gdenr)
	estimates store reg_`var'
	}
	esttab reg_* using "indep_reg_1/output/ind_reg_`dist'.tex", keep(ln_rcma) ///
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
		
		reghdfe `var' 	`rcma'	if `no_agglo' & `dist'==1, a(gdenr##c.jahr `fe_pop' `fe_tax') cluster(gdenr)
	estimates store reg_`var'
	}
	esttab reg_* using "indep_reg_1/output/ind_reg_nolog`dist'.tex", keep(rcma) ///
		nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore
}


eststo clear


*Logs agglo
foreach dist in `dist_bands' {
	foreach var in `log_pop_vars' log_tax90 {
		if `var' == ln_stpf_norm_under_p50	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p50_p75	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p75_p90	 local fe_pop "jahr"
		if `var' == ln_stpf_norm_p90	 	 local fe_pop "jahr"
		if `var' == log_tax90 				 local fe_tax "i.jahr##i.kannr"
		
		reghdfe `var' 	`log_rcma'		if zentren == 0 & `dist'==1, a(gdenr##c.jahr `fe_pop' `fe_tax') cluster(gdenr)
	estimates store reg_`var'
	}
	esttab reg_* using "indep_reg_1/output/ind_reg_agglo_`dist'.tex", keep(ln_rcma) ///
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
		
		reghdfe `var' 	`rcma'	if zentren == 0 & `dist'==1, a(gdenr##c.jahr `fe_pop' `fe_tax') cluster(gdenr)
	estimates store reg_`var'
	}
	esttab reg_* using "indep_reg_1/output/ind_reg_agglo_nolog`dist'.tex", keep(rcma) ///
		nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore
}

















eststo clear
qui{
eststo: reghdfe ln_stpf_norm_under_p50  ln_rcma d_ln_1_rcma-d_ln_10_rcma 	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 ==1, a(i.gdenr i.jahr ) 
eststo: reghdfe ln_stpf_norm_p50_p75    ln_rcma d_ln_1_rcma-d_ln_10_rcma 	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 ==1, a(i.gdenr i.jahr ) 
eststo: reghdfe ln_stpf_norm_p75_p90    ln_rcma d_ln_1_rcma-d_ln_10_rcma 	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 ==1, a(i.gdenr i.jahr ) 
eststo: reghdfe ln_stpf_norm_p90 		ln_rcma d_ln_1_rcma-d_ln_10_rcma 	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 ==1, a(i.gdenr i.jahr ) 
eststo: reghdfe ln_einkst_v0k_p90 		ln_rcma d_ln_1_rcma-d_ln_10_rcma 	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 ==1, a(i.gdenr  i.jahr##i.kannr ) 
}
esttab using "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/indep_reg_1/output/indep_reg_4class_zug10_1.tex", replace label keep (ln_rcma) nonum mti("0-50" "50-75" "75-90" "90+" "Tax") 



eststo clear
qui{
eststo: reghdfe ln_stpf_norm_under_p50  rcma d1_rcma-d10_rcma 	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 ==0, a(i.gdenr i.jahr ) 
eststo: reghdfe ln_stpf_norm_p50_p75    rcma d1_rcma-d10_rcma 	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 ==0, a(i.gdenr i.jahr ) 
eststo: reghdfe ln_stpf_norm_p75_p90    rcma d1_rcma-d10_rcma 	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 ==0, a(i.gdenr i.jahr ) 
eststo: reghdfe ln_stpf_norm_p90 		rcma d1_rcma-d10_rcma 	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 ==0, a(i.gdenr i.jahr ) 
eststo: reghdfe ln_einkst_v0k_p90 		rcma d1_rcma-d10_rcma 	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 ==0, a(i.gdenr  i.jahr##i.kannr ) 
}
esttab using "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/indep_reg_1/output/indep_reg_4class_zug10_0_nolog.tex", replace label keep (rcma) nonum mti("0-50" "50-75" "75-90" "90+" "Tax") 





***** Independent regressions b90-t10 *****
eststo clear
foreach var of varlist ln_stpf_norm_under_p90 ln_stpf_norm_p90 ln_einkst_v0k_p90 {
qui{
eststo: reg `var'	ln_rcma d_ln_1_rcma-d_ln_10_rcma 	i.gdenr i.jahr 		if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1
}
}
** alternative with canton-year f.e. and municipality linear time trend
qui{
eststo: reg ln_stpf_norm_under_p90  ln_rcma d_ln_1_rcma-d_ln_10_rcma 	i.gdenr##c.periode i.jahr 				if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1
eststo: reg ln_stpf_norm_p90 		ln_rcma d_ln_1_rcma-d_ln_10_rcma 	i.gdenr##c.periode i.jahr 				if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1
eststo: reg ln_einkst_v0k_p90 		ln_rcma d_ln_1_rcma-d_ln_10_rcma 	i.gdenr##c.periode i.jahr##i.kannr  	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1
}
esttab using "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/indep_reg_1/output/indep_reg_b90_t10.tex", replace label keep (ln_rcma) nonum mti("Bot90" "Top10" "Tax" "Bot90" "Top10" "Tax") 


reghdfe ln_stpf_norm_p90 		c.ln_rcm##i.zugang_p_10 		if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1, a(i.gdenr##c.periode i.jahr) 

reghdfe ln_stpf_norm_p90 		rcma  if  zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1 & zugang_p_10 == 1, a(i.gdenr##c.periode i.jahr) 



* Basic reg 
reghdfe ln_stpf_norm 	ln_rcma 	d_ln_1_rcma-d_ln_10_rcma	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1 & dist_zentrum_cat2_2 < 30, absorb(gdenr##c.jahr jahr) cluster(gdenr)
* Same no log 
reghdfe ln_stpf_norm 	rcma 		d1_rcma-d10_rcma	 		 if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1 & dist_zentrum_cat2_2 < 30, absorb(gdenr##c.jahr jahr) cluster(gdenr)





* Basic with modified variables
reghdfe ln_stpf_norm_p90 	ln_rcma 	d_mln_1_rcma-d_mln_10_rcma	 if zentren == 0 & agglomeration == 0 /*& in_zugang_p_10 == 1*/ & dist_zentrum_cat2_2 < 40 &  jahr < 2010 & jahr > 1955, absorb(gdenr jahr) cluster(gdenr)


*=============================
set more off
cap drop FE*
cap drop res1 res2
reghdfe ln_stpf_norm_p90 	d1_rcma-d10_rcma	if zentren == 0 & agglomeration == 1 & in_zugang_p_10 == 1, absorb(FE_g=gdenr FE_j=jahr) cluster(gdenr)
predict res1, residuals

cap drop FE*
reghdfe rcma 			d1_rcma-d10_rcma	if zentren == 0 & agglomeration == 1 & in_zugang_p_10 == 1, absorb(FE_g=gdenr FE_j=jahr) cluster(gdenr)
predict res2, residuals

gen mylabel = kanton if abs(res2) > 0.5
graph tw scatter res1 res2, msize(tiny) mlabel(mylabel) mlabsize(1)  || lfit res1 res2
drop mylabel
*=============================

*=============================
set more off
cap drop FE*
cap drop res1 res2
reghdfe ln_stpf_norm_p90 d_ln_1_rcma-d_ln_10_rcma if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1 & dist_zentrum_cat2_2 < 30, absorb(FE_g=gdenr FE_j=jahr) cluster(gdenr)
predict res1, residuals

cap drop FE*
reghdfe ln_rcma d_ln_1_rcma-d_ln_10_rcma if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1 & dist_zentrum_cat2_2 < 30, absorb(FE_g=gdenr FE_j=jahr) cluster(gdenr)
predict res2, residuals

gen mylabel = kanton if abs(res2) > 0.2
graph tw scatter res1 res2, msize(tiny) mlabel(mylabel) mlabsize(1)  || lfit res1 res2
drop mylabel
*=============================



***** Independent regressions b90-t10, cluster alternative with canton-year f.e. and municipality linear time trend *****
eststo clear
foreach var of varlist ln_stpf_norm_under_p90 ln_stpf_norm_p90 ln_einkst_v0k_p90 {
qui{
eststo: reg `var'	ln_rcma ln_s1_rcma-ln_s10_rcma 	i.gdenr##c.periode i.jahr##i.kannr  	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1, cluster(gdenr)
}
}
estout using "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/indep_reg_1/output/indep_reg_b90_t10.tex", replace label{"Independent regressions b90-t10 cluster"} keep (ln_rcma) nonum mti("Bot90" "Top10" "Tax") 





set more off
***** Independent reghdfe b90-t10, cluster municip *****
foreach var of varlist ln_stpf_norm_under_p90 ln_stpf_norm_p90 ln_einkst_v0k_p90 {
	reghdfe `var'	ln_rcma ln_s1_rcma-ln_s10_rcma 	if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1, absorb(i.gdenr##c.periode i.jahr##i.kannr) cluster(gdenr)
	*estimates store `var'
}
/*	estfe . ln_stpf_norm_under_p90 ln_stpf_norm_p90 ln_einkst_v0k_p90
	return list

	esttab . ln_stpf_norm_under_p90 ln_stpf_norm_p90 ln_einkst_v0k_p90
	
	estfe . ln_stpf_norm_under_p90 ln_stpf_norm_p90 ln_einkst_v0k_p90, restore
	*/
	
	
	
***** Independent reghdfe b90-t10, cluster municip&year *****
set more off
***** Independent reghdfe b90-t10 *****
foreach var of varlist ln_stpf_norm_under_p90 ln_stpf_norm_p90 ln_einkst_v0k_p90 {
	reghdfe `var'	ln_rcma ln_s1_rcma-ln_s10_rcma 	i.gdenr i.jahr 		if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1, absorb(i.gdenr##c.periode i.jahr##i.kannr) cluster(gdenr jahr)
	estimates store `var'
}
	estfe . ln_stpf_norm_under_p90 ln_stpf_norm_p90 ln_einkst_v0k_p90
	return list

	esttab . ln_stpf_norm_under_p90 ln_stpf_norm_p90 ln_einkst_v0k_p90
	
	estfe . ln_stpf_norm_under_p90 ln_stpf_norm_p90 ln_einkst_v0k_p90, restore
	
	
	
* graph event-study like
* graph "first stage" i.e. rcma vs pre/after-opening years (use the "hw age varibles")
* will need leads (other than lags), assume after 2010 rcma stays constant







