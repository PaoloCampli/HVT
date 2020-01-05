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

cd /Users/paolocampli/hw/data_to_maps/code

use "../../top5times_to_reg/output/top5times_to_reg.dta"
keep gdenr jahr w_tttop5 gdename log_tax90 kannr zentren agglomeration 
bys gdenr: replace kannr = kannr[1]
bys gdenr: replace gdename  = gdename[1]
save "../input/top5times_names.dta", replace


clear
import delimited "../input/swiss_towns_WGS84.csv", encoding(UTF-8)

gen kannr = substr(kantonsnum, 3, 2)
drop kantonsnum
destring kannr, replace
rename namn1 gdename

* Just one duplicate for gdename+kannr, drop one arbitrarily
drop if bfs_nummer == 627 & gdename == "Ried"

merge 1:m gdename kannr using "../input/top5times_names.dta"
keep if _merge == 3
drop _merge

bys gdename (jahr): gen drop_tttop5 = - w_tttop5[_N] + w_tttop5[1]
* the following should be improved: many municip only have tax data later on, 
* so log_tax[1] is == . and same for the resulting expression
bys gdename (jahr): gen drop_log_tax = - log_tax90[_N] + log_tax90[1]


collapse x y bfs_nummer kannr drop_tttop5 drop_log_tax zentren agglomeration, by(gdenr)


hist drop_tttop5 if agglo == 0 & drop_tttop5 > 0, bcolor(gs6) density ///
	plotregion(fcolor(white)) graphregion(fcolor(white)) legend(off) xtitle("Drop in minutes")
graph export ../output/hist_drop.pdf, replace


export delimited using "../output/data_to_maps.csv", replace
