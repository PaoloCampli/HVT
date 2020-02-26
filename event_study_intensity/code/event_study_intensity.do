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




**** Intensity using top events in terms of tt40 reduction ****

*cd /Users/paolocampli/hw
use times_to_reg/output/times_to_reg.dta, clear


qui: sum jahr
local init_year = r(min)
local fin_year = r(max)

* Old event definition based on hw access to check that it reduces to old design
gen event_zugang_p_10 = D.zugang_p_10

*** Event definitions ***
foreach v of varlist top05_log_tt40_red top10_log_tt40_red {
	gen event_`v' = `v'
}



*** imputing missing
foreach v of varlist top05_log_tt40_red top10_log_tt40_red zugang_p_10 {
	replace event_`v' = . if jahr > 2015					// no hw data post 2015
	replace event_`v' = 0 if jahr < 1955 & event_`v' == .	// no hw  at all pre 1955
}


*** Weighted events
foreach v of varlist event_top05_log_tt40_red event_top10_log_tt40_red {
	gen w_`v' = `v'*log_tt40_red
}


*** Weighted event zugang_p_10
gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
bys gdenr: gen time_window = inrange(jahr, first_access - 2, first_access + 10)
bys gdenr: egen w_event_zugang_p_10 = total(tt40_red*time_window)
bys gdenr: replace w_event_zugang_p_10 = w_event_zugang_p_10*event_zugang_p_10

drop access_year first_access time_window




******* EVENT *******
local event "w_event_top10_log_tt40_red"
*local event "w_event_zugang_p_10"



*** Treatment dates, totals etc
gen treat_year = .
bys gdenr: replace treat_year 	= jahr if `event' > 0 & `event' < .
bys gdenr: egen first_treat 	= min(treat_year)
bys gdenr: egen last_treat 		= max(treat_year)
bys gdenr: egen tot_treat 		= total(treat_year/treat_year)
		   egen cumul_treat		= total(treat_year/treat_year)
bys jahr:  egen events_per_year = total(treat_year/treat_year)
bys gdenr (jahr): gen events_bef_year 	= sum(events_per_year)
gen event_fraction 				= events_bef_year/cumul_treat


local sample "zentren == 0 & agglomeration == 0 & in_zugang_p_30 ==1"

*** Events graphs
twoway hist treat_year if `sample', bcolor(sandb) density yaxis(2) yscale(range(0) axis(1)) ///
	|| line event_fraction jahr  if `sample', lcolor(black) sort yaxis(1) yscale(range(0) axis(1)) ///
	, plotregion(fcolor(white)) graphregion(fcolor(white)) legend(off)
graph export event_study_intensity/output/`event'.pdf, replace





*** Time locals
* non-binned
local pre 	14
local post	20
* base year
local base	4
local pre_base  = `base' + 2
local post_base = `base' - 2
* binned:
local start = `pre'+2
local end	= `post'+2





xtset gdenr periode
*** Creation of event study dummies ***
***
* Create b_pre`start': binned var for pre period
forvalues year = `init_year'(2)`fin_year' {
	bys gdenr: gen a`year'_temp = `event' if jahr == `year'
}
forvalues year = `init_year'(2)`fin_year' {
	bys gdenr: egen a`year' = sum(a`year'_temp)
}
forvalues year = `init_year'(2)`fin_year' {
	local min = `year' + `start'
	if `min' < `fin_year'	{
		egen b_pre`start'`year' = rowtotal(a`min'-a`fin_year')
	}
	else if `min' >= `fin_year' {
		gen b_pre`start'`year' = 0
	}
}
gen b_pre`start' = 0
forvalues year = `init_year'(2)`fin_year' {
	replace b_pre`start' = b_pre`start'`year' if jahr == `year'
}
drop b_pre`start'1* b_pre`start'2*



* Create b_pre
forvalues x = `pre'(-2)2 {
	local y = `x'/2
	bysort gdenr: gen b_pre`x' = ///
	F`y'.`event'
}


