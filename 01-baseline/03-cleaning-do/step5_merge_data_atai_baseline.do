clear all
version 14
cap log close
set logtype text
set more off
set maxvar 20000
/****************************************************************************
NOTE: This file may not run. We made minimal edits to protect PII.					
****************************************************************************/

gl Main ""

*Input data
loc form1		"01-baseline/04-cleaned-data/form_one/ATAI_baseline_survey_clean.dta"
loc form3		"01-baseline/04-cleaned-data/form_three/ATAI_baseline_Form_3_clean.dta"
loc soil_data	"07-soil-health-data/02-raw-data/ATAI_Soil_Tests_Results_Recommendations.dta"
loc master_kt	"OMITTED"

*Output data
loc merged_data	"01-baseline/04-cleaned-data/merged/ATAI_baseline_all.dta"

*Log
loc logfile "OMITTED"

log using "`logfile'", replace

*Form 3
use "`form3'" 

duplicates list uid
duplicates tag uid, gen(aux)
gen form3_dup = (aux>0)
la var form3_dup "Form 3 is duplicated in the server"
drop aux

tempfile form_3
save `form_3'
clear

*KT Master Data 
use "`master_kt'", clear
rename service_no mobile_number_f
keep if atai_year2 == 1

keep mobile_number_f name block village
tostring mobile_number_f, replace format("%25.0f")

tempfile ktdata
save `ktdata'

* Form 1
use "`form1'", clear

duplicates list uid
duplicates tag uid, gen(aux)
gen form1_dup = (aux>0)
la var form1_dup "Form 1 is duplicated in the server"

sort uid not_eligible a4_1
gen respondent_replaced = 0
by uid : gen n = _n
by uid : replace respondent_replaced = 1 if n > 1 & a4_1 == 1 & not_eligible == 1

drop n
drop if respondent_replaced == 1
drop respondent_replaced

merge m:m uid using `form_3'

**B03V40F1189 - this is a pilot village UID
gen form_1 = (_m == 3 | _m == 1)
la val form_1 yesno
la var form_1 "Form 1 is in the server"

gen form_3 = (_m == 3 | _m == 2)
la val form_3 yesno
la var form_3 "Form 3 is in the server"

tab form_1 form_3

list uid if form_1 == 1 & form_3 == 0

list uid if form_1 == 0 & form_3 == 1

tab consent

tab not_eligible

tab applicable

tab r1

tab f3_consent

list uid name_f date if r1 == 0 & f3_consent == 1

gen inapplicable_refusal = (consent == 0 | not_eligible == 1 | applicable == 0 | f3_consent == 0 )

tab block inapplicable_refusal

list uid name_f if inapplicable_refusal == 1

drop if inapplicable_refusal == 1

**Ajmer village was droppet from the study sample
list uid name_f date if village == "ajmer"
drop if village == "ajmer"


list uid if form_1 == 1 & form_3 == 0
 
list uid if form_1 == 0 & form_3 == 1

drop _m

merge m:1 mobile_number_f using `ktdata'

list uid mobile_number_f if _merge== 2 | _merge== 3

drop if _merge== 2 | _merge== 3

drop _m


gen form1_form3_completed = complete == 1 & f3_success == 1

tab block form1_form3_completed

list uid name_f if form1_form3_completed == 1

keep if form1_form3_completed == 1

tab village

bys village : gen village_size = _N

list uid name_f village if village_size <10

drop if village_size <10 

*Fixing the mobile number duplicates based on Correct_Name_Report 
drop if uid == "B03V31F0936" & mobile_number_f == "OMITTED"
drop if uid == "B05V68F1899" & mobile_number_f == "OMITTED"


save "`merged_data'", replace

note : ATAI Baseline dataset to be used in treatment assignment. Dataset was generated on $S_DATE with step5_merde_data_atai_baseline.do

log close
