use "$merged_data", clear 

**********************************************************************************************************
* Create a merged cotton area variable (in hectares) that uses farmer-reported data if GPS data is not available
**********************************************************************************************************
generate merged_cotton_area = calc_cotton_area 
replace merged_cotton_area = reported_cotton_area if missing(calc_cotton_area) //Endline farmer-reported cotton area 
replace merged_cotton_area = Cotton_area if missing(merged_cotton_area) //Midline farmer-reported cotton area 

replace merged_cotton_area = merged_cotton_area/6.177625  // Conversion from bigha to hectares 

**********************************************************************************************************
* Create indicator variables defining the sample based on survey data and satellite data 
**********************************************************************************************************
// Generate an indicator for whether the respondent answered the basal AND full season fertilizer questions 
generate missing_basal = cond(missing(SII_5), 1, 0)
generate missing_midline = cond(missing(used_inorganic_fertilizers), 1, 0)
egen missing_fertilizer_data = rowmax(missing_basal missing_midline)
generate complete_fertilizer_data = 1 - missing_fertilizer_data
label var complete_fertilizer_data "Respondent provided basal and full season fertilizer data"
label define complete_fertilizer_data 0 "Missing basal or full season fertilizer data" 1 "Complete fertilizer data"
label val complete_fertilizer_data complete_fertilizer_data
drop missing_basal missing_midline missing_fertilizer_data

// Generate an indicator capturing whether we have endline satellite data 
generate satellite_data = 0 
foreach x of varlist c_re705_2018*median {
	replace satellite_data = 1 if !missing(`x')
}
label var satellite_data "Satellite data available"
label define satellite_data 0 "No satellite data" 1 "2018 satellite data"
label val satellite_data satellite_data

**********************************************************************************************************
* Calculate basal fertilizer application information, in per hectare values 
**********************************************************************************************************

//Basal fertilizer area 
//If applied fertilizer to full plot, recode area applied with cotton area (calculated) 
//If did not apply fertilizer, recode area applied to 0 

//Calculate this as calculated area of plot times fraction of plot fertilizer was applied to 

destring SII_4_1 SII_5, force replace 

foreach x in "UREA" "DAP" "MOP" "ZINC" {

replace SII_6_1_`x' = 0 if SII_5 == 0

}

foreach x in "UREA" "DAP" "MOP" "ZINC" {
  replace `x'_area = 0 if SII_6_1_`x' == 0  // Did not apply any of specific fertilizer 
  replace `x'_area = 0 if SII_5 == 0 //Indicates no fertilizer was applied 
  rename `x'_area `x'_fraction_basal
  generate `x'_area_basal = merged_cotton_area*`x'_fraction_basal
}

replace area_units = "hectare" if area_units == "hectare"

*First we need to convert all recommendations to per hectare values 
*The original conversions were to bigha, but we want per hectare for the paper, so just convert the final value
foreach x of varlist zinc_rec_ir *bd_rec* *total_rec* {
	replace `x' = `x' / 2.5 if area_units =="acre"
	replace `x' = `x' / 6.177625 if area_units =="hectare"
	replace `x' = `x' / 6.177625 if area_units =="guntha"
	replace `x' = 6.177625 * `x' //From per bigha to per hectare values
}

*Next calculate application in kg/hectare using self-reported fertilizer application and true plot size 
foreach x in "UREA" "DAP" "MOP" "ZINC" {
	replace `x'_Kg = 0 if SII_6_1_`x' == 0 //Indicates that they did not apply the fertilizer type
	replace `x'_Kg = 0 if SII_5 == 0 //Indicates no basal fertilizer was applied 
	generate `x'_kg_hectare_bd = `x'_Kg/`x'_area_basal
	local proper = proper("`x'")
	replace `x'_kg_hectare_bd = 0 if `x'_area_basal == 0 //This replaces erroneously missing values created by trying to divide by 0
}

*Next generate the basal fertilizer gap variable 
foreach x in "UREA" "DAP" "MOP" "ZINC"{
	local lower = lower("`x'")
	if "`x'" == "UREA" {
	generate distance_`x' = abs(`lower'_bd_rec_ur - `x'_kg_hectare_bd)
	replace distance_`x' = abs(`lower'_bd_rec_ir - `x'_kg_hectare_bd) if SII_4_1 == 1
	}
	else{
	if "`x'" == "ZINC" {
	generate distance_`x' = abs(`x'_kg_hectare_bd - zinc_rec_ir) if SII_4_1 == 1
	replace distance_`x' = abs(`x'_kg_hectare_bd) if SII_4_1 == 0
	}
	else{
	generate distance_`x' = abs(`lower'_bd_rec_ir - `x'_kg_hectare_bd) if SII_4_1 == 1
	replace distance_`x' = abs(`x'_kg_hectare_bd) if SII_4_1 == 0 
	}
	}

	winsor2 distance_`x', replace cuts(0 99)

	label var distance_`x' "Basal: distance between recommended and applied, `x'"
}

