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



* =========================================


cd /Users/paolocampli/hw
use times_to_reg/output/times_to_reg.dta, clear
xtset

gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
drop access_year


local pre 	8
local post	8
local start = `pre'+2
local end	= `post'+2


/*
*** test using single cohorts
keep if inrange(first_access,  1981, 1989) | first_access == .
*/




bysort gdenr: gen b_pre`start' = jahr <= first_access - `start'


forvalues x = `pre'(-2)2 {
	bysort gdenr: gen b_pre`x' ///
	= inrange(jahr, first_access - `x', first_access - `x' + 1)
}


bysort gdenr: gen b_0 = inrange(jahr, first_access - 0, first_access +1)


forvalues x = 2(2)`post' {
	bysort gdenr: gen b_post`x' ///
	= inrange(jahr, first_access + `x', first_access + `x' + 1)
}


bysort gdenr: gen b_post`end' = jahr >= first_access + `end'


by gdenr: egen flag_pre  = max(b_pre`start')
by gdenr: egen flag_post = max(b_post`end')

gen flag = flag_pre*flag_post



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
* Regs cut
local labels0 	"coeflabels(b_pre20 = "-20" b_pre18 = "-18" b_pre16 = "-16""
local labels1 	"b_pre14 = "-14" b_pre12 = "-12" b_pre10 = "-10" b_pre8 = "-8""
local labels2	"b_pre6 = "-6" b_pre4 = "-4" b_pre2 = "-2" b_0 = "0" b_post2 = "2" b_post4 = "4" b_post6 = "6""
local labels3	"b_post8 = "8" b_post10 = "10" b_post12 = "12" b_post14 = "14""
local labels4	"b_post16 = "16" b_post18 = "18" b_post20 = "20")"
local labels 	"`labels0' `labels1' `labels2' `labels3'`labels4'"

local window		"b_pre10-b_pre6 b_pre2-b_0 b_post*"

local drop			"b_pre10 b_post10"


local std_sample	"zentren == 0 & agglomeration == 0 & in_zugang_p_30 ==1"
					 /* & balanced_sample > 0*/
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
graph export event_study/output/graph_lndt_`pre'_cut.pdf, replace
clear matrix



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
graph export event_study/output/ev_sty_ln_stpf_norm_p90_`pre'_cut.pdf, replace
	
	
	
***
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
graph export event_study/output/graph_log_tax90_`pre'_cut.pdf, replace







































/*
*==============================
asdf
*==============================


cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks"

use times_to_reg/output/times_to_reg.dta, clear


gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
drop access_year



* -----------------------------------------
* Vars creation

gen b_pre10 = 0
bysort gdenr: replace b_pre10 = 1 if jahr <= first_access - 10

gen b_pre8 = 0
bysort gdenr: replace b_pre8 = inrange(jahr, first_access - 8, first_access - 7)

gen b_pre6 = 0
bysort gdenr: replace b_pre6 = inrange(jahr, first_access - 6, first_access - 5)

gen b_pre4 = 0
bysort gdenr: replace b_pre4 = inrange(jahr, first_access - 4, first_access - 3)

gen b_pre2 = 0
bysort gdenr: replace b_pre2 = inrange(jahr, first_access - 2, first_access - 1)

gen b_0 = 0
bysort gdenr: replace b_0 = inrange(jahr, first_access - 0, first_access +1)

gen b_post2 = 0
bysort gdenr: replace b_post2 = inrange(jahr, first_access + 2, first_access + 3)

gen b_post4 = 0
bysort gdenr: replace b_post4 = inrange(jahr, first_access + 4, first_access + 5)

gen b_post6 = 0
bysort gdenr: replace b_post6 = inrange(jahr, first_access + 6, first_access + 7)

gen b_post8 = 0
bysort gdenr: replace b_post8 = inrange(jahr, first_access + 8, first_access + 9)

gen b_post10 = 0
bysort gdenr: replace b_post10 = 1 if jahr >= first_access + 10



* -----------------------------------------
* Regs


reghdfe time_to_40  b_pre10-b_pre4 b_0 b_post* ///
	if in_zugang_p_10 == 1, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre10 b_pre8 b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_dt_10_treated.pdf, replace



reghdfe time_to_40  b_pre10-b_pre4 b_0 b_post*, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre10 b_pre8 b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_dt_10_all.pdf, replace



set more off
reghdfe ln_time_to_40  b_pre10-b_pre4 b_0 b_post* ///
	if in_zugang_p_10 == 1, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre10 b_pre8 b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_lndt_10_treated.pdf, replace



reghdfe ln_time_to_40  b_pre10-b_pre4 b_0 b_post*, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre10 b_pre8 b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_lndt_10_all.pdf, replace



* =========================================
* Version imposing zeros for non-treated


set more off

cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks"

use times_to_reg/output/times_to_reg.dta, clear


gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
drop access_year



bysort gdenr: gen b_pre20 = jahr <= first_access - 20
replace b_pre20 = 0 if in_zugang_p_10 == 0

forvalues x = 18(-2)2 {
	bysort gdenr: gen b_pre`x' ///
	= inrange(jahr, first_access - `x', first_access - `x' + 1)
	replace b_pre`x' = 0 if in_zugang_p_10 == 0
}


bysort gdenr: gen b_0 = inrange(jahr, first_access - 0, first_access +1)
replace b_0 = 0 if in_zugang_p_10 == 0


forvalues x = 2(2)12 {
	bysort gdenr: gen b_post`x' ///
	= inrange(jahr, first_access + `x', first_access + `x' + 1)
	replace b_post`x' = 0 if in_zugang_p_10 == 0

}


bysort gdenr: gen b_post14 = jahr >= first_access + 14
replace b_post14 = 0 if in_zugang_p_10 == 0



set more off
reghdfe time_to_40  b_pre20-b_pre4 b_0 b_post*, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre20 b_pre18 b_pre16 b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	





set more off
reghdfe time_to_40  b_pre20-b_pre4 b_0 b_post* ///
	if in_zugang_p_10 == 1, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre20 b_pre18 b_pre16 b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_dt_20_treated.pdf, replace



reghdfe time_to_40  b_pre20-b_pre4 b_0 b_post*, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre20 b_pre18 b_pre16 b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_dt_20_all.pdf, replace




set more off
reghdfe ln_time_to_40  b_pre20-b_pre4 b_0 b_post* ///
	if in_zugang_p_10 == 1, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre20 b_pre18 b_pre16 b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_lndt_20_treated.pdf, replace



reghdfe ln_time_to_40  b_pre20-b_pre4 b_0 b_post*, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre20 b_pre18 b_pre16 b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_lndt_20_all.pdf, replace




local labels "coeflabels(b_pre14 = "-14" b_pre12 = "-12" b_pre10 = "-10" b_pre8 = "-8" b_pre6 = "-6" b_pre4 = "-4" b_0 = "0" b_post2 = "2" b_post4 = "4" b_post6 = "6" b_post8 = "8" b_post10 = "10" b_post12 = "12" b_post14 = "14")"















* -----------------------------------------
* -----------------------------------------
* RCMA equivalent

set more off
cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks"

use rcma_to_reg/output/rcma_to_reg.dta, clear


gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
drop access_year



* -----------------------------------------
* Vars creation

gen b_pre10 = 0
bysort gdenr: replace b_pre10 = 1 if jahr <= first_access - 10

gen b_pre8 = 0
bysort gdenr: replace b_pre8 = inrange(jahr, first_access - 8, first_access - 7)

gen b_pre6 = 0
bysort gdenr: replace b_pre6 = inrange(jahr, first_access - 6, first_access - 5)

gen b_pre4 = 0
bysort gdenr: replace b_pre4 = inrange(jahr, first_access - 4, first_access - 3)

gen b_pre2 = 0
bysort gdenr: replace b_pre2 = inrange(jahr, first_access - 2, first_access - 1)

gen b_0 = 0
bysort gdenr: replace b_0 = inrange(jahr, first_access - 0, first_access +1)

gen b_post2 = 0
bysort gdenr: replace b_post2 = inrange(jahr, first_access + 2, first_access + 3)

gen b_post4 = 0
bysort gdenr: replace b_post4 = inrange(jahr, first_access + 4, first_access + 5)

gen b_post6 = 0
bysort gdenr: replace b_post6 = inrange(jahr, first_access + 6, first_access + 7)

gen b_post8 = 0
bysort gdenr: replace b_post8 = inrange(jahr, first_access + 8, first_access + 9)

gen b_post10 = 0
bysort gdenr: replace b_post10 = 1 if jahr >= first_access + 10



* -----------------------------------------
* Regs
* log rcma
set more off
reghdfe 	ln_rcma  b_pre10-b_pre4 b_0 b_post*  ///
			if in_zugang_p_10 == 1, a(gdenr jahr) cluster(gdenr)
	
coefplot, 	keep(b_pre10 b_pre8 b_pre6 b_pre4 b_0 b_post*) ///
			vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_lnrcma_10_treated.pdf, replace

	
	
reghdfe 	ln_rcma  b_pre10-b_pre4 b_0 b_post*, a(gdenr jahr) cluster(gdenr)

coefplot, 	keep(b_pre10 b_pre8 b_pre6 b_pre4 b_0 b_post*) ///
			vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))
			
graph export event_study/output/graph_lnrcma_10_all.pdf, replace

* -----------


* rcma
set more off
reghdfe 	rcma  b_pre10-b_pre4 b_0 b_post*  ///
			if in_zugang_p_10 == 1, a(gdenr jahr) cluster(gdenr)
	
coefplot, 	keep(b_pre10 b_pre8 b_pre6 b_pre4 b_0 b_post*) ///
			vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_rcma_10_treated.pdf, replace

	
	
reghdfe 	rcma  b_pre10-b_pre4 b_0 b_post*, a(gdenr jahr) cluster(gdenr)

coefplot, 	keep(b_pre10 b_pre8 b_pre6 b_pre4 b_0 b_post*) ///
			vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))
			
graph export event_study/output/graph_rcma_10_all.pdf, replace



* =========================================







set more off
cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks"

use rcma_to_reg/output/rcma_to_reg.dta, clear


gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
drop access_year



bysort gdenr: gen b_pre20 = jahr <= first_access - 20


forvalues x = 18(-2)2 {
	bysort gdenr: gen b_pre`x' ///
	= inrange(jahr, first_access - `x', first_access - `x' + 1)
}


bysort gdenr: gen b_0 = inrange(jahr, first_access - 0, first_access +1)


forvalues x = 2(2)12 {
	bysort gdenr: gen b_post`x' ///
	= inrange(jahr, first_access + `x', first_access + `x' + 1)
}


bysort gdenr: gen b_post14 = jahr >= first_access + 14




* -----------------------------------------
* Regs
set more off




reghdfe ln_rcma  b_pre20-b_pre4 b_0 b_post*, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_pre2 b_0 b_post*) ///
	 xline(0) yline(7) plotregion(fcolor(white)) graphregion(fcolor(white)) ///
	 coeflabels(b_pre14 = "-14" b_pre12 = "-12" b_pre10 = "-10" b_pre8 = "-8" b_pre6 = "-6" b_pre4 = "-4" b_0 = "0" b_post2 = "2" b_post4 = "4" b_post6 = "6" b_post8 = "8" b_post10 = "10" b_post12 = "12" b_post14 = "14")

graph export event_study/output/graph_lnrcma_20_all_cut.pdf, replace


reghdfe ln_rcma  b_pre20-b_pre4 b_0 b_post* if zentren == 0 & agglomeration == 0 , a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_pre2 b_0 b_post*) ///
	 xline(0) yline(7) plotregion(fcolor(white)) graphregion(fcolor(white)) ///
	 coeflabels(b_pre14 = "-14" b_pre12 = "-12" b_pre10 = "-10" b_pre8 = "-8" b_pre6 = "-6" b_pre4 = "-4" b_0 = "0" b_post2 = "2" b_post4 = "4" b_post6 = "6" b_post8 = "8" b_post10 = "10" b_post12 = "12" b_post14 = "14")

