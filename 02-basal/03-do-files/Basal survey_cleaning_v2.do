clear all
version 14
cap log close
set more off
set maxvar 20000
/****************************************************************************
NOTE: This file will not run because PII was removed 
****************************************************************************/
*specify main path

cd ""

*Input data
loc raw "02-basal/02-raw-data/Basal Survey.dta"

*Output data
loc clean "02-basal/04-processed-data/Basal_Survey_clean_TEST.dta"
****************************************************************************/
use "`raw'"

label var respondent_name "Name of respondent" 
label var block "Block name"
label var village "Village name"
label var mobile "Mobile numer of respondent"
label var plot_name "Name of 'applicable plot' from baseline"

destring consent, replace
label var consent "Consent for the survey"
label define yesno 1 "Yes" 0 "No"
label values consent yesno 

destring SII_1, replace
label var SII_1 "Sown cotton in plot surveyed at baseline"
replace SII_1 = 2 if SII_1==-98
label define sowing 0 "No sowing" 1 "Sowing" 2 "Crop failure"
label values SII_1 sowing  
label var SII_1_other "Reason for crop failaure"
label var SII_1_reason "Reason for not sowing cotton"

* Generating date of sowing
destring SII_2 SII_2_unit, replace
replace SII_2_unit = 1 if SII_2>3 & SII_2_unit == 2 //surveyors selected option for months instead of days by mistake 
replace SII_2 = SII_2*30 if SII_2_unit==2 //multiplying data by 30 for if farmer responded in terms of months
gen Date = date(LoginDate, "DMY"), after(SII_1_reason) 
format Date %td
gen Sow_date = Date - SII_2, after(Date) 
format Sow_date %td
label var Sow_date "Start of cotton sowing"
label var Date "Date of basal survey"
drop SII_2 SII_2_unit SII_2_unit_other 
*twoway kdensity sow_date if tdum1=="Treatment" || kdensity sow_date if tdum1=="Control", legend(order(1 "Treatment" 2 "Control")) xtitle("Date of sowing") xla(,format("%td"))

* In case farmer reported in terms of acre/bigha and guntha then adding guntha to acre/bigha   
destring SII_3_1 SII_3_1_sub, replace 
replace SII_3_1 = SII_3_1 + (SII_3_1_sub*(1/16)) if SII_3_1_sub>0 & SII_3_2_sub == "4" & SII_3_2 == "1" // 16 guntha = 1 bigha
replace SII_3_1 = SII_3_1 + (SII_3_1_sub*(1/40)) if SII_3_1_sub>0 & SII_3_2_sub == "4" & SII_3_2 == "2" //40 guntha = 1 acre

label var SII_3_1 "Cotton area in sampled plot"
label var SII_3_2 "Unit of cotton area in sampled plot"
destring SII_3_2, replace
label define area 1 "Bigha" 2 "Acre" 3 "Hectare" 4 "Guntha"
label values SII_3_2 area
drop SII_3_1_sub SII_3_2_sub SII_3_2_other

* Irrigation
label var SII_4_1 "Access to irrigation for cotton crop in sampled plot"
label define SII_4_1 1 "Yes" 0 "No"
** Incorporating irrigation data collected in 'notes' by surveyors into main data
replace SII_4_1 = "0" if SII_4_2_other=="BIN PIYAT CHHE"
replace SII_4_2 = "" if SII_4_2_other=="BIN PIYAT CHHE"
replace SII_4_2 = "4" if SII_4_2_other=="KANAL" 
replace SII_4_2 = "4" if SII_4_2_other=="KENAL"
replace SII_4_2 = "4" if SII_4_2_other=="NADINU PANI"
replace SII_4_2 = "4" if SII_4_2_other=="DRIP IRIGATION"
replace SII_4_2 = "4" if SII_4_2_other=="DRIP IRRAGATION"
replace SII_4_2 = "4" if SII_4_2_other=="DRIP IRREGATION"
replace SII_4_2 = "4" if SII_4_2_other=="DRIP THI PANI NAKHE CHE"
replace SII_4_2 = "4" if SII_4_2_other=="DRIP IRRIGATION"
replace SII_4_2 = "4" if SII_4_2_other=="TAPAK"
replace SII_4_2 = "4" if SII_4_2_other=="TAPAK  PADDHITI"
replace SII_4_2 = "4" if SII_4_2_other=="TAPAK PADDHTI CHE"
replace SII_4_2 = "4" if SII_4_2_other=="BHADE PANI LAVE CHE"
replace SII_4_2 = "2" if SII_4_2_other=="KUVAMATHI BHADE THI PANI LAVE CHHE."
replace SII_4_2 = "4" if SII_4_2_other=="GHARNA PANI NO UPYOG KARE CHE"
destring SII_4_2, replace
label var SII_4_2 "Source of irrigation"
lab define SII_4_2	1 "Rainfall" 2	"Underground water" 3	"Dam" 4 "Surface Irrigation"
label values SII_4_2 SII_4_2
drop SII_4_2_other 
drop ComputerName LoginPerson LoginStartTime LoginEndTime Srno ComputerName_Last LoginPerson_Last LoginStartTime_Last LoginEndTime_Last Srno_Last LoginDate LoginDate_Last

