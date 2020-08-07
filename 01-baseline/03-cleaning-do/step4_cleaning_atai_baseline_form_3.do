clear all
version 14
cap log close
set more off
set maxvar 20000
/****************************************************************************
NOTE: This file cannot run because it requires variables with PII. It is included with minimal edits for reference.
****************************************************************************/

*Input data
loc raw "01-baseline/02-raw-data/form_three/ATAI_Baseline_Form_3_Test.dta"

*Output data
loc clean "01-baseline/04-cleaned-data/form_three/ATAI_baseline_Form_3_clean.dta"


use "`raw'"

drop if key=="uuid:88dbe98d-9b0d-4ef6-81bd-2c341bc3f467" //Same survey uploaded twice
drop if key=="uuid:82cf12ae-8a71-4532-97cf-3136b69b5e69" //Seems that form was uploaded twice
drop if key=="uuid:8826b613-487b-46cc-922c-9de38f609531" //Seems that form was uploaded twice
drop if key=="uuid:bdc27243-d739-4fa2-9514-cd8f95d6ba2f" //// Two respondents were surveyed for two different plots of the same owner. Keeping the one with Largest plot size.
drop if uid == "uid_key"
drop if uid == "B03V40F1189" //this is a pilot village UID. Azfar we should drop this, right? AK- Yes we are dropping.


* soil sample for uid = B01V09F0268 was collected	
replace f3_a9 = 0 if uid == "B01V09F0268"	
replace f3_a10 = 1 if uid == "B01V09F0268"
replace success = 1 if uid == "B01V09F0268"

order f3_a13, after(f3_a12)

*Plot marker
replace f3_a5 = lower(f3_a5)

rename f3_a3	f3_revisit
rename f3_a4	f3_same_plot
rename f3_a5	f3_plot_marker
rename f3_a6	f3_ready_collect_soil_sample
rename f3_a7	f3_plot_empty
rename f3_a8	f3_soil_dry
rename f3_a9	f3_no_fertilizer_soil
rename f3_a10	f3_consent
rename f3_a11	f3_forms_bag
rename f3_a12	f3_no_completition
rename f3_a13	f3_revisit_date
rename success	f3_success

*Success
replace f3_success = 0 if f3_success == .

*Date
gen f3_date =  dofc(starttime)
format f3_date %td_N-CY


*Drop SurveyCTO vars
drop deviceid	subscriberid	simid	devicephonenum
		
save "`clean'", replace

