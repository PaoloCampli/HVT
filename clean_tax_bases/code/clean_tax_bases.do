* 28/1/2019
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


********
* Data *
********

*cd /Users/paolocampli/hw
use ../input/data_Paolo.dta, clear

qui: sum jahr if stpf_norm != .
global y_min = r(min)
global y_max = r(max)


generate periode=(jahr-1)/2-973
order gdenr gdename beznr bezname kannr kanton jahr periode


*******************************************************************
* Municipalities change canton in BE, JU, BL -> use canton of 2011*
*******************************************************************
sort gdenr jahr
g cnr = kannr if jahr == 2011
g cname = kanton if jahr == 2011
gsort gdenr -jahr
replace cnr = cnr[_n-1] if cnr==.
replace cname = cname[_n-1] if cname==""
sort gdenr jahr
replace kannr = cnr if kannr != cnr
replace kanton = cname if kanton != cname


xtset gdenr periode

*************
* Variables *
*************
g zentren_cat1 = (dist_zentrum_cat1 == 0)
g zentren_cat2 = (dist_zentrum_cat2 == 0)


*****************
* Data cleaning *
*****************
replace zentren = 0 if zentren == 1 & agglo == 0 // redefine agglo & center: 9 municipalities that are center but not part of an agglomeration -> zentren = 0

gsort gdenr -jahr
foreach var of varlist agglo zentren see dist_flughafen dist_zentrum*{
bysort gdenr: replace `var' = `var'[_n-1] if `var' == . // missing values in first years
}
sort gdenr jahr

*Restrict period to 2010
drop if jahr == 2011 /* only one observation for tax base for a two-year period */

***************************************************************************************
* Tax base : Income and Tax revenue pro inhabitant & share of top (bottom) X% (in Mio)*
***************************************************************************************

* Share of top X%
foreach var in stpf_norm{
g s_`var'_p50_p75 = s_`var'_p50 - s_`var'_p75
g s_`var'_p75_p90 = s_`var'_p75 - s_`var'_p90
}

* Number of taxpayers
foreach var in stpf_norm stpf_norm_under_p50 stpf_norm_p50_p75 stpf_norm_p75_p90 stpf_norm_p90 stpf_norm_p75{
cap g `var' = s_`var'*stpf_norm
}


***************************
* Composition of population
***************************

g resemp_ed = resemp_e1 + resemp_e2 + resemp_e3
g wkpemp_ed = wkpemp_e1 + wkpemp_e2 + wkpemp_e3
g linwin_ed = linwin_e1 + linwin_e2 + linwin_e3
g loutwin_ed = loutwin_e1 + loutwin_e2 + loutwin_e3
g linwout_ed = linwout_e1 + linwout_e2 + linwout_e3

foreach v in e1 e2 e3{
g s_resemp_`v' = resemp_`v'/resemp_ed
g s_wkpemp_`v' = wkpemp_`v'/wkpemp_ed
g s_linwin_`v' = linwin_`v'/linwin_ed
g s_loutwin_`v' = loutwin_`v'/loutwin_ed
g s_linwout_`v' = linwout_`v'/linwout_ed
}

***********
* Use logs
***********

foreach var of varlist s_* eink medeink eink_* stpf stpf_* stbetr stbetr_* einkst_v0k_* /* nb_firms*  nb_emp* */ ewg efh rents einwohner gini linwin* linwout* loutwin* resemp* wkpemp*{
qui: g ln_`var' = ln(`var')
}


**************************
* Municipalities at access
**************************

foreach var in zugang_p{
generate `var'_0=0
replace `var'_0=1 if `var'==0
}


**************************
* Distance bands (Splines)
**************************
foreach var in zugang_p{
generate `var'_5t10=0
replace `var'_5t10=1 if `var'_5==0 & `var'_10==1

generate `var'_10t15=0
replace `var'_10t15=1 if `var'_10==0 & `var'_15==1

/*
generate `var'_15t20=0
replace `var'_15t20=1 if `var'_15==0 & `var'_20==1

generate `var'_10t20=0
replace `var'_10t20=1 if `var'_10==0 & `var'_20==1
*/
g in_`var'_5t10 = (in_`var'_10 == 1 & in_`var'_5 == 0)
g in_`var'_10t15 = (in_`var'_15 == 1 & in_`var'_10 == 0) //mun. with an access between 10-15km but that nerver had any access closer than 10
/*
g in_`var'_15t20 = (in_`var'_20 == 1 & in_`var'_15 == 0) //mun. with an access between 15-20km but that nerver had any access closer than 15
g in_`var'_10t20 = (in_`var'_20 == 1 & in_`var'_10 == 0) //mun. with an access between 10-20km but that nerver had any access closer than 10
*/
}


***********************
* Highway age variables
***********************
sort gdenr periode

