* Paolo Campli, USI
*--------------------------------------------------

*--------------------------------------------------
* Program Setup
*--------------------------------------------------
version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 100        // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
* --------------------------------------------------


clear matrix
cap clear mata
set matsize 11000
set maxvar 20000

cd /Users/paolocampli/hw
use times_to_reg/output/times_to_reg.dta, clear




local ln_time40 	"ln_time_to_40 		d_ln_1_time_to_40-d_ln_20_time_to_40"
local time40 		"time_to_40 		d1_time_to_40-d20_time_to_40"

local ln_time80 	"ln_time_to_80 		d_ln_1_time_to_80-d_ln_20_time_to_80"
local time80 		"time_to_80 		d1_time_to_80-d20_time_to_80"

local log_pop_vars 	"ln_stpf_norm_under_p50 ln_stpf_norm_p50_p75 ln_stpf_norm_p75_p90 ln_stpf_norm_p90"
local pop_vars 		"stpf_norm_under_p50 stpf_norm_p50_p75 stpf_norm_p75_p90 stpf_norm_p90"


local no_agglo		"zentren == 0 & agglomeration == 0"
local dist_bands 	"in_zugang_p_5 in_zugang_p_10 in_zugang_p_15 in_zugang_p_20 in_zugang_p_30 1"

local std_sample	"zentren == 0 & agglomeration == 0 & in_zugang_p_30 ==1 & obs == 1"


timer clear 1
timer on 1

***** Sureg 4 income classes *****

