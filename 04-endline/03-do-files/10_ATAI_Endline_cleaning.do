drop _all
clear matrix
set more off
capture log close
set logtype text
set maxvar 10000

/****************************************************************************
****************************************************************************/

//Set directory: insert the path to the base ATAI year 2 directory 
else if c(username) == "grady" {
  global user "~/Dropbox (Precision Agr)/Field_data_india/ATAI_DATA_FOR_PUBLICATION"
}

cd "$user"

//Input Data
global form_1 "04-endline/02-raw-data/ATAI_Endline_Form_1.dta"
global form_2 "04-endline/02-raw-data/ATAI_Endline_Form_2.dta"

//Output Data
global cleaned_endline "04-endline/04-cleaned-data/ATAI_Endline_2019_Clean.dta"

/***********************************************************************************
Clean form 2 and prepare the data to be merged with form 1
***********************************************************************************/
use "$form_2", clear 

local numobs_f2_1 = _N

//Drop metadata variables 
replace uid_confirm = upper(uid_confirm)
assert uid == uid_confirm 
drop deviceid subscriberid simid devicephonenum intro duration uid_confirm surveyor supervisor  
drop date time date_v time_v time_a f2_a1 note* formdef_version submissiondate starttime
drop endtime date_a end_time

drop f2_a2_1 f2_a6 f2_a5

local numobs_f2_2 = _N

//Handle duplicates 

//Make sure that UIDs use uppercase letters only 
replace uid = upper(uid)

duplicates drop uid f2_a2 f2_a3 f2_a4 f2_a7, force //Identical across all the variables of interest

*In a lot of cases the plot was eventually mapped, this next block of code is designed to get rid of failed visits in these cases
*The area variable seems to most reliably indicate if the observation should be kept or not 
duplicates tag uid, gen(dup)
sort uid f2_a7
by uid: gen group_id = _n 
drop if dup>0 & _n>1 & missing(f2_a7)

drop dup group_id 

//This leaves 2 duplicates left -- these were resolved by going to the logs 
replace uid = "B02V16F0467" if key == "uuid:cb330576-40b1-49f2-aa89-a95659dc0a75"
drop if key == "uuid:9ffef4bd-0c9c-4b41-9610-e4e4b3a6bd5b"
replace uid="B03V36F1079" if uid=="B03V36F1179"
replace uid = "B02V16F0467" if key == "uuid:cb330576-40b1-49f2-aa89-a95659dc0a75"

isid uid 

//Rename variables we want to keep
rename f2_a2 mapped_surveyed_plot
rename f2_a3 consent_mapping 
rename f2_a4 cotton_partial
drop f2_a7 
rename success mapping_complete

local numobs_f2_final = _N 


drop key

tempfile form_2_cleaned
save `form_2_cleaned'

/***********************************************************************************
Clean form 1
***********************************************************************************/
use "$form_1", clear 

describe 
local numobs_f2_1 = _N 

//Drop variables for which all observations are missing 
  foreach x of varlist _all {
    quietly tab `x'
    if `r(N)' == 0 {
      drop `x'
      dis in red "Dropped `x' because all observations were missing"
    }
  }

//Recode incorrect 888 values to -888 
replace a8_1_2 = -888 if key == "uuid:e0a1984d-91bd-479f-aa26-bd5a42f89796"

//Recode -888 to missing 
ds, has(type numeric)