foreach type in zugang_p{
foreach d in /*20*/ 15 10 5{

* 1. periode_zugang_*: 2-year period when getting an access within * km reach
generate periode_`type'_`d'=periode if `type'_`d'==1 & l1.`type'_`d'==0
bysort gdenr (periode_`type'_`d'): replace periode_`type'_`d' = periode_`type'_`d'[1]
sort gdenr periode

* 2. alter_`type'_*: Number of periods since periode_`type'_*
generate alter_`type'_`d'=periode-periode_`type'_`d'

* 3. Calculate dummies for each age value of alter_`type'_*
* 3a. Positive ages:
forvalues t = 0/28 {
generate a_`type'_`d'_plus`t' = alter_`type'_`d'==`t'
}

* 3b. Negative ages ("run-up period"):
forvalues t = 1/31 {
generate a_`type'_`d'_minus`t' = alter_`type'_`d'==-`t'
}

** 10 periods plus:
generate ag_`type'_`d'_p10p=0
replace ag_`type'_`d'_p10p=1 if alter_`type'_`d'>=10

** 11 periods plus:
generate ag_`type'_`d'_p11p=0
replace ag_`type'_`d'_p11p=1 if alter_`type'_`d'>=11

** 8 periods minus:
generate ag_`type'_`d'_p8m=0
replace ag_`type'_`d'_p8m=1 if alter_`type'_`d'<=8

}
}

****************
* Opening year *
****************
foreach type in zugang_p{
foreach d in 10{
g o_`type'_`d'_d = (`type'_`d'==1 & `type'_`d'[_n-1]==0)
g o_`type'_`d'_tmp = jahr if `type'_`d'==1 & `type'_`d'[_n-1]==0
bysort gdenr: egen  o_`type'_`d' = mean(o_`type'_`d'_tmp)
drop o_`type'_`d'_tmp

sort gdenr jahr
g o_`type'_`d'_70 = (o_`type'_`d' >= 1970 & o_`type'_`d' < 1990)
g o_`type'_`d'_90 = (o_`type'_`d' >= 1990)
}
}

**********************
* Trend and periodes *
**********************
g trend = .
replace trend = periode if a_zugang_p_10_plus0 ==1
bysort gdenr: egen periode_tmp = mean(trend)
replace trend = periode-periode_tmp

cap drop per_*
g per_50_60 = (o_zugang_p_10 < 1970)
g per_70_80 = (o_zugang_p_10 >= 1970 & o_zugang_p_10 < 1990)
g per_90_00 = (o_zugang_p_10 >= 1990)



**********************************************************
* Transform lags to compute long-term effects as in DMcK *
**********************************************************
sort gdenr periode
/* data for long-term effect as in Davidson and MacKinnon */
/* replace missing values due to lags by 0 */
foreach type in zugang_p{
foreach d in 5 10 15 /*20*/ 5t10 10t15 /*15t20 10t20*/{
foreach t of numlist 1/20{
g L`t'_`type'_`d' = L`t'.`type'_`d'
replace L`t'_`type'_`d' = 0 if L`t'_`type'_`d' == .
g l`t'_`type'_`d' = L`t'_`type'_`d'-`type'_`d' //x_t - x_t-j
drop L`t'_`type'_`d'
}
}
}
sort gdenr periode

**********
* Labels *
**********
foreach type in zugang_p{
label var `type'_10 "Long-term effect ($\hat{\gamma}$)"
label var `type'_15 "Long-term effect ($\hat{\gamma}$)"
/*label var `type'_20 "Long-term effect ($\hat{\gamma}$)"*/
}

foreach type in zugang_p{
label var `type'_5 "Long-term 0-5 km"
label var `type'_5t10 "Long-term 5-10 km"
label var `type'_10t15 "Long-term 10-15 km"
/*label var `type'_15t20 "Long-term 15-20 km"*/
}
label var auslander "\% Foreign nationals"
label var junge "\% Young (< 15)"
label var alte_80 "\% Old (>= 80)"
label var wirtsektII "\% Workers in secondary sector"
label var wirtsektIII "\% Workers in tertiary sector"
label var nichterwerb "Unemployment rate"
label var kino "No. of movie theaters within 10 km"


*********************************************************************
* Data for analysis on commuting (aggregated data per municipality) *
*********************************************************************
foreach co of varlist linwout loutwin{
foreach var of varlist `co'_trsp `co'_car `co'_train `co'_train_bus{
g `var'_ed = `var'_e1+`var'_e2+`var'_e3 /*generate totals based on education and trsp mode*/
g ln_`var'_ed = ln(`var'_ed)
g ln2_`var'_ed = ln(`var'_ed+1)
g ln_dist_`var' = ln(dist_`var')
foreach ed in e1 e2 e3{
g ln2_`var'_`ed' = ln(`var'_`ed'+1)
g ln_dist_`var'_`ed' = ln(dist_`var'_`ed')
}
}
}


foreach var in zugang_p{
g in_`var'_0 = d_`var'
}


save ../output/clean_tax_bases.dta, replace