* Create b_0
bysort gdenr: gen b_0 = `event'


* Create b_post
forvalues x = 2(2)`post' {
	local y = `x'/2
	bysort gdenr: gen b_post`x' = ///
	L`y'.`event'
	replace b_post`x' = 0 if b_post`x' == .
}


* Create b_post`end': binned var for post period
forvalues year = `init_year'(2)`fin_year' {
	local max = `year' - `end'
	if `init_year' < `max' {
		egen b_post`end'`year' = rowtotal(a`init_year'-a`max')
	}
	else if `init_year' >= `max' {
		gen b_post`end'`year' = 0
	}
}
gen b_post`end' = 0
forvalues year = `init_year'(2)`fin_year' {
	replace b_post`end' = b_post`end'`year' if jahr == `year'
}
drop b_post`end'1* b_post`end'2*
drop a1* a2*


* years when we have tax data
keep if jahr >= 1947 & jahr <= 2009


* Balancedness: we only show coefficients identified by all municipalities
* if a municip has all zeros for some dummie, the max is 0
foreach var of varlist b_pre`start'-b_post`end' {
	bys gdenr: egen max_`var' = max(`var')
}
gen balanced_sample = 1
foreach var of varlist max_b_pre`start'-max_b_post`end' {
	replace balanced_sample = balanced_sample*`var'
}




* -----------------------------------------
*** Regressions and graphs ***


local labels0 		"coeflabels(b_pre12 = "-12" b_pre10 = "-10" b_pre8 = "-8""
local labels1		"b_pre6 = "-6" b_pre4 = "-4" b_pre2 = "-2" b_0 = "0" b_post2 = "2" b_post4 = "4""
local labels2		"b_post6 = "6" b_post8 = "8" b_post10 = "10" b_post12 = "12""
local labels3		"b_post14 = "14" b_post16 = "16" b_post18 = "18" b_post20 = "20")"
local labels 		"`labels0' `labels1' `labels2' `labels3'"


local window		"b_pre`start'-b_pre`pre_base' b_pre`post_base'-b_0 b_post2-b_post`end'"


local std_sample1	"zentren == 0 & agglomeration == 0 & in_zugang_p_30 == 1"
local std_sample2	"& balanced_sample > 0"
local std_sample3	"& (balanced_sample > 0 | last_treat == .)"
local std_sample	"`std_sample1' `std_sample2'"


local graph_opt1	"vertical xline(8) yline(0) plotregion(fcolor(white))"
local graph_opt2	"ciopts(recast(rcap)) graphregion(fcolor(white))"
local graph_opt		"`graph_opt1' `graph_opt2'"


local rownames10		"-10 -8 -6 -4 -2 +0 +2 +4 +6 +8 +10"
local rownames20	"-14 -12 -10 -8 -6 -4 -2 +0 +2 +4 +6 +8 +10 +12 +14 +16 +18 +20"




local dep_vars		"ln_time_to_40	ln_stpf_norm_p90	log_tax90"


