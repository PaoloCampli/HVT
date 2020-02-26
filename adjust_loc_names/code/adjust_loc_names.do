* 23/1/2019
* Paolo Campli, USI
*--------------------------------------------------
* Changes the names slightly to make them consistent with the arcgis ones and have a consistent id
*


***
***
*** This doesn't work, generate wrong id as we already dropped some localities during merging!
***
***


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

*cd /Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT
use "Data/merge_townsbfsplz_commuting1950clean.dta", clear


sort name

replace name = "Aesch (Neftenbach)" if name == "Aesch ZH"
replace name = "Baar (Nendaz)" if name == "Baar Nendaz"
replace name = "Beinwil (Freiamt)" if name == "Beinwil Freiamt"
replace name = "Bertschikon (Gossau ZH)" if name == "Bertschikon"
replace name = "Blatten (Lotschen)" if name == "Blatten"
replace name = "Brione (Verzasca)" if name == "Brione Verzasca"
replace name = "Campo (Blenio)" if name == "Campo Blenio"
replace name = "Chapelle (Broye)" if name == "Chapelle Broye"
replace name = "Chapelle (Glâne)" if name == "Chapelle Glâne"
replace name = "Charmey (Gruyère)" if name == "Charmey Gruyère"
replace name = "Dettighofen (Lengwil)" if name == "Dettighofen"
replace name = "Forel (Lavaux)" if name == "Forel Lavaux"
replace name = "Gerra (Gambarogno)" if name == "Gerra Gambarogno"
replace name = "Gerra (Verzasca)" if name == "Gerra Verzasca"
replace name = "Granges (Veveyse)" if name == "Granges Veveyse"
replace name = "La Chaux (Cossonay)" if name == "La Chaux Cossonay"
replace name = "Montet (Broye)" if name == "Montet Broye"
replace name = "Montet (Glâne)" if name == "Montet Glâne"
replace name = "Mur (Vully) VD" if name == "Mur Vully VD"
replace name = "Môtier (Vully)" if name == "Môtier Vully"
replace name = "Mühlebach (Goms)" if name == "Mühlebach Goms"
replace name = "Pont (Veveyse)" if name == "Pont Veveyse"
replace name = "Prato (Leventina)" if name == "Prato Leventina"
replace name = "Praz (Vully)" if name == "Praz Vully"
replace name = "Rüthi (Rheintal)" if name == "Rüthi Rheintal"
replace name = "Schmitten (Albula)" if name == "Schmitten Albula"
replace name = "St-Germain (Savièse)" if name == "St-Germain Savièse"
replace name = "St-Saphorin (Lavaux)" if name == "St-Saphorin Lavaux"
replace name = "Sâles (Gruyère)" if name == "Sâles Gruyère"
replace name = "Treytorrens (Payerne)" if name == "Treytorrens Payerne"
replace name = "Villette (Lavaux)" if name == "Villette Lavaux"
replace name = "Vira (Gambarogno)" if name == "Vira Gambarogno"
replace name = "Wilen (Gottshaus)" if name == "Wilen Gottshaus"
replace name = "Wiler (Lötschen)" if name == "Wiler Lötschen"


drop id
sort name
gen id = _n


save "0.tasks/adjust_loc_names/output/merge_towns_adj_bfsplz_commuting1950clean.dta", replace
