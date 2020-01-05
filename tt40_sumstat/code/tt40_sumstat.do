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

keep 	gdename gdenr kannr jahr periode time_to_40 time_to_80 zugang_p_10 zentren ///
		agglomeration in_zugang_p_10 in_zugang_p_30 ln_time_to_40 ///
		ln_stpf_norm_p90 log_tax90 

		
foreach var of varlist time_to_40-time_to_80 {
	bysort gdenr: gen `var'_reduction = - D.`var'
}

rename (time_to_40_reduction time_to_80_reduction) (tt40_red tt80_red)
order tt40_red tt80_red, a(gdename)


foreach var of varlist tt40_red-tt80_red {
	qui: sum `var'
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

order top01* top10* top25*, a(tt80_red)


foreach v of varlist top01_norm_tt40_red-top25_norm_tt80_red {
	bys gdenr: egen tot_`v' = total(`v')
}

order tot_*, a(top25_norm_tt80)


foreach v of varlist top01_norm_tt40_red-top25_norm_tt80_red {
	gen in_`v' = tot_`v' > 0
}



foreach v of varlist top01_norm_tt40_red-top25_norm_tt80_red {
	bys gdenr: gen sum_`v' = sum(`v')
}


gen balanced = sum_top01_norm_tt40_red



save tt40_sumstat/output/tt40_sumstats.dta, replace