graph export event_study/output/graph_lnrcma_20_noagglo_cut.pdf, replace




reghdfe ln_rcma  b_pre20-b_pre4 b_0 b_post* if zentren == 0 & agglomeration == 0 & in_zugang_p_10 == 1, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_pre2 b_0 b_post*) ///
	 xline(0) yline(7) plotregion(fcolor(white)) graphregion(fcolor(white)) ///
	 coeflabels(b_pre14 = "-14" b_pre12 = "-12" b_pre10 = "-10" b_pre8 = "-8" b_pre6 = "-6" b_pre4 = "-4" b_0 = "0" b_post2 = "2" b_post4 = "4" b_post6 = "6" b_post8 = "8" b_post10 = "10" b_post12 = "12" b_post14 = "14")

graph export event_study/output/graph_lnrcma_20_noagglo_zug10_1_cut.pdf, replace





* log_rcma
reghdfe ln_rcma  b_pre20-b_pre4 b_0 b_post* if in_zugang_p_10 == 1, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre20 b_pre18 b_pre16 b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_lnrcma_20_treated.pdf, replace



reghdfe ln_rcma  b_pre20-b_pre4 b_0 b_post*, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre20 b_pre18 b_pre16 b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_lnrcma_20_all.pdf, replace

* -----------

set more off
* rcma
reghdfe rcma  b_pre20-b_pre4 b_0 b_post* ///
	if in_zugang_p_10 == 1, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre20 b_pre18 b_pre16 b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_rcma_20_treated.pdf, replace



