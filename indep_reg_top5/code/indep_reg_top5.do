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


local no_agglo		"zentren == 0 & agglomeration == 0"
local dist_bands 	"in_zugang_p_5 in_zugang_p_10 in_zugang_p_15 in_zugang_p_20 in_zugang_p_30 1"

local std_sample	"zentren == 0 & agglomeration == 0 "

/*
/*
***
* ------ all
foreach var in `log_pop_vars' {
		reghdfe `var' 		`ln_time40'		if `std_sample', a(gdenr##c.jahr jahr) cluster(gdenr)
		estimates store reg_`var'
	}
		reghdfe log_tax90 	`ln_time40'		if `std_sample', a(gdenr##c.jahr i.jahr##i.kannr) cluster(gdenr)
		estimates store reg_tax

	esttab reg_* using "indep_reg_times/output/ind_reg_noagglo.tex", keep(ln_time_to_40) ///
		nonumbers p mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore


***
* ------ zugangp-10
foreach var in `log_pop_vars' {
		reghdfe `var' 		`ln_time40'		if `no_agglo'  & in_zugang_p_10 ==1, a(gdenr##c.jahr jahr) cluster(gdenr)
		estimates store reg_`var'
	}
		reghdfe log_tax90 	`ln_time40'		if `no_agglo' & in_zugang_p_10==1, a(gdenr##c.jahr i.jahr##i.kannr) cluster(gdenr)
		estimates store reg_tax

	esttab reg_* using "indep_reg_times/output/ind_reg_noagglo_zug10.tex", keep(ln_time_to_40) ///
		nonumbers p mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore


***
* ------ zugangp-20
foreach var in `log_pop_vars' {
		reghdfe `var' 		`ln_time40'		if `no_agglo' & in_zugang_p_20==1, a(gdenr##c.jahr jahr) cluster(gdenr)
		estimates store reg_`var'
	}
		reghdfe log_tax90 	`ln_time40'		if `no_agglo' & in_zugang_p_20==1, a(gdenr##c.jahr i.jahr##i.kannr) cluster(gdenr)
		estimates store reg_tax

	esttab reg_* using "indep_reg_times/output/ind_reg_noagglo_zug20.tex", keep(ln_time_to_40) ///
		nonumbers p mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore






***
* ------ Excluding municip at highway entry
*** (where industries would prob be located)
foreach var in `log_pop_vars' {
		reghdfe `var' 		`ln_time40'		if `std_sample' & in_zugang_p_0 == 0, a(gdenr##c.jahr jahr) cluster(gdenr)
		estimates store reg_`var'
	}
		reghdfe log_tax90 	`ln_time40'		if `std_sample' & in_zugang_p_0 == 0, a(gdenr##c.jahr i.jahr##i.kannr) cluster(gdenr)
		estimates store reg_tax

	esttab reg_* using "indep_reg_times/output/ind_reg_noagglo_noaccess.tex", keep(ln_time_to_40) ///
		nonumbers p mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore




***
* ------ Distance bands interaction terms
foreach var in `log_pop_vars' {
		reghdfe `var' 		i.in_zugang_p_30##(c.ln_time_to_40 	c.d_ln_1_time_to_40 c.d_ln_2_time_to_40 c.d_ln_3_time_to_40 c.d_ln_4_time_to_40)	if `std_sample', a(gdenr##c.jahr jahr) cluster(gdenr)
		estimates store reg_`var'
	}
		reghdfe log_tax90 	i.in_zugang_p_30##(c.ln_time_to_40 	c.d_ln_1_time_to_40 c.d_ln_2_time_to_40 c.d_ln_3_time_to_40 c.d_ln_4_time_to_40)	if `std_sample', a(gdenr##c.jahr i.jahr##i.kannr) cluster(gdenr)
		estimates store reg_tax

	esttab reg_* using "indep_reg_times/output/ind_reg_noagglo_band_30.tex", keep(ln_time_to_40 in_zugang_p_30#ln_time_to_40) ///
		nonumbers p mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore


*/