*** Output ***
foreach var of varlist `dep_vars' {
	reghdfe `var'  `window' if `std_sample', a(gdenr jahr) cl(gdenr)

	foreach v of varlist `window' {
		lincom _b[`v']
		scalar coef`v' = r(estimate)
		scalar se`v' = r(se)
		scalar dof`v' = r(df)
		scalar lower`v' = coef`v' - se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
		scalar upper`v' = coef`v' + se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
		matrix matnoint`v' = (coef`v', lower`v', upper`v')
		matrix colnames matnoint`v' = coef lower upper
	}


	*** Matrix ***
		matrix L1 = (matnointb_pre`pre')
	local x = `pre' - 2
	forvalues y = `x'(-2)`pre_base' {
		matrix L1 = (L1 \ matnointb_pre`y')
	}
		matrix L1 = (L1 \ 0,0,0) // baseline
	forvalues y = `post_base'(-2)2 {
		matrix L1 = (L1 \ matnointb_pre`y')
	}
		matrix L1 = (L1 \ matnointb_0)
	forvalues y = 2(2)`post' {
		matrix L1 = (L1 \ matnointb_post`y')
	}


	matrix rownames L1 = `rownames20'

	coefplot (matrix(L1[,1]), ci((L1[,2] L1[,3])) label("total")), `graph_opt' `labels'
	graph export event_study_intensity/output/`var'_base`base'_to`post'_`event'.pdf, replace

}





/*
* =========================================
stop
* =========================================



cd /Users/paolocampli/hw
use times_to_reg/output/times_to_reg.dta, clear
xtset


foreach var of varlist time_to_40-time_to_80 {
	bysort gdenr: gen `var'_reduction = - D.`var'
}

rename (time_to_40_reduction time_to_80_reduction) (tt40_red tt80_red)
order tt40_red tt80_red, a(time_to_80)


foreach var of varlist tt40_red-tt80_red {
	sum `var'
	gen norm_`var' = (`var' - r(mean))/r(sd)
}



local pre 	8
local post	8
local start = `pre'+2
local end	= `post'+2
local fin_year  1999
local init_year 1965



* Create b_pre`start'
forvalues year = 1949(2)2009 {
	bys gdenr: gen norm_tt40_red`year'_temp = norm_tt40_red if jahr == `year'
}
forvalues year = 1949(2)2009 {
	bys gdenr: egen norm_tt40_red`year' = sum(norm_tt40_red`year'_temp)
}
forvalues year = 1949(2)`fin_year' {
	local min = `year' + 10
	egen b_pre`start'`year' = rowtotal(norm_tt40_red`min'-norm_tt40_red2009)
}
gen b_pre`start' = 0
forvalues year = 1949(2)`fin_year' {
	replace b_pre`start' = b_pre`start'`year' if jahr == `year'
}





forvalues x = `pre'(-2)2 {
	local y = `x'/2
	bysort gdenr: gen b_pre`x' = ///
	F`y'.norm_tt40_red
}



bysort gdenr: gen b_0 = norm_tt40_red



forvalues x = 2(2)`post' {
	local y = `x'/2
	bysort gdenr: gen b_post`x' = ///
	L`y'.norm_tt40_red
}




* Create b_post`end'
forvalues year = `init_year'(2)2009 {
	local max = `year' - 10
	local init_year_m10 = `init_year' - 10
	egen b_post`end'`year' = rowtotal(norm_tt40_red`init_year_m10'-norm_tt40_red`max')
}
gen b_post`end' = 0
forvalues year = 1965(2)`fin_year' {
	replace b_post`end' = b_post`end'`year' if jahr == `year'
}




drop norm_tt40_red1949_temp-norm_tt40_red2009_temp		norm_tt40_red1949-norm_tt40_red2009
drop b_pre`start'`init_year'-b_pre`start'`fin_year'		b_post`end'`init_year'-b_post`end'`fin_year'
drop b_post102001-b_post102009
/*
foreach v of var * {
	drop `v' if regexm(`v', "b_[a-z]+10[0-9]+")
}
*/




* -----------------------------------------
* Regs cut
local labels0 	"coeflabels(b_pre20 = "-20" b_pre18 = "-18" b_pre16 = "-16""
local labels1 	"b_pre14 = "-14" b_pre12 = "-12" b_pre10 = "-10" b_pre8 = "-8""
local labels2	"b_pre6 = "-6" b_pre4 = "-4" b_pre2 = "-2" b_0 = "0" b_post2 = "2" b_post4 = "4" b_post6 = "6""
local labels3	"b_post8 = "8" b_post10 = "10" b_post12 = "12" b_post14 = "14""
local labels4	"b_post16 = "16" b_post18 = "18" b_post20 = "20")"
local labels 	"`labels0' `labels1' `labels2' `labels3'`labels4'"

local window		"b_pre10-b_pre4 b_0 b_post2-b_post8 b_post10"

local drop			"b_pre10 b_post10"

local std_sample	"zentren == 0 & agglomeration == 0 & in_zugang_p_30 ==1"
					/*& jahr >= `init_year' & jahr <= `fin_year' "*/
					/*& obs == 1 & jahr > 1963 & jahr < 2003*/
					/*should be at most 1999 to have a correct b_post10*/

