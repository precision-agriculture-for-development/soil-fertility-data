use "$final_data_with_attriters", clear 

// Create a t-a2 folder to store outputs if it doesn't exist 
capture mkdir "tables/t-a2/"

// Generate survey completion variables 

generate missing_map = cond(map_merge==1,1,0)
label var missing_map "Missing plot map"
label define missing_map 0 "Plot mapped" 1 "Plot not mapped"
label val missing_map missing_map

generate fr_yield_attrition = 1 - fr_yield_sample
generate satellite_yield_attrition = 1 - satellite_yield_sample

generate basal_att = cond(consent_basal == 1, 0, 1)
label var basal_att "Basal"
label define basal_att 0 "Completed basal survey" 1 "Attrited"
label val basal_att basal_att

generate midline_att = cond(consent_ml == 1, 0, 1)
label var midline_att "Midline"
label define midline_att 0 "Completed midline survey" 1 "Attrited"
label val midline_att midline_att

generate endline_att = cond(consent_el == 1, 0, 1)
label var endline_att "Endline"
label define endline_att 0 "Completed endline survey" 1 "Attrited"
label val endline_att endline_att

label var pucca_house "Strong house"
label drop pucca_house
label define pucca_house 0 "Weak house" 1 "Strong house"
label val pucca_house pucca_house
label var literate "Literate"
generate total_cotton_land_ha = total_cotton_land/6.177625  // Conversion from bigha to hectares 
label var total_cotton_land_ha "Total cotton land (2017)" 
generate sampled_plot_size_ha = sampled_plot_size/6.177625
label var sampled_plot_size_ha "Sampled plot size (2017)"
label var physical_irrigation_bl "Irrigation"
label define physical_irrigation_bl 0 "No irrigation" 1 "Irrigation"
label val physical_irrigation_bl physical_irrigation_bl
label var plough_own "Own plough"
label define plough_own 0 "Do not own plough" 1 "Own plough"
label val plough_own plough_own
label var crop_insurance "Crop insurance"
label define crop_insurance 0 "No crop insurance" 1 "Crop insurance"
label val crop_insurance crop_insurance
label var children "Children"
label var educated "$>$ median education"
label define educated 0 "$leq$ median education" 1 "$>$ median education"
label val educated educated
label drop soil_test_before
label define soil_test_before 0 "No soil test" 1 "Soil tested prior to study"
label val soil_test_before soil_test_before
replace fertilizer_plot_kg_bigha_1 = 6.177625*fertilizer_plot_kg_bigha_1
label var fertilizer_plot_kg_bigha_1 "UREA last season (kg/ha)"
replace fertilizer_plot_kg_bigha_3 = 6.177625*fertilizer_plot_kg_bigha_3
label var fertilizer_plot_kg_bigha_3 "DAP last season (kg/ha)"
replace fertilizer_plot_kg_bigha_5 = 6.177625*fertilizer_plot_kg_bigha_5
label var fertilizer_plot_kg_bigha_5 "MOP last season (kg/ha)"
replace fertilizer_plot_kg_bigha_12 = 6.177625*fertilizer_plot_kg_bigha_12
label var fertilizer_plot_kg_bigha_12 "Zinc last season (kg/ha)"

foreach x of varlist age_bl literate total_cotton_land_ha sampled_plot_size_ha physical_irrigation_bl pucca_house plough_own crop_insurance children educated soil_test_before ///
fertilizer_plot_kg_bigha_1 fertilizer_plot_kg_bigha_3 fertilizer_plot_kg_bigha_5 fertilizer_plot_kg_bigha_12 {
	summarize `x', detail 
	replace `x' = r(p50) if missing(`x')
}

eststo clear

eststo: regress basal_att i.treatment##(c.age_bl i.literate c.total_cotton_land_ha c.sampled_plot_size_ha i.physical_irrigation_bl i.pucca_house ///
i.plough_own i.crop_insurance c.children i.educated i.soil_test_before ///
c.fertilizer_plot_kg_bigha_1 c.fertilizer_plot_kg_bigha_3 c.fertilizer_plot_kg_bigha_5 c.fertilizer_plot_kg_bigha_12) i.block_id, robust
summarize basal_att if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'
testparm i.treatment#(c.age_bl i.literate c.total_cotton_land_ha c.sampled_plot_size_ha i.physical_irrigation_bl i.pucca_house ///
i.plough_own  i.crop_insurance c.children i.educated i.soil_test_before ///
c.fertilizer_plot_kg_bigha_1 c.fertilizer_plot_kg_bigha_3 c.fertilizer_plot_kg_bigha_5 c.fertilizer_plot_kg_bigha_12)
local jointTest: di %9.3f `r(p)'
estadd scalar intTest = `jointTest'

