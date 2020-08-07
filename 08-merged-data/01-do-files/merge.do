drop _all
clear matrix
set more off
set maxvar 10000

*****************************************
* Generates the final data set used in analysis
*****************************************

cd ""

//Input Data
global baseline "01-baseline/04-cleaned-data/merged/ATAI_baseline_treatment_assignment.dta"
global basal "02-basal/04-processed-data/basal_clean_2.dta"
global midline "03-midline/04-cleaned-data/ATAI_Midline_2018_Clean.dta"
global zonalStats "05-satellite-yield-measurements/04-output-data/zonalStats.dta"
global cleaned_endline "04-endline/04-cleaned-data/ATAI_Endline_2019_Clean.dta"

//Output Data
global merged_endline "08-merged-data/02-output/ATAI_Endline_2019_Clean_Merged.dta"

use "$cleaned_endline", clear 

/***********************************************************************************
Add baseline, basal, and midline variables that we intend to use 
***********************************************************************************/

rename consent consent_el

merge 1:1 uid using "$baseline", ///
generate(baseline_merge) nolabel ///
keepusing(total_cotton_land sampled_plot_cotton_area gender_f sampled_plot_quantity_harvested ///
  p4_2_1 p4_2_2 p4_2_3 p4_2_o treatment age pucca_house p4_2_o risk_attitude_agriculture ///
  soil_test_before gender_f sampled_plot_size primary_occupation_farming block ///
  fertilizer_plot_kg_bigha_1 fertilizer_plot_kg_bigha_3 fertilizer_plot_kg_bigha_5 fertilizer_plot_kg_bigha_12 ///
  n4_3 n6_1 risk_attitude_agriculture e9 q10* ///
  k1-k6 b3 savings tractor_own plough_own b3-b9 children village_code)
  
egen village_id = group(village_code)
drop village_code
  
rename q10_1 used_urea_bl
rename q10_3 used_dap_bl
rename q10_5 used_mop_bl
rename q10_12 used_zinc_bl


generate k1_correct = cond(missing(k1), ., cond(k1==1,1,0))
generate k2_correct = cond(missing(k2), ., cond(k2==1,1,0))
generate k3_correct = cond(missing(k3), ., cond(k3==1,1,0))
generate k4_correct = cond(missing(k4), ., cond(k4==1,1,0))
generate k5_correct = cond(missing(k5), ., cond(k5==1,1,0))
generate k6_correct = cond(missing(k6), ., cond(k6==1,1,0))

drop k?

egen bl_fert_qs_correct = rowtotal(k?_correct)
label var bl_fert_qs_correct "Baseline: fertilizer questions correct"

quietly summarize bl_fert_qs_correct, detail 
local median = `r(p50)'

generate low_knowledge = cond(bl_fert_qs_correct< `median',1,0)
replace low_knowledge = . if missing(bl_fert_qs_correct)

label var low_knowledge "Low baseline fertilizer knowledge"
label define low_knowledge 0 "High knowledge" 1 "Low knowledge"
label val low_knowledge low_knowledge

recode treatment (2=0)
label define treatment 0 "Control" 1 "Treatment"
label val treatment treatment

rename p4_2_1 irrigation_rain_bl
rename p4_2_2 irrigation_well_bl
rename p4_2_3 irrigation_dam_bl

generate educated = cond(b3>4,1,0)
replace educated = . if missing(b3)

generate crop_insurance = 1 if n4_3 == 2 
replace crop_insurance = 0 if n4_3 < 2

generate financial_resilience = 1 if n6_1 == 1 
replace financial_resilience = 0 if n6_1 > 1 & n6_1 < 5
label var financial_resilience "Can obtain Rs 5,000 in 3 days"
label define financial_resilience 0 "With difficulty or no" 1 "Yes, easily"
label val financial_resilience financial_resilience
drop n6_1 

pca educated financial_resilience savings tractor_own plough_own pucca_house
predict financial_index 

