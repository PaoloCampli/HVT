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

use "../input/merge_connectivity_measures.dta", clear


* time_to_40
hist time_to_40 if agglo == 0 & time_to_40 > 0, bcolor(gs6) density ///
	plotregion(fcolor(white)) graphregion(fcolor(white)) legend(off) xtitle("Drop in minutes")
graph export ../output/hist_drop_time.pdf, replace



*gain in time vs pop/time_to_40 rank 1955, color code in/out sample
sort gdenr jahr
bys gdenr: gen diff_time_to_40 = -(time_to_40[_N] - time_to_40[1])

hist diff_time_to_40  if jahr > 1955

bys gdenr: egen min_pop = min(stpf)
gen log_min_pop = log(min_pop)

separate diff_time_to_40, by(agglomeration) veryshortlabel

scatter diff_time_to_401 diff_time_to_400 log_min_pop if diff_time_to_40 >0 ///
	, sort ytitle("Cumulative drop in driving time") xtitle("Municipality initial size (log)") ///
	msize(vsmall tiny) mcolor("gs13" "gs6") leg(off) graphregion(color(white))



	*** Treatment dates, totals etc
	gen treat_year = .
	bys gdenr: replace treat_year 	= jahr if `event' > 0 & `event' < .
	bys gdenr: egen first_treat 	= min(treat_year)
	bys gdenr: egen last_treat 		= max(treat_year)
	bys gdenr: egen tot_treat 		= total(treat_year/treat_year)
			   egen cumul_treat		= total(treat_year/treat_year)
	bys jahr:  egen events_per_year = total(treat_year/treat_year)
	bys gdenr (jahr): gen events_bef_year 	= sum(events_per_year)
	gen event_fraction 				= events_bef_year/cumul_treat


	local sample "zentren == 0 & agglomeration == 0 & in_zugang_p_30 ==1"

	*** Events graphs
	twoway hist treat_year if `sample', bcolor(sandb) density yaxis(2) yscale(range(0) axis(1)) ///
		|| line event_fraction jahr  if `sample', lcolor(black) sort yaxis(1) yscale(range(0) axis(1)) ///
		, plotregion(fcolor(white)) graphregion(fcolor(white)) legend(off)
	graph export ../output/`event'.pdf, replace