reghdfe rcma  b_pre20-b_pre4 b_0 b_post*, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre20 b_pre18 b_pre16 b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))

graph export event_study/output/graph_rcma_20_all.pdf, replace



set more off
* rcma
reghdfe ln_rcma  b_pre20-b_pre4 b_0 b_post* ///
	if  in_zugang_p_10 == 1 & kannr == 21, a(gdenr jahr) cluster(gdenr)

coefplot, keep(b_pre20 b_pre18 b_pre16 b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))
	

	
* ==============================

set more off, permanently
set emptycells drop
set matsize 11000
* rcma
reghdfe ln_rcma, a(gd=i.gdenr yr=i.jahr) cluster(gdenr)	
predict resid, residuals

scatter resid jahr


reghdfe resid  b_pre20-b_pre4 b_0 b_post* ///
	if  in_zugang_p_10 == 1, a(gdenr jahr) cluster(gdenr)
coefplot, keep(b_pre20 b_pre18 b_pre16 b_pre14 b_pre12 b_pre10 b_pre8 ///
				b_pre6 b_pre4 b_0 b_post*) ///
	vertical yline(0) plotregion(fcolor(white)) graphregion(fcolor(white))
	

	
foreach var of varlist b_* {
	gen resid_`var' = resid*`var'
}



