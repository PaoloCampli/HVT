*--------------------------------------------------
* Takes ODyear csv, cleans it, merge with merge_townsbfsplz_commuting1950, keeps successful merges, construct rcma, fcma,
* keeps these + origin properties and collapse by origin, saves the resulting small file
*
*
* Change local year for import and save
*
*
* 23/11/2018
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



forvalues year = 2011(2)2015 {

	* Cleaning ODyear
	use "/Volumes/Samsung Portable SSD T5 Paolo/hw_years_small/hw`year'.dta"



	* Create a variable "number of destinations" for each origin, drops the least connected
	bysort idO: egen Fnum_dest = total(idO)
	gen num_dest = Fnum_dest/idO
	drop Fnum_dest
	drop if num_dest < 5
	drop num_dest


	* ---------------------------------------------------------

	*cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks"

	* Merge
	merge m:1 id using "update_gdenr/output/merge_towns_adj_update_bfsplz_commuting1950clean.dta" ///
			, keepusing(gdenr resemp_1950 wkpemp_1950)

	keep if _merge == 3
	drop _merge

	rename gdenr gdenr_d

	merge m:1 idO using "update_gdenr/output/merge_towns_adj_update_bfsplz_commuting1950clean.dta" ///
			, keepusing(gdenr)

	keep if _merge == 3
	drop _merge

	rename gdenr gdenr_o

	order gdenr_d, a(destination_name)
	order gdenr_o, a(origin_name)


	* ---------------------------------------------------------


	* Measures of market access: residents commuter market access: rcma; and for firms: fcma
	scalar fixed_time_cost = 10 //Arbitrary for now, in minutes
	scalar kappa = 0.047 //Back of the envelope estimation, it's scale factor in next formula for commuting cost
	gen commuting_cost = exp(kappa*(time + fixed_time_cost))
	bysort origin_name: egen rcma = total(resemp_1950/commuting_cost)
	bysort origin_name: egen fcma = total(wkpemp_1950/commuting_cost)
	order time commuting_cost rcma fcma, a(destination_name)


	* ---------------------------------------------------------


	collapse (mean) rcma fcma (max) max_rcma=rcma max_fcma=fcma (min) min_rcma=rcma min_fcma=fcma, by(gdenr_o)


	* ---------------------------------------------------------


	gen year = `year'

	* histogram rcma, frequency title(residents commuter market access `year' kappa = 0.047)
	* graph save Graph "/Users/paolocampli/Desktop/Work/Projects/HVT/Graphs/rcma`year'.gph", replace

	save "dta_to_rcma/output/mkt_access_byorigin`year'_cut.dta", replace

}
