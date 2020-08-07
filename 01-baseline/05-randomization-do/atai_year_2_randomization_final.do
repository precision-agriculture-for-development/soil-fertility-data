clear all
drop _all
set more off
set matsize 11000
label drop _all
version 14.0

cap log close
set logtype text

/****************************************************************************
NOTE: This file may not run. We made minimal modifications to protect PII.
****************************************************************************/

*specify main path
cd ""

*Input data
loc inputdata "01-baseline/04-cleaned-data/merged/ATAI_baseline_all.dta"
*loc inputdata "${Main}0518_Randomization/Data/Input/ATAI_baseline_all.dta"

*Output data
loc outputdata "01-baseline/04-cleaned-data/merged/ATAI_baseline_treatment_assignment.dta"


*Log
loc logfile "OMITTED"

log using "`logfile'", replace

use "`inputdata'" , clear 

sort uid
duplicates list uid
/*
 Rerandomization involves checking Balance for a set of covariates:
 Checking Balance within strata on key covariates:
 a) Age (age)
 b) Resides in a pucca house (pucca_house)
 c) Has his soil tested before (soil_test_before)
 d) Risk attitude regarding agricultural matters (risk_attitude_agriculture)
 e) Sampled plot size
 f) Sampled plot cotton yield
 g) Urea applied in the sampled plot in 2017 (fertilizer_plot_kg_bigha_1)
 h) DAP applied in the sampled plot in 2017 (fertilizer_plot_kg_bigha_3)
 i) MOP applied in the sampled plot in 2017 (fertilizer_plot_kg_bigha_5)
 j) Zinc applied in the sampled plot in 2017 (fertilizer_plot_kg_bigha_12)
 k) Total land devoted to grow cotton
*/

*Define the covariates here
#delimit ;
local covariates	age
					pucca_house
					soil_test_before
					risk_attitude_agriculture
					sampled_plot_size
					sampled_plot_yield
					fertilizer_plot_kg_bigha_1
					fertilizer_plot_kg_bigha_3
					fertilizer_plot_kg_bigha_5
					fertilizer_plot_kg_bigha_12
					total_cotton_land
					;


#delimit cr

sum `covariates' , d

*Hardcode the numer of covariates we will be checking balance
local numcovariates = 11


*Hardcode the variables that we will use to assign farmes into stratas
local stratavars =  "block"
*local stratavars =  "village_code"
egen  strata = group(`stratavars')
qui tab strata

*Total number of strata (hardcoded) 
local numstrata= r(r) 
display `numstrata'

/*generating a local variable strata needed
below in a foreach loop */
levelsof strata, local(strata) 

local totcoefs_stratum_by_stratum = `numstrata'*`numcovariates'


distinct strata
tab strata
tabmiss strata


bys strata: gen totnum = _N
la var totnum "Total # Farmers in Stratum"


preserve
duplicates drop strata, force
list `stratvars' totnum  strata
restore

/*
Starting with Rerandomization loop
The idea is that within each stratum we want to compare 
treatment mean to the control mean and compute the t-statistics (2 for each 
stratum for each variable) and keep re-randomizing until the largest
t-statistic for any stratum is below 1.3

We then carried out the following iterative procedure to allocate farmers into two arms within each
stratum (i.e. we use within-stratum randomization).
1. Within each stratum, randomize farmers into two treatment arms.
2. Using this treatment assignment do the following: Within each stratum  regress each of 11 baseline
covariates on treatment assignment dummies and conduct a Wald test of the null hypothesis that the associated coefficients
are jointly equal to zero. Then, collect the associated p-values.

3. Collect all the p-values from across the stratas and compute the fraction of these that
are less than .05. If the fraction is lower than .025, then stop. If not, return to step 1.
*/

set seed 9000


*Step 1: Randomization

*Hardcode the number of treatments. In case we want to change it later
local ntreatments = 2

sort uid
gen rand = uniform()
bys strata (rand) : gen rank = _n
bys strata: gen totobs = _N
replace rank = rank + strata - 1 /*alternate the order of T/C assignment across strata*/

bys strata : gen treatment = mod(rank,`ntreatments')+1
tab treatment 

la var treatment "Treatment"
label define treatment 1 "T" 2 "C"
label values treatment treatment

foreach num of numlist 1/`ntreatments'{
	
	bys strata: egen total_treated_`num' = sum(treatment ==`num')
	gen frac_treated_`num' = total_treated_`num'/totobs
    
	}

tab treatment, gen(tdum)

 /**************************************************************
 Generating the Table for the 2 arms randomization balance 
 ****************************************************************/

*Step 2: Computing the p-values for randomization

 matrix mat_pvals_final = J(`numstrata',`numcovariates',.)

* Step 2a: Loop across stratas
	foreach stratum of local strata {
	
	*Step 2b: Within Each Stratum Compute the 2*`numcovariates' p-values and store them
	local i=1
	
		foreach covariate in `covariates' {
		
		display "`covariate'"

		reg `covariate' tdum* if strata == `stratum'  , nocons
		test tdum1=tdum2
		mat mat_pvals_final[`stratum',`i']=r(p)
		  
		local i=`i'+1

		  }

	}

matrix list mat_pvals_final

*Calculate how many p-values are less than .05

matrix mat_pv_05 = J(`numstrata',`numcovariates',.05)
mata: mata clear
mata: mat_pv_final = st_matrix("mat_pvals_final")
mata: mat_pv_05 = st_matrix("mat_pv_05")
mata: lessthan05_final = mat_pv_final:< mat_pv_05
mata: totlessthan05_final = sum(lessthan05_final)
mata:  st_numscalar("totlessthan05_final", totlessthan05_final)
scalar list totlessthan05_final 




/* Not Doing Stratum-by-Stratum */
/* now checking balance across arms (with and without strata dummies)
rather than doing stratum-by-stratum*/

/* First for the 2 Treatments Randomization*/
local i=1
matrix mat_pvals_com = J(`numcovariates',2,.)

	foreach covariate in `covariates' {

	display "`covariate'"
	
	reg `covariate' tdum* i.strata , nocons
	test tdum1=tdum2
	mat mat_pvals_com[`i',1]=r(p)
	
	reg `covariate' tdum* , nocons
	test tdum1=tdum2
	mat mat_pvals_com[`i',2]=r(p)
	
	local i=`i'+1
	
	}
	
matrix list mat_pvals_com

*Calculating how many p-values are less than 0.05
matrix mat_pv_05_2 = J(`numcovariates',2,.05)
mata: mata clear
mata: mat_pv_final_2 = st_matrix("mat_pvals_com")
mata: mat_pv_05_2 = st_matrix("mat_pv_05_2")
mata: lessthan05_final_2 = mat_pv_final_2:< mat_pv_05_2
mata: totlessthan05_final_2 = sum(lessthan05_final_2)
mata:  st_numscalar("totlessthan05_final_2", totlessthan05_final_2)

di "*-------------------------------------------------------------------------"
di "Total Number of p-values less than .05 in stratum-by-stratum regressions"
di "*-------------------------------------------------------------------------"
scalar list totlessthan05_final
di "Out of a total of"
display `totcoefs_stratum_by_stratum'
di "So that the fraction of coefficients with p-values <.05 is"
display totlessthan05_final/`totcoefs_stratum_by_stratum'


di "Total Number of p-values less than .05 in 2 regressions (OLS w/ and w/o strata)"
scalar list totlessthan05_final_2





save "`outputdata'", replace

cap log close