graph bar resid_*, legend(off)
graph export event_study/output/bars_resid.pdf, replace





* Just sums resid over b_pre20 and b_post10, obtaining the total effect;
* No effect on other dummies
collapse first_access (sum) resid_*, by(gdenr)

dotplot resid_*



foreach var of varlist resid_* {
	gen log_`var' = log(`var')
}

dotplot log_resid_*


local markers = "marker(1, msize(vsmall)) marker(2, msize(vsmall)) marker(3, msize(vsmall)) marker(4, msize(vsmall)) marker(5, msize(vsmall)) marker(6, msize(vsmall)) marker(7, msize(vsmall)) marker(8, msize(vsmall)) marker(9, msize(vsmall)) marker(10, msize(vsmall)) marker(11, msize(vsmall)) marker(12, msize(vsmall)) marker(13, msize(vsmall)) marker(14, msize(vsmall)) marker(15, msize(vsmall)) marker(16, msize(vsmall))"
graph box resid_b_pre18-resid_b_post8, legend(off) `markers'
graph export event_study/output/box_no_extr_resid.pdf, replace


local markers = "marker(1, msize(vsmall)) marker(2, msize(vsmall)) marker(3, msize(vsmall)) marker(4, msize(vsmall)) marker(5, msize(vsmall)) marker(6, msize(vsmall)) marker(7, msize(vsmall)) marker(8, msize(vsmall)) marker(9, msize(vsmall)) marker(10, msize(vsmall)) marker(11, msize(vsmall)) marker(12, msize(vsmall)) marker(13, msize(vsmall)) marker(14, msize(vsmall)) marker(15, msize(vsmall)) marker(16, msize(vsmall))"
graph box resid_b_*, legend(off) `markers'
graph export event_study/output/box_resid.pdf, replace


