use "$final_data", clear

// Create a f7 folder to store outputs if it doesn't exist 
capture mkdir "figures/f7/"

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

replace productivity_2017 = yield_hectare_2017_alt
eststo: regress yield_hectare_2018_alt i.treatment productivity_2017 i.block_id, robust

//////////////////////////////////////////////////////
//Regression 2 - satellite, 2016 control (full sample)
//////////////////////////////////////////////////////

replace productivity_2017 = sentinel_2017
eststo: regress sentinel_2018 i.treatment productivity_2017 max_re705_2016 i.block_id, robust

//////////////////////////////////////////////////////
//Regression 3 - farmer-reported yield and plot size 
//////////////////////////////////////////////////////

preserve

// We want to examine the effect of data source on power, so we only keep observations that are non-missing for each data type 
drop if missing(sentinel_2018, sentinel_2017, yield_hectare_2018_alt, yield_hectare_2017_alt)

replace productivity_2017 = yield_hectare_2017_alt
eststo: regress yield_hectare_2018_alt i.treatment productivity_2017 i.block_id, robust

//////////////////////////////////////////////////////
//Regression 4 - satellite, no 2016 control
//////////////////////////////////////////////////////

replace productivity_2017 = sentinel_2017
eststo: regress sentinel_2018 i.treatment productivity_2017 i.block_id, robust 

//////////////////////////////////////////////////////
//Regression 5 - satellite, 2016 control
//////////////////////////////////////////////////////

replace productivity_2017 = sentinel_2017
eststo: regress sentinel_2018 i.treatment productivity_2017 max_re705_2016 i.block_id, robust

restore

set scheme s2color //Default scheme 

coefplot est1 || est2 || est3 || est4 || est5, keep(1.treatment) bycoefs bylabels("FR" "Satellite" "FR" `""Satellite" "(exc. 2016)""' "Satellite") xline(0) ///
msymbol(d) mcolor(white) levels(99 95 90 80 70) ciopts(lwidth(3 ..) lcolor(*.2 *.4 *.6 *.8 *1)) ///
legend(order(1 "99" 2 "95" 3 "90" 4 "80" 5 "70") rows(1)) groups(1 2="All data" 3 4 5="Intersecting sample") ///
graphregion(color(white)) plotregion(margin(b = 0))

gexport, file("figures/f7/confidence_intervals.png")

