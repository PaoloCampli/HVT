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


use "/Volumes/Samsung Portable SSD T5 Paolo/hw_years_small/hw1955.dta"


* ---------------------------------------------------------

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

rename (distance time) (distance1955 time1955)

* ---------------------------------------------------------


drop if distance > 80
save "distance_cutoff/output/dist_cutoff_1955_80.dta", replace

drop if distance > 60
save "distance_cutoff/output/dist_cutoff_1955_60.dta", replace

drop if distance > 40
save "distance_cutoff/output/dist_cutoff_1955_40.dta", replace

drop if distance > 20
save "distance_cutoff/output/dist_cutoff_1955_20.dta", replace



* ========================================================
asdf








*** Version which creates cutoffs fixed at the end period

use "/Volumes/Samsung Portable SSD T5 Paolo/hw_years_small/hw2010.dta", clear


* ---------------------------------------------------------


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


* ---------------------------------------------------------


drop if distance > 80
save "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/distance_cutoff/output/dist_cutoff_2010_80.dta", replace

drop if distance > 60
save "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/distance_cutoff/output/dist_cutoff_2010_60.dta", replace

drop if distance > 40
save "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/distance_cutoff/output/dist_cutoff_2010_40.dta", replace

drop if distance > 20
save "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/distance_cutoff/output/dist_cutoff_2010_20.dta", replace