local graph_opt		"vertical xline(5) yline(0) plotregion(fcolor(white)) ciopts(recast(rcap)) graphregion(fcolor(white))"
local rownames		"-8 -6 -4 -2 +0 +2 +4 +6 +8"




***
* ------- times
reghdfe ln_time_to_40  `window' if `std_sample', a(gdenr jahr) cl(gdenr)

foreach v of varlist `window' {
	lincom _b[`v']
	scalar coef`v' = r(estimate)
	scalar se`v' = r(se)
	scalar dof`v' = r(df)
	scalar lower`v' = coef`v' - se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
	scalar upper`v' = coef`v' + se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
	matrix matnoint`v' = (coef`v', lower`v', upper`v')
	matrix colnames matnoint`v' = coef lower upper
}


*matrix L1 = (matnointb_pre10)
matrix L1 = (matnointb_pre8)
matrix L1 = (L1 \ matnointb_pre6)
matrix L1 = (L1 \ matnointb_pre4)
matrix L1 = (L1 \ 0,0,0)
matrix L1 = (L1 \ matnointb_0)
matrix L1 = (L1 \ matnointb_post2)
matrix L1 = (L1 \ matnointb_post4)
matrix L1 = (L1 \ matnointb_post6)
matrix L1 = (L1 \ matnointb_post8)
*matrix L1 = (L1 \ matnointb_post10)

matrix rownames L1 =  `rownames'

coefplot (matrix(L1[,1]), ci((L1[,2] L1[,3])) label("total")), drop(`drop') `graph_opt' `labels'
graph export event_study_intensity/output/graph_lndt_`pre'_cut.pdf, replace




***
* ------- pop
reghdfe ln_stpf_norm_p90  `window' if `std_sample', a(gdenr jahr) cl(gdenr)

foreach v of varlist `window' {
	lincom _b[`v']
	scalar coef`v' = r(estimate)
	scalar se`v' = r(se)
	scalar dof`v' = r(df)
	scalar lower`v' = coef`v' - se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
	scalar upper`v' = coef`v' + se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
	matrix matnoint`v' = (coef`v', lower`v', upper`v')
	matrix colnames matnoint`v' = coef lower upper
}


*matrix L1 = (matnointb_pre10)
matrix L1 = (matnointb_pre8)
matrix L1 = (L1 \ matnointb_pre6)
matrix L1 = (L1 \ matnointb_pre4)
matrix L1 = (L1 \ 0,0,0)
matrix L1 = (L1 \ matnointb_0)
matrix L1 = (L1 \ matnointb_post2)
matrix L1 = (L1 \ matnointb_post4)
matrix L1 = (L1 \ matnointb_post6)
matrix L1 = (L1 \ matnointb_post8)
*matrix L1 = (L1 \ matnointb_post10)

matrix rownames L1 =  `rownames'

coefplot (matrix(L1[,1]), ci((L1[,2] L1[,3]))), drop(`drop') `graph_opt' `labels'
graph export event_study_intensity/output/ev_sty_ln_stpf_norm_p90_`pre'_cut.pdf, replace




* ------- tax
reghdfe log_tax90  `window' if `std_sample', a(gdenr i.jahr##i.kannr) cl(gdenr)

