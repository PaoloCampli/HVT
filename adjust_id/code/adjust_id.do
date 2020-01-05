* 28/1/2019
* Paolo Campli, USI
*--------------------------------------------------
* Changes id slightly to make it consistent with the arcgis ones 

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

use "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/adjust_id/input/merge_townsbfsplz_commuting1950clean.dta", clear


sort name

replace id = 0 if name == "Beinwil Freiamt"
replace id = 246 if name == "Beinwil am See"
replace id = 247 if name == "Beinwil Freiamt"

replace id = 0 if name == "Brione Verzasca"
replace id = 450 if name == "Brione sopra Minusio"
replace id = 451 if name == "Brione Verzasca"

replace id = 0 if name == "Granges VS"
replace id = 1403 if name == "Granges Veveyse"
replace id = 1404 if name == "Granges VS"

replace id = 0 if name == "Rüthi Rheintal"
replace id = 3158 if name == "Rüti b. Riggisberg"
replace id = 3164 if name == "Rüthi Rheintal"

replace id = 0 if name == "Schmitten Albula"
replace id = 3284 if name == "Schmitten FR"
replace id = 3285 if name == "Schmitten Albula"

replace id = 0 if name == "Wilen Gottshaus"
replace id = 4087 if name == "Wilen b. Wil"
replace id = 4090 if name == "Wilen Gottshaus"

replace id = 0 if name == "Wiler Lötschen"
replace id = 4093 if name == "Wiler b. Utzenstorf"
replace id = 4095 if name == "Wiler Lötschen"

save "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/0.tasks/adjust_id/output/merge_towns_adjid_bfsplz_commuting1950clean.dta", replace