**Fertilizers
label var SII_5 "Used fertilizer at time of sowing"
label define quantity 1 "Kilo" 2 "Litre" 3 "Gram" 4 "Milliliter" 5"Bag"
label define bagsize 1 "25 Kilogram" 2 "45 Kilogram" 3 "50 Kilogram" 4 "75 Kilogram"

**Incorporating entries collected under 'other units' of fertilizer quantity with main data
**Dropping variables associated with 'other units' of fertilizer quantity   
destring SII_6_2_ZINC, replace
replace SII_6_2_ZINC = SII_6_2_ZINC * 20 if SII_6_4_other_ZINC=="20 KG"
replace SII_6_3_ZINC = "1" if SII_6_4_other_ZINC=="20 KG"

drop SII_6_3_other_UREA SII_6_4_other_UREA SII_6_3_other_DAP SII_6_4_other_DAP
drop SII_6_3_other_MOP SII_6_4_other_MOP SII_6_3_other_ZINC SII_6_4_other_ZINC
drop SII_6_3_other_NPK SII_6_4_other_NPK

label var FKT_1 "Receiving regular KT Calls"
destring FKT_1 FKT_2, replace
label values FKT_1 yesno 
label var FKT_2 "Rating of usefulness of KT calls" 
label define rating 1 "Not useful" 2 "Very little use" 3 "Somewhat useful" 4 "Useful" 5 "Very useful"
label values FKT_2 rating
label var FKT_3 "Suggested Changes in KT Calls" 

rename SII_6_1_NPK SII_6_1_NPK_202020 
rename SII_6_2_NPK SII_6_2_NPK_202020
rename SII_6_3_NPK SII_6_3_NPK_202020
rename SII_6_4_NPK SII_6_4_NPK_202020
rename SII_7_1_NPK SII_7_1_NPK_202020 
rename SII_7_2_NPK SII_7_2_NPK_202020
rename SII_7_3_NPK SII_7_3_NPK_202020

**Incorportaing data on NPK grade fertilizers which was captured in notes into main data
gen SII_6_1_NPK_20200 = . , before(FKT_1)
gen SII_6_2_NPK_20200 = "" , before(FKT_1) 
gen SII_6_3_NPK_20200 = . , before(FKT_1) 
gen SII_6_4_NPK_20200 = . , before(FKT_1)
gen SII_7_1_NPK_20200 = . , before(FKT_1)
gen SII_7_2_NPK_20200 = "" , before(FKT_1)
gen SII_7_3_NPK_20200 = . , before(FKT_1)

replace SII_6_1_NPK_20200 = 1 if Id=="B01V03F0082"
replace SII_6_2_NPK_20200 = "50" if Id=="B01V03F0082"
replace SII_6_3_NPK_20200 = 1 if Id=="B01V03F0082"
replace SII_7_1_NPK_20200 = 1 if Id=="B01V03F0082"

gen SII_6_1_NPK_123216 = . , before(FKT_1)
gen SII_6_2_NPK_123216 = "" , before(FKT_1)
gen SII_6_3_NPK_123216 = . , before(FKT_1)
gen SII_6_4_NPK_123216 = . , before(FKT_1)
gen SII_7_1_NPK_123216 = . , before(FKT_1)
gen SII_7_2_NPK_123216 = "" , before(FKT_1)
gen SII_7_3_NPK_123216 = . , before(FKT_1)

replace SII_6_1_NPK_123216 = 1 if Id=="B01V01F0004"
replace SII_6_2_NPK_123216 = "4" if Id=="B01V01F0004"
replace SII_6_3_NPK_123216 = 5 if Id=="B01V01F0004"
replace SII_6_4_NPK_123216 = 3 if Id=="B01V01F0004"
replace SII_7_1_NPK_123216 = 0 if Id=="B01V01F0004"
replace SII_7_2_NPK_123216 = "15" if Id=="B01V01F0004"
replace SII_7_3_NPK_123216 = 1 if Id=="B01V01F0004"