foreach x in "UREA" "DAP" "MOP" "ZINC"{

local lower = lower("`x'")
if "`x'" == "UREA" {
generate difference_`x' = `x'_kg_hectare_bd - `lower'_bd_rec_ur 
replace difference_`x' = `x'_kg_hectare_bd - `lower'_bd_rec_ir if SII_4_1 == 1
}
else{
if "`x'" == "ZINC" {
generate difference_`x' = `x'_kg_hectare_bd - zinc_rec_ir if SII_4_1 == 1
replace difference_`x' = `x'_kg_hectare_bd if SII_4_1 == 0
}
else{
generate difference_`x' = `x'_kg_hectare_bd - `lower'_bd_rec_ir if SII_4_1 == 1
replace difference_`x' = `x'_kg_hectare_bd if SII_4_1 == 0 
}
}

winsor2 difference_`x', replace cuts(0 99)

label var difference_`x' "Basal: difference between recommended and applied, `x'"
}

**********************************************************************************************************
* Calculate midline fertilizer application information, in per hectare values 
**********************************************************************************************************

* Generate fertilizer application average area and average dose, full season 

foreach x in "urea" "dap" "mop" "zinc" {
  egen `x'_fraction_average = rowmean(`x'_d?_area)
  generate `x'_area_average = `x'_fraction_average*merged_cotton_area
  generate `x'_kg_hectare_ml = `x'_total_kg/`x'_area_average 
  replace `x'_area_average = 0 if used_`x' == 0 & !missing(merged_cotton_area)
  replace `x'_kg_hectare_ml = 0 if used_`x' == 0 & !missing(merged_cotton_area)
}

generate compost_total_rec = 6.177625*1500  //Rec per bigha was 1500 per according to Victor's midline do file
generate compost_kg_hectare = (compost_kg/merged_cotton_area)
generate distance_compost = abs(compost_total_rec - compost_kg_hectare)
label var distance_compost "Compost"

generate distance_urea = abs(urea_total_rec_ur - urea_kg_hectare_ml) 
replace distance_urea = abs(urea_total_rec_ir - urea_kg_hectare_ml) if irrigation_ml == 1 
label var distance_urea "UREA"

generate distance_dap = dap_kg_hectare_ml /*Recommendation for unirrigated cotton was zero*/
replace distance_dap = abs(dap_total_rec_ir - dap_kg_hectare_ml) if irrigation_ml == 1 /*Irrigated*/
label var distance_dap "DAP"

generate distance_mop = mop_kg_hectare_ml /*Recommendation for unirrigated cotton was zero*/
replace distance_mop = abs(mop_total_rec_ir - mop_kg_hectare_ml) if irrigation_ml == 1 /*Irrigated*/
label var distance_mop "MOP"

generate distance_zinc = abs(zinc_kg_hectare_ml) /*Recommendation for unirrigated cotton was zero*/
replace distance_zinc = abs(zinc_sulphate_total_rec_ir - zinc_kg_hectare_ml) if irrigation_ml == 1 /*Irrigated*/
label var distance_zinc "Zinc"

generate difference_urea = urea_kg_hectare_ml - urea_total_rec_ur 
replace difference_urea = urea_kg_hectare_ml - urea_total_rec_ir if irrigation_ml == 1 
label var difference_urea "UREA"

generate difference_dap = dap_kg_hectare_ml /*Recommendation for unirrigated cotton was zero*/
replace difference_dap = dap_kg_hectare_ml - dap_total_rec_ir if irrigation_ml == 1 /*Irrigated*/
label var difference_dap "DAP"

generate difference_mop = mop_kg_hectare_ml /*Recommendation for unirrigated cotton was zero*/
replace difference_mop = mop_kg_hectare_ml - mop_total_rec_ir if irrigation_ml == 1 /*Irrigated*/
label var difference_mop "MOP"

