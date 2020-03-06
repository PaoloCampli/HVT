mata: // there are two routines in this mata section
mata clear 



void mycmd(theta) // optimisation program
	{
		external pi, pi90, pi75, pi50, iV, iV90, iV75, iV50, alpha, beta, epsilon, tax, tax1, tax2, tax3, tax4, delta1, delta2, delta3, delta4  /* w_m, mean_pop, mean_stpf_p90, mean_stpf_u_p90, w_m_p90, w_mean_stpf_p90, w_mean_stpf_u_p90, mean_tax, Nmean_stpf_u_p90, Nmean_stpf_p90, t1, t2 */
		
	//	Setting up calibrated parameters and estimate matrices
		alpha = st_numscalar("alpha") // defines a scalar
		beta = st_numscalar("beta") // defines a scalar
		epsilon = st_numscalar("epsilon") // defines a scalar
		delta1 = st_numscalar("delta1") // defines a scalar
		delta2 = st_numscalar("delta2") // defines a scalar
		delta3 = st_numscalar("delta3") // defines a scalar
		delta4 = st_numscalar("delta4") // defines a scalar
		tax = st_numscalar("tax") // defines a scalar
		tax1 = st_numscalar("tax1") // defines a scalar
		tax2 = st_numscalar("tax2") // defines a scalar
		tax3 = st_numscalar("tax3") // defines a scalar
		tax4 = st_numscalar("tax4") // defines a scalar
		
		/*
		w_m = st_numscalar("w_m")
		mean_pop = st_numscalar("mean_pop")
		mean_stpf_p90 = st_numscalar("mean_stpf_p90")
		mean_stpf_u_p90 = st_numscalar("mean_stpf_u_p90")
		w_m_p90 = st_numscalar("w_m_p90")
		w_mean_stpf_p90 = st_numscalar("w_mean_stpf_p90")
		w_mean_stpf_u_p90 = st_numscalar("w_mean_stpf_u_p90")
		mean_tax = st_numscalar("mean_tax")
		Nmean_stpf_u_p90 = st_numscalar("Nmean_stpf_u_p90")
		Nmean_stpf_p90 = st_numscalar("Nmean_stpf_p90")
		t1 = st_numscalar("t1")
		t2 = st_numscalar("t2")
		*/
		
		pi = st_matrix("pi") // defines the reduced for coefficient matrix
		pi50 = st_matrix("pi50") // defines the reduced for coefficient matrix
		pi75 = st_matrix("pi75") // defines the reduced for coefficient matrix
		pi90 = st_matrix("pi90") // defines the reduced for coefficient matrix
		V = st_matrix("V") // defines var-cov matrix
		V50 = st_matrix("V50") // defines var-cov matrix
		V75 = st_matrix("V75") // defines var-cov matrix
		V90 = st_matrix("V90") // defines var-cov matrix
		iV = cholinv(V) // positive definite matrix inversion of V	
		iV50 = cholinv(V50) // positive definite matrix inversion of V	
		iV75 = cholinv(V75) // positive definite matrix inversion of V
		iV90 = cholinv(V90) // positive definite matrix inversion of V

	//	Initiating the optimisation
		init = st_matrix("theta") // initial values
		S = optimize_init() // initiates the optimiser...
	
	//	Defining the optimisation criteria
		optimize_init_evaluator(S, &i_crit()) // "i_crit()" is the user-defined evaluation function. It reports "f(p)"
		
	//	Defining the optimisation environment
		optimize_init_which(S, "min") // minimisation
		optimize_init_evaluatortype(S, "d0") // "d0" is the version which doesn't return a gradient rowvector
		optimize_init_params(S, init) // "init" is a real rowvector of initial values
		optimize_init_conv_warning(S, "on") // specifies whether the warning message "convergence not achieved"
		optimize_init_technique(S, "nm 10") // Nelder-Mead technique...
		optimize_init_nmsimplexdeltas(S, 0.5*J(1,cols(5),1)) // sets initial values to be used along with initial parameter values
	
	//	Performs the optimisation
		p = optimize(S) // performs the optimization and returns a real row vector of the parameter values that achieve the minimum
		
	//	Report the optimised values
		p
	

		chi=optimize_result_value(S) // function that is used to access other values associated with the solution
		chi = (chi) 
		chi 		

		
	//	st_replacematrix("mt",mt)		 	 
	//	st_replacematrix("Q",chi)
		st_replacematrix("rb",p)
	//	st_replacematrix("rV",pV)
	//	st_replacematrix("tV",pV)
	}
	
