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

forvalues year = 2011(1)2015 {

	use "/Volumes/Samsung Portable SSD T5 Paolo/hw_years_small/hw`year'.dta"


	*cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks"

	* Merge
	merge m:1 id using "update_gdenr/output/merge_towns_adj_update_bfsplz_commuting1950clean.dta", keepusing(gdenr)

	keep if _merge == 3
	drop _merge
	rename gdenr gdenr_d


	merge m:1 idO using "update_gdenr/output/merge_towns_adj_update_bfsplz_commuting1950clean.dta", keepusing(gdenr)

	keep if _merge == 3
	drop _merge
	rename gdenr gdenr_o


	order gdenr_d, a(destination_name)
	order gdenr_o, a(origin_name)


	merge 1:1 origin_name destination_name using ///
			"distance_cutoff/output/dist_cutoff_1955_80.dta", keepusing(origin_name destination_name distance1955 time1955)

	*drop if distance > 80
	drop if _merge < 3
	bysort origin_name: egen time_to_80 = mean(time)
	drop _merge


	merge 1:1 origin_name destination_name using ///
			"distance_cutoff/output/dist_cutoff_1955_40.dta", keepusing(origin_name destination_name)

	*drop if distance > 40
	drop if _merge < 3
	bysort origin_name: egen time_to_40 = mean(time)
	drop _merge


	* This collapse only retains current municipalities
	collapse time_to_40 time_to_80, by(gdenr_o)

	gen year = `year'

	save "dta_to_times_fixed_sample/output/times_byorigin`year'.dta", replace

}







/*


asdf

* ====================================================

set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all

forvalues year = 1955(1)2010 {

	use "/Volumes/Samsung Portable SSD T5 Paolo/hw_years_small/hw`year'.dta"


	* Merge
	merge m:1 id using "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/update_gdenr/output/merge_towns_adj_update_bfsplz_commuting1950clean.dta", keepusing(gdenr)

	keep if _merge == 3
	drop _merge
	rename gdenr gdenr_d


	merge m:1 idO using "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/update_gdenr/output/merge_towns_adj_update_bfsplz_commuting1950clean.dta", keepusing(gdenr)

	keep if _merge == 3
	drop _merge
	rename gdenr gdenr_o


	order gdenr_d, a(destination_name)
	order gdenr_o, a(origin_name)


	merge 1:1 origin_name destination_name using "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/distance_cutoff/output/dist_cutoff_2010_80.dta"

	drop if distance > 80
	bysort origin_name: egen time_to_80 = mean(time)
	drop _merge


	merge 1:1 origin_name destination_name using "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/distance_cutoff/output/dist_cutoff_2010_40.dta"

	drop if distance > 40
	bysort origin_name: egen time_to_40 = mean(time)
	drop _merge


	* This collapse only retains current municipalities
	collapse time_to_40 time_to_80, by(gdenr_o)

	gen year = `year'

	save "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/dta_to_times_fixed_sample/output/times_byorigin`year'_2010.dta", replace

}