generate difference_zinc = zinc_kg_hectare_ml /*Recommendation for unirrigated cotton was zero*/
replace difference_zinc = zinc_kg_hectare_ml - zinc_sulphate_total_rec_ir if irrigation_ml == 1 /*Irrigated*/
label var difference_zinc "Zinc"

foreach x in "urea" "dap" "mop" "zinc" {
	winsor2 distance_`x', cuts(0 99) replace
	winsor2 difference_`x', cuts(0 99) replace
}

**********************************************************************************************************
* Farmer-reported yield/productivity  
**********************************************************************************************************

//////////////////////////////////////////////////////
//Self-reported harvest and plot size 
//////////////////////////////////////////////////////

generate yield_hectare_2018_alt = 6.177625*(yield_kg/reported_cotton_area) 
replace yield_hectare_2018_alt = 0 if harvested_cotton == 0 & !missing(reported_cotton_area)
label var yield_hectare_2018_alt "Self-reported yield and area (kg/hectare)"

// Store raw variable in a tempvar 
tempvar unwinsorized_yield
generate `unwinsorized_yield' = yield_hectare_2018_alt

// We will winsorize POSITIVE yield values at the 2nd and 98th percentile. We expect that values reported at 0 are actually accurate, but there can be small 
//outliers for very small positive values 
tempvar positive_alt_18
generate `positive_alt_18' = yield_hectare_2018_alt if yield_hectare_2018_alt > 0
winsor2 `positive_alt_18', replace cuts(2 98)
replace yield_hectare_2018_alt = `positive_alt_18' if yield_hectare_2018 > 0

generate yield_hectare_2017_alt = 6.177625*(sampled_plot_quantity_harvested/sampled_plot_cotton_area) 
tempvar positive_alt_17
generate `positive_alt_17' = yield_hectare_2017_alt if yield_hectare_2017_alt > 0
winsor2 `positive_alt_17', replace cuts(2 98)
replace yield_hectare_2017_alt = `positive_alt_17' if yield_hectare_2017_alt > 0 

//////////////////////////////////////////////////////
//Self-reported harvest and measured plot size
//////////////////////////////////////////////////////
generate yield_hectare_2018 = 6.177625*(yield_kg/calc_cotton_area) 
replace yield_hectare_2018 = 0 if harvested_cotton == 0 & !missing(calc_cotton_area)
label var yield_hectare_2018 "Self-reported yield (kg/hectare)"

// We will winsorize POSITIVE yield values at the 2nd and 98th percentile. We expect that values reported at 0 are actually accurate, but there can be small 
//outliers for very small positive values 
tempvar positive_yield_18 
generate `positive_yield_18' = yield_hectare_2018 if yield_hectare_2018 > 0
winsor2 `positive_yield_18', replace cuts(2 98)
replace yield_hectare_2018 = `positive_yield_18' if yield_hectare_2018 > 0

generate yield_hectare_2017 = 6.177625*(sampled_plot_quantity_harvested/calc_cotton_area) 
tempvar positive_yield_17 
generate `positive_yield_17' = yield_hectare_2017 if yield_hectare_2017 > 0
winsor2 `positive_yield_17', replace cuts(2 98)
replace yield_hectare_2017 = `positive_yield_17' if yield_hectare_2017 > 0

//////////////////////////////////////////////////////
//Self-reported harvest and combined plot size
//////////////////////////////////////////////////////
generate yield_hectare_2018_merged = yield_kg/merged_cotton_area
replace yield_hectare_2018_merged = 0 if harvested_cotton == 0 & !missing(merged_cotton_area)
label var yield_hectare_2018_merged "Self-reported yield (kg/hectare)"

// We will winsorize POSITIVE yield values at the 2nd and 98th percentile. We expect that values reported at 0 are actually accurate, but there can be small 
//outliers for very small positive values 
tempvar positive_yield_18_merged 
generate `positive_yield_18_merged' = yield_hectare_2018_merged if yield_hectare_2018_merged > 0
winsor2 `positive_yield_18_merged', replace cuts(2 98)
replace yield_hectare_2018_merged = `positive_yield_18_merged' if yield_hectare_2018_merged > 0

