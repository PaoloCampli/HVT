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

forvalues year = 1955(1)2010 {

	* Cleaning ODyear
	import delimited "/Volumes/Samsung Portable SSD T5 Paolo/hw_years/hw`year'.csv", delimiter("", asstring) encoding(UTF-8) clear
	
	split v3, p(" - ")
	
	sort v32 
	egen id = group(v32)
	sort v31
	egen idO = group(v31)
	
	rename v3 path
	rename (v31 v32) (origin_name destination_name)
	drop v1 v2
	
	gen time = v4*60
	gen distance = v5/1000
	drop v4 v5
	
	order idO origin_name id destination_name time distance
	
	label variable time "minutes"
	label variable distance "km"
	label variable id "destination id"
	label variable idO "origin id"
	
	compress
	
	* Create a variable "number of destinations" for each origin, drops the least connected
	bysort idO: egen Fnum_dest = total(idO)
	gen num_dest = Fnum_dest/idO
	drop Fnum_dest 
	drop if num_dest < 5
	drop num_dest 
	
	
	* ---------------------------------------------------------
	
	
	* Merge
	merge m:1 id using "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/update_gdenr/output/merge_towns_adj_update_bfsplz_commuting1950clean.dta"
	
	keep if _merge == 3
	drop _merge 
	
	rename gdenr gdenr_d
	
	merge m:1 idO using "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/update_gdenr/output/merge_towns_adj_update_bfsplz_commuting1950clean.dta", keepusing(gdenr)
	
	keep if _merge == 3
	drop _merge 
	
	rename gdenr gdenr_o
	
	order gdenr_d, a(destination_name)
	order gdenr_o, a(origin_name)
	
	
	* ---------------------------------------------------------
	
	drop if distance > 80
	bysort origin_name: egen time_to_80 = mean(time)
	
	drop if distance > 60
	bysort origin_name: egen time_to_60 = mean(time)

	drop if distance > 40
	bysort origin_name: egen time_to_40 = mean(time)
	
	drop if distance > 20
	bysort origin_name: egen time_to_20 = mean(time)
	
	
	collapse time_to_20 time_to_40 time_to_60 time_to_80, by(gdenr_o)
	
	gen year = `year'
	
	save "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/csv_to_times/output/times_byorigin`year'.dta", replace

	
}
	