eststo: regress midline_att i.treatment##(c.age_bl i.literate c.total_cotton_land_ha c.sampled_plot_size_ha i.physical_irrigation_bl i.pucca_house ///
i.plough_own i.crop_insurance c.children i.educated i.soil_test_before ///
c.fertilizer_plot_kg_bigha_1 c.fertilizer_plot_kg_bigha_3 c.fertilizer_plot_kg_bigha_5 c.fertilizer_plot_kg_bigha_12) i.block_id, robust
summarize midline_att if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'
testparm i.treatment#(c.age_bl i.literate c.total_cotton_land_ha c.sampled_plot_size_ha i.physical_irrigation_bl i.pucca_house ///
i.plough_own i.crop_insurance c.children i.educated i.soil_test_before ///
c.fertilizer_plot_kg_bigha_1 c.fertilizer_plot_kg_bigha_3 c.fertilizer_plot_kg_bigha_5 c.fertilizer_plot_kg_bigha_12)
local jointTest: di %9.3f `r(p)'
estadd scalar intTest = `jointTest'

eststo: regress endline_att i.treatment##(c.age_bl i.literate c.total_cotton_land_ha c.sampled_plot_size_ha i.physical_irrigation_bl i.pucca_house ///
i.plough_own i.crop_insurance c.children i.educated i.soil_test_before ///
c.fertilizer_plot_kg_bigha_1 c.fertilizer_plot_kg_bigha_3 c.fertilizer_plot_kg_bigha_5 c.fertilizer_plot_kg_bigha_12) i.block_id, robust
summarize endline_att if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'
testparm i.treatment#(c.age_bl i.literate c.total_cotton_land_ha c.sampled_plot_size_ha i.physical_irrigation_bl i.pucca_house ///
i.plough_own i.crop_insurance c.children i.educated i.soil_test_before ///
c.fertilizer_plot_kg_bigha_1 c.fertilizer_plot_kg_bigha_3 c.fertilizer_plot_kg_bigha_5 c.fertilizer_plot_kg_bigha_12)
local jointTest: di %9.3f `r(p)'
estadd scalar intTest = `jointTest'

eststo: regress fr_yield_attrition i.treatment##(c.age_bl i.literate c.total_cotton_land_ha c.sampled_plot_size_ha i.physical_irrigation_bl i.pucca_house ///
i.plough_own i.crop_insurance c.children i.educated i.soil_test_before ///
c.fertilizer_plot_kg_bigha_1 c.fertilizer_plot_kg_bigha_3 c.fertilizer_plot_kg_bigha_5 c.fertilizer_plot_kg_bigha_12) i.block_id, robust
summarize fr_yield_attrition if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'
testparm i.treatment#(c.age_bl i.literate c.total_cotton_land_ha c.sampled_plot_size_ha i.physical_irrigation_bl i.pucca_house ///
i.plough_own i.crop_insurance c.children i.educated i.soil_test_before ///
c.fertilizer_plot_kg_bigha_1 c.fertilizer_plot_kg_bigha_3 c.fertilizer_plot_kg_bigha_5 c.fertilizer_plot_kg_bigha_12)
local jointTest: di %9.3f `r(p)'
estadd scalar intTest = `jointTest'

eststo: regress satellite_yield_attrition i.treatment##(c.age_bl i.literate c.total_cotton_land_ha c.sampled_plot_size_ha i.physical_irrigation_bl i.pucca_house ///
i.plough_own i.crop_insurance c.children i.educated i.soil_test_before ///
c.fertilizer_plot_kg_bigha_1 c.fertilizer_plot_kg_bigha_3 c.fertilizer_plot_kg_bigha_5 c.fertilizer_plot_kg_bigha_12) i.block_id, robust
summarize satellite_yield_attrition if treatment == 0, meanonly
local varMean: di %9.3f `r(mean)'
estadd scalar depMean = `varMean'
testparm i.treatment#(c.age_bl i.literate c.total_cotton_land_ha c.sampled_plot_size_ha i.physical_irrigation_bl i.pucca_house ///
i.plough_own i.crop_insurance c.children i.educated i.soil_test_before ///
c.fertilizer_plot_kg_bigha_1 c.fertilizer_plot_kg_bigha_3 c.fertilizer_plot_kg_bigha_5 c.fertilizer_plot_kg_bigha_12)
local jointTest: di %9.3f `r(p)'
estadd scalar intTest = `jointTest'

esttab using "tables/t-a2/attrition.tex", replace noconstant noobs ///
frag se interaction(" x ") not label tex star(* 0.10 ** 0.05 *** 0.01) ///
indicate("Block FE = *block*") noomitted nobaselevels ///
drop(*#*) ///
scalars("N Observations" "r2_a Adjusted \$R^2$" "depMean Control attrition rate" "intTest p-val of interactions") sfmt(%9.0fc %9.3fc %9.3fc %9.3fc)