generate yield_hectare_2017_merged = sampled_plot_quantity_harvested/merged_cotton_area 
tempvar positive_yield_17_merged
generate `positive_yield_17_merged' = yield_hectare_2017_merged if yield_hectare_2017_merged > 0
winsor2 `positive_yield_17_merged', replace cuts(2 98)
replace yield_hectare_2017_merged = `positive_yield_17_merged' if yield_hectare_2017_merged > 0

**********************************************************************************************************
* Indicator variable identifying whether 2018 farmer-reported harvest and plot size is non-missing
**********************************************************************************************************

generate farmer_reported_yield = cond(missing(yield_hectare_2018_alt), 0, 1)
label var farmer_reported_yield "Respondent provided yield data"
label define farmer_reported_yield 0 "No farmer-reported yield" 1 "Farmer-reported yield"
label val farmer_reported_yield farmer_reported_yield

**********************************************************************************************************
* Fix instances when farmers said they did not sow cotton but reported cotton yields
**********************************************************************************************************
replace sowed_cotton = 1 if !missing(yield_kg) & yield_kg > 0 
foreach x of varlist yield*2018* {
	replace `x' = . if !missing(`x') & sowed_cotton == 0  // Handles a case where the farmer said they did not sow cotton or harvest it, but yield was coded to 0
}

**********************************************************************************************************
* Calculate the peak value of each Sentinel-2 VI in each year 
**********************************************************************************************************

//Drop the mean VI readings, which we decided not to use 
drop c*mean 

//Drop the full plot zonal stats, which we do not use 
drop p_*

//Drop satellite images before October 15th of each year 
//We originally downloaded these, but were concerned that they're too early in the growing season if farmers sowed late
//Including them also decreased the R^2 between farmer-reported and satellite yields 
drop c*20180928_median c*20181003_median  c*20171008_median

foreach x in ndvi re705 gcvi mtci lai {
	egen max_`x'_2018 = rowmax(c_`x'_2018*)
	egen placebo_`x'_2018 = rowmax(c_placebo_`x'_2018*)
	egen max_`x'_2017 = rowmax(c_`x'_2017*)
	egen placebo_`x'_2017 = rowmax(c_placebo_`x'_2017*)
	rename c_`x'_20161028_median max_`x'_2016  // There is only a single 2016 image
	rename c_placebo_`x'_20161028_median placebo_`x'_2016
	// Drop the individual passes which we no longer need 
	drop c_`x'_2018*
	drop c_`x'_2017*
	drop c_placebo_`x'_2018*
	drop c_placebo_`x'_2017*
}

**********************************************************************************************************
* Export a CSV for predicting the gap between satellite-estimated and farmer-reported yield in Python
**********************************************************************************************************
preserve 

//Generate satellite yield prediction for 2018
regress yield_hectare_2018 max_re705_2018
predict satellite_yield_2018, xb

//Generate variables for the difference between farmer-reported yield and satellite estimated yield and the absolute value of this difference 
//Use raw data 
generate difference_fr_sat = `unwinsorized_yield' - satellite_yield_2018
generate distance_fr_sat = abs(difference_fr_sat)

//Only keep variables we plan to use, and observations for which the variables we aim to predict are non-missing 
drop if missing(difference_fr_sat)

replace b5 = . if b5 == 999  // Data cleaning issue 
replace willingness_to_experiment = . if willingness_to_experiment == 999  // Data cleaning issue 

generate sow_time = Sow_date - date("2018-06-01", "YMD")  // Sowing date in days after June 1st

generate total_cotton_land_ha = total_cotton_land/6.177625  // Conversion from bigha to hectares 
generate sampled_plot_size_ha = sampled_plot_size/6.177625

egen numerical_literacy = rowmin(b7 b8)
egen literacy = rowmin(b5 b6)

keep uid difference_fr_sat distance_fr_sat age_bl total_cotton_land_ha sampled_plot_size_ha ///
physical_irrigation_bl pucca_house plough_own crop_insurance children educated soil_test_before ///
tractor_own k?_correct literacy numerical_literacy risk_attitude_agriculture_bl savings financial_resilience sow_time

//Replace all extended missing values with normal missing values, so they cells are left blank in the CSV 
ds, has(type numeric)
foreach x of varlist `r(varlist)' {
  replace `x' = .  if missing(`x')
}

export delimited using "data/nosync/fr_sat_gap_analysis.csv", replace nolabel 

restore 

**********************************************************************************************************
* Export a CSV to examine whether we can predict 2018 yields in the treatment group
**********************************************************************************************************
preserve 

//Generate satellite yield predictions
regress yield_hectare_2018 max_re705_2018
predict satellite_yield_2018, xb

regress yield_hectare_2017 max_re705_2017
predict satellite_yield_2017, xb