foreach var of varlist `r(varlist)' {
  replace `var' = .d  if `var' == -888
  assert `var' != 888 //make sure there are no values where 888 was accidentally entered in place of -888
}


/***********************************************************************************
Duplicates 
***********************************************************************************/
replace uid_confirm = upper(uid_confirm)
assert uid == uid_confirm
drop uid_confirm

drop if key == "uuid:9816af0b-a3bd-4ef0-b720-7e4df9595028" //Incomplete and duplicate 
drop if key == "uuid:c6a6e191-2ea7-40b8-a73e-64fff98f8b3a" //The farmer didn't consent at this point, but later completed the survey 
drop if key == "uuid:8fb5be02-c2fe-42f2-9994-33d65e3b85c4" //The other observation with a duplicate uid matches the tracking log 
drop if key == "uuid:78d44326-237d-4e42-87b7-1001dd625a6b" //The other observation with a duplicate uid matches the tracking log 

isid uid 

*key is no longer needed to uniquely identify the data, so we may drop it 
drop key

/***********************************************************************************
Metadata 
***********************************************************************************/

//Drop metadata and variables pulled from earlier surveys

drop deviceid simid duration start_time_sx surveyor supervisor land_plot*

drop unit_land_bl land_size_midline cotton_area_midline ///
unit_land_ml nonsurvey_plots instancename formdef_version

drop date time date_v time_v time_a start? isvalidated submissiondate endtime

drop start_time* end_time*

//Drop block because we will merge it from the baseline data where none is missing 
drop block 

//The reject why options should have been select one, not multiple, so we may drop all but the first variable
drop reject_why_* 

/*
To make the data cleaner I get rid of all but the first "consent_no" variables since the rest can 
be derived from this, we are unlikely to use this, and it makes the data messy
*/
drop consent_no_*

drop x? //We do not care if this information has changed since it is only for tracking 

/***********************************************************************************
Section A: Area and Harvest (Surveyed Plot) 
***********************************************************************************/

rename a1 cultivated_cotton 

drop a2* //surveycto already translates the data into final area measurements 
drop pri_area_sp_dkda sec_area_sp_dkda pri_area_sp_bigha sec_area_sp_bigha total_area_sp_dkda
rename total_area_sp_bigha reported_area_bigha 
label var reported_area_bigha "Farmer reported plot size (bigha)"


rename total_cot_area_sp_bigha reported_cotton_area
replace reported_cotton_area = cotton_area_bigha_midline if a3 == 1
drop cotton_area_bigha_midline a3* pri_cot_area_sp_dkda sec_cot_area_sp_dkda ///
pri_cot_area_sp_bigha sec_cot_area_sp_bigha total_cot_area_sp_dkda cot_area_sp_check 

rename a4 irrigation_el 
rename a5 harvested_cotton 
rename a6 number_harvests 

drop harvests_count harvest_no_? harv_splot_hw_dkda harv_splot_hw_kg ///
harv_splot_dq_dkda harv_splot_dq_kg harv_splot_dkda harv_splot_maund a9_1*

drop a7* a8* //We are unlikely to use these harvest wise variables (harvest time and harvest wise yield)
//in final analysis, so I'm removing them from the cleaned data so that it's easier to find variables 
//that we are looking for, if we decide to use them remove these lines 

rename harv_splot_kg yield_kg 
replace yield_kg = . if a9_2 == 0
drop a9_2 

/***********************************************************************************
Section B: Area and Harvest (Non-Surveyed Plots) 
***********************************************************************************/

//In this section, I get rid of all intermediary variables used to calculate a final result 

//I also move all plot level variables to the end of the data since we probably won't analyze them 

rename nsplots_count nonsurveyed_plots 
label var nonsurveyed_plots "Number of non-surveyed plots"

drop nsplot_id* nsplot_land_* harv_nsplot_dkda_* harv_nsplot_maund_*
drop b5_* b6_* pri_area_ns_dkda_* sec_area_ns_dkda_* pri_area_ns_bigha_* sec_area_ns_bigha_* total_area_ns_dkda_* area_ns_compare_*

drop b7* pri_cot_area_ns_dkda_* sec_cot_area_ns_dkda_* pri_cot_area_ns_bigha_* sec_cot_area_ns_bigha_* total_cot_area_ns_dkda_* cot_area_ns_check_*

drop b8_* b9_* b10_* b10_1_*

drop b1_* b2* b3* b4* total_area_ns_bigha_* total_cot_area_ns_bigha_* harv_nsplot_kg_* //We are unlikely to use these harvest wise variables (harvest time and harvest wise yield)
//in final analysis, so I'm removing them from the cleaned data so that it's easier to find variables 
//that we are looking for, if we decide to use them remove these lines 

drop marker_* land_* land_bigha_* harv_all_nsplot_dkda

label var harv_all_nsplot_kg "Total harvested cotton from non-surveyed plots (kg)"

drop aplot_no* b11 b11_1 b12_1* 

//Additional plot plotwise values, delete the following code if you want these in the final data 
drop b12_7* b12_8* b12_9* b13*

drop b12_2* b12_3* b12_4* total_area_ap_bigha_* total_cot_area_ap_bigha_* harv_aplot_kg_* //We are unlikely to use these harvest wise variables (harvest time and harvest wise yield)
//in final analysis, so I'm removing them from the cleaned data so that it's easier to find variables 
//that we are looking for, if we decide to use them remove these lines 

drop b12_5* b12_6* temp* pri_area_ap_dkda_* sec_area_ap_dkda_* pri_area_ap_bigha_* ///
sec_area_ap_bigha_* total_area_ap_dkda_* ///
pri_cot_area_ap_dkda_* sec_cot_area_ap_dkda_* pri_cot_area_ap_bigha_* sec_cot_area_ap_bigha_* ///
total_cot_area_ap_dkda_* cot_area_ap_check_* harv_aplot_dkda_* harv_aplot_maund_*

drop harv_all_aplot_dkda harv_total_cc_dkda harv_temp_* ///
harv_total_cc_kg harv_total_dq_dkda harv_total_dq_kg harv_total_dkda harv_total_maund

/***********************************************************************************
Section C: Sale and Reserve Details  
***********************************************************************************/

rename c1 selling_cotton 
rename c2 cotton_sales

drop sale_no*

drop c3* c4* //time and location of individual sales, delete this code if we end up using this in analysis

rename c5_total_kg cotton_sold_kg
replace cotton_sold_kg = 0 if selling_cotton == 0 //Have not started selling
label var cotton_sold_kg "Total cotton sold (kg)"

egen total_sale_revenue = rowtotal(c6_1*), missing 
label var total_sale_revenue "Total revenue from all sales (rupees)"

drop c5* c6* //Sale wise volume and amount, delete this code if we decide to use it in analysis 

drop sales_count reserve_count 

rename c7 unsold_cotton 

rename c8 storage_locations 
rename c8_1 storage_own_house 
rename c8_2 storage_own_godown
rename c8_3 storage_neighbor_godown
rename c8_4 storage_market_warehouse
rename c8_5 storage_other 
rename c8__d storage_dk 
rename c8_o other_storage_location

drop c8_id* c8_name* 

drop c9_temp c9_all_dkda c9_total_maund c9_1* c9_dkda* c9_maund* c9_kg_* c9_2* //Intermediate variables and storage-location wise storage amount 

rename c9_total_kg cotton_stored_kg 
label var cotton_stored_kg "Total cotton stored (kg)"

local i = 1
foreach var of varlist c10* { 
rename `var' planned_sale_time_`i'
local i = `i' + 1
}

egen expected_storage_revenue = rowtotal(c11_1*), missing 
label var expected_storage_revenue "Expected revenue from selling stored cotton (Rs)"

drop  c11* //Storage-location wise sales, delete this code if you want to use it 

//Fix a variable that was coded as -848 instead of -888
replace c12 = .d if c12 == -848 
drop c12_dkda

generate total_sold_stored = 20*c12 
label var total_sold_stored "Total cotton sold and stored (kg)"
drop c12 //This is in maund which we are not using for analysis 

/***********************************************************************************
Section D: Sale and Reserve Details  
***********************************************************************************/

rename d1 knowledge_1 
drop d1_o //These responses are incorrect

replace d2 = 2 if inlist(d2_o, "12 32", "12 32 16", "12-32-16", "12/32/16m p", ///
  "NPK- 12-32-16", "Npk-12-32-16", "12-32-16", "N p k")

replace d2 =4 if inlist(d2_o, "D A P", "D AP", "D a p", "D.a.p", "DAP", "DAp", "DaP", ///
  "Dap", "Dop")

rename d2 knowledge_2 
label define knowledge_2 1 "Murate of Potash (MOP)" 2 "NPK grade fertilizer" ///
3 "Organic  Fertilizers" 4 "DAP" .d "Does not know" .o "Other"
label val knowledge_2 knowledge_2

drop d2_o //I extracted the consistent responses that are valid (a lot cite multiple fertilizers but it's select one)

rename d3 knowledge_3

drop d3_o //This doesn't make any sense in this question 

replace d4 = 4 if inlist(d4_o, "D A P", "D.A.P.", "DA", "DAP", "Dap")
replace d4 = 5 if inlist(d4_o, "Urea", "Uria", "Uriya", "Uriyq")

rename d4 knowledge_4 
label define knowledge_4 1 "Ammonium Sulphate/SSP/Gypsum/Chirodi" 2 "Sulphur fertilizer" 3 "None" 4 "DAP" 5 "UREA"

label val knowledge_4 knowledge_4
drop d4_o

rename d5 knowledge_5
drop d5_o //This question should not have had an "other" option 

local i = 1
foreach var of varlist d6_? {
  rename `var' knowledge_6_`i' 
  local i = `i' + 1
}

local i = 1
foreach var of varlist d6_?_1 {
  rename `var' knowledge_6_`i'_1 
  local i = `i' + 1
}

local i = 1
foreach var of varlist d7_* {
  rename `var' knowledge_7_`i' 
  local i = `i' + 1
}

/***********************************************************************************
Section E: Source of Information   
***********************************************************************************/

rename e1_1 info_tv 
rename e1_2 info_mobile_phone
rename e1_3 info_gov_extension 
rename e1_4 info_ngo 
rename e1_5 info_farmers 
rename e1_6 info_agro_shops 
rename e1_7 info_traders
rename e1_8 info_radio 
rename e1_9 info_krushi_mela 
rename e1_10 info_newspaper 
rename e1_11 info_other 
rename e1_11_o other_info_source 

rename e2_1 trust_tv 
rename e2_2 trust_mobile_phone
rename e2_3 trust_gov_extension 
rename e2_4 trust_ngo 
rename e2_5 trust_farmers 
rename e2_6 trust_agro_shops 
rename e2_7 trust_traders
rename e2_8 trust_radio 
rename e2_9 trust_krushi_mela 
rename e2_10 trust_newspaper 
rename e2_11 trust_other 

rename e3_1 phone_info_sources 
rename e3_1_1 phone_info_kt
rename e3_1_2 phone_info_iffco_kisaan
rename e3_1_3 phone_info_reliance_foundation 
rename e3_1_4 phone_info_local_kvk
rename e3_1__d phone_info_dk
rename e3_1__o phone_info_other 
rename e3_1_o other_phone_info

rename e3_2 call_frequency
rename e3_3 days_called 
drop e3_3_* //The data is in days_called and I don't think we're likely to use this 

rename e3_4 phone_service_start

rename e4 primary_info_source 
rename e4_o other_primary_source

/***********************************************************************************
Section F: Willingness to Experiment    
***********************************************************************************/

rename f1 willingness_to_experiment
rename f2 experimented_2018  
rename f3 experiments_2018 
rename f3_1 expriment_bore_well
rename f3_2 expriment_new_fertilizer 
rename f3_3 experiment_fert_quantity 
rename f3_4 experiment_pesticide 
rename f3_5 experiment_machinery
rename f3_6 experiment_intercropping
rename f3_7 experiment_seed_variety 
rename f3_8 experiment_drip_irrigation 
rename f3_9 experiment_organic
rename f3_10 experiment_land_prep
rename f3_11 experiment_new_crop
rename f3_12 experiment_fencing
rename f3__o experiment_other 
rename f3__d experiment_dk
rename f3_999 experiment_refuse
rename f3_o other_experiment 

rename f4 exp_reason 
rename f4_1 exp_reason_observation 
rename f4_2 exp_reason_gov
rename f4_3 exp_reason_subsidy
rename f4_4 exp_reason_rec
rename f4_5 exp_reason_info_source
rename f4_6 exp_reason_self
rename f4__o exp_reason_other
rename f4__d exp_reason_dk
rename f4_999 exp_reason_refuse
rename f4_o other_exp_reason


/***********************************************************************************
Merge form 2 data and save  
***********************************************************************************/

merge 1:1 uid using `form_2_cleaned', generate(form_merge)

save "$cleaned_endline", replace 
