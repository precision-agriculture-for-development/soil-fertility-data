use "$final_data_with_attriters", clear

// Create a t6 folder to store outputs if it doesn't exist 
capture mkdir "tables/t7/"

*****************************************************************************
* Convert raw vegetation index values to yield estimates 
*****************************************************************************

regress yield_hectare_2017 max_re705_2017 
predict sentinel_2017, xb 
replace sentinel_2017 = 0 if sentinel_2017 < 0 

regress yield_hectare_2018 max_re705_2018 
predict sentinel_2018, xb 
replace sentinel_2018 = 0 if sentinel_2018 < 0 

//Store the percent of farmers that sowed cotton 
summarize sowed_cotton 
local sowed_cotton_share = r(mean)

// Initiate the output LaTex file 
cap file close handle
file open handle using "tables/t7/power.tex", write replace

file w handle "\begin{tabular}{l} \hline \hline \\[-2mm] \\ \\ \hline Sample size \\ ANCOVA \\ Lee Bounds \\ Multiple pre-intervention years \\ Attrition rate \\ \hline \end{tabular}%" _n

///////////////////////////////////////////////////////////////////////////////
// Column (1) farmer-reported, no 2017 control 
///////////////////////////////////////////////////////////////////////////////
* Calculate the attrition rate 
generate missing_yield = cond(missing(yield_hectare_2018_alt), 1, 0)
assert missing_yield == 1 if sowed_cotton == 0 
summarize missing_yield
local completion_rate = 1 - r(mean)
local survey_attrition_rate: di %9.3fc 1 - `completion_rate'

* Drop observations where the farmer did not sow cotton 
* This decision was made before treatment, so this shouldn't be considered in differential attrition calculations 
drop if sowed_cotton == 0 

* Store farmer-reported mean, sd, and year-to-year correlation among the control group in macros 
summarize yield_hectare_2018_alt if treatment == 0
local fr_control_mean = r(mean)
local fr_treatment_mean = 1.05*`fr_control_mean'
local fr_sd = r(sd)
regress yield_hectare_2018_alt yield_hectare_2017_alt if treatment == 0
local fr_r2 = e(r2)
local fr_corr = `fr_r2'^0.5

sampsi `fr_control_mean' `fr_treatment_mean', sd1(`fr_sd') p(0.9) 
local n_c1_raw = r(N_1) + r(N_2)
local n_column_1: di %9.0fc ceil((r(N_1) + r(N_2))/(`completion_rate'))

* Create this column 
file w handle "\begin{tabular}{c} \hline \hline \\[-2mm] (1) \\ Survey \\ \hline `n_column_1' \\ NO \\ NO \\ N/A \\ `survey_attrition_rate' \\ \hline \end{tabular}%" _n

////////////////////////////////////////////////////////////////////////////
// Column (2) farmer-reported, 2017 control 
////////////////////////////////////////////////////////////////////////////

sampsi `fr_control_mean' `fr_treatment_mean', sd1(`fr_sd') p(0.9) pre(1) r01(`fr_corr') method(ancova)
local n_column_2: di %9.0fc ceil((r(N_1) + r(N_2))/(`completion_rate'))

*Write the column 
file w handle "\begin{tabular}{c} \hline \hline \\[-2mm] (2) \\ Survey \\ \hline `n_column_2' \\ YES \\ NO \\ N/A \\ `survey_attrition_rate' \\ \hline \end{tabular}%" _n

//////////////////////////////////////////////////////////////////////////
// Column (3) farmer-reported, 2017 control, Lee Bounds 
//////////////////////////////////////////////////////////////////////////

* First, run Lee Bounds 
* NOTE: Including tight(block_id) increases the CI, so I exclude it
leebounds yield_hectare_2018_alt treatment, cieffect
* Store the size of the confidence interval to a local macro 
local lee_ci_distance = e(ciupper) - e(cilower)

* Obtain CI length without correcting for attrition 
regress yield_hectare_2018_alt treatment i.block_id, robust 
local ci_distance_no_correction = 2*(invttail(e(df_r),0.025)*_se[treatment])

* Get the ratio of the length of the CI with the Lee Bounds correction to that without 
local ratio_ci_lengths = `lee_ci_distance' / `ci_distance_no_correction'

* Our correction factor is this squared, divided by 1 - attrition rate, since the length of the CI decreases relative to the inverse of the square root of sample size, 
* and we only expect to get data from 1-attrition rate share of new people we survey. 
*This is the estimate increase in sample size we would need to obtain CIs of length equal to those observed in our current data without the Lee Bounds correction once the correction is applied

local lee_bounds_correction = (`ratio_ci_lengths')^2

* Hence, the estimated sample size needed to detect an effect with the correction is this constance times our previous sample size 
local n_column_3: di %9.0fc ceil((`n_c1_raw' * `lee_bounds_correction')/(`completion_rate'))

* Write the column 
file w handle "\begin{tabular}{c} \hline \hline \\[-2mm] (3) \\ Survey \\ \hline `n_column_3' \\ NO \\ YES \\ N/A \\ `survey_attrition_rate'  \\\hline \end{tabular}%" _n

//////////////////////////////////////////////////////////////////////////
// Column (4) satellite-measured, no 2017 control, survey data completion rate
//////////////////////////////////////////////////////////////////////////

* Store control mean, control SD, and 1.05*control mean in local macros 
summarize sentinel_2018 if treatment == 0
local control_mean_sentinel = r(mean)
local sentinel_sd = r(sd) 
local treatment_mean_sentinel = 1.05 * `control_mean_sentinel'

sampsi `control_mean_sentinel' `treatment_mean_sentinel', sd1(`sentinel_sd') p(0.9) 

local n_column_4: di %9.0fc ceil((r(N_1) + r(N_2))/(`completion_rate'))  // Note: This intentionally uses the completion and attrition rates from survey data 

*Write the column 
file w handle "\begin{tabular}{c} \hline \hline \\[-2mm] (4) \\ Satellite \\ \hline `n_column_4' \\ NO \\ NO \\ NO \\ `survey_attrition_rate' \\ \hline \end{tabular}%" _n


//////////////////////////////////////////////////////////////////////////
// Column (5) satellite-measured, no 2017 control 
//////////////////////////////////////////////////////////////////////////

* Define 1 - attrition rate for satellite imagery as the number of plots we were able to get imagery for  ON ALL DATS (this is an upper bound) over the number of plots that we mapped 
generate sat_data_2016 = cond(missing(max_re705_2016), 0, 1)
generate sat_data_2017 = cond(missing(max_re705_2017), 0, 1)
generate sat_data_2018 = cond(missing(max_re705_2018), 0, 1)

foreach x in 2016 2017 2018 {
	replace sat_data_`x' = . if map_merge != 3  // The plot was not mapped 
	label var sat_data_`x' "Sentinel-2: `x'"
	label define sat_data_`x' 0 "No data" 1 "Data"
	label val sat_data_`x' sat_data_`x'
}

generate all_sentinel_data = 1
foreach x of varlist sat_data_20* {
	replace all_sentinel_data = 0 if `x' != 1 
}
replace all_sentinel_data = . if map_merge != 3
summarize all_sentinel_data 

local sat_completion_rate = r(mean)
local sat_attrition_rate: di %9.3fc 1 - `sat_completion_rate'

sampsi `control_mean_sentinel' `treatment_mean_sentinel', sd1(`sentinel_sd') p(0.9) 

local n_column_5: di %9.0fc ceil((r(N_1) + r(N_2))/(`sat_completion_rate'))

*Write the column 
file w handle "\begin{tabular}{c} \hline \hline \\[-2mm] (5) \\ Satellite \\ \hline `n_column_5' \\ NO \\ NO \\ NO \\ `sat_attrition_rate' \\ \hline \end{tabular}%" _n

////////////////////////////////////////////////////////////////////////
// Column (6) satellite-measured, 2017 control 
////////////////////////////////////////////////////////////////////////

regress max_re705_2018 max_re705_2017 if treatment == 0  // This is equivalent to using yield values since yield is an affine transformation of this value 
local r_1_lag = (e(r2))^0.5

sampsi `control_mean_sentinel' `treatment_mean_sentinel', sd1(`sentinel_sd') p(0.9) pre(1) r01(`r_1_lag') method(ancova)

local n_column_6: di %9.0fc ceil((r(N_1) + r(N_2))/(`sat_completion_rate'))

*Write the column 
file w handle "\begin{tabular}{c} \hline \hline \\[-2mm] (6) \\ Satellite \\ \hline `n_column_6' \\ YES \\ NO \\ NO \\ `sat_attrition_rate' \\ \hline \end{tabular}%" _n


//////////////////////////////////////////////////////////////////////////
// Column (7) satellite-measured, 2017 control and 2016 control
//////////////////////////////////////////////////////////////////////////

regress max_re705_2018 max_re705_2017 max_re705_2016 if treatment == 0  // This is equivalent to using yield values since yield is an affine transformation of this value 
local r_2_lags = (e(r2))^0.5

sampsi `control_mean_sentinel' `treatment_mean_sentinel', sd1(`sentinel_sd') p(0.9) pre(1) r01(`r_2_lags') method(ancova)

local n_column_7: di %9.0fc ceil((r(N_1) + r(N_2))/(`sat_completion_rate'))

*Write the column 
file w handle "\begin{tabular}{c} \hline \hline \\[-2mm] (7) \\ Satellite \\ \hline `n_column_7' \\ YES \\ NO \\ YES \\ `sat_attrition_rate' \\ \hline \end{tabular}" _n

file close handle