qui{
sureg 	(eq1: ln_stpf_norm_p90 			`ln_time40'		 i.gdenr i.jahr) ///
		(eq2: ln_stpf_norm_p75_p90 		`ln_time40'		 i.gdenr i.jahr) ///
		(eq3: ln_stpf_norm_p50_p75 		`ln_time40'		 i.gdenr i.jahr) ///
		(eq4: ln_stpf_norm_under_p50 	`ln_time40'		 i.gdenr i.jahr) ///
		(eq5: log_tax90			 		`ln_time40'		 i.gdenr i.jahr##i.kannr) ///
	if `std_sample'
}

timer off 1
timer list 1

*canton-year f.e. in 3rd equation? to be added in 3rd regression (instead of canton f.e.? think about it)
*for now no municipality specific linear time trend?
est sto sureg4inc
est table sureg4inc, keep(ln_time_to_40) b se


scalar observations = e(N)
matrix b = e(b)
matrix Vt = e(V)


scalar s_k = colsof(b)/5 // b is a row vector

mat pi = (0) // Creates 1x1 matrix with value 0
qui{
*** With canton fixed effects
mat pi = (pi,_b[eq1:ln_time_to_40]) // appends the coeff to the right
mat pi = (pi,_b[eq2:ln_time_to_40])
mat pi = (pi,_b[eq3:ln_time_to_40])
mat pi = (pi,_b[eq4:ln_time_to_40])
mat pi = (pi,_b[eq5:ln_time_to_40])
// here add more lines as we run the entire sureg
mat pi = pi[1,2...] // discards the first 0
mat mt = pi*0 // Creates a matrix "mt" with the same dimensions as pi but filled with zeros
}



mat V =(0)
mat V = (V, Vt ["eq1:ln_time_to_40", "eq1:ln_time_to_40"])
mat V = (V, Vt ["eq1:ln_time_to_40", "eq2:ln_time_to_40"])
mat V = (V, Vt ["eq1:ln_time_to_40", "eq3:ln_time_to_40"])
mat V = (V, Vt ["eq1:ln_time_to_40", "eq4:ln_time_to_40"])
mat V = (V, Vt ["eq1:ln_time_to_40", "eq5:ln_time_to_40"])
mat V = (V, Vt ["eq2:ln_time_to_40", "eq1:ln_time_to_40"])
mat V = (V, Vt ["eq2:ln_time_to_40", "eq2:ln_time_to_40"])
mat V = (V, Vt ["eq2:ln_time_to_40", "eq3:ln_time_to_40"])
mat V = (V, Vt ["eq2:ln_time_to_40", "eq4:ln_time_to_40"])
mat V = (V, Vt ["eq2:ln_time_to_40", "eq5:ln_time_to_40"])
mat V = (V, Vt ["eq3:ln_time_to_40", "eq1:ln_time_to_40"])
mat V = (V, Vt ["eq3:ln_time_to_40", "eq2:ln_time_to_40"])
mat V = (V, Vt ["eq3:ln_time_to_40", "eq3:ln_time_to_40"])
mat V = (V, Vt ["eq3:ln_time_to_40", "eq4:ln_time_to_40"])
mat V = (V, Vt ["eq3:ln_time_to_40", "eq5:ln_time_to_40"])
mat V = (V, Vt ["eq4:ln_time_to_40", "eq1:ln_time_to_40"])
mat V = (V, Vt ["eq4:ln_time_to_40", "eq2:ln_time_to_40"])
mat V = (V, Vt ["eq4:ln_time_to_40", "eq3:ln_time_to_40"])
mat V = (V, Vt ["eq4:ln_time_to_40", "eq4:ln_time_to_40"])
mat V = (V, Vt ["eq4:ln_time_to_40", "eq5:ln_time_to_40"])
mat V = (V, Vt ["eq5:ln_time_to_40", "eq1:ln_time_to_40"])
mat V = (V, Vt ["eq5:ln_time_to_40", "eq2:ln_time_to_40"])
mat V = (V, Vt ["eq5:ln_time_to_40", "eq3:ln_time_to_40"])
mat V = (V, Vt ["eq5:ln_time_to_40", "eq4:ln_time_to_40"])
mat V = (V, Vt ["eq5:ln_time_to_40", "eq5:ln_time_to_40"])
mat V = V[1,2...]


		mata: st_matrix("V", rowshape( st_matrix("V")', 5) ) // This takes the vector and puts it in matrix form
		mat li V

	local N = e(N)






/*
scalar observations = e(N)
matrix b = e(b)
matrix Vt = e(V)


scalar s_k = colsof(b)/3 // b is a row vector

mat pi = (0) // Creates 1x1 matrix with value 0
qui{
*** With canton fixed effects
mat pi = (pi,_b[eq1:zugang_p_10]) // appends the coeff to the right
mat pi = (pi,_b[eq2:zugang_p_10])
mat pi = (pi,_b[eq3:zugang_p_10])
// here add more lines as we run the entire sureg
mat pi = pi[1,2...] // discards the first 0
mat mt = pi*0 // Creates a matrix "mt" with the same dimensions as pi but filled with zeros
}



mat V =(0)
mat V = (V, Vt ["eq1:zugang_p_10", "eq1:zugang_p_10"])
mat V = (V, Vt ["eq1:zugang_p_10", "eq2:zugang_p_10"])
mat V = (V, Vt ["eq1:zugang_p_10", "eq3:zugang_p_10"])
mat V = (V, Vt ["eq2:zugang_p_10", "eq1:zugang_p_10"])
mat V = (V, Vt ["eq2:zugang_p_10", "eq2:zugang_p_10"])
mat V = (V, Vt ["eq2:zugang_p_10", "eq3:zugang_p_10"])
mat V = (V, Vt ["eq3:zugang_p_10", "eq1:zugang_p_10"])
mat V = (V, Vt ["eq3:zugang_p_10", "eq2:zugang_p_10"])
mat V = (V, Vt ["eq3:zugang_p_10", "eq3:zugang_p_10"])
mat V = V[1,2...]


		mata: st_matrix("V", rowshape( st_matrix("V")', 3) ) // This takes the vector and puts it in matrix form
		mat li V

	local N = e(N)




*/





/// Tri-dimensional parameter

		mat theta = (0,0,0,0,0)  	/* Our starting values */


/*
/// bidimensional
		mat theta = (.01,.01)  		/* Our starting values */
*/

		mat rb= J(1,5,0)
		mat rV = J(5,5,0)
		mat Q = 0



***************
* Def globals *
***************

scalar alpha=0
scalar beta=2
scalar epsilon=1/3
scalar delta1=.3
scalar delta2=.4
scalar delta3=.5
scalar delta4=.6
scalar tax = .2
scalar tax1 = 1/2
scalar tax2 = 1/3
scalar tax3 = 1/2
scalar tax4 = 1/3
scalar favtax1 = delta1/(1+delta1)
scalar favtax2 = delta2/(1+delta2)

/*
scalar Nt1= (1/tax)*0.9* ///
		 (0.9*delta1/(1+delta1) - 0.1*delta2/(1+delta2))\

scalar Nt2= (1/tax)*0.1* ///
		 (0.1*delta2/(1+delta2) - 0.9*delta1/(1+delta1))
*/

***************
** Def means **
***************

/*
bysort gdenr: egen overallmean_w = mean(medeink)
sum overallmean_w [fw=stpf_norm]
scalar w_m = r(mean)

sum stpf_norm  [fw=stpf_norm]
scalar mean_pop = r(mean)

sum stpf_norm_p90   [fw=stpf_norm]
scalar mean_stpf_p90 = r(mean)

sum stpf_norm_under_p90 [fw=stpf_norm]
scalar mean_stpf_u_p90 = r(mean)

sum eink_p90 [fw=stpf_norm]
scalar w_m_p90 = r(mean)

scalar w_mean_stpf_p90 = 1000000*w_m_p90/mean_stpf_p90
scalar w_mean_stpf_u_p90 = 1000000*(w_m*mean_pop-w_m_p90*mean_stpf_p90)/mean_stpf_u_p90

sum einkst_v0k_p90   [fw=stpf_norm]
scalar mean_tax = r(mean)

*** sample?






******************************
*** Defining the matrices ****
******************************



foreach i in mean_stpf_p90 mean_stpf_u_p90 {
		scalar N`i'=(alpha *(1-delta -w_`i'+w_m)-beta* beta/ (1+epsilon)) *(`i'/mean_pop)
		}



		scalar t1= (1/(mean_tax*mean_pop^2))*mean_stpf_u_p90* ///
		alpha* (mean_pop/w_mean_stpf_u_p90 - mean_stpf_p90/w_mean_stpf_p90)

		scalar t2= (1/(mean_tax*mean_pop^2))*mean_stpf_p90* ///
		alpha* (mean_pop/w_mean_stpf_p90 - mean_stpf_u_p90/w_mean_stpf_u_p90)

		*** maybe N1/N simply = 0.1?

* Remember: using mean w, should use median? Same for pop numbers etc

*/



cd "/Users/paolocampli/iCloud Drive (Archive)/Desktop/Work/Projects/HVT/doFiles/"




run "Paolo_HWT_Mata2.do"


*** Estimation
mata: mycmd(st_matrix("theta"))



local N = observations
ereturn post rb, obs(`N')
