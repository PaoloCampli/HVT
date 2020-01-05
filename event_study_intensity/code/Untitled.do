* Program Setup
*--------------------------------------------------
version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
* --------------------------------------------------



* =========================================


cd /Users/paolocampli/hw
use times_to_reg/output/times_to_reg.dta, clear



		
foreach var of varlist time_to_40-time_to_80 {
	bysort gdenr: gen `var'_reduction = - D.`var'
}

rename (time_to_40_reduction time_to_80_reduction) (tt40_red tt80_red)
order tt40_red tt80_red, a(gdename)


foreach var of varlist tt40_red-tt80_red {
	qui: sum `var' if jahr > 1955
	gen norm_`var' = (`var' - r(mean))/r(sd)
}


foreach v of varlist norm_tt40_red-norm_tt80_red {
	gen top01_`v' = 0
	gen top10_`v' = 0
	gen top25_`v' = 0
	qui: sum `v', d
	replace top01_`v' = inrange(`v', r(p99), r(max)+1)
	replace top10_`v' = inrange(`v', r(p90), r(max)+1)
	replace top25_`v' = inrange(`v', r(p75), r(max)+1)
}




gen zugang_p_10_2009 = zugang_p_10 if jahr == 2009
bys gdenr: egen zugang_p_10_2009bis = total(zugang_p_10_2009)



gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)

*gen not_zugang_p_10 = 1 - zugang_p_10

gen event = D.zugang_p_10
replace event = 0 if event == .

replace event = zugang_p_10_2009bis if jahr > 2009 & event == .
replace event = 0 if jahr < 1955 & event == .


gen event_red = top01_norm_tt40_red
replace event = event_red

*** drop temp



local pre 	10
local post	20
local start = `pre'+2
local end	= `post'+2
*local fin_year  1999
*local init_year 1965


qui: sum jahr
local init_year = r(min)
local fin_year = r(max)



* Create b_pre`start'
forvalues year = `init_year'(2)`fin_year' {
	bys gdenr: gen a`year'_temp = event if jahr == `year'
}
forvalues year = `init_year'(2)`fin_year' {
	bys gdenr: egen a`year' = sum(a`year'_temp) 
}
/* drop temp
local effective_fin_year = `fin_year' - `end' - 2 /* this limitation to not have vars out of order in sum */
forvalues year = `init_year'(2)`effective_fin_year' {
	local min = `year' + `start'
	local max = `fin_year' + `end' - 2 - `end' /* this -`end' to have all vars for next sum */
	egen b_pre`start'`year' = rowtotal(a`min'-a`max')
}
*/
/*
* drop temp
forvalues year = `init_year'(2)`fin_year' {
	local min = `year' + `start'
	local max = `fin_year' + `start' - 2
	if `min' < `max' & `max' < `fin_year'	{
		egen b_pre`start'`year' = rowtotal(a`min'-a`max')
	}
	else if `min' < `max' & `max' >= `fin_year'	{
		gen b_pre`start'`year' = .
	}
	else if `min' >= `max' {
		gen b_pre`start'`year' = 0
	}
}
*/


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





forvalues x = `pre'(-2)2 {
	local y = `x'/2
	bysort gdenr: gen b_pre`x' = ///
	F`y'.event
}



bysort gdenr: gen b_0 = event



forvalues x = 2(2)`post' {
	local y = `x'/2
	bysort gdenr: gen b_post`x' = ///
	L`y'.event
	replace b_post`x' = 0 if b_post`x' == .
}




* Create b_post`end'
/*
local effective_init_year = `init_year' + `end' 
local effective_init_year_p2 = `effective_init_year' + 2
forvalues year = `effective_init_year_p2'(2)`fin_year' {
	local max = `year' - `end'
	local min = `effective_init_year' - `end' + 2
	egen b_post`end'`year' = rowtotal(a`min'-a`max') 
}
*/

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





* -----------------------------------------
* Regs cut
local labels0 	"coeflabels(b_pre20 = "-20" b_pre18 = "-18" b_pre16 = "-16""
local labels1 	"b_pre14 = "-14" b_pre12 = "-12" b_pre10 = "-10" b_pre8 = "-8""
local labels2	"b_pre6 = "-6" b_pre4 = "-4" b_pre2 = "-2" b_0 = "0" b_post2 = "2" b_post4 = "4" b_post6 = "6""
local labels3	"b_post8 = "8" b_post10 = "10" b_post12 = "12" b_post14 = "14""
local labels4	"b_post16 = "16" b_post18 = "18" b_post20 = "20")"
local labels 	"`labels0' `labels1' `labels2' `labels3'`labels4'"

local window		"b_pre12-b_pre4 b_0 b_post2-b_post20 b_post22"

*local drop			"b_pre10 b_post10"

local std_sample	"zentren == 0 & agglomeration == 0 & in_zugang_p_30 ==1"
					/*& jahr >= `init_year' & jahr <= `fin_year' "*/
					/*& obs == 1 & jahr > 1963 & jahr < 2003*/
					/*should be at most 1999 to have a correct b_post10*/ 
					
local graph_opt		"vertical xline(5) yline(0) plotregion(fcolor(white)) ciopts(recast(rcap)) graphregion(fcolor(white))"
local rownames		"-10 -8 -6 -4 -2 +0 +2 +4 +6 +8 +10 +12 +14 +16 +18 +20"	

	
	
	
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


matrix L1 = (matnointb_pre10)
matrix L1 = (L1 \ matnointb_pre8)
matrix L1 = (L1 \ matnointb_pre6)
matrix L1 = (L1 \ matnointb_pre4)
matrix L1 = (L1 \ 0,0,0)
matrix L1 = (L1 \ matnointb_0)
matrix L1 = (L1 \ matnointb_post2)
matrix L1 = (L1 \ matnointb_post4)
matrix L1 = (L1 \ matnointb_post6)
matrix L1 = (L1 \ matnointb_post8)
matrix L1 = (L1 \ matnointb_post10)
matrix L1 = (L1 \ matnointb_post12)
matrix L1 = (L1 \ matnointb_post14)
matrix L1 = (L1 \ matnointb_post16)
matrix L1 = (L1 \ matnointb_post18)
matrix L1 = (L1 \ matnointb_post20)


matrix rownames L1 =  `rownames'

coefplot (matrix(L1[,1]), ci((L1[,2] L1[,3])) label("total")), drop(`drop') `graph_opt' `labels'





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


matrix L1 = (matnointb_pre10)
matrix L1 = (L1 \ matnointb_pre8)
matrix L1 = (L1 \ matnointb_pre6)
matrix L1 = (L1 \ matnointb_pre4)
matrix L1 = (L1 \ 0,0,0)
matrix L1 = (L1 \ matnointb_0)
matrix L1 = (L1 \ matnointb_post2)
matrix L1 = (L1 \ matnointb_post4)
matrix L1 = (L1 \ matnointb_post6)
matrix L1 = (L1 \ matnointb_post8)
matrix L1 = (L1 \ matnointb_post10)
matrix L1 = (L1 \ matnointb_post12)
matrix L1 = (L1 \ matnointb_post14)
matrix L1 = (L1 \ matnointb_post16)
matrix L1 = (L1 \ matnointb_post18)
matrix L1 = (L1 \ matnointb_post20)


matrix rownames L1 =  `rownames'

coefplot (matrix(L1[,1]), ci((L1[,2] L1[,3])) label("total")), drop(`drop') `graph_opt' `labels'