quietly summarize financial_index, detail 
gen wealthy = cond(financial_index>`r(p50)', 1, 0)
label var wealthy "Above median financial index"
label define wealthy 0 "Below median wealth" 1 "Above median wealth"
label val wealthy wealthy

generate fert_belief = 1 if e9 == 1
replace fert_belief = 0 if e9 == 0 | e9==2 
label var fert_belief "Belief about the effect of optimal fertilizer on yields"
label define fert_belief 0 "No or moderate increase" 1 "Significant increase"
label val fert_belief fert_belief
drop e9

generate irrigation_canal_bl = cond(inlist(p4_2_o, "Canal", "Canal thi", "Kenal", "Kenal thi"), 1, 0)
drop p4_2_o

egen physical_irrigation_bl = rowmax(irrigation_well_bl irrigation_dam_bl irrigation_canal_bl)
label var physical_irrigation_bl "Irrigation based on a well, dam, or canal"

merge 1:1 uid using "$basal", generate(basal_merge) nolabel keepusing(SII_1 consent Cotton_area ///
  SII_6_1* SII_5 *_Kg *_area SII_4_1 Sow_date)
rename consent consent_basal
label var SII_1 "Sowed cotton"
label define SII_1 0 "No" 1 "Yes" 2 "Crop failed"
rename SII_1 sowed_cotton_basal

rename cultivated_cotton cultivated_cotton_el

label var age "Age (baseline)"
rename age age_bl
label define pucca_house 0 "No" 1 "Pucca house (English)"
label val pucca_house pucca_house
label var risk_attitude_agriculture "Openess to ag. risk baseline"
rename risk_attitude_agriculture risk_attitude_agriculture_bl
label var soil_test_before "Soil tested prior to study"
label define soil_test_before 0 "No prior test" 1 "Received a prior soil test"
label val soil_test_before soil_test_before
label var gender_f "Male"
label define gender_f 0 "Female" 1 "Male"
label val gender_f gender_f
label define b4 0 "Illiterate" 1 "Literate"
label val b4 b4
label var b4 "Literacy"
rename b4 literate
label var sampled_plot_quantity_harvested "Yield (2017, kg)"
label var sampled_plot_size "Sampled plot size 2017 (bigha)"
label var pucca_house "Pucca house (English)"
label var sampled_plot_cotton_area "Cotton area (2017)"
label var fertilizer_plot_kg_bigha_1 "UREA usage last season (kg/bigha)"
label var fertilizer_plot_kg_bigha_3 "DAP usage last season (kg/bigha)"
label var fertilizer_plot_kg_bigha_5 "MOP usage last season (kg/bigha)"
label var fertilizer_plot_kg_bigha_12 "Zinc usage last season (kg/bigha)"
label var primary_occupation_farming "Primary occupation is self-employed farming"
label var total_cotton_land "Total cotton land (2017)"

merge 1:1 uid using "$midline", keepusing(sowed_cotton consent used_* irrigated_cotton ///
kt_rating *total_kg e*_correct compost_kg *_area *_kg irrigation_source* plot_area_bigha ///
crop_failure_r1-crop_failure_r10 crop_loss_r1-crop_loss_r10 *seeds_kg used*seeds ///
fertilizers_man_hours fertilizers_average_wage fertilizers_average_in_kind_wage *spent) ///
nolabel generate(midline_merge) 

egen seeds_kg = rowtotal(*seeds_kg) 
drop *_seeds_kg 
label var seeds_kg "Kg of cotton seeds used" 

drop crop_failure_r1 //Drought -- we want a variable for shocks which we are excluding low water from since it imapcted almost everyone 
//Other crop failure also excluded (not merged) 
drop crop_loss_r1 //same reason as crop failure 

egen shock = rowmax(crop_failure* crop_loss*) 
label var shock "Suffered production shock" 
label define shock 0 "No shock" 1 "Suffered production shock" 
label val shock shock 
drop crop_failure* crop_loss*

replace reported_area_bigha = plot_area_bigha if missing(reported_area_bigha) //Replace plot size with the midline value if missing

egen physical_irrigation_ml = rowmax( irrigation_source_r2 irrigation_source_r3 irrigation_source_r4)
label var physical_irrigation_ml "Irrigation (midline, excluding rainfall)"
label define physical_irrigation_ml 0 "No irrigation" 1 " Irrigation"
label val physical_irrigation_ml physical_irrigation_ml

rename irrigated_cotton irrigation_ml 

//Add in recommended fertilizer doses 
merge 1:1 uid using "07-soil-health-data/04-processed-data/ATAI_Soil_Tests_Results_Recommendations.dta", ///
nogenerate nolabel keep(1 3) keepusing(*bd_rec* zinc_rec_ir area_units dap_total_rec_ir-urea_d2_rec_ur_str)

drop *rec*str // these are string variables and we already have numeric recs

rename sowed_cotton sowed_cotton_midline
rename consent consent_ml
rename kt_rating rating 
label var rating "KT call rating"

merge 1:1 uid using "$zonalStats", assert(1 3) generate(map_merge)

//Note: Earlier versions of this file included rainfall data in zonalStats and the merged output
//After adding more years, the number of variables is huge so rainfall is now stored in a separate file and some do files using the merged product may not execute

drop __000000 __000001 //these are temp variables that somehow got saved

egen block_id = group(block), label 
drop block 

//Generate the following sowed cotton variable: 
*If midline data exists, use that 
*If not, see if basal data exists
*If no basal or midline data, use endline data 

generate sowed_cotton = sowed_cotton_midline
replace sowed_cotton = sowed_cotton_basal if missing(sowed_cotton)
replace sowed_cotton = 1 if sowed_cotton == 2 //This means they sowed cotton but it failed, include this since they still sowed
replace sowed_cotton = cultivated_cotton_el if missing(sowed_cotton)

label define sowed_cotton 0 "No" 1 "Yes" 
label val sowed_cotton sowed_cotton

drop cultivated_cotton_el sowed_cotton_midline sowed_cotton_basal

//Now add in listening rate data 
merge 1:1 uid using "06-kt-metadata/03-kt-call-data/KT_qs.dta", assert(1 3) generate(inbound_merge)
merge 1:1 uid using "06-kt-metadata/03-kt-call-data/KT_call details.dta", assert(1 3) generate(kt_merge)
merge 1:1 uid using "06-kt-metadata/02-treatment-call-data/ATAI_call details.dta", assert(1 3) generate(atai_merge)

preserve 

clear
import excel using "04-endline/02-raw-data/question_tags.xls", firstrow

egen question_category = concat(Tag C D E F G H)

keep uid question_category

replace question_category = lower(question_category)

gen fert_question = cond(strpos(question_category, "fertilizer"), 1, 0)
drop question_category

collapse (sum) fert_question, by(uid)

label var fert_question "Number of questions asked about fertilizer"
tempfile fert_questions 
save `fert_questions', replace 

restore 

merge 1:1 uid using `fert_questions', assert(1 3) nogenerate 

replace fert_question = 0 if missing(fert_question) //Never left any questions 

// Add soil health values 
merge 1:1 uid using "07-soil-health-data/04-processed-data/ATAI_Soil_Test_Results.dta", keep(1 3) nogenerate

save "$merged_endline", replace
