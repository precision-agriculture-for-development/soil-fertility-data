use "$final_data", clear

// Create a t6 folder to store outputs if it doesn't exist 
capture mkdir "tables/t6/"

eststo clear 

generate productivity_2017 = . //We will replace this variable in each regression so all 2017 values of the dependent variable appear in one row 
label var productivity_2017 "2017 yield"


*****************************************************************************
* Convert raw vegetation index values to yield estimates 
*****************************************************************************

regress yield_hectare_2017 max_re705_2017 
predict sentinel_2017, xb 
replace sentinel_2017 = 0 if sentinel_2017 < 0 

regress yield_hectare_2018 max_re705_2018 
predict sentinel_2018, xb 
replace sentinel_2018 = 0 if sentinel_2018 < 0 

//////////////////////////////////////////////////////
//Regression 1 - farmer-reported yield and plot size: full sample and Lee Bounds
//////////////////////////////////////////////////////

leebounds yield_hectare_2018_alt treatment, cieffect 
local lower: di %9.3f `e(cilower)'
local upper: di %9.3f `e(ciupper)'

replace productivity_2017 = yield_hectare_2017_alt
summarize yield_hectare_2018_alt if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
eststo: regress yield_hectare_2018_alt i.treatment productivity_2017 i.block_id, robust
local ci_lower = _b[1.treatment] - invttail(e(df_r),0.025)*_se[1.treatment] // Add 95% confidence interval (no Lee bounds)
local ci_lower: di %9.3f `ci_lower'
local ci_upper = _b[1.treatment] + invttail(e(df_r),0.025)*_se[1.treatment] 
local ci_upper: di %9.3f `ci_upper'
estadd local confidence_interval "[`ci_lower', `ci_upper']"
estadd scalar depMean = `varMean'
estadd local bounds "[`lower', `upper']" , replace

//////////////////////////////////////////////////////
//Regression 2 - satellite, 2016 control (full sample)
//////////////////////////////////////////////////////

label var max_re705_2016 "2016 reNDVI"

replace productivity_2017 = sentinel_2017

eststo: regress sentinel_2018 i.treatment productivity_2017 max_re705_2016 i.block_id, robust
local ci_lower = _b[1.treatment] - invttail(e(df_r),0.025)*_se[1.treatment] // Add 95% confidence interval (no Lee bounds)
local ci_lower: di %9.3f `ci_lower'
local ci_upper = _b[1.treatment] + invttail(e(df_r),0.025)*_se[1.treatment] 
local ci_upper: di %9.3f `ci_upper'
estadd local confidence_interval "[`ci_lower', `ci_upper']"

summarize sentinel_2018 if treatment == 0 
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'
estadd local bounds "N/A" , replace

//////////////////////////////////////////////////////
//Regression 3 - farmer-reported yield and plot size 
//////////////////////////////////////////////////////

preserve

// We want to examine the effect of data source on power, so we only keep observations that are non-missing for each data type 
drop if missing(sentinel_2018, sentinel_2017, yield_hectare_2018_alt, yield_hectare_2017_alt)

replace productivity_2017 = yield_hectare_2017_alt
summarize yield_hectare_2018_alt if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
eststo: regress yield_hectare_2018_alt i.treatment productivity_2017 i.block_id, robust
local ci_lower = _b[1.treatment] - invttail(e(df_r),0.025)*_se[1.treatment] // Add 95% confidence interval (no Lee bounds)
local ci_lower: di %9.3f `ci_lower'
local ci_upper = _b[1.treatment] + invttail(e(df_r),0.025)*_se[1.treatment] 
local ci_upper: di %9.3f `ci_upper'
estadd local confidence_interval "[`ci_lower', `ci_upper']"
estadd scalar depMean = `varMean'
estadd local bounds "N/A" , replace

//////////////////////////////////////////////////////
//Regression 4 - satellite, no 2016 control
//////////////////////////////////////////////////////

replace productivity_2017 = sentinel_2017

eststo: regress sentinel_2018 i.treatment productivity_2017 i.block_id, robust 
local ci_lower = _b[1.treatment] - invttail(e(df_r),0.025)*_se[1.treatment] // Add 95% confidence interval (no Lee bounds)
local ci_lower: di %9.3f `ci_lower'
local ci_upper = _b[1.treatment] + invttail(e(df_r),0.025)*_se[1.treatment] 
local ci_upper: di %9.3f `ci_upper'
estadd local confidence_interval "[`ci_lower', `ci_upper']"

summarize sentinel_2018 if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'
estadd local bounds "N/A" , replace

//////////////////////////////////////////////////////
//Regression 5 - satellite, 2016 control
//////////////////////////////////////////////////////

label var max_re705_2016 "2016 reNDVI"

replace productivity_2017 = sentinel_2017

eststo: regress sentinel_2018 i.treatment productivity_2017 max_re705_2016 i.block_id, robust
local ci_lower = _b[1.treatment] - invttail(e(df_r),0.025)*_se[1.treatment] // Add 95% confidence interval (no Lee bounds)
local ci_lower: di %9.3f `ci_lower'
local ci_upper = _b[1.treatment] + invttail(e(df_r),0.025)*_se[1.treatment] 
local ci_upper: di %9.3f `ci_upper'
estadd local confidence_interval "[`ci_lower', `ci_upper']"

summarize sentinel_2018 if treatment == 0 
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'
estadd local bounds "N/A" , replace

restore


esttab using "tables/t6/sat_vs_fr_yield.tex", replace se noobs ///
not label tex star(* 0.10 ** 0.05 *** 0.01) noconstant b(%9.3fc) ///
noomitted nobaselevels scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control mean" "confidence_interval 95\% CI:" "bounds Lee bounds (95\% CI):") ///
sfmt(%9.0fc %9.3fc %9.3fc %20g %20g) ///
frag indicate("Block FE = *block*") ///
mtitles("\makecell[c]{Reported yield \\ and plot size}" "\makecell[c]{Satellite yield}" "\makecell[c]{Reported yield \\ and plot size}" ///
	"\makecell[c]{Satellite yield}" "\makecell[c]{Satellite yield}")