foreach v of varlist `window' {
	lincom _b[`v']
	scalar coef`v' = r(estimate)
	scalar se`v' = r(se)
	scalar dof`v' = r(df)
	scalar lower`v' = coef`v' - se`v' * invttail(dof`v', 0.05) /* 0.025 for 95% CI, 0.05 for 90% CI */
	scalar upper`v' = coef`v' + se`v' * invttail(dof`v', 0.05) /* 0.025 for 95% CI, 0.05 for 90% CI */
	matrix matnoint`v' = (coef`v', lower`v', upper`v')
	matrix colnames matnoint`v' = coef lower upper
}

*matrix L1 = (matnointb_pre10)
matrix L1 = (matnointb_pre8)
matrix L1 = (L1 \ matnointb_pre6)
matrix L1 = (L1 \ matnointb_pre4)
matrix L1 = (L1 \ 0,0,0)
matrix L1 = (L1 \ matnointb_0)
matrix L1 = (L1 \ matnointb_post2)
matrix L1 = (L1 \ matnointb_post4)
matrix L1 = (L1 \ matnointb_post6)
matrix L1 = (L1 \ matnointb_post8)
*matrix L1 = (L1 \ matnointb_post10)

matrix rownames L1 =  `rownames'

coefplot (matrix(L1[,1]), ci((L1[,2] L1[,3]))), drop(`drop') `graph_opt' `labels'
graph export event_study_intensity/output/graph_log_tax90_`pre'_cut.pdf, replace









asdf








****
* Semi-intensity
****

version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
* --------------------------------------------------



* =========================================


cd /Users/paolocampli/hw
use tt40_sumstat/output/tt40_sumstats.dta, clear



local pre 	8
local post	8
local start = `pre'+2
local end	= `post'+2
local fin_year  1999
local init_year 1965



* Create b_pre`start'
forvalues year = 1949(2)2009 {
	bys gdenr: gen top10_norm_tt40_red`year'_temp = top10_norm_tt40_red if jahr == `year'
}
forvalues year = 1949(2)2009 {
	bys gdenr: egen top10_norm_tt40_red`year' = sum(top10_norm_tt40_red`year'_temp)
}
forvalues year = 1949(2)`fin_year' {
	local min = `year' + 10
	egen b_pre`start'`year' = rowtotal(top10_norm_tt40_red`min'-top10_norm_tt40_red2009)
}
gen b_pre`start' = 0
forvalues year = 1949(2)`fin_year' {
	replace b_pre`start' = b_pre`start'`year' if jahr == `year'
}





forvalues x = `pre'(-2)2 {
	local y = `x'/2
	bysort gdenr: gen b_pre`x' = ///
	F`y'.top10_norm_tt40_red
}



bysort gdenr: gen b_0 = top10_norm_tt40_red



forvalues x = 2(2)`post' {
	local y = `x'/2
	bysort gdenr: gen b_post`x' = ///
	L`y'.top10_norm_tt40_red
}



* Create b_post`end'
forvalues year = `init_year'(2)2009 {
	local max = `year' - 10
	local init_year_m10 = `init_year' - 10
	egen b_post`end'`year' = rowtotal(top10_norm_tt40_red`init_year_m10'-top10_norm_tt40_red`max')
}
gen b_post`end' = 0
forvalues year = 1965(2)`fin_year' {
	replace b_post`end' = b_post`end'`year' if jahr == `year'
}



***
* DROP
***



* -----------------------------------------
* Regs cut
local labels0 	"coeflabels(b_pre20 = "-20" b_pre18 = "-18" b_pre16 = "-16""
local labels1 	"b_pre14 = "-14" b_pre12 = "-12" b_pre10 = "-10" b_pre8 = "-8""
local labels2	"b_pre6 = "-6" b_pre4 = "-4" b_pre2 = "-2" b_0 = "0" b_post2 = "2" b_post4 = "4" b_post6 = "6""
local labels3	"b_post8 = "8" b_post10 = "10" b_post12 = "12" b_post14 = "14""
local labels4	"b_post16 = "16" b_post18 = "18" b_post20 = "20")"
local labels 	"`labels0' `labels1' `labels2' `labels3'`labels4'"

local window		"b_pre10 b_pre8 b_pre6 b_pre2 b_0 b_post2 b_post4 b_post6 b_post8 b_post10"

local drop			"b_pre10 b_post10"

local std_sample	"zentren == 0 & agglomeration == 0 & in_zugang_p_30 ==1 & jahr >= `init_year' & jahr <= `fin_year' "
					/*& obs == 1 & jahr > 1963 & jahr < 2003*/

local graph_opt		"vertical xline(5) yline(0) plotregion(fcolor(white)) ciopts(recast(rcap)) graphregion(fcolor(white))"
local rownames		"-8 -6 -4 -2 +0 +2 +4 +6 +8"




***
* ------- times
reghdfe ln_time_to_40  `window' if `std_sample', a(gdenr jahr) cl(gdenr)

