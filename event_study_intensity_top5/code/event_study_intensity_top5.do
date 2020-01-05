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




**** Intensity using top events in terms of top5times reduction ****

cd /Users/paolocampli/hw/event_study_intensity_top5
use input/top5times_to_reg.dta, clear


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
foreach v of varlist top05_log_w_tttop5_red top10_log_w_tttop5_red  {
	gen event_`v' = `v'
}



*** imputing missing
foreach v of varlist top05_log_w_tttop5_red top10_log_w_tttop5_red  zugang_p_10 {
	replace event_`v' = . if jahr > 2015					// no hw data post 2015
	replace event_`v' = 0 if jahr < 1955 & event_`v' == .	// no hw  at all pre 1955
}



*** Weighted events
foreach v of varlist event_top05_log_w_tttop5_red event_top10_log_w_tttop5_red  {
	gen w_`v' = `v'*log_w_tttop5_red 
}



*** Weighted event zugang_p_10
gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
bys gdenr: gen time_window = inrange(jahr, first_access - 2, first_access + 10)
bys gdenr: egen w_event_zugang_p_10 = total(log_w_tttop5_red*time_window)
bys gdenr: replace w_event_zugang_p_10 = w_event_zugang_p_10*event_zugang_p_10

drop access_year first_access time_window




******* EVENT *******
local event "event_top05_log_w_tttop5_red"
*local event "event_zugang_p_10"



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
graph export output/`event'.pdf, replace





*** Time locals
* non-binned
local pre 	-8
local post	 12
* base year
local base	 -2
local pre_base  = `base' - 2
local post_base = `base' + 2
local m_pre_base	= - `pre_base'		// stupid stata doesn't accept "-" in varname
local m_post_base	= - `post_base'
* binned:
local start = `pre' - 2
local end	= `post' + 2

local m_start = - `start' 






xtset gdenr periode
*** Creation of event study dummies ***
***

* Create b_`start': binned var for pre period
forvalues year = `init_year'(2)`fin_year' {
	bys gdenr: gen a`year'_temp = `event' if jahr == `year'
}
forvalues year = `init_year'(2)`fin_year' {
	bys gdenr: egen a`year' = sum(a`year'_temp)
}
forvalues year = `init_year'(2)`fin_year' {
	local min = `year' - `start'
	if `min' < `fin_year'	{
		egen b_m`m_start'`year' = rowtotal(a`min'-a`fin_year')
	}
	else if `min' >= `fin_year' {
		gen b_m`m_start'`year' = 0
	}
}
gen b_m`m_start' = 0
forvalues year = `init_year'(2)`fin_year' {
	replace b_m`m_start' = b_m`m_start'`year' if jahr == `year'
}
drop b_m`m_start'1* b_m`m_start'2*



* Create b_t
forvalues x = `pre'(2)`post' {
	if `x' < 0 {
	local m_x = -`x'
	local y = `m_x'/2
	bysort gdenr: gen b_m`m_x' = ///
	F`y'.`event'
	}
	else if `x' >= 0 {
	local y = `x'/2
	bysort gdenr: gen b_`x' = ///
	L`y'.`event'
	}
}



* Create b_`end': binned var for post period
forvalues year = `init_year'(2)`fin_year' {
	local max = `year' - `end'
	if `init_year' < `max' {
		egen b_`end'`year' = rowtotal(a`init_year'-a`max')
	}
	else if `init_year' >= `max' {
		gen b_`end'`year' = 0
	}
}
gen b_`end' = 0
forvalues year = `init_year'(2)`fin_year' {
	replace b_`end' = b_`end'`year' if jahr == `year'
}
drop b_`end'1* b_`end'2*
drop a1* a2*


* replace missings: we should confirm this makes sense
foreach var of varlist b_* {
	replace `var' = 0 if `var' == .
}


* years when we have tax data
keep if jahr >= 1947 & jahr <= 2009


* Balancedness: we only show coefficients identified by all municipalities
* if a municip has all zeros for some dummie, the max is 0
foreach var of varlist b_m`m_start'-b_`end' {
	bys gdenr: egen max_`var' = max(`var')
}
gen balanced_sample = 1
foreach var of varlist max_b_m`m_start'-max_b_`end' {
	replace balanced_sample = balanced_sample*`var'
}




* -----------------------------------------
*** Regressions and graphs ***



* Window definition
if `m_post_base' == 0 {
	local window		"b_m`m_start'-b_m`m_pre_base' b_0 b_2-b_`end'"
}
else {
	local window		"b_m`m_start'-b_m`m_pre_base' b_m`m_post_base'-b_0 b_2-b_`end'"
}


local std_sample1	"zentren == 0 & agglomeration == 0 & in_zugang_p_30 == 1"
local std_sample2	"& balanced_sample > 0 & flag_times_issue == 0"
local std_sample3	"& (balanced_sample > 0 | last_treat == .)"
local std_sample	"`std_sample1' `std_sample2'"

local xline_pos 	= -`pre'/2 +1
local graph_opt1	"vertical xline(`xline_pos') yline(0) plotregion(fcolor(white))"
local graph_opt2	"ciopts(recast(rcap)) graphregion(fcolor(white))"
local graph_opt		"`graph_opt1' `graph_opt2'"


local rows ""
forvalues y = `pre'(2)`post' {
	local rows = "`rows' `y'"
}



local dep_vars		"log_w_tttop5	ln_stpf_norm_p90	log_tax90"


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
		matrix M`v' = (coef`v', lower`v', upper`v')
		matrix colnames M`v' = coef lower upper
		}


	*** Matrix ***
	local m_pre = -`pre'
		matrix L1 = (Mb_m`m_pre')
		
	local x = `pre' + 2
	forvalues y = `x'(2)`pre_base' {
		local m_y = -`y'
		matrix L1 = (L1 \ Mb_m`m_y')
		}
		
		matrix L1 = (L1 \ 0,0,0) 	// baseline
		
	forvalues y = `post_base'(2)`post' {
		if `y' < 0 {
			local m_y = -`y'
			matrix L1 = (L1 \ Mb_m`m_y')
			}
		
		else {
			matrix L1 = (L1 \ Mb_`y')
			}
		}


	matrix rownames L1 = `rows'

	coefplot (matrix(L1[,1]), ci((L1[,2] L1[,3])) label("total")), `graph_opt' `labels'
	graph export output/`var'_pre`m_pre'_to`post'_`event'.pdf, replace

}