merge 1:1 gdenr jahr using "/Users/paolocampli/Dropbox/Highways, Taxes and Voting/data_Paolo_nb_firms.dta"
reghdfe nb_firms	`ln_time40'		if `std_sample', a(gdenr##c.jahr jahr) cluster(gdenr)
	estimates store reg_firms
	esttab reg_firms using "indep_reg_times/output/ind_reg_noagglo_firms.tex", keep(ln_time_to_40) ///
		nonumbers p mtitles("Number of firms") replace
	cap estfe . reg_*, restore



local 10leads_lags "ln_l1_time_to_40-ln_l10_time_to_40	ln_f1_time_to_40-ln_f10_time_to_40"
local 20leads_lags "ln_l1_time_to_40-ln_l20_time_to_40	ln_f1_time_to_40-ln_f20_time_to_40"

***
* ------ leads and lags
foreach var in `log_pop_vars' {
		reghdfe `var' 		ln_time_to_40  `20leads_lags'		if `std_sample', a(gdenr##c.jahr jahr) cluster(gdenr)
		estimates store reg_`var'
	}
		reghdfe log_tax90 	ln_time_to_40  `20leads_lags'		if `std_sample', a(gdenr##c.jahr i.jahr##i.kannr) cluster(gdenr)
		estimates store reg_tax

	esttab reg_* using "indep_reg_times/output/ind_reg_noagglo_20leads_lags.tex", keep(ln_time_to_40) ///
		nonumbers p mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore















***** These regs have problems, fe_tax always active after first round *****
/*
*Logs
foreach dist in `dist_bands' {
	foreach var in `log_pop_vars' log_tax90 {

		if `var' == log_tax90 			local fe_tax "i.jahr##i.kannr"
		reghdfe `var' 	`ln_time40'		if `no_agglo' & `dist'==1, a(gdenr##c.jahr jahr `fe_tax') cluster(gdenr)
		estimates store reg_`var'

	}
	esttab reg_* using "indep_reg_times/output/ind_reg_`dist'.tex", keep(ln_time_to_40) ///
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

		reghdfe `var' 	`time40'	if `no_agglo' & `dist'==1, a(gdenr##c.jahr `fe_pop' `fe_tax') cluster(gdenr)
	estimates store reg_`var'
	}
	esttab reg_* using "indep_reg_times/output/ind_reg_nolog`dist'.tex", keep(time_to_40) ///
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

		reghdfe `var' 	`ln_time40'		if zentren == 0 & `dist'==1, a(gdenr##c.jahr `fe_pop' `fe_tax') cluster(gdenr)
	estimates store reg_`var'
	}
	esttab reg_* using "indep_reg_times/output/ind_reg_agglo_`dist'.tex", keep(ln_time_to_40) ///
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
	esttab reg_* using "indep_reg_times/output/ind_reg_agglo_nolog`dist'.tex", keep(time_to_40) ///
		nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
	cap estfe . reg_*, restore
}


*/


*/



set more off

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
esttab reg_* using "../output/ind_reg_noagglo.tex", se keep(ln_w_tttop5) nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
estfe . reg_*, restore





local ln_w_tttop5 	"ln_w_tttop5 		d_ln_1_w_tttop5 - d_ln_10_w_tttop5"
local std_sample	"zentren == 0 & agglomeration == 0 "
local years			"jahr >= 1959 & jahr <= 1981"

gen stpf_norm_under_p75 = stpf_norm_under_p50 + stpf_norm_p50_p75
gen ln_stpf_norm_under_p75 = log(stpf_norm_under_p75)