foreach v of varlist `window' {
	lincom _b[`v']
	scalar coef`v' = r(estimate)
	scalar se`v' = r(se)
	scalar dof`v' = r(df)
	scalar lower`v' = coef`v' - se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
	scalar upper`v' = coef`v' + se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
	matrix matnoint`v' = (coef`v', lower`v', upper`v')
	matrix colnames matnoint`v' = coef lower upper
}

*matrix L1 = (matnointb_pre10)
matrix L1 = (matnointb_pre8)
matrix L1 = (L1 \ matnointb_pre6)
matrix L1 = (L1 \ 0,0,0)
matrix L1 = (L1 \ matnointb_pre2)
matrix L1 = (L1 \ matnointb_0)
matrix L1 = (L1 \ matnointb_post2)
matrix L1 = (L1 \ matnointb_post4)
matrix L1 = (L1 \ matnointb_post6)
matrix L1 = (L1 \ matnointb_post8)
*matrix L1 = (L1 \ matnointb_post10)

matrix rownames L1 =  `rownames'

coefplot (matrix(L1[,1]), ci((L1[,2] L1[,3])) label("total")), drop(`drop') `graph_opt' `labels'
graph export event_study_intensity/output/graph_lndt_`pre'_top10.pdf, replace




***
* ------- pop
reghdfe ln_stpf_norm_p90  `window' if `std_sample', a(gdenr jahr) cl(gdenr)

foreach v of varlist `window' {
	lincom _b[`v']
	scalar coef`v' = r(estimate)
	scalar se`v' = r(se)
	scalar dof`v' = r(df)
	scalar lower`v' = coef`v' - se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
	scalar upper`v' = coef`v' + se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
	matrix matnoint`v' = (coef`v', lower`v', upper`v')
	matrix colnames matnoint`v' = coef lower upper
}


*matrix L1 = (matnointb_pre10)
matrix L1 = (matnointb_pre8)
matrix L1 = (L1 \ matnointb_pre6)
matrix L1 = (L1 \ 0,0,0)
matrix L1 = (L1 \ matnointb_pre2)
matrix L1 = (L1 \ matnointb_0)
matrix L1 = (L1 \ matnointb_post2)
matrix L1 = (L1 \ matnointb_post4)
matrix L1 = (L1 \ matnointb_post6)
matrix L1 = (L1 \ matnointb_post8)
*matrix L1 = (L1 \ matnointb_post10)

matrix rownames L1 =  `rownames'

coefplot (matrix(L1[,1]), ci((L1[,2] L1[,3]))), drop(`drop') `graph_opt' `labels'
graph export event_study_intensity/output/ev_sty_ln_stpf_norm_p90_`pre'_top10.pdf, replace




* ------- tax
reghdfe log_tax90  `window' if `std_sample', a(gdenr i.jahr##i.kannr) cl(gdenr)

foreach v of varlist `window' {
	lincom _b[`v']
	scalar coef`v' = r(estimate)
	scalar se`v' = r(se)
	scalar dof`v' = r(df)
	scalar lower`v' = coef`v' - se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
	scalar upper`v' = coef`v' + se`v' * invttail(dof`v', 0.025) /* 0.025 for 95% CI, 0.05 for 90% CI */
	matrix matnoint`v' = (coef`v', lower`v', upper`v')
	matrix colnames matnoint`v' = coef lower upper
}

*matrix L1 = (matnointb_pre10)
matrix L1 = (matnointb_pre8)
matrix L1 = (L1 \ matnointb_pre6)
matrix L1 = (L1 \ 0,0,0)
matrix L1 = (L1 \ matnointb_pre2)
matrix L1 = (L1 \ matnointb_0)
matrix L1 = (L1 \ matnointb_post2)
matrix L1 = (L1 \ matnointb_post4)
matrix L1 = (L1 \ matnointb_post6)
matrix L1 = (L1 \ matnointb_post8)
*matrix L1 = (L1 \ matnointb_post10)

matrix rownames L1 =  `rownames'

coefplot (matrix(L1[,1]), ci((L1[,2] L1[,3]))), drop(`drop') `graph_opt' `labels'
graph export event_study_intensity/output/graph_log_tax90_`pre'_top10.pdf, replace