replace SII_6_1_NPK_123216 = 1 if Id=="B01V03F0093"
replace SII_6_2_NPK_123216 = "2" if Id=="B01V03F0093"
replace SII_6_3_NPK_123216 = 5 if Id=="B01V03F0093"
replace SII_6_4_NPK_123216 = 3 if Id=="B01V03F0093"
replace SII_7_1_NPK_123216 = 0 if Id=="B01V03F0093"
replace SII_7_2_NPK_123216 = "2" if Id=="B01V03F0093"
replace SII_7_3_NPK_123216 = 2 if Id=="B01V03F0093"

replace SII_6_1_NPK_123216 = 1 if Id=="B01V05F0131"
replace SII_6_2_NPK_123216 = "100" if Id=="B01V05F0131"
replace SII_6_3_NPK_123216 = 1 if Id=="B01V05F0131"
replace SII_7_1_NPK_123216 = 1 if Id=="B01V05F0131"

replace SII_6_1_NPK_20200 = 1 if Id=="B01V05F0137"
replace SII_6_2_NPK_20200 = "2" if Id=="B01V05F0137"
replace SII_6_3_NPK_20200 = 5 if Id=="B01V05F0137"
replace SII_6_4_NPK_20200 = 3 if Id=="B01V05F0137"
replace SII_7_1_NPK_20200 = 0 if Id=="B01V05F0137"
replace SII_7_2_NPK_20200 = "1.5" if Id=="B01V05F0137"
replace SII_7_3_NPK_20200 = 2 if Id=="B01V05F0137"

replace SII_6_1_NPK_20200 = 1 if Id=="B01V05F0143"
replace SII_6_2_NPK_20200 = "2" if Id=="B01V05F0143"
replace SII_6_3_NPK_20200 = 5 if Id=="B01V05F0143"
replace SII_6_4_NPK_20200 = 3 if Id=="B01V05F0143"
replace SII_7_1_NPK_20200 = 0 if Id=="B01V05F0143"
replace SII_7_2_NPK_20200 = "5" if Id=="B01V05F0143"
replace SII_7_3_NPK_20200 = 2 if Id=="B01V05F0143"

replace SII_6_1_NPK_20200 = 1 if Id=="B01V05F0149"
replace SII_6_2_NPK_20200 = "6" if Id=="B01V05F0149"
replace SII_6_3_NPK_20200 = 5 if Id=="B01V05F0149"
replace SII_6_4_NPK_20200 = 3 if Id=="B01V05F0149"
replace SII_7_1_NPK_20200 = 1 if Id=="B01V05F0149"

replace SII_6_1_NPK_123216 = 1 if Id=="B01V08F0224"
replace SII_6_2_NPK_123216 = "1" if Id=="B01V08F0224"
replace SII_6_3_NPK_123216 = 5 if Id=="B01V08F0224"
replace SII_6_4_NPK_123216 = 3 if Id=="B01V08F0224"
replace SII_7_1_NPK_123216 = 1 if Id=="B01V08F0224"

replace SII_6_1_NPK_123216 = 1 if Id=="B01V10F0271"
replace SII_6_2_NPK_123216 = "8" if Id=="B01V10F0271"
replace SII_6_3_NPK_123216 = 5 if Id=="B01V10F0271"
replace SII_6_4_NPK_123216 = 3 if Id=="B01V10F0271"
replace SII_7_1_NPK_123216 = 1 if Id=="B01V10F0271"

replace SII_6_1_NPK_123216 = 1 if Id=="B01V10F0273"
replace SII_6_2_NPK_123216 = "240" if Id=="B01V10F0273"
replace SII_6_3_NPK_123216 = 1 if Id=="B01V10F0273"
replace SII_7_1_NPK_123216 = 0 if Id=="B01V10F0273"
replace SII_7_2_NPK_123216 = "8" if Id=="B01V10F0273"
replace SII_7_3_NPK_123216 = 2 if Id=="B01V10F0273"

replace SII_6_1_NPK_123216 = 1 if Id=="B01V10F0278"
replace SII_6_2_NPK_123216 = "3" if Id=="B01V10F0278"
replace SII_6_3_NPK_123216 = 5 if Id=="B01V10F0278"
replace SII_6_4_NPK_123216 = 3 if Id=="B01V10F0278"
replace SII_7_1_NPK_123216 = 1 if Id=="B01V10F0278"

replace SII_6_1_NPK_123216 = 1 if Id=="B01V10F0291"
replace SII_6_2_NPK_123216 = "23" if Id=="B01V10F0291"
replace SII_6_3_NPK_123216 = 5 if Id=="B01V10F0291"
replace SII_6_4_NPK_123216 = 3 if Id=="B01V10F0291"
replace SII_7_1_NPK_123216 = 1 if Id=="B01V10F0291"