//Add rainfall data 
merge 1:1 uid using "$rainfall_data", keep(1 3) nogenerate
egen rain_june_2017 = rowmean(rain_daily_201706*)
egen rain_july_2017 = rowmean(rain_daily_201707*)
egen rain_august_2017 = rowmean(rain_daily_201708*)
egen rain_september_2017 = rowmean(rain_daily_201709*)
egen rain_october_2017 = rowmean(rain_daily_201710*)

egen rain_june_2018 = rowmean(rain_daily_201806*)
egen rain_july_2018 = rowmean(rain_daily_201807*)
egen rain_august_2018 = rowmean(rain_daily_201808*)
egen rain_september_2018 = rowmean(rain_daily_201809*)
egen rain_october_2018 = rowmean(rain_daily_201810*)

drop rain_daily* 

rename physical_irrigation_bl irrigation_2017 
egen irrigation_2018 = rowmin(irrigation_el irrigation_ml)  // Conservative irrigation variable using midline and endline data 
egen knowledge_2017 = std(bl_fert_qs_correct)  // Standardized knowledge score
egen correct_questions_2018 = rowtotal(e*_correct), missing // Fertilizer questions correct at midline 
egen knowledge_2018 = std(correct_questions_2018)

generate sow_time = Sow_date - date("2018-06-01", "YMD")  // Sowing date in days after June 1st

rename fertilizer_plot_kg_bigha_1 urea_2017 
replace urea_2017 = urea_2017*6.177625  // Per bigha to per hectare 
rename urea_kg_hectare_ml urea_2018

rename fertilizer_plot_kg_bigha_3 dap_2017 
replace dap_2017 = dap_2017*6.177625
rename dap_kg_hectare_ml dap_2018 

rename fertilizer_plot_kg_bigha_5 mop_2017
replace mop_2017 = mop_2017*6.177625
rename mop_kg_hectare_ml mop_2018

rename fertilizer_plot_kg_bigha_12 zinc_2017 
replace zinc_2017 = zinc_2017*6.177625
rename zinc_kg_hectare_ml zinc_2018

generate lag_re705_2018 = max_re705_2017
generate lag_re705_2017 = max_re705_2016
drop max_re705_2016

drop yield*alt yield*merged 

drop if missing(rain_june_2017, rain_june_2018)

keep uid yield_hectare* max_re705* irrigation_201? knowledge_201? urea_201? dap_201? mop_201? zinc_201? rain_* ///
 tractor_own plough_own willingness_to_experiment crop_insurance sow_time satellite_yield* treatment ///
 ph_value ec_value nitrogen_value phosphorous_value potash_value zinc_value iron_value sulphur_value lag_re705_*

rename zinc_value soil_test_zinc_value //Otherwise we end up with value as a j value in reshape and this gets combined with zinc fertilizer application 

reshape long yield_hectare_ satellite_yield_ max_re705_ irrigation_ knowledge_ urea_ dap_ mop_ zinc_ ///
rain_june_ rain_july_ rain_august_ rain_september_ rain_october_ lag_re705_, i(uid) j(date) string 

egen id = concat(uid date)
drop uid

generate year_2018 = cond(date == "2018", 1, 0)  // Indicator for year 
drop date 

//Replace all extended missing values with normal missing values, so they cells are left blank in the CSV 
ds, has(type numeric)
foreach x of varlist `r(varlist)' {
  replace `x' = .  if missing(`x')
}

export delimited using "data/nosync/yield_prediction.csv", replace nolabel 

restore 

**********************************************************************************************************
* Drop tempvars (a bug is causing them to save)
**********************************************************************************************************
drop __0*

**********************************************************************************************************
* Generate indicators for the 3 sub-samples that we analyze 
**********************************************************************************************************

generate fr_yield_sample = cond(!missing(yield_hectare_2018_alt), 1, 0)
label var fr_yield_sample "Farmers that provided yield data"

generate satellite_yield_sample = cond(!missing(max_re705_2018), 1, 0)
label var satellite_yield_sample "Observations with satellite data"

egen intersecting_sample = rowmin(fr_yield_sample satellite_yield_sample)
label var intersecting_sample "Observations with farmer-reported and satellite yields"

**********************************************************************************************************
* Save data with farmers that didn't grow cotton for power calculations 
**********************************************************************************************************
drop if missing(treatment)  // Not part of the sample, product of a failed merge somewhere 
save "$final_data_with_attriters", replace 

**********************************************************************************************************
* Remove attriters (make sure to use "$merged_data" in attrition analysis and not the output of this file)
**********************************************************************************************************

drop if sowed_cotton == 0  // Attrition condition 