void i_crit(todo,b,crit,g,H) // This is the evaluator function f(). "b" represents parameters, 
							//"crit" is what is being evaluated (essentially a function), "g" is gradient, 
						   //"H" is a hesssian. However, "d1" is specified here. So, only g1 is relevant.
	{ 
		external pi, pi90, pi75, pi50, iV, iV90, iV75, iV50, alpha, beta, epsilon, tax, tax1, tax2, tax3, tax4, delta1, delta2, delta3, delta4  /* w_m, mean_pop, mean_stpf_p90, mean_stpf_u_p90, w_m_p90, w_mean_stpf_p90, w_mean_stpf_u_p90, mean_tax, Nmean_stpf_u_p90, Nmean_stpf_p90, t1, t2 */
		
			
		c=b
		
	    lambda1 = c[1]
		mu1 = c[2]
		mu2 = c[3]	
		mu3 = c[4]
		mu4 = c[5]	
		
		
		m = J(1,5,0) // Row vector with 3 columns and filled with zeros
		
		
		B = (mu1 \ mu2 \ mu3 \ mu4 \ 0) // missing the mean commuting time factor
		
		
/*
///		Two-classes and two-mu miopic	
A75 = (1/tax)*(0.75*0.25)*(lambda1*delta1/(1+delta1)+(0.75/(1-0.75))*lambda1*delta2/(1+delta2)-(1/0.25)*delta2/(1+delta2))
	
		A = 	(1/beta,				0,				-delta1+tax/(1-tax) \ ///
				 0, 				1/beta,  			-delta2+tax/(1-tax) \ ///
				A75,    			-A75,								-1)


/// **************************************************************************************************
*/
/*
///		Two-classes and two-mu non-miopic 50p (with y1=5, y2=1, i.e. tax base = 1.4)
base_u50 = .19
tax_u50 = 
tax_50 = 
A50 = (1/tax)*(0.5*0.5)*(lambda1*delta1/(1+delta1)+(0.5/(1-0.5))*lambda1*delta2/(1+delta2)-(1/0.5)*delta2/(1+delta2))

	
	
		A = 	(1/beta-(1-base_u50),				-base_u50,				-delta1+tax_50/(1-tax_50) \ ///
						 -(1-base_u50), 			1/beta-base_u50,  			-delta2+tax_u50/(1-tax_u50) \ ///
						A50,   						 -A50,								-1)
				
/// **************************************************************************************************
*/
/*						
///		Two-classes and two-mu non-miopic 75p (with y1=5, y2=1, i.e. tax base = 1.4)
base_u70 = .37
tax_u70 = 
tax_70 = 
A75 = (1/tax)*(0.75*0.25)*(lambda1*delta1/(1+delta1)+(0.75/(1-0.75))*lambda1*delta2/(1+delta2)-(1/0.25)*delta2/(1+delta2))

	
	
		A = 	(1/beta-(1-base_u70),				-base_u70,				-delta1+tax_70/(1-tax_70) \ ///
						 -(1-base_u70), 			1/beta-base_u70,  			-delta2+tax_u70/(1-tax_u70) \ ///
						A75,   						 -A75,								-1)						

/// **************************************************************************************************
*/
/*
///	Two-classes and two-mu non-miopic 90p (below 90p: taxes paid = 20%, tax base = 67%)
base_u90 = 0.67
tax_u90 = 0.1
tax_90 = 0.3
A90 = (1/tax)*(0.9*0.1)*(lambda1*(delta1/(1+delta1)+(0.9/(1-0.9))*delta2/(1+delta2))-(1/0.1)*delta2/(1+delta2))

	
	
		A = 	(1/beta-(1-base_u90),				-base_u90,				-delta1+tax_90/(1-tax_90) \ ///
						 -(1-base_u90), 			1/beta-base_u90,  			-delta2+tax_u90/(1-tax_u90) \ ///
									A90,   					-A90,									-1)
					
/// **************************************************************************************************
*/

///	4-classes and 4-mu non-miopic bottom50-75-90-100
base_90 = .34
base_7590 = .23
base_5075 = .24
base_u50 = .19

tax_90 = 0.3
tax_7590 = 0.2
tax_5075 = 0.15
tax_u50 = 0.1

favtax1 = delta1/(1+delta1)
favtax2 = delta2/(1+delta2)
favtax3 = delta3/(1+delta3)
favtax4 = delta4/(1+delta4)

A1 = lambda1*(1/tax)*.1*(favtax1*(1-.1)	-2*favtax2*.15		-3*favtax3*.25		-4*favtax4*.5)
A2 = lambda1*(1/tax)*.15*(-favtax1*.1	+2*favtax2*(1-.15)	-3*favtax3*.25		-4*favtax4*.5)
A3 = lambda1*(1/tax)*.25*(-favtax1*.1	-2*favtax2*.15		+3*favtax3*(1-.25)	-4*favtax4*.5)
A4 = lambda1*(1/tax)*.50*(-favtax1*.1	-2*favtax2*.15		-3*favtax3*.25		+4*favtax4*(1-.5))
	
	
		A = 	(1/beta-base_90,	      -base_7590,	      -base_5075,	      -base_u50,	-delta1+tax_90/(1-tax_90) \ ///
					   -base_90,	1/beta-base_7590,	      -base_5075,	      -base_u50,	-delta2+tax_7590/(1-tax_7590) \ ///
			           -base_90,     	  -base_7590,	1/beta-base_5075,	      -base_u50,	-delta3+tax_5075/(1-tax_5075) \ ///
					   -base_90,	      -base_7590,	      -base_5075,	1/beta-base_u50,	-delta4+tax_u50/(1-tax_u50) \ ///
							 A1,   			      A2,				  A3,				 A4,					        -1)
					
												
						
						
						
						
/// if I reg a semi-elasticity (i.e. level instead of log of tax) can I get rid of 1/tax in A13??

	

		A_1 = luinv(A)
		
		
		mt = (A_1*B)'	
	
	
		m = pi-mt // comparing reduced form estimates with moments from the model
		
		
	//	This is the minimisation criteria
		crit = m*iV*m' 		

		
				
	} 	
end


// Miopic version: public good is linear function of tax: g=t e allo stesso modo g_hat=t_hat


