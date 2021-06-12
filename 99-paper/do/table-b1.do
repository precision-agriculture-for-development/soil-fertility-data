use "$final_data", clear 

// Create a t-b1 folder to store outputs if it doesn't exist 
capture mkdir "tables/t-b1/"

//By treatment and control: tab the percent of farmers whose plots were mapped and that we have satellite data for

label var map_merge "Plot mapped"
label define map_merge 3 "Mapped" 1 "Not mapped"
label val map_merge map_merge 

//Calculate attrition for Sentinel-2

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
label var all_sentinel_data "Sentinel-2: no missing data"
label define all_sentinel_data 0 "Missing data" 1 "No missing data"
label val all_sentinel_data all_sentinel_data

tabout map_merge sat_data_2016 sat_data_2017 sat_data_2018 all_sentinel_data ///
treatment ///
using "tables/t-b1/sentinel-attrition.tex", cells(freq col) format(0c 1c) clab(Number Percent) ///
replace style(tex) font(italic) bt cl1(2-7) cl2(2-3 4-5 6-7) ///
topstr(14cm) ptotal(none) 