local markers = "marker(1, msize(vsmall)) marker(2, msize(vsmall)) marker(3, msize(vsmall)) marker(4, msize(vsmall)) marker(5, msize(vsmall)) marker(6, msize(vsmall)) marker(7, msize(vsmall)) marker(8, msize(vsmall)) marker(9, msize(vsmall)) marker(10, msize(vsmall)) marker(11, msize(vsmall)) marker(12, msize(vsmall)) marker(13, msize(vsmall)) marker(14, msize(vsmall)) marker(15, msize(vsmall)) marker(16, msize(vsmall))"
graph box log_resid_b_*, legend(off) `markers'
graph export event_study/output/box_log_resid.pdf, replace


collapse (sum) resid_*, by(first_access)
drop if first_access == .
graph box resid_b_pre20 resid_b_post10, over(first_access)  
graph export event_study/output/box_collapse_resid.pdf, replace





* ========
* scatter resid on age of highway, by early vs late opener (and maybe collapse by group)
* also group by canton
* campare with non-log and also for driving times 




set more off
cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks"

use rcma_to_reg/output/rcma_to_reg.dta, clear


gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
drop access_year

bysort gdenr: gen age_of_hw = jahr - first_access

* Log_rcma
reghdfe ln_rcma, a(gd=i.gdenr yr=i.jahr) cluster(gdenr)	
predict resid, residuals

/*
gen adopter = "no access"
replace adopter = "early" if inrange(first_access, 1950, 1969)
replace adopter = "middle" if inrange(first_access, 1970, 1989)
replace adopter = "late" if inrange(first_access, 1990, 2010)


separate resid, by(adopter) veryshortlabel
scatter resid? age_of_hw, msize(small vsmall vtiny ) mcolor(gs2 sandb gs11)
graph export event_study/output/scatter_resid_adopter.pdf, replace
drop resid1-resid4
*/

gen access_decade = "No access"
replace access_decade = "50s" if inrange(first_access, 1950, 1959)
replace access_decade = "60s" if inrange(first_access, 1960, 1969)
replace access_decade = "70s" if inrange(first_access, 1970, 1979)
replace access_decade = "80s" if inrange(first_access, 1980, 1989)
replace access_decade = "90s" if inrange(first_access, 1990, 1999)
replace access_decade = "00s" if inrange(first_access, 2000, 2009)
replace access_decade = "10s" if inrange(first_access, 2010, 2019)



separate resid, by(access_decade) veryshortlabel
foreach var of varlist resid1-resid7 {
	bysort age_of_hw: egen mean_`var' = mean(`var')
}
forvalues num = 1/7 {
	scatter resid`num' mean_resid`num' age_of_hw, yline(0) xline(0) msize(tiny) mcolor(dkorange navy) title("log(rcma)")
	graph export event_study/output/scatter_resid_decade_lnrcma`num'.pdf, replace
}
rename  (mean_resid1 mean_resid2 mean_resid3 mean_resid4 mean_resid5 mean_resid6) ///
		(mean_resid00s mean_resid50s mean_resid60s mean_resid70s mean_resid80s mean_resid90s)
twoway line mean_resid*s age_of_hw, sort yline(0) xline(0) lcolor(orange gs3 gs6 gs9 green sandb ) title("log(rcma)")
graph export event_study/output/lines_resid_decade_lnrcma.pdf, replace

drop resid1-resid7 mean_resid*


/*
preserve
separate resid, by(kanton) veryshortlabel
collapse resid*, by(kanton age_of_hw) 
* scatter of the highest variance cantons:
twoway scatter resid10 resid14 resid15 resid21 resid22 resid24 age_of_hw, scale(0.4) mlabel(kanton kanton kanton kanton kanton kanton) legend(off) ms(none) mlabpos(0) mlabsize(*1.2) dcolor(bg)
graph export event_study/output/scatter_resid_collapsed_k_age.pdf, replace
restore
*/



* ===========================
* No Logs
drop resid gd yr

reghdfe rcma, a(gd=i.gdenr yr=i.jahr) cluster(gdenr)	
predict resid, residuals

separate resid, by(access_decade) veryshortlabel
foreach var of varlist resid1-resid7 {
	bysort age_of_hw: egen mean_`var' = mean(`var')
}
forvalues num = 1/7 {
	scatter resid`num' mean_resid`num' age_of_hw, msize(tiny) mcolor(dkorange navy) title("rcma")
	graph export event_study/output/scatter_resid_decade_rcma`num'.pdf, replace
}
rename  (mean_resid1 mean_resid2 mean_resid3 mean_resid4 mean_resid5 mean_resid6) ///
		(mean_resid00s mean_resid50s mean_resid60s mean_resid70s mean_resid80s mean_resid90s)
twoway line mean_resid*s age_of_hw, sort yline(0) xline(0) lcolor(orange gs3 gs6 gs9 green sandb ) title("log(rcma)")
graph export event_study/output/lines_resid_decade_rcma.pdf, replace

drop resid1-resid7 mean_resid*





* ==========================
* Driving times


set more off
cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks"

use times_to_reg/output/times_to_reg.dta, clear


gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
drop access_year

bysort gdenr: gen age_of_hw = jahr - first_access


* Log_tt40
reghdfe ln_time_to_40, a(gd=i.gdenr yr=i.jahr) cluster(gdenr)	
predict resid, residuals



gen access_decade = "No access"
replace access_decade = "50s" if inrange(first_access, 1950, 1959)
replace access_decade = "60s" if inrange(first_access, 1960, 1969)
replace access_decade = "70s" if inrange(first_access, 1970, 1979)
replace access_decade = "80s" if inrange(first_access, 1980, 1989)
replace access_decade = "90s" if inrange(first_access, 1990, 1999)
replace access_decade = "00s" if inrange(first_access, 2000, 2009)
replace access_decade = "10s" if inrange(first_access, 2010, 2019)



separate resid, by(access_decade) veryshortlabel
foreach var of varlist resid1-resid7 {
	bysort age_of_hw: egen mean_`var' = mean(`var')
}
forvalues num = 1/7 {
	scatter resid`num' mean_resid`num' age_of_hw, msize(tiny) mcolor(dkorange navy) title("log(time_to_40)")
	graph export event_study/output/scatter_resid_decade_lntt40`num'.pdf, replace
}
rename  (mean_resid1 mean_resid2 mean_resid3 mean_resid4 mean_resid5 mean_resid6) ///
		(mean_resid00s mean_resid50s mean_resid60s mean_resid70s mean_resid80s mean_resid90s)
twoway line mean_resid*s age_of_hw, sort yline(0) xline(0) lcolor(orange gs3 gs6 gs9 green sandb ) title("log(rcma)")
graph export event_study/output/lines_resid_decade_lntt40.pdf, replace

drop resid resid1-resid7 mean_resid*

* ----------------
* time_to_40
drop gd yr

reghdfe time_to_40, a(gd=i.gdenr yr=i.jahr) cluster(gdenr)	
predict resid, residuals


separate resid, by(access_decade) veryshortlabel
foreach var of varlist resid1-resid7 {
	bysort age_of_hw: egen mean_`var' = mean(`var')
}
forvalues num = 1/7 {
	scatter resid`num' mean_resid`num' age_of_hw, msize(tiny) mcolor(dkorange navy) title("time to 40")
	graph export event_study/output/scatter_resid_decade_tt40`num'.pdf, replace
}
rename  (mean_resid1 mean_resid2 mean_resid3 mean_resid4 mean_resid5 mean_resid6) ///
		(mean_resid00s mean_resid50s mean_resid60s mean_resid70s mean_resid80s mean_resid90s)
twoway line mean_resid*s age_of_hw, sort yline(0) xline(0) lcolor(orange gs3 gs6 gs9 green sandb ) title("log(rcma)")
graph export event_study/output/lines_resid_decade_tt40.pdf, replace

drop resid1-resid7 mean_resid*





* =================================

* =================================




set more off
cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks"

use rcma_to_reg/output/rcma_to_reg.dta, clear


gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
drop access_year

bysort gdenr: gen age_of_hw = jahr - first_access

gen dummie_before = jahr - first_access < -10
gen dummie_window = inrange(jahr, first_access - 10, first_access + 10)
replace dummie_window = 0 if first_access == .
gen dummie_after  = jahr - first_access > 10

gen dummie = 0 + dummie_window + 2*dummie_after

/*
reghdfe stpf_norm_p90 c.ln_rcma#(dummie_before dummie_window dummie_after), a(jahr gdenr) cluster(gdenr)
margins dummie_*, dydx(ln_rcma)
*/


reghdfe ln_stpf_norm_p90 c.ln_rcma##dummie, a(jahr gdenr) cluster(gdenr)
margins ln_rcma, dydx(dummie)



reghdfe stpf_norm_p90 c.rcma##dummie, a(jahr gdenr) cluster(gdenr)
margins dummie, dydx(rcma)


* _________________________________________________ *


set more off
cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks"

use times_to_reg/output/times_to_reg.dta, clear


gen access_year = .
bysort gdenr: replace access_year = jahr if zugang_p_10 == 1
bysort gdenr: egen first_access = min(access_year)
drop access_year

bysort gdenr: gen age_of_hw = jahr - first_access

gen dummie_before = jahr - first_access < -10
gen dummie_window = inrange(jahr, first_access - 10, first_access + 10)
replace dummie_window = 0 if first_access == .
gen dummie_after  = jahr - first_access > 10

gen dummie = 0 + dummie_window + 2*dummie_after



reghdfe ln_stpf_norm_p90 c.ln_time_to_40##dummie if agglo == 0 & in_zugang_p_10 == 1, a(jahr gdenr) cluster(gdenr)
margins, dydx(ln_time_to_40) over(dummie)


reghdfe stpf_norm_p90 c.time_to_40##dummie, a(jahr gdenr) cluster(gdenr)
margins dummie, dydx(time_to_40)







*/