replace SII_6_1_NPK_123216 = 1 if Id=="B02V16F0493"
replace SII_6_2_NPK_123216 = "2" if Id=="B02V16F0493"
replace SII_6_3_NPK_123216 = 5 if Id=="B02V16F0493"
replace SII_6_4_NPK_123216 = 3 if Id=="B02V16F0493"
replace SII_7_1_NPK_123216 = 1 if Id=="B02V16F0493"

replace SII_6_1_NPK_123216 = 1 if Id=="B02V16F0495"
replace SII_6_2_NPK_123216 = "2" if Id=="B02V16F0495"
replace SII_6_3_NPK_123216 = 5 if Id=="B02V16F0495"
replace SII_6_4_NPK_123216 = 3 if Id=="B02V16F0495"
replace SII_7_1_NPK_123216 = 1 if Id=="B02V16F0495"

replace SII_6_1_NPK_123216 = 1 if Id=="B02V17F0503"
replace SII_6_2_NPK_123216 = "4" if Id=="B02V17F0503"
replace SII_6_3_NPK_123216 = 5 if Id=="B02V17F0503"
replace SII_6_4_NPK_123216 = 3 if Id=="B02V17F0503"
replace SII_7_1_NPK_123216 = 1 if Id=="B02V17F0503"

replace SII_6_1_NPK_123216 = 1 if Id=="B02V17F0515"
replace SII_6_2_NPK_123216 = "1" if Id=="B02V17F0515"
replace SII_6_3_NPK_123216 = 5 if Id=="B02V17F0515"
replace SII_6_4_NPK_123216 = 3 if Id=="B02V17F0515"
replace SII_7_1_NPK_123216 = 1 if Id=="B02V17F0515"

replace SII_6_1_NPK_123216 = 1 if Id=="B02V17F0518"
replace SII_6_2_NPK_123216 = "9" if Id=="B02V17F0518"
replace SII_6_3_NPK_123216 = 5 if Id=="B02V17F0518"
replace SII_6_4_NPK_123216 = 3 if Id=="B02V17F0518"
replace SII_7_1_NPK_123216 = 1 if Id=="B02V17F0518"

replace SII_6_1_NPK_123216 = 1 if Id=="B02V17F0530"
replace SII_6_2_NPK_123216 = "3" if Id=="B02V17F0530"
replace SII_6_3_NPK_123216 = 5 if Id=="B02V17F0530"
replace SII_6_4_NPK_123216 = 3 if Id=="B02V17F0530"
replace SII_7_1_NPK_123216 = 1 if Id=="B02V17F0530"

replace SII_6_1_NPK_123216 = 1 if Id=="B02V17F0533"
replace SII_6_2_NPK_123216 = "4" if Id=="B02V17F0533"
replace SII_6_3_NPK_123216 = 5 if Id=="B02V17F0533"
replace SII_6_4_NPK_123216 = 3 if Id=="B02V17F0533"
replace SII_7_1_NPK_123216 = 1 if Id=="B02V17F0533"

replace SII_6_1_NPK_123216 = 1 if Id=="B02V17F0518"
replace SII_6_2_NPK_123216 = "3" if Id=="B02V17F0518"
replace SII_6_3_NPK_123216 = 5 if Id=="B02V17F0518"
replace SII_6_4_NPK_123216 = 3 if Id=="B02V17F0518"
replace SII_7_1_NPK_123216 = 1 if Id=="B02V17F0518"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V81F2332"
replace SII_6_2_NPK_123216 = "6" if Id=="B06V81F2332"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V81F2332"
replace SII_6_4_NPK_123216 = 1 if Id=="B06V81F2332"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V81F2332"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V81F2331"
replace SII_6_2_NPK_123216 = "400" if Id=="B06V81F2331"
replace SII_6_3_NPK_123216 = 1 if Id=="B06V81F2331"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V81F2331"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V81F2325"
replace SII_6_2_NPK_123216 = "1" if Id=="B06V81F2325"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V81F2325"
replace SII_6_4_NPK_123216 = 1 if Id=="B06V81F2325"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V81F2325"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V81F2319"
replace SII_6_2_NPK_123216 = "8" if Id=="B06V81F2319"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V81F2319"
replace SII_6_4_NPK_123216 = 3 if Id=="B06V81F2319"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V81F2319"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V81F2317"
replace SII_6_2_NPK_123216 = "200" if Id=="B06V81F2317"
replace SII_6_3_NPK_123216 = 1 if Id=="B06V81F2317"
replace SII_7_1_NPK_123216 = 0 if Id=="B06V81F2317"
replace SII_7_2_NPK_123216 = "10" if Id=="B06V81F2317"
replace SII_7_3_NPK_123216 = 1 if Id=="B01V10F0273"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V78F2241"
replace SII_6_2_NPK_123216 = "8" if Id=="B06V78F2241"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V78F2241"
replace SII_6_4_NPK_123216 = 3 if Id=="B06V78F2241"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V78F2241"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V78F2222"
replace SII_6_2_NPK_123216 = "666" if Id=="B06V78F2222"
replace SII_6_3_NPK_123216 = 1 if Id=="B06V78F2222"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V78F2222"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V75F2146"
replace SII_6_2_NPK_123216 = "10" if Id=="B06V75F2146"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V75F2146"
replace SII_6_4_NPK_123216 = 3 if Id=="B06V75F2146"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V75F2146"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V75F2145"
replace SII_6_2_NPK_123216 = "8" if Id=="B06V75F2145"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V75F2145"
replace SII_6_4_NPK_123216 = 3 if Id=="B06V75F2145"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V75F2145"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V75F2144"
replace SII_6_2_NPK_123216 = "8" if Id=="B06V75F2144"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V75F2144"
replace SII_6_4_NPK_123216 = 3 if Id=="B06V75F2144"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V75F2144"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V75F2139"
replace SII_6_2_NPK_123216 = "35" if Id=="B06V75F2139"
replace SII_6_3_NPK_123216 = 1 if Id=="B06V75F2139"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V75F2139"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V75F2135"
replace SII_6_2_NPK_123216 = "7" if Id=="B06V75F2135"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V75F2135"
replace SII_6_4_NPK_123216 = 2 if Id=="B06V75F2135"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V75F2135"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V75F2127"
replace SII_6_2_NPK_123216 = "3" if Id=="B06V75F2127"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V75F2127"
replace SII_6_4_NPK_123216 = 3 if Id=="B06V75F2127"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V75F2127"

