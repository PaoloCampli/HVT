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


use "/Volumes/Samsung Portable SSD T5 Paolo/hw_years_small/hw1955.dta", clear

*cd /Users/paolocampli/hw


merge m:1 id using "../input/merge_towns_adj_update_bfsplz_commuting1950clean.dta" ///
		, keepusing(gdenr resemp_1950)

keep if _merge == 3
drop _merge
rename gdenr gdenr_d


merge m:1 idO using "../input/merge_towns_adj_update_bfsplz_commuting1950clean.dta" ///
		, keepusing(gdenr)

keep if _merge == 3
drop _merge
rename gdenr gdenr_o


order gdenr_d, a(destination_name)
order gdenr_o, a(origin_name)


scalar fixed_time_cost = 10 //Arbitrary for now, in minutes
scalar kappa = 0.047 //Back of the envelope estimation, it's scale factor in next formula for commuting cost
gen commuting_cost = exp(kappa*(time + fixed_time_cost))
gen w_resemp = resemp_1950/commuting_cost

gsort gdenr_o idO -w_resemp
bys gdenr_o idO: drop if _n > 5

bys gdenr_o idO: egen rcma_t5 = total(w_resemp)
bys gdenr_o idO: gen rcma_share = w_resemp/rcma_t5

save "../output/top5_1955"

keep idO origin_name gdenr_o id destination_name gdenr_d rcma_share
save "../output/top5_1955_small"



forvalues year = 1955(2)2015 {

	use "/Volumes/Samsung Portable SSD T5 Paolo/hw_years_small/hw`year'.dta", clear


	*cd /Users/paolocampli/hw

	* Merge
	merge m:1 id using "../input/merge_towns_adj_update_bfsplz_commuting1950clean.dta" ///
			, keepusing(gdenr resemp_1950)

	keep if _merge == 3
	drop _merge
	rename gdenr gdenr_d


	merge m:1 idO using "../input/merge_towns_adj_update_bfsplz_commuting1950clean.dta" ///
			, keepusing(gdenr)

	keep if _merge == 3
	drop _merge
	rename gdenr gdenr_o


	order gdenr_d, a(destination_name)
	order gdenr_o, a(origin_name)

	merge 1:m gdenr_o gdenr_d idO id using "../output/top5_1955_small.dta", ///
			keepusing(gdenr_d id rcma_share)

	keep if _merge == 3
	drop _merge

	bys gdenr_o idO: egen w_tttop5 = total(time*rcma_share)
	collapse w_tttop5, by(gdenr_o) /* omitting an idO inside the by(), I'm taking averages among
									locations with same gdenr_o and diff idO. Seems most cost-effectove
									solution as we don't have data to distinguish e.g. pop among those*/

	gen year = `year'

	save "../output/times_top5_`year'.dta", replace


}



* Contruction of commuting zones
