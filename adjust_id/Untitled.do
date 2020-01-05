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

