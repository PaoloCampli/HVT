* Paolo Campli, USI
*--------------------------------------------------

version 14
set more off
capture log close

* program takes arguments: an event (a stata variable) and two numbers, pre and post,
* "pre" is intended as a negative integer (e.g. years before event), "post" is positive, 
* plus locals for sample definition and dependent variables for regressions
args event pre post sample dep_vars


qui: sum jahr
local init_year = r(min)
local fin_year = r(max)


*** Treatment dates, totals etc
gen treat_year = .
bys gdenr: replace treat_year = jahr if `event' > 0 & `event' < .
bys gdenr: egen first_treat 	= min(treat_year)
bys gdenr: egen last_treat 		= max(treat_year)
bys gdenr: egen tot_treat 		= total(treat_year/treat_year)
		       egen cumul_treat	  = total(treat_year/treat_year)

bys jahr: egen events_per_year        = total(treat_year/treat_year)
bys gdenr (jahr): gen events_bef_year = sum(events_per_year)

gen event_fraction 	= events_bef_year/cumul_treat


*** Time locals
* non-binned pre and post are arguments
* base year:
local base	- 4
* these are defined for later convenience
local pre_base  = `base' - 2
local post_base = `base' + 2
local m_pre_base	= - `pre_base'		// stupid stata doesn't accept "-" in varname
local m_post_base	= - `post_base'
* all periods before pre and after post are binned:
local start = `pre' - 2
local end	  = `post' + 2

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



local xline_pos 	= -`pre'/2 +1
local graph_opt1	"vertical xline(`xline_pos') yline(0) plotregion(fcolor(white))"
local graph_opt2	"ciopts(recast(rcap)) graphregion(fcolor(white))"
local graph_opt		"`graph_opt1' `graph_opt2'"


local rows ""
forvalues y = `pre'(2)`post' {
	local rows = "`rows' `y'"
}

macro li

*** Output ***
foreach var of varlist `dep_vars' {
	reghdfe `var'  `window' if `sample', a(gdenr jahr) cl(gdenr)

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
	graph export "../output/`var'_pre`m_pre'_to`post'_`event'.pdf", replace

}