replace SII_6_1_NPK_20200 = 1 if Id=="B06V74F2110"
replace SII_6_2_NPK_20200 = "100" if Id=="B06V74F2110"
replace SII_6_3_NPK_20200 = 1 if Id=="B06V74F2110"
replace SII_7_1_NPK_20200 = 1 if Id=="B06V74F2110"

replace SII_6_1_NPK_20200 = 1 if Id=="B06V74F2103"
replace SII_6_2_NPK_20200 = "3" if Id=="B06V74F2103"
replace SII_6_3_NPK_20200 = 5 if Id=="B06V74F2103"
replace SII_6_4_NPK_20200 = 3 if Id=="B06V74F2103"
replace SII_7_1_NPK_20200 = 1 if Id=="B06V74F2103"

replace SII_6_1_NPK_20200 = 1 if Id=="B06V73F2077"
replace SII_6_2_NPK_20200 = "200" if Id=="B06V73F2077"
replace SII_6_3_NPK_20200 = 1 if Id=="B06V73F2077"
replace SII_7_1_NPK_20200 = 0 if Id=="B06V73F2077"
replace SII_7_2_NPK_20200 = "11" if Id=="B06V73F2077"
replace SII_7_3_NPK_20200 = 1 if Id=="B06V73F2077"

replace SII_6_1_NPK_20200 = 1 if Id=="B06V73F2068"
replace SII_6_2_NPK_20200 = "125" if Id=="B06V73F2068"
replace SII_6_3_NPK_20200 = 1 if Id=="B06V73F2068"
replace SII_7_1_NPK_20200 = 1 if Id=="B06V73F2068"

replace SII_6_1_NPK_20200 = 1 if Id=="B06V72F2038"
replace SII_6_2_NPK_20200 = "10" if Id=="B06V72F2038"
replace SII_6_3_NPK_20200 = 5 if Id=="B06V72F2038"
replace SII_6_3_NPK_20200 = 3 if Id=="B06V72F2038"
replace SII_7_1_NPK_20200 = 1 if Id=="B06V72F2038"

replace SII_6_1_NPK_20200 = 1 if Id=="B06V71F2012"
replace SII_6_2_NPK_20200 = "3" if Id=="B06V71F2012"
replace SII_6_3_NPK_20200 = 5 if Id=="B06V71F2012"
replace SII_6_3_NPK_20200 = 3 if Id=="B06V71F2012"
replace SII_7_1_NPK_20200 = 1 if Id=="B06V71F2012"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V72F2029"
replace SII_6_2_NPK_123216 = "1" if Id=="B06V72F2029"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V72F2029"
replace SII_6_4_NPK_123216 = 3 if Id=="B06V72F2029"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V72F2029"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V71F2010"
replace SII_6_2_NPK_123216 = "6" if Id=="B06V71F2010"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V71F2010"
replace SII_6_4_NPK_123216 = 3 if Id=="B06V71F2010"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V71F2010"

