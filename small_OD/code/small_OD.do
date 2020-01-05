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

forvalues year = 1955(1)2015 {

	* Cleaning ODyear
	import delimited "/Volumes/Samsung Portable SSD T5 Paolo/hw_years/hw`year'.csv" ///
		, delimiter("", asstring) encoding(UTF-8) clear
	
	split v3, p(" - ")
	
	sort v32 
	egen id = group(v32)
	sort v31
	egen idO = group(v31)
	rename (v31 v32) (origin_name destination_name)
	drop v1 v2 v3
	
	gen time = v4*60
	gen distance = v5/1000
	drop v4 v5
	
	order idO origin_name id destination_name time distance
	
	label variable time "minutes"
	label variable distance "km"
	label variable id "destination id"
	label variable idO "origin id"
	
	format origin_name destination_name %-12s 
	
	compress
	
	* Create a variable "number of destinations" for each origin, drops the least connected
	bysort idO: egen Fnum_dest = total(idO)
	gen num_dest = Fnum_dest/idO
	drop Fnum_dest 
	drop if num_dest < 5
	drop num_dest 
	
	* Drops many pairs to keep data small
	drop if distance > 100
	
	save "/Volumes/Samsung Portable SSD T5 Paolo/hw_years_small/hw`year'.dta", replace
	
}


/*
forvalues year = 1957(1)2015 {

	use "/Volumes/Samsung Portable SSD T5 Paolo/hw_years_small/hw`year'.dta", clear
	
	drop path
	format origin_name destination_name %-12s 

	save "/Volumes/Samsung Portable SSD T5 Paolo/hw_years_small/hw`year'.dta", replace

}
*/
