use "$final_data", clear 

// Create a t-b4 folder to store outputs if it doesn't exist 
capture confirm file "tables/t-b4/"
if _rc mkdir "tables/t-b4/"

// Keep observations that are non-missing for satellite measured and farmer-reported 2017 and 2018 yields 
drop if missing(max_re705_2017, max_re705_2017, yield_hectare_2018_alt, yield_hectare_2017_alt)


*****************************************************************************
* Convert raw vegetation index values to yield estimates 
*****************************************************************************

regress yield_hectare_2017 max_re705_2017 
predict sentinel_2017, xb 
replace sentinel_2017 = 0 if sentinel_2017 < 0 

regress yield_hectare_2018 max_re705_2018 
predict sentinel_2018, xb 
replace sentinel_2018 = 0 if sentinel_2018 < 0 

eststo clear 

preserve 
keep uid sentinel_2018 sentinel_2017 yield_hectare* physical_irrigation_bl
rename yield_hectare_2017_alt yield_hectare_alt_2017
rename yield_hectare_2018_alt yield_hectare_alt_2018

generate numeric_id = _n 

reshape long sentinel_ yield_hectare_alt_ yield_hectare_, i(numeric_id) j(year) 

eststo: regress yield_hectare_alt_ i.physical_irrigation_bl##i.year, cluster(numeric_id)
eststo: regress yield_hectare_ i.physical_irrigation_bl##i.year, cluster(numeric_id)
eststo: regress sentinel_ i.physical_irrigation_bl##i.year, cluster(numeric_id) 

//Label variables
label var year "Year"
label define year 2017 "2017" 2018 "2018"
label val year year 
label var physical_irrigation_bl "Irrigation"
label define physical_irrigation_bl 0 "No irrigation" 1 "Irrigation"
label val physical_irrigation_bl physical_irrigation_bl

esttab using "tables/t-b4/irrigation.tex", replace se noobs ///
not tex star(* 0.10 ** 0.05 *** 0.01) label scalars("N Observations" "N_clust Clusters" "r2_a Adjusted \$R^2$") sfmt(%9.0fc %9.0fc %9.3fc) ///
noomitted nobaselevels frag b(%9.3fc) interaction(" x ") ///
mtitles("\makecell[c]{Survey yield \\ Survey area}" "\makecell[c]{Survey yield \\ GPS area}" "\makecell[c]{Satellite yield}")