* 2 inc classes 1960-1980
reghdfe ln_stpf_norm_under_p75	`ln_w_tttop5' 	if `std_sample' & `years', a(gdenr##c.jahr  jahr) cl(gdenr)
reghdfe ln_stpf_norm_p75		`ln_w_tttop5' 	if `std_sample' & `years', a(gdenr##c.jahr  jahr) cl(gdenr)
reghdfe log_tax90 				`ln_w_tttop5' 	if `std_sample' & `years', a(gdenr##c.jahr i.jahr##i.kannr jahr) 	cl(gdenr)








/*


merge 1:1 gdenr jahr using "/Users/paolocampli/Dropbox/Highways, Taxes and Voting/data_Paolo_nb_firms.dta"
keep if _merge == 3


gen log_nb_firms = log(nb_firms)
reghdfe log_nb_firms 	`ln_w_tttop5' 	if `std_sample', a(gdenr##c.jahr jahr) 	cl(gdenr)



*/





/*


set more off

* 4 income classes log
reghdfe ln_stpf_norm_under_p50 	ln_time_to_80 		d_ln_1_time_to_80-d_ln_10_time_to_80	 	if zentren == 0 & agglomeration == 0 /*& in_zugang_p_10 == 1 & dist_zentrum_cat2_2 < 30*/, absorb(gdenr##c.jahr  jahr) 					cluster(gdenr)
estimates store reg_b50

reghdfe ln_stpf_norm_p50_p75 	ln_time_to_80 		d_ln_1_time_to_80-d_ln_10_time_to_80	 	if zentren == 0 & agglomeration == 0 /*& in_zugang_p_10 == 1 & dist_zentrum_cat2_2 < 30*/, absorb(gdenr##c.jahr  jahr) 					cluster(gdenr)
estimates store reg_50_75

reghdfe ln_stpf_norm_p75_p90 	ln_time_to_80 		d_ln_1_time_to_80-d_ln_10_time_to_80	 	if zentren == 0 & agglomeration == 0 /*& in_zugang_p_10 == 1 & dist_zentrum_cat2_2 < 30*/, absorb(gdenr##c.jahr  jahr) 					cluster(gdenr)
estimates store reg_75_90

reghdfe ln_stpf_norm_p90 		ln_time_to_80 		d_ln_1_time_to_80-d_ln_10_time_to_80	 	if zentren == 0 & agglomeration == 0 /*& in_zugang_p_10 == 1 & dist_zentrum_cat2_2 < 30*/, absorb(gdenr##c.jahr  jahr) 					cluster(gdenr)
estimates store reg_t10

reghdfe ln_einkst_v0k_p90 		ln_time_to_80 		d_ln_1_time_to_80-d_ln_10_time_to_80	 	if zentren == 0 & agglomeration == 0 /*& in_zugang_p_10 == 1 & dist_zentrum_cat2_2 < 30*/, absorb(gdenr##c.jahr i.jahr##i.kannr jahr) 	cluster(gdenr)
estimates store reg_tax

estfe . reg_*
return list
esttab reg_* using "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/indep_reg_times/output/ind_reg_1955_80.tex", keep(ln_time_to_80) nonumbers mtitles("B50" "50-75" "75-90" "T10" "Tax") replace
estfe . reg_*, restore




set more off
local m = 1
foreach indep_var 	of varlist	 	time_to_80  {
foreach dep_var 	of varlist 		ln_stpf_norm_under_p50 ln_stpf_norm_p50_p75 ln_stpf_norm_p75_p90 ln_stpf_norm_p90 ln_einkst_v0k_p90 {

reghdfe `dep_var'	`indep_var' 	d1_`indep_var'-d10_`indep_var' 	if zentren == 0 & agglomeration == 0, absorb(gdenr##c.jahr  jahr) 	cluster(gdenr)
estimates store reg_`m'
local ++m

}
}



asdf





hist ln_stpf_norm_p90



/*
***** Sureg b90-t10 *****


sureg 	(eq1: ln_stpf_norm_p90 			ln_time_to_40 		d_ln_1_time_to_40-d_ln_10_time_to_40 	i.gdenr i.jahr) ///
		(eq2: ln_stpf_norm_under_p90 	ln_time_to_40 		d_ln_1_time_to_40-d_ln_10_time_to_40 	i.gdenr i.jahr) ///
		(eq3: ln_einkst_v0k_p90 		ln_time_to_40 		d_ln_1_time_to_40-d_ln_10_time_to_40 	i.gdenr i.jahr) ///
		if zentren == 0 & agglomeration == 0


*canton-year f.e. in 3rd equation? to be added in 3rd regression (instead of canton f.e.? think about it)
*for now no municipality specific linear time trend?
est sto sureg1
est table sureg1, keep(ln_time_to_40) b se

scalar observations = e(N)
matrix b = e(b)
matrix Vt = e(V)


scalar s_k = colsof(b)/3 // b is a row vector

mat pi90 = (0) // Creates 1x1 matrix with value 0
qui{
*** With canton fixed effects
mat pi90 = (pi90,_b[eq1:ln_time_to_40]) // appends the coeff to the right
mat pi90 = (pi90,_b[eq2:ln_time_to_40])
mat pi90 = (pi90,_b[eq3:ln_time_to_40])
// here add more lines as we run the entire sureg
mat pi90 = pi90[1,2...] // discards the first 0
mat mt = pi90*0 // Creates a matrix "mt" with the same dimensions as pi but filled with zeros
}



mat V90 =(0)
mat V90 = (V90, Vt ["eq1:ln_time_to_40", "eq1:ln_time_to_40"])
mat V90 = (V90, Vt ["eq1:ln_time_to_40", "eq2:ln_time_to_40"])
mat V90 = (V90, Vt ["eq1:ln_time_to_40", "eq3:ln_time_to_40"])
mat V90 = (V90, Vt ["eq2:ln_time_to_40", "eq1:ln_time_to_40"])
mat V90 = (V90, Vt ["eq2:ln_time_to_40", "eq2:ln_time_to_40"])
mat V90 = (V90, Vt ["eq2:ln_time_to_40", "eq3:ln_time_to_40"])
mat V90 = (V90, Vt ["eq3:ln_time_to_40", "eq1:ln_time_to_40"])
mat V90 = (V90, Vt ["eq3:ln_time_to_40", "eq2:ln_time_to_40"])
mat V90 = (V90, Vt ["eq3:ln_time_to_40", "eq3:ln_time_to_40"])
mat V90 = V90[1,2...]


		mata: st_matrix("V90", rowshape( st_matrix("V90")', 3) ) // This takes the vector and puts it in matrix form
		mat li V90

	local N = e(N)

*/


**********************************

***** Sureg 4 income classes *****


sureg 	(eq1: ln_stpf_norm_p90 			ln_time_to_40 		d_ln_1_time_to_40-d_ln_10_time_to_40 		i.gdenr i.jahr) ///
		(eq2: ln_stpf_norm_p75_p90 		ln_time_to_40 		d_ln_1_time_to_40-d_ln_10_time_to_40 		i.gdenr i.jahr) ///
		(eq3: ln_stpf_norm_p50_p75 		ln_time_to_40 		d_ln_1_time_to_40-d_ln_10_time_to_40 		i.gdenr i.jahr) ///
		(eq4: ln_stpf_norm_under_p50 	ln_time_to_40 		d_ln_1_time_to_40-d_ln_10_time_to_40 		i.gdenr i.jahr) ///
		(eq5: ln_einkst_v0k_p90 		ln_time_to_40 		d_ln_1_time_to_40-d_ln_10_time_to_40 		i.gdenr i.jahr) ///
	if zentren == 0 & agglomeration == 0


*canton-year f.e. in 3rd equation? to be added in 3rd regression (instead of canton f.e.? think about it)
*for now no municipality specific linear time trend?
est sto sureg4inc
est table sureg4inc, keep(ln_time_to_40) b se


scalar observations = e(N)
matrix b = e(b)
matrix Vt = e(V)


scalar s_k = colsof(b)/5 // b is a row vector

mat pi = (0) // Creates 1x1 matrix with value 0
qui{
*** With canton fixed effects
mat pi = (pi,_b[eq1:ln_time_to_40]) // appends the coeff to the right
mat pi = (pi,_b[eq2:ln_time_to_40])
mat pi = (pi,_b[eq3:ln_time_to_40])
mat pi = (pi,_b[eq4:ln_time_to_40])
mat pi = (pi,_b[eq5:ln_time_to_40])
// here add more lines as we run the entire sureg
mat pi = pi[1,2...] // discards the first 0
mat mt = pi*0 // Creates a matrix "mt" with the same dimensions as pi but filled with zeros
}



mat V =(0)
mat V = (V, Vt ["eq1:ln_time_to_40", "eq1:ln_time_to_40"])
mat V = (V, Vt ["eq1:ln_time_to_40", "eq2:ln_time_to_40"])
mat V = (V, Vt ["eq1:ln_time_to_40", "eq3:ln_time_to_40"])
mat V = (V, Vt ["eq1:ln_time_to_40", "eq4:ln_time_to_40"])
mat V = (V, Vt ["eq1:ln_time_to_40", "eq5:ln_time_to_40"])
mat V = (V, Vt ["eq2:ln_time_to_40", "eq1:ln_time_to_40"])
mat V = (V, Vt ["eq2:ln_time_to_40", "eq2:ln_time_to_40"])
mat V = (V, Vt ["eq2:ln_time_to_40", "eq3:ln_time_to_40"])
mat V = (V, Vt ["eq2:ln_time_to_40", "eq4:ln_time_to_40"])
mat V = (V, Vt ["eq2:ln_time_to_40", "eq5:ln_time_to_40"])
mat V = (V, Vt ["eq3:ln_time_to_40", "eq1:ln_time_to_40"])
mat V = (V, Vt ["eq3:ln_time_to_40", "eq2:ln_time_to_40"])
mat V = (V, Vt ["eq3:ln_time_to_40", "eq3:ln_time_to_40"])
mat V = (V, Vt ["eq3:ln_time_to_40", "eq4:ln_time_to_40"])
mat V = (V, Vt ["eq3:ln_time_to_40", "eq5:ln_time_to_40"])
mat V = (V, Vt ["eq4:ln_time_to_40", "eq1:ln_time_to_40"])
mat V = (V, Vt ["eq4:ln_time_to_40", "eq2:ln_time_to_40"])
mat V = (V, Vt ["eq4:ln_time_to_40", "eq3:ln_time_to_40"])
mat V = (V, Vt ["eq4:ln_time_to_40", "eq4:ln_time_to_40"])
mat V = (V, Vt ["eq4:ln_time_to_40", "eq5:ln_time_to_40"])
mat V = (V, Vt ["eq5:ln_time_to_40", "eq1:ln_time_to_40"])
mat V = (V, Vt ["eq5:ln_time_to_40", "eq2:ln_time_to_40"])
mat V = (V, Vt ["eq5:ln_time_to_40", "eq3:ln_time_to_40"])
mat V = (V, Vt ["eq5:ln_time_to_40", "eq4:ln_time_to_40"])
mat V = (V, Vt ["eq5:ln_time_to_40", "eq5:ln_time_to_40"])
mat V = V[1,2...]


		mata: st_matrix("V", rowshape( st_matrix("V")', 5) ) // This takes the vector and puts it in matrix form
		mat li V

	local N = e(N)


/// five-dimensional parameter

		mat theta = (0,0,0,0,0)  	/* Our starting values */


/*
/// bidimensional
		mat theta = (.01,.01)  		/* Our starting values */
*/

		mat rb= J(1,5,0)
		mat rV = J(5,5,0)
		mat Q = 0



***************
* Def globals *
***************

scalar alpha=0
scalar beta=2
scalar epsilon=1/3
scalar delta1=.3
scalar delta2=.4
scalar delta3=.5
scalar delta4=.6
scalar tax = .2
scalar tax1 = 1/2
scalar tax2 = 1/2.3
scalar tax3 = 1/3
scalar tax4 = 1/3.5



****************************
run "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/doFiles/Paolo_HWT_Mata2.do"


*** Estimation
mata: mycmd(st_matrix("theta"))



local N = observations
ereturn post rb, obs(`N')



****************************


sort gdenr jahr
bys gdenr: gen diff_time_to_40 = -(time_to_40[_N] - time_to_40[1])

hist diff_time_to_40  if jahr > 1955



*gain in time vs pop/time_to_40 rank 1955, color code in/out sample

bys gdenr: egen min_pop = min(stpf)
gen log_min_pop = log(min_pop)

separate diff_time_to_40, by(agglomeration) veryshortlabel


scatter diff_time_to_401 diff_time_to_400 log_min_pop if diff_time_to_40 >0, sort ytitle("Cumulative drop in driving time") xtitle("Municipality initial size (log)") msize(vsmall tiny) mcolor("gs13" "gs6") leg(off) graphregion(color(white))