replace SII_6_1_NPK_123216 = 1 if Id=="B06V71F1986"
replace SII_6_2_NPK_123216 = "5" if Id=="B06V71F1986"
replace SII_6_3_NPK_123216 = 5 if Id=="B06V71F1986"
replace SII_6_4_NPK_123216 = 3 if Id=="B06V71F1986"
replace SII_7_1_NPK_123216 = 1 if Id=="B06V71F1986"

replace SII_6_1_NPK_123216 = 1 if Id=="B05V65F1825"
replace SII_6_2_NPK_123216 = "2" if Id=="B05V65F1825"
replace SII_6_3_NPK_123216 = 5 if Id=="B05V65F1825"
replace SII_6_4_NPK_123216 = 3 if Id=="B05V65F1825"
replace SII_7_1_NPK_123216 = 1 if Id=="B05V65F1825"

replace SII_6_1_NPK_123216 = 1 if Id=="B05V65F1828"
replace SII_6_2_NPK_123216 = "2" if Id=="B05V65F1828"
replace SII_6_3_NPK_123216 = 5 if Id=="B05V65F1828"
replace SII_6_4_NPK_123216 = 3 if Id=="B05V65F1828"
replace SII_7_1_NPK_123216 = 1 if Id=="B05V65F1828"

replace SII_6_1_NPK_123216 = 1 if Id=="B05V65F1810"
replace SII_6_2_NPK_123216 = "150" if Id=="B05V65F1810"
replace SII_6_3_NPK_123216 = 1 if Id=="B05V65F1810"
replace SII_7_1_NPK_123216 = 1 if Id=="B05V65F1810"

replace SII_6_1_NPK_123216 = 1 if Id=="B05V65F1805"
replace SII_6_2_NPK_123216 = "4" if Id=="B05V65F1805"
replace SII_6_3_NPK_123216 = 5 if Id=="B05V65F1805"
replace SII_6_4_NPK_123216 = 3 if Id=="B05V65F1805"
replace SII_7_1_NPK_123216 = 1 if Id=="B05V65F1805"

replace SII_6_1_NPK_123216 = 1 if Id=="B05V64F1775"
replace SII_6_2_NPK_123216 = "3" if Id=="B05V64F1775"
replace SII_6_3_NPK_123216 = 5 if Id=="B05V64F1775"
replace SII_6_4_NPK_123216 = 3 if Id=="B05V64F1775"
replace SII_7_1_NPK_123216 = 1 if Id=="B05V64F1775"

replace SII_6_1_NPK_123216 = 1 if Id=="B05V57F1585"
replace SII_6_2_NPK_123216 = "25" if Id=="B05V57F1585"
replace SII_6_3_NPK_123216 = 1 if Id=="B05V57F1585"
replace SII_7_1_NPK_123216 = 0 if Id=="B05V57F1585"
replace SII_7_2_NPK_123216 = "9.5" if Id=="B05V57F1585"
replace SII_7_3_NPK_123216 = 1 if Id=="B05V57F1585"

replace SII_6_1_NPK_123216 = 1 if Id=="B04V52F1457"
replace SII_6_2_NPK_123216 = "2" if Id=="B04V52F1457"
replace SII_6_3_NPK_123216 = 5 if Id=="B04V52F1457"
replace SII_6_4_NPK_123216 = 3 if Id=="B04V52F1457"
replace SII_7_1_NPK_123216 = 1 if Id=="B04V52F1457"

replace SII_6_1_NPK_123216 = 1 if Id=="B04V46F1327"
replace SII_6_2_NPK_123216 = "1" if Id=="B04V46F1327"
replace SII_6_3_NPK_123216 = 5 if Id=="B04V46F1327"
replace SII_6_4_NPK_123216 = 3 if Id=="B04V46F1327"
replace SII_7_1_NPK_123216 = 1 if Id=="B04V46F1327"

replace SII_6_1_NPK_123216 = 1 if Id=="B04V44F1250"
replace SII_6_2_NPK_123216 = "2.5" if Id=="B04V44F1250"
replace SII_6_3_NPK_123216 = 5 if Id=="B04V44F1250"
replace SII_6_4_NPK_123216 = 3 if Id=="B04V44F1250"
replace SII_7_1_NPK_123216 = 0 if Id=="B04V44F1250"
replace SII_7_2_NPK_123216 = "2.5" if Id=="B04V44F1250"
replace SII_7_3_NPK_123216 = 1 if Id=="B04V44F1250"

replace SII_6_1_NPK_123216 = 1 if Id=="B04V43F1238"
replace SII_6_2_NPK_123216 = "150" if Id=="B04V43F1238"
replace SII_6_3_NPK_123216 = 1 if Id=="B04V43F1238"
replace SII_7_1_NPK_123216 = 1 if Id=="B04V43F1238"

