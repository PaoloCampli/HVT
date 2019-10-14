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




**** Intensity using top events in terms of rcma reduction ****

cd /Users/paolocampli/hw
use event_study_intensity_rcma/input/rcmacut_to_reg.dta, clear


qui: sum jahr
local init_year = r(min)
local fin_year = r(max)
xtset gdenr periode


* drop very few municip which only appear later
bys gdenr: egen start = min(jahr)
drop if start > 1950
drop start


* Old event definition based on hw access to check that it reduces to old design
gen event_zugang_p_10 = D.zugang_p_10

*** Event definitions ***
foreach v of varlist top05_log_rcma_inc top10_log_rcma_inc {
	gen event_`v' = `v'
}



*** imputing missing
foreach v of varlist top05_log_rcma_inc top10_log_rcma_inc zugang_p_10 {
	replace event_`v' = . if jahr > 2015					// no hw data post 2015
	replace event_`v' = 0 if jahr < 1955 & event_`v' == .	// no hw  at all pre 1955
}


*** Weighted events
foreach v of varlist event_top05_log_rcma_inc event_top10_log_rcma_inc {
	gen w_`v' = `v'*log_rcma_inc
}


*** Weighted event zugang_p_10
gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
bys gdenr: gen time_window = inrange(jahr, first_access - 2, first_access + 10)
bys gdenr: egen w_event_zugang_p_10 = total(log_rcma_inc*time_window)
bys gdenr: replace w_event_zugang_p_10 = w_event_zugang_p_10*event_zugang_p_10

drop access_year first_access time_window




******* EVENT *******
local event "event_top10_log_rcma_inc"
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
graph export event_study_intensity_rcma/output/`event'.pdf, replace





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




local dep_vars		"ln_rcma	ln_stpf_norm_p90	log_tax90"


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
	graph export event_study_intensity_rcma/output/`var'_base`base'_to`post'_`event'.pdf, replace

}