replace SII_6_1_NPK_123216 = 1 if Id=="B03V38F1143"
replace SII_6_2_NPK_123216 = "1.5" if Id=="B03V38F1143"
replace SII_6_3_NPK_123216 = 5 if Id=="B03V38F1143"
replace SII_6_4_NPK_123216 = 3 if Id=="B03V38F1143"
replace SII_7_1_NPK_123216 = 1 if Id=="B03V38F1143"

replace SII_6_1_NPK_123216 = 1 if Id=="B03V38F1133"
replace SII_6_2_NPK_123216 = "3" if Id=="B03V38F1133"
replace SII_6_3_NPK_123216 = 5 if Id=="B03V38F1133"
replace SII_6_4_NPK_123216 = 3 if Id=="B03V38F1133"
replace SII_7_1_NPK_123216 = 1 if Id=="B03V38F1133"

replace SII_6_1_NPK_123216 = 1 if Id=="B03V37F1105"
replace SII_6_2_NPK_123216 = "5" if Id=="B03V37F1105"
replace SII_6_3_NPK_123216 = 5 if Id=="B03V37F1105"
replace SII_6_4_NPK_123216 = 3 if Id=="B03V37F1105"
replace SII_7_1_NPK_123216 = 1 if Id=="B03V37F1105"

replace SII_6_1_NPK_123216 = 1 if Id=="B03V37F1091"
replace SII_6_2_NPK_123216 = "300" if Id=="B03V37F1091"
replace SII_6_3_NPK_123216 = 1 if Id=="B03V37F1091"
replace SII_7_1_NPK_123216 = 1 if Id=="B03V37F1091"

replace SII_6_1_NPK_123216 = 1 if Id=="B03V35F1039"
replace SII_6_2_NPK_123216 = "5" if Id=="B03V35F1039"
replace SII_6_3_NPK_123216 = 5 if Id=="B03V35F1039"
replace SII_6_4_NPK_123216 = 3 if Id=="B03V35F1039"
replace SII_7_1_NPK_123216 = 1 if Id=="B03V35F1039"

replace SII_6_1_NPK_123216 = 1 if Id=="B03V35F1025"
replace SII_6_2_NPK_123216 = "8" if Id=="B03V35F1025"
replace SII_6_3_NPK_123216 = 5 if Id=="B03V35F1025"
replace SII_6_4_NPK_123216 = 3 if Id=="B03V35F1025"
replace SII_7_1_NPK_123216 = 1 if Id=="B03V35F1025"

replace SII_6_1_NPK_123216 = 1 if Id=="B03V32F0966"
replace SII_6_2_NPK_123216 = "6" if Id=="B03V32F0966"
replace SII_6_3_NPK_123216 = 5 if Id=="B03V32F0966"
replace SII_6_4_NPK_123216 = 3 if Id=="B03V32F0966"
replace SII_7_1_NPK_123216 = 1 if Id=="B03V32F0966"

replace SII_6_1_NPK_123216 = 1 if Id=="B03V30F0885"
replace SII_6_2_NPK_123216 = "4" if Id=="B03V30F0885"
replace SII_6_3_NPK_123216 = 5 if Id=="B03V30F0885"
replace SII_6_4_NPK_123216 = 3 if Id=="B03V30F0885"
replace SII_7_1_NPK_123216 = 1 if Id=="B03V30F0885"

replace SII_6_1_NPK_123216 = 1 if Id=="B03V31F0927"
replace SII_6_2_NPK_123216 = "2" if Id=="B03V31F0927"
replace SII_6_3_NPK_123216 = 5 if Id=="B03V31F0927"
replace SII_6_4_NPK_123216 = 3 if Id=="B03V31F0927"
replace SII_7_1_NPK_123216 = 0 if Id=="B03V31F0927"
replace SII_7_2_NPK_123216 = "7" if Id=="B03V31F0927"
replace SII_7_3_NPK_123216 = 1 if Id=="B03V31F0927"

replace SII_6_1_NPK_123216 = 1 if Id=="B03V32F0967"
replace SII_6_2_NPK_123216 = "100" if Id=="B03V32F0967"
replace SII_6_3_NPK_123216 = 1 if Id=="B03V32F0967"
replace SII_7_1_NPK_123216 = 0 if Id=="B03V32F0967"
replace SII_7_2_NPK_123216 = "4" if Id=="B03V32F0967"
replace SII_7_3_NPK_123216 = 1 if Id=="B03V32F0967"

replace SII_6_1_NPK_123216 = 1 if Id=="B03V28F0826"
replace SII_6_2_NPK_123216 = "2" if Id=="B03V28F0826"
replace SII_6_3_NPK_123216 = 5 if Id=="B03V28F0826"
replace SII_6_4_NPK_123216 = 3 if Id=="B03V28F0826"
replace SII_7_1_NPK_123216 = 1 if Id=="B03V28F0826"

replace SII_6_1_NPK_123216 = 1 if Id=="B02V26F0778"
replace SII_6_2_NPK_123216 = "2" if Id=="B02V26F0778"
replace SII_6_3_NPK_123216 = 5 if Id=="B02V26F0778"
replace SII_6_4_NPK_123216 = 3 if Id=="B02V26F0778"
replace SII_7_1_NPK_123216 = 1 if Id=="B02V26F0778"

replace SII_6_1_NPK_20200 = 1 if Id=="B02V25F0763"
replace SII_6_2_NPK_20200 = "20" if Id=="B02V25F0763"
replace SII_6_3_NPK_20200 = 5 if Id=="B02V25F0763"
replace SII_6_4_NPK_20200 = 3 if Id=="B02V25F0763"
replace SII_7_1_NPK_20200 = 1 if Id=="B02V25F0763"

replace SII_6_1_NPK_20200 = 1 if Id=="B02V21F0638"
replace SII_6_2_NPK_20200 = "50" if Id=="B02V21F0638"
replace SII_6_3_NPK_20200 = 1 if Id=="B02V21F0638"
replace SII_7_1_NPK_20200 = 0 if Id=="B02V21F0638"
replace SII_7_2_NPK_20200 = "10" if Id=="B02V21F0638"
replace SII_7_3_NPK_20200 = 1 if Id=="B02V21F0638"

replace SII_6_1_NPK_20200 = 1 if Id=="B02V19F0577"
replace SII_6_2_NPK_20200 = "2" if Id=="B02V19F0577"
replace SII_6_3_NPK_20200 = 5 if Id=="B02V19F0577"
replace SII_6_4_NPK_20200 = 3 if Id=="B02V19F0577"
replace SII_7_1_NPK_20200 = 1 if Id=="B02V19F0577"

replace SII_6_1_NPK_123216 = 1 if Id=="B02V18F0549"
replace SII_6_2_NPK_123216 = "11.5" if Id=="B02V18F0549"
replace SII_6_3_NPK_123216 = 5 if Id=="B02V18F0549"
replace SII_6_4_NPK_123216 = 3 if Id=="B02V18F0549"
replace SII_7_1_NPK_123216 = 1 if Id=="B02V18F0549"

foreach i in UREA DAP MOP ZINC NPK_202020 NPK_20200 NPK_123216 {
 label var SII_6_1_`i' "Used `i' in sampled plot at time of sowing" 
 destring SII_6_1_`i', replace
 label values SII_6_1_`i' yesno
 label var SII_6_2_`i' "Quantity of `i' applied in sampled plot at time of sowing"
 label var SII_6_3_`i' "Unit in which `i' applied in sampled plot at time of sowing"
 destring SII_6_3_`i', replace
 destring SII_6_3_`i', replace
 label values SII_6_3_`i' quantity
 label var SII_6_4_`i' "Size of `i' bag if bag selected in fertilizer unit" 
 destring SII_6_4_`i', replace
 label values SII_6_4_`i' bagsize
 label var SII_7_1_`i' "Used `i' in entire area of cotton sowing" 
 destring SII_7_1_`i', replace
 label values SII_7_1_`i' yesno
 label var SII_7_2_`i' "Area in sampled plot in which `i' applied" 
 label var SII_7_3_`i' "Unit of area in sampled plot in which `i' applied"
 destring SII_7_3_`i', replace
 label values SII_7_3_`i' area
  }

* Correcting errors in data
replace SII_6_3_DAP=1 if SII_6_3_DAP==3 //fertilizer quantity unit mistakenly selected as litre
replace SII_6_3_DAP=1 if SII_6_3_DAP==2 //fertilizer quantity unit mistakenly selected as gram
replace SII_6_3_DAP=1 if SII_6_2_DAP=="135" & SII_6_4_DAP==2 //fertilizer quantity unit mistakenly selected as bag
replace SII_6_4_DAP=. if SII_6_2_DAP=="135" & SII_6_4_DAP==2 //fertilizer quantity unit mistakenly selected as bag
replace SII_6_2_DAP="2" if Id=="B03V29F0866" //number of bags entered wrong
replace SII_6_2_MOP="2" if Id=="B05V56F1560" //number of bags entered wrong
replace SII_6_2_MOP="2" if Id=="B02V16F0488" //number of bags entered wrong
replace SII_6_2_ZINC=1.5 if Id=="B02V26F0775" //number of bags entered wrong

replace consent = 0 if Id=="B01V11F0304"
rename Id uid

save "`clean'", replace


